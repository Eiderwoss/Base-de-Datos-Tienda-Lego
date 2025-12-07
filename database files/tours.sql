-----------------------------------------
-- PROCEDIMIENTOS/FUNCIONES PARA TOURS--
-----------------------------------------

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
    p_fecha_tour         IN DATE,
    p_cadena_personas    IN VARCHAR2 -- Ejemplo: '100:CLIENTE, 10:FAN'
) IS
    v_num_inscripcion  NUMBER;
    v_costo_tour       NUMBER;
    v_cupos_totales    NUMBER;
    v_cupos_ocupados   NUMBER;
    v_next_id_detalle  NUMBER := 1;
    v_nuevo_total      NUMBER;
    
    -- Variables para el parsing
    v_lista_trabajo    VARCHAR2(4000) := p_cadena_personas;
    v_pos_coma         NUMBER;
    v_pos_dos_puntos   NUMBER;
    v_bloque_persona   VARCHAR2(100);
    v_id_persona       NUMBER;
    v_tipo_persona     VARCHAR2(20);
    
    -- Excepción personalizada para cupos
    e_cupos_llenos     EXCEPTION;
BEGIN
    -- 1. VALIDACIÓN INICIAL DE CUPOS Y EXISTENCIA TOUR
    BEGIN
        -- Obtenemos costo y cupos totales del tour
        SELECT costo, cupos_totales 
        INTO v_costo_tour, v_cupos_totales 
        FROM Tours 
        WHERE fecha = p_fecha_tour;

        -- Contamos cuánta gente hay ya inscrita en todo el tour
        SELECT COUNT(*) 
        INTO v_cupos_ocupados
        FROM Detalle_Inscripciones
        WHERE fecha_tour_ins = p_fecha_tour;
        
        -- Validamos si ya está lleno antes de empezar
        IF v_cupos_ocupados >= v_cupos_totales THEN
            RAISE e_cupos_llenos;
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'El Tour especificado para esa fecha no existe.');
    END;

    -- 2. Generar ID Inscripción (Cabecera)
    SELECT NVL(MAX(numeroinscripcion), 0) + 1 
    INTO v_num_inscripcion 
    FROM Inscripciones 
    WHERE fecha_tour = p_fecha_tour;

    -- 3. Insertar Cabecera (Inicialmente en 0 o costo base)
    INSERT INTO Inscripciones (
        fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, SYSDATE, 'PENDIENTE', 0
    );

    -- 4. Insertar al PAGADOR (Siempre ocupa 1 cupo)
    -- Verificamos cupo de nuevo (cupos_ocupados + 1)
    IF (v_cupos_ocupados + 1) > v_cupos_totales THEN
        RAISE e_cupos_llenos;
    END IF;

    INSERT INTO Detalle_Inscripciones (
        fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, p_id_cliente_pagador, NULL
    );
    
    -- Actualizamos contador de ocupados en memoria
    v_cupos_ocupados := v_cupos_ocupados + 1;

    -- 5. PROCESAR ACOMPAÑANTES (Loop)
    IF v_lista_trabajo IS NOT NULL AND LENGTH(v_lista_trabajo) > 0 THEN
        v_lista_trabajo := v_lista_trabajo || ',';
        
        LOOP
            v_pos_coma := INSTR(v_lista_trabajo, ',');
            EXIT WHEN v_pos_coma = 0;
            
            v_bloque_persona := SUBSTR(v_lista_trabajo, 1, v_pos_coma - 1);
            v_pos_dos_puntos := INSTR(v_bloque_persona, ':');
            
            IF v_pos_dos_puntos > 0 THEN
                -- VALIDAR CUPO PARA ESTE ACOMPAÑANTE
                IF (v_cupos_ocupados + 1) > v_cupos_totales THEN
                    RAISE e_cupos_llenos;
                END IF;

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
                
                -- Ocupamos otro cupo en memoria
                v_cupos_ocupados := v_cupos_ocupados + 1;
            END IF;
            
            v_lista_trabajo := SUBSTR(v_lista_trabajo, v_pos_coma + 1);
        END LOOP;
    END IF;

    -- 6. ACTUALIZAR EL TOTAL USANDO LA FUNCIÓN (Tu requerimiento)
    v_nuevo_total := fn_calcular_total_inscripcion(p_fecha_tour, v_num_inscripcion);

    UPDATE Inscripciones
    SET total = v_nuevo_total
    WHERE fecha_tour = p_fecha_tour 
      AND numeroinscripcion = v_num_inscripcion;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Grupo inscrito. Total a pagar: ' || v_nuevo_total);

EXCEPTION
    WHEN e_cupos_llenos THEN
        ROLLBACK; -- Deshacemos todo si no caben
        RAISE_APPLICATION_ERROR(-20090, 'Error: No hay suficientes cupos en el tour para todo el grupo.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE; -- Re-lanza cualquier otro error (como edad, triggers, etc)
END;
/


--Calcular el total de la inscripcion
CREATE OR REPLACE FUNCTION fn_calcular_total_inscripcion (
    p_fecha_tour DATE,
    p_num_insc   NUMBER
) RETURN NUMBER IS
    v_costo_tour NUMBER;
    v_cantidad   NUMBER;
    v_total      NUMBER;
BEGIN
    -- 1. Buscamos el costo unitario del tour
    SELECT t.costo
    INTO v_costo_tour
    FROM Inscripciones i
    JOIN Tours t ON i.fecha_tour = t.fecha -- Ajustado a tu relación por fecha
    WHERE i.fecha_tour = p_fecha_tour 
      AND i.numeroinscripcion = p_num_insc;

    -- 2. Contamos cuántas personas hay en esa inscripción
    SELECT COUNT(*)
    INTO v_cantidad
    FROM Detalle_Inscripciones
    WHERE fecha_tour_ins = p_fecha_tour
      AND numeroinscripcion = p_num_insc;

    -- 3. Calculamos
    v_total := v_costo_tour * v_cantidad;

    RETURN v_total;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-------------------------------
-- TRIGGERS PARA LOS TOURS --
-------------------------------

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
        
        V_EDAD := fn_calcular_edad(v_fecha_nac);
        
        IF V_EDAD < 21 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error de Inscripcion: El cliente con ID ' || :NEW.ID_LEGO_CLI || ' tiene ' || V_EDAD || ' años y debe ser mayor de 21 para inscribirse.');
        END IF;
        
    -- Validacion para fans (id_lego_fan)
    ELSIF :NEW.ID_LEGO_FAN IS NOT NULL THEN
        
        SELECT f.fecha_nacimiento, f.id_lego_cliente INTO V_FECHA_NAC, V_REPRESENTANTE
        FROM fan_lego_menores f
        WHERE f.id_lego = :NEW.ID_LEGO_FAN;
        
        V_EDAD := fn_calcular_edad(v_fecha_nac);
        
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
CREATE OR REPLACE TRIGGER trg_validar_menores_entradas
BEFORE INSERT ON Entradas
FOR EACH ROW
DECLARE
    v_fecha DATE;
    v_num   NUMBER;
    
    v_cantidad_adultos NUMBER;
BEGIN
    v_fecha := :NEW.fecha_tour_ins;
    v_num   := :NEW.numeroinscripcion;

    IF :NEW.tipo = 'MENOR' THEN
        
        SELECT COUNT(*)
        INTO v_cantidad_adultos
        FROM Entradas
        WHERE fecha_tour_ins = v_fecha
          AND numeroinscripcion = v_num
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
