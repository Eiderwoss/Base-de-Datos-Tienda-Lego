---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA ONLINE --
---------------------------------------------

--10. Funcion de otorgar puntos
CREATE OR REPLACE FUNCTION fn_calcular_puntos (p_monto_total NUMBER) 
RETURN NUMBER IS
    v_puntos NUMBER := 0;
BEGIN
    -- Rango A: Menos de 10
    IF p_monto_total < 10 THEN
        v_puntos := 5;
        
    -- Rango B: Entre 10 y 70
    ELSIF p_monto_total >= 10 AND p_monto_total <= 70 THEN
        v_puntos := 20;
        
    -- Rango C: Más de 70 hasta 200
    ELSIF p_monto_total > 70 AND p_monto_total <= 200 THEN
        v_puntos := 50;
        
    -- Rango D: Más de 200 (El documento dice "+ de 200")
    ELSE
        v_puntos := 200;
    END IF;
    
    RETURN v_puntos;
END;
/


 CREATE OR REPLACE PROCEDURE sp_venta_online_txt (
    p_id_cliente      IN NUMBER,
    p_lista_productos IN VARCHAR2 -- Ejemplo: '201:1, 101:2'
) IS
    -- Variables de Cabecera
    v_num_venta      NUMBER;
    v_pais_res       NUMBER;
    v_es_ue          CHAR(2); 
    v_total_bruto    NUMBER := 0;
    v_recargo        NUMBER := 0;
    v_total_neto     NUMBER := 0;
    v_puntos         NUMBER := 0;

    -- Variables para Parsing (Corte de cadena)
    v_lista_trabajo  VARCHAR2(4000) := p_lista_productos;
    v_pos_coma       NUMBER;
    v_pos_dos_puntos NUMBER;
    v_bloque         VARCHAR2(100);
    v_prod_id        NUMBER;
    v_prod_cant      NUMBER;
    v_precio_unit    NUMBER;
    v_next_id_det    NUMBER := 1; -- ID autoincremental para el detalle

BEGIN
    -- 1. Obtener Datos del Cliente (País y si pertenece a la UE para el impuesto)
    -- Usamos JOIN con Paises para saber lo de la Unión Europea
    SELECT c.id_pais_res, p.union_europea
    INTO v_pais_res, v_es_ue
    FROM Clientes c
    JOIN Paises p ON c.id_pais_res = p.id
    WHERE c.id_lego = p_id_cliente;

    -- 2. Generar ID de Venta
    SELECT NVL(MAX(numeroventa), 0) + 1 INTO v_num_venta FROM Factura_Ventas_Online;

    -- 3. Crear Factura Inicial (Total 0 por ahora)
    INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
    VALUES (v_num_venta, SYSDATE, 'NO', p_id_cliente, 0, 0);

    -- 4. PROCESAMIENTO DE LA LISTA DE PRODUCTOS
    IF v_lista_trabajo IS NOT NULL THEN
        v_lista_trabajo := v_lista_trabajo || ','; 

        LOOP
            v_pos_coma := INSTR(v_lista_trabajo, ',');
            EXIT WHEN v_pos_coma = 0;

            -- Cortamos el bloque "ID:CANTIDAD"
            v_bloque := SUBSTR(v_lista_trabajo, 1, v_pos_coma - 1);
            v_pos_dos_puntos := INSTR(v_bloque, ':');

            IF v_pos_dos_puntos > 0 THEN
                v_prod_id := TO_NUMBER(SUBSTR(v_bloque, 1, v_pos_dos_puntos - 1));
                v_prod_cant := TO_NUMBER(SUBSTR(v_bloque, v_pos_dos_puntos + 1));

                -- A. Buscar Precio Actual del Juguete
                -- (Asumimos que existe precio activo con fecha_fin NULL)
                BEGIN
                    SELECT precio INTO v_precio_unit
                    FROM Historico_Precios
                    WHERE id_juguete = v_prod_id AND fecha_fin IS NULL;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         RAISE_APPLICATION_ERROR(-20060, 'El juguete '||v_prod_id||' no tiene precio activo.');
                END;

                -- B. Acumular Total Bruto
                v_total_bruto := v_total_bruto + (v_precio_unit * v_prod_cant);

                -- C. Insertar en Detalle
                -- IMPORTANTE: Aquí pasamos v_pais_res como id_pais_cat.
                -- El trigger 'trg_validar_detalle_online' verificará esto automáticamente.
                INSERT INTO Detalle_Factura_Ventas_Online (
                    numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat
                ) VALUES (
                    v_num_venta, v_next_id_det, v_prod_cant, 'ADULTO', v_prod_id, v_pais_res
                );
                
                v_next_id_det := v_next_id_det + 1;
            END IF;

            -- Avanzar al siguiente producto
            v_lista_trabajo := SUBSTR(v_lista_trabajo, v_pos_coma + 1);
        END LOOP;
    END IF;

    -- 5. Calcular Impuestos/Envío 
    IF v_es_ue = 'SI' THEN
        v_recargo := v_total_bruto * 0.05; -- 5% si es UE
    ELSE
        v_recargo := v_total_bruto * 0.15; -- 15% Resto del Mundo
    END IF;

    v_total_neto := v_total_bruto + v_recargo;

    -- 6. Calcular Puntos (LLAMANDO A LA FUNCIÓN QUE HICIMOS ARRIBA)
    v_puntos := fn_calcular_puntos(v_total_neto);

    -- 7. Actualizar la Factura con los montos finales
    UPDATE Factura_Ventas_Online
    SET total = v_total_neto,
        puntos_generados = v_puntos
    WHERE numeroventa = v_num_venta;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Venta Online #' || v_num_venta || ' generada.');
    DBMS_OUTPUT.PUT_LINE('Total pagado: ' || v_total_neto || ' (Envío: ' || v_recargo || ')');
    DBMS_OUTPUT.PUT_LINE('Puntos ganados: ' || v_puntos);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Si algo falla, deshacemos la factura y los detalles
        RAISE_APPLICATION_ERROR(-20099, 'Error procesando venta: ' || SQLERRM);
END;
/   
    

-----------------------------
-- TRIGGERS VENTA ONLINE --
-----------------------------

CREATE OR REPLACE TRIGGER trg_validar_detalle_online
BEFORE INSERT ON Detalle_Factura_Ventas_Online
FOR EACH ROW
DECLARE
    v_num_venta     NUMBER;
    v_id_pais_cat   NUMBER;
    v_id_juguete    NUMBER;
    v_cantidad      NUMBER;

    v_id_cliente    NUMBER;
    v_pais_res      NUMBER;
    v_limite_pais   NUMBER;
    v_existe_cat    NUMBER;
BEGIN
    v_num_venta   := :NEW.numeroventa;
    v_id_pais_cat := :NEW.id_pais_cat;
    v_id_juguete  := :NEW.id_juguete_cat;
    v_cantidad    := :NEW.cantidad;

    -- A. Obtener el cliente dueño de la factura
    SELECT id_lego_cliente 
    INTO v_id_cliente
    FROM Factura_Ventas_Online
    WHERE numeroventa = v_num_venta;

    -- B. Obtener el país de residencia del cliente
    SELECT id_pais_res 
    INTO v_pais_res
    FROM Clientes
    WHERE id_lego = v_id_cliente;

    -- REGLA 1: Coherencia de País (PDF)
    -- El país del catálogo del detalle debe ser igual al país de residencia
    IF v_pais_res != v_id_pais_cat THEN
        RAISE_APPLICATION_ERROR(-20050, 'Error: El cliente reside en el país ID ' || v_pais_res || ' pero se intenta registrar una venta del catálogo del país ID ' || v_id_pais_cat);
    END IF;

    -- REGLA 2: Validar Límite y Existencia en Catálogo
    -- Verificamos si existe en el catálogo y traemos el límite
    BEGIN
        SELECT limite 
        INTO v_limite_pais
        FROM Catalogo_Paises
        WHERE id_juguete = v_id_juguete 
          AND id_pais = v_id_pais_cat;
          
        -- Si cantidad supera límite
        IF v_cantidad > v_limite_pais THEN
            RAISE_APPLICATION_ERROR(-20051, 'Error: La cantidad ('|| v_cantidad ||') excede el límite permitido ('|| v_limite_pais ||') para este producto en este país.');
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20052, 'Error: El juguete '|| v_id_juguete ||' no existe en el catálogo del país '|| v_id_pais_cat);
    END;

END;
/
