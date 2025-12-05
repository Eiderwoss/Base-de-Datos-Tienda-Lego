-- PROCEDIMIENTOS/FUNCIONES GENERALES --

-- 3. Funcion para validar edad
CREATE OR REPLACE FUNCTION fn_calcular_edad (p_fecha_nac DATE) 
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, p_fecha_nac) / 12);
END;
/

-- 4.    Funcion para conversion de las moendas
CREATE OR REPLACE FUNCTION fn_convertir_moneda (
    p_monto_dolares NUMBER, 
    p_moneda_destino VARCHAR2
) RETURN NUMBER IS
    v_resultado NUMBER;
BEGIN
    IF UPPER(p_moneda_destino) = 'EURO' THEN
        v_resultado := p_monto_dolares * 0.92; -- 1 USD = 0.92 EUR
    ELSIF UPPER(p_moneda_destino) LIKE 'CORONA%' THEN
        v_resultado := p_monto_dolares * 6.85; -- 1 USD = 6.85 DKK
    ELSE
        v_resultado := p_monto_dolares;
    END IF;
    
    RETURN ROUND(v_resultado, 2);
END;
/

--5. Trigger de control de precios
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_control_precios
BEFORE INSERT ON Historico_Precios
FOR EACH ROW
BEGIN
    UPDATE Historico_Precios
    SET fecha_fin = SYSDATE
    WHERE id_juguete = :NEW.id_juguete
      AND fecha_fin IS NULL;
    :NEW.fecha_fin := NULL;
END;
/

-- PROCEDIMIENTOS/FUNCIONES PARA TOURS--

--11. Procedimiento de inscripcion
CREATE OR REPLACE PROCEDURE sp_inscribir_tour (
    p_id_cliente  IN NUMBER,
    p_id_tour     IN NUMBER,
    p_fecha_tour  IN DATE
) IS
    v_num_inscripcion NUMBER;
    v_costo_tour      NUMBER;
BEGIN
    BEGIN
        SELECT costo INTO v_costo_tour 
        FROM Tours 
        WHERE id = p_id_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'El Tour especificado no existe.');
    END;

    SELECT NVL(MAX(numeroinscripcion), 0) + 1 
    INTO v_num_inscripcion 
    FROM Inscripciones 
    WHERE fecha_tour = p_fecha_tour;

    INSERT INTO Inscripciones (
        fecha_tour, numeroinscripcion, fecha_inscripcion, 
        id_tour, id_lego_cliente
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, SYSDATE, 
        p_id_tour, p_id_cliente
    );

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Inscripción #' || v_num_inscripcion || ' creada exitosamente.');
    DBMS_OUTPUT.PUT_LINE('Por favor proceda a registrar los participantes en DETALLE_INSCRIPCIONES.');
END;
/

--12. Procedimiento de venta en linea
CREATE OR REPLACE PROCEDURE sp_venta_online (
    p_id_cliente   IN NUMBER,
    p_total_bruto  IN NUMBER
) IS
    v_es_ue          CHAR(2) := 'NO';
    v_recargo        NUMBER;
    v_total_neto     NUMBER;
    v_puntos_ganados NUMBER;
    v_num_venta      NUMBER;
BEGIN
    IF v_es_ue = 'SI' THEN
        v_recargo := p_total_bruto * 0.05;
    ELSE
        v_recargo := p_total_bruto * 0.15;
    END IF;

    v_total_neto := p_total_bruto + v_recargo;

    v_puntos_ganados := fn_calcular_puntos(v_total_neto);

    SELECT NVL(MAX(numeroventa), 0) + 1 INTO v_num_venta FROM Factura_Ventas_Online;

    INSERT INTO Factura_Ventas_Online (
        numeroventa, 
        fecha_venta, 
        total, 
        id_lego_cliente
    ) VALUES (
        v_num_venta, 
        SYSDATE, 
        v_total_neto, 
        p_id_cliente
    );

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Venta Online #' || v_num_venta || ' generada exitosamente.');
    DBMS_OUTPUT.PUT_LINE('Total a pagar (con envio): ' || v_total_neto);
    DBMS_OUTPUT.PUT_LINE('Puntos de lealtad obtenidos: ' || v_puntos_ganados);
END;
/

--13. Procedimiento de la inscripcion al tour
CREATE OR REPLACE PROCEDURE sp_inscripcion_grupal_txt (
    p_id_cliente_pagador IN NUMBER,       
    p_id_tour            IN NUMBER,
    p_fecha_tour         IN DATE,
    p_cadena_personas    IN VARCHAR2 -- Ejemplo: '100:CLIENTE,10:FAN'
) IS
    v_num_inscripcion NUMBER;
    v_costo_tour      NUMBER;
    v_next_id_detalle NUMBER := 1;
    
    -- Variables para el corte de cadena
    v_lista_trabajo   VARCHAR2(4000) := p_cadena_personas;
    v_pos_coma        NUMBER;
    v_pos_dos_puntos  NUMBER;
    v_bloque_persona  VARCHAR2(100);
    v_id_persona      NUMBER;
    v_tipo_persona    VARCHAR2(20);
BEGIN
    BEGIN
        SELECT costo INTO v_costo_tour FROM Tours WHERE id = p_id_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'El Tour especificado no existe.');
    END;

    SELECT NVL(MAX(numeroinscripcion), 0) + 1 
    INTO v_num_inscripcion 
    FROM Inscripciones 
    WHERE fecha_tour = p_fecha_tour;

    INSERT INTO Inscripciones (
        fecha_tour, numeroinscripcion, fecha_inscripcion, id_tour, id_lego_cliente
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, SYSDATE, p_id_tour, p_id_cliente_pagador
    );

    INSERT INTO Detalle_Inscripciones (
        fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, p_id_cliente_pagador, NULL
    );

    IF v_lista_trabajo IS NOT NULL AND LENGTH(v_lista_trabajo) > 0 THEN
        
        v_lista_trabajo := v_lista_trabajo || ',';
        
        LOOP
            v_pos_coma := INSTR(v_lista_trabajo, ',');
            
            EXIT WHEN v_pos_coma = 0;
            
            v_bloque_persona := SUBSTR(v_lista_trabajo, 1, v_pos_coma - 1);
            
            v_pos_dos_puntos := INSTR(v_bloque_persona, ':');
            
            IF v_pos_dos_puntos > 0 THEN
                v_id_persona := TO_NUMBER(SUBSTR(v_bloque_persona, 1, v_pos_dos_puntos - 1));
                v_tipo_persona := SUBSTR(v_bloque_persona, v_pos_dos_puntos + 1);
                
                v_next_id_detalle := v_next_id_detalle + 1;

                IF UPPER(trim(v_tipo_persona)) = 'CLIENTE' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (
                        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, v_id_persona, NULL
                    );
                ELSIF UPPER(trim(v_tipo_persona)) = 'FAN' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (
                        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, NULL, v_id_persona
                    );
                END IF;
            END IF;
            
            -- Recortamos la cadena principal para seguir con el siguiente
            v_lista_trabajo := SUBSTR(v_lista_trabajo, v_pos_coma + 1);
            
        END LOOP;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Grupo procesado. ID Inscripción: ' || v_num_inscripcion || '. Total: ' || v_next_id_detalle);
END;
/ 
--Ejemplo
BEGIN
    sp_inscripcion_grupal_txt(
        p_id_cliente_pagador => 99,
        p_id_tour            => 1,
        p_fecha_tour         => TO_DATE('15/12/2025', 'DD/MM/YYYY'),
        p_cadena_personas    => '100:CLIENTE, 10:FAN' 
    );
END;
/

-- TODO VENTA FÍSICA --

-- 2. Trigger para actualizar stock 
-- Modificar, una consulta no puede tener eventos cómo new u old
-- Esto solo verifica si hay stock, no lo descuenta
CREATE OR REPLACE TRIGGER descontar_stock_tienda
AFTER INSERT ON detalle_factura_ventas_tienda
FOR EACH ROW
DECLARE
    V_STOCK_DISPONIBLE NUMBER(4);
BEGIN
    SELECT cantidad INTO V_STOCK_DISPONIBLE
    FROM inventario_lotes
    WHERE id_juguete = :NEW.id_juguete_inv
        AND id_tienda = :NEW.id_tienda_inv
        AND num_lote = :NEW.num_lote_inv;
    
    IF V_STOCK_DISPONIBLE < :NEW.cantidad THEN
        RAISE_APPLICATION_ERROR(-20103, 'Error de Stock: Stock insuficiente (' || V_STOCK_DISPONIBLE || ') para vender ' || :NEW.cantidad || ' unidades del juguete ' || :NEW.id_juguete_inv);
    END IF;
    
END;
/

--9. Trigger Control de lotes
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_control_lotes
BEFORE INSERT ON Inventario_Lotes
FOR EACH ROW
BEGIN
    UPDATE Inventario_Lotes
    SET fecha_fin = SYSDATE
    WHERE id_tienda = :NEW.id_tienda
      AND id_juguete = :NEW.id_juguete
      AND fecha_fin IS NULL;
      
    :NEW.fecha_fin := NULL; 
END;
/

-- 8. Trigger Validar catalogo
-- Creo que Lúcia dijo que esto le valía verga para las tiendas físicas
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_validar_catalogo_pais
BEFORE INSERT ON Inventario_Lotes
FOR EACH ROW
DECLARE
    v_pais_tienda NUMBER;
    v_existe      NUMBER;
BEGIN
    SELECT id_pais_ciu 
    INTO v_pais_tienda
    FROM Tiendas
    WHERE id = :NEW.id_tienda;

    SELECT COUNT(*)
    INTO v_existe
    FROM Catalogo_Paises
    WHERE id_juguete = :NEW.id_juguete
      AND id_pais = v_pais_tienda;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'ERROR: Este juguete no está autorizado para venta en el país de esta tienda.');
    END IF;
END;
/

-- TODO DE VENTA ONLINE --

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

-- TRIGGERS PARA LOS TOURS --

-- 1. Trigger para validar edad del participante
-- Especificar para qué actividad estamos validando la edad
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER validar_edad
BEFORE INSERT OR UPDATE ON detalle_inscripciones
FOR EACH ROW

DECLARE
    V_FECHA_NAC DATE;
    V_REPRESENTANTE NUMBER(6);
    V_EDAD NUMBER;
    V_FECHA_TOUR DATE := :NEW.FECHA_TOUR_INS;
    
BEGIN
    -- Validacion para clientes (id_lego_cli)
    IF :NEW.ID_LEGO_CLI IS NOT NULL THEN
        
        SELECT c.fecha_nacimiento INTO V_FECHA_NAC
        FROM clientes c
        WHERE c.id_lego = :NEW.ID_LEGO_CLI;
        
        V_EDAD := TRUNC(MONTHS_BETWEEN(V_FECHA_TOUR, V_FECHA_NAC) / 12);
        
        IF V_EDAD < 21 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error de Inscripcion: El cliente con ID ' || :NEW.ID_LEGO_CLI || ' tiene ' || V_EDAD || ' años y debe ser mayor de 21 para inscribirse.');
        END IF;
        
    -- Validacion para fans (id_lego_fan)
    ELSIF :NEW.ID_LEGO_FAN IS NOT NULL THEN
        
        SELECT f.fecha_nacimiento, f.id_lego_cliente INTO V_FECHA_NAC, V_REPRESENTANTE
        FROM fan_lego_menores f
        WHERE f.id_lego = :NEW.ID_LEGO_FAN;
        
        V_EDAD := TRUNC(MONTHS_BETWEEN(V_FECHA_TOUR, V_FECHA_NAC) / 12);
        
        IF V_EDAD < 12 OR V_EDAD > 20 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error de Inscripcion: El Fan Lego con ID ' || :NEW.ID_LEGO_FAN || ' tiene ' || V_EDAD || ' años. Solo se permiten participantes entre 12 y 20 años.');
        END IF;
        
        IF V_EDAD BETWEEN 12 AND 17 THEN
            IF V_REPRESENTANTE IS NULL THEN
                RAISE_APPLICATION_ERROR(-20003, 'Error de Inscripcion: El Fan Lego menor de 18 años (' || V_EDAD || ' años) debe tener un representante registrado.');
            END IF;
        END IF;
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error de Integridad: El ID del participante (Cliente o Fan) no existe en la base de datos.');
END;
/

-- 6. Trigger validar menores
-- Especificar en el nombre que son para las entradas
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_validar_menores
BEFORE INSERT ON Entradas
FOR EACH ROW
DECLARE
    v_cantidad_adultos NUMBER;
BEGIN
    IF :NEW.tipo = 'MENOR' THEN
        SELECT COUNT(*)
        INTO v_cantidad_adultos
        FROM Entradas
        WHERE fecha_tour_ins = :NEW.fecha_tour_ins
          AND numeroinscripcion = :NEW.numeroinscripcion
          AND tipo = 'ADULTO';
        IF v_cantidad_adultos = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'ERROR: No se puede registrar un MENOR sin haber registrado primero un ADULTO responsable.');
        END IF;
        
    END IF;
END;
/

--7. Trigger Validar fecha Tour
CREATE OR REPLACE TRIGGER trg_validar_fecha_inscripcion
BEFORE INSERT ON Inscripciones
FOR EACH ROW
DECLARE
    v_fecha_inicio_tour DATE;
BEGIN
    IF :NEW.fecha_inscripcion > :NEW.fecha_tour THEN
        RAISE_APPLICATION_ERROR(-20010, 'ERROR: No se puede inscribir en una fecha posterior al inicio del tour.');
    END IF;
END;
/