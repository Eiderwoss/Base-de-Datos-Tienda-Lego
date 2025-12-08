-----------------------------
-- SECUENCIAS VENTA ONLINE --
-----------------------------

CREATE SEQUENCE seq_factura_online
START WITH 1
INCREMENT BY 1
NOCACHE;
/

-------------------------
-- VISTAS VENTA ONLINE --
-------------------------

CREATE OR REPLACE VIEW v_saldo_puntos_cliente AS
SELECT
    c.id_lego AS ID_CLIENTE,
    c.primer_nombre AS PRIMER_NOMBRE,
    c.primer_apellido AS PRIMER_APELLIDO,
    fn_obtener_saldo_puntos(c.id_lego) AS PUNTOS_DISPONIBLES
FROM
    Clientes c;

/

---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA ONLINE --
---------------------------------------------

-- Calcular saldo total dinamicamente (Suma desde la ultima factura GRATIS = 'SI')
CREATE OR REPLACE FUNCTION fn_obtener_saldo_puntos (
    p_id_cliente IN NUMBER
)
RETURN NUMBER IS
    v_saldo_acumulado NUMBER := 0;
    v_ultima_venta_gratis NUMBER;
BEGIN
    BEGIN
        SELECT MAX(numeroventa)
        INTO v_ultima_venta_gratis
        FROM Factura_Ventas_Online
        WHERE id_lego_cliente = p_id_cliente    
            AND gratis = 'SI';
        
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_ultima_venta_gratis := NULL;
    END;
    
    IF v_ultima_venta_gratis IS NULL THEN
        SELECT NVL(SUM(puntos_generados), 0)
        INTO v_saldo_acumulado
        FROM Factura_Ventas_Online
        WHERE id_lego_cliente= p_id_cliente;
    ELSE
        SELECT NVL(SUM(puntos_generados), 0)
        INTO v_saldo_acumulado
        FROM Factura_Ventas_Online
        WHERE id_lego_cliente = p_id_cliente
            AND numeroventa > v_ultima_venta_gratis;
    END IF;
    
    RETURN v_saldo_acumulado;
    
END;
/

-- Validar canjeo de puntos
CREATE OR REPLACE PROCEDURE sp_validar_canje_puntos (
    p_id_cliente IN NUMBER,
    p_puntos_usar IN NUMBER
) IS
    v_saldo_actual NUMBER;
BEGIN
    -- Calcular el saldo actual de forma dinamica
    v_saldo_actual := fn_obtener_saldo_puntos(p_id_cliente);
    
    -- Validar saldo y cantidad a usar
    IF p_puntos_usar <= 0 THEN
        RAISE_APPLICATION_ERROR(-20042, 'No tienes puntos para usar.');
    ELSIF v_saldo_actual < p_puntos_usar THEN
        RAISE_APPLICATION_ERROR(-20040, 'Saldo insuficiente. El cliente solo tiene ' || v_saldo_actual || ' puntos acumulados en su ciclo actual.');
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20041, 'Cliente con ID ' || p_id_cliente || ' no encontrado.');
END;
/

-- Canjeo de puntos
CREATE OR REPLACE PROCEDURE sp_canjear_puntos (
    p_id_cliente IN NUMBER,
    p_id_juguete_canje IN NUMBER,
    p_puntos_requeridos IN NUMBER
)
IS
    v_num_venta NUMBER;
    v_pais_res NUMBER;
    v_es_ue CHAR(2);
    
    e_saldo_insuficiente EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_saldo_insuficiente, -20040);
BEGIN
    -- Validacion del saldo
    sp_validar_canje_puntos(
        p_id_cliente => p_id_cliente,
        p_puntos_usar => p_puntos_requeridos
    );
    
    -- Obtener datos del cliente (ncesario para la validacion de catalogo en el detalle factura)
    SELECT c.id_pais_res, p.union_europea
    INTO v_pais_res, v_es_ue
    FROM Clientes c
    JOIN Paises p ON c.id_pais_res = p.id
    WHERE c.id_lego = p_id_cliente;
    
    -- Crear la factura del canje
    INSERT INTO Factura_Ventas_Online (
        numeroventa, 
        fecha_venta, 
        gratis, 
        id_lego_cliente, 
        total, 
        puntos_generados
    ) VALUES (
        NULL, 
        SYSDATE, 
        'SI',              
        p_id_cliente, 
        0,                
        0                 
    )
    RETURNING numeroventa INTO v_num_venta;
    
    -- Insertar el detalle
    INSERT INTO Detalle_Factura_Ventas_Online (
        numeroventa, 
        id, 
        cantidad, 
        tipo_cliente, 
        id_juguete_cat, 
        id_pais_cat
    ) VALUES (
        v_num_venta, 
        1, 
        1, 
        'ADULTO',      
        p_id_juguete_canje, 
        v_pais_res     
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('CANJE EXITOSO. Factura gratuita #' || v_num_venta || 
                         ' creada. Se consumieron ' || p_puntos_requeridos || ' puntos.');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20041, 'Cliente ID ' || p_id_cliente || ' no encontrado. Asegurese de que existe en la tabla Clientes.');
    WHEN e_saldo_insuficiente THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20040, SQLERRM);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error inesperado al procesar canje: ' || SQLERRM);
END;
/

-- Funcion de otorgar puntos
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
        
    -- Rango C: Mas de 70 hasta 200
    ELSIF p_monto_total > 70 AND p_monto_total <= 200 THEN
        v_puntos := 50;
        
    -- Rango D: Mas de 200
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

    -- 2. Crear Factura Inicial (Total 0 por ahora)
    INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
        VALUES (NULL, SYSDATE, 'NO', p_id_cliente, 0, 0)
        RETURNING numeroventa INTO v_num_venta;

    -- 3. PROCESAMIENTO DE LA LISTA DE PRODUCTOS
    IF v_lista_trabajo IS NOT NULL THEN
        v_lista_trabajo := v_lista_trabajo || ','; 

        LOOP
            v_pos_coma := INSTR(v_lista_trabajo, ',');
            EXIT WHEN NVL(v_pos_coma, 0) = 0;

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

    -- 4. Calcular Impuestos/Envío 
    IF v_es_ue = 'SI' THEN
        v_recargo := v_total_bruto * 0.05; -- 5% si es UE
    ELSE
        v_recargo := v_total_bruto * 0.15; -- 15% Resto del Mundo
    END IF;

    v_total_neto := v_total_bruto + v_recargo;

    -- 5. Calcular Puntos (LLAMANDO A LA FUNCIÓN QUE HICIMOS ARRIBA)
    v_puntos := fn_calcular_puntos(v_total_neto);

    -- 6. Actualizar la Factura con los montos finales
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

/*Modificar este trigger porque la inserción de un nuevo valor de secuencia en un insert se hace al llamar al insert, no con trigger*/
CREATE OR REPLACE TRIGGER trg_factura_online_autonum
BEFORE INSERT ON Factura_Ventas_Online
FOR EACH ROW
BEGIN
    :NEW.numeroventa := seq_factura_online.NEXTVAL;
END;
/

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




