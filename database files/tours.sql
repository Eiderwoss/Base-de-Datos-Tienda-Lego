-----------------------------------------
-- PROCEDIMIENTOS/FUNCIONES PARA TOURS--
-----------------------------------------

CREATE OR REPLACE FUNCTION fn_cupos_disponibles (
    p_fecha_tour DATE
) RETURN NUMBER IS
    v_cupos_totales  NUMBER;
    v_ocupados       NUMBER;
    v_disponibles    NUMBER;
BEGIN
    -- 1. Obtener capacidad total del tour
    BEGIN
        SELECT cupos_totales 
        INTO v_cupos_totales
        FROM Tours
        WHERE fecha = p_fecha_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0; -- Si no existe el tour, 0 cupos
    END;

    -- 2. Contar cuántos inscritos hay en total (sumando todos los grupos)
    SELECT COUNT(*)
    INTO v_ocupados
    FROM Detalle_Inscripciones
    WHERE fecha_tour_ins = p_fecha_tour;

    -- 3. Calcular resta
    v_disponibles := v_cupos_totales - v_ocupados;

    -- Seguridad por si hay error de datos negativos
    IF v_disponibles < 0 THEN
        v_disponibles := 0;
    END IF;

    RETURN v_disponibles;
END;
/



CREATE OR REPLACE PROCEDURE sp_realizar_inscripcion (
    p_id_cliente_pagador IN NUMBER,       
    p_fecha_tour         IN DATE,
    p_lista_acompanantes IN VARCHAR2 -- Puede ser NULL si va solo
) IS
    -- Variables de control
    v_num_inscripcion   NUMBER;
    v_cupos_disponibles NUMBER;
    v_personas_total    NUMBER := 1; -- Empieza en 1 (el pagador)
    v_nuevo_total       NUMBER;
    v_next_id_detalle   NUMBER := 1;

    -- Variables para el Bucle (Parsing de texto)
    v_lista_trabajo     VARCHAR2(4000) := p_lista_acompanantes;
    v_pos_coma          NUMBER;
    v_pos_dos_puntos    NUMBER;
    v_bloque            VARCHAR2(100);
    v_id_persona        NUMBER;
    v_tipo              VARCHAR2(20);

BEGIN
    -- ------------------------------------------------------------
    -- PASO 1: CALCULAR CUÁNTOS SON EN TOTAL
    -- ------------------------------------------------------------
    IF p_lista_acompanantes IS NOT NULL AND LENGTH(TRIM(p_lista_acompanantes)) > 0 THEN
        -- Contamos las comas y sumamos 1 para saber cuántos acompañantes hay
        -- Luego sumamos el pagador que ya inicializamos en 1
        v_personas_total := v_personas_total + REGEXP_COUNT(p_lista_acompanantes, ',') + 1;
    END IF;

    -- ------------------------------------------------------------
    -- PASO 2: VALIDAR SI HAY CUPO PARA TODOS (Todo o Nada)
    -- ------------------------------------------------------------
    v_cupos_disponibles := fn_cupos_disponibles(p_fecha_tour);

    IF v_personas_total > v_cupos_disponibles THEN
        RAISE_APPLICATION_ERROR(-20095, 
            'Cupos Insuficientes. El grupo es de ' || v_personas_total || 
            ' personas pero solo quedan ' || v_cupos_disponibles || ' cupos disponibles.');
    END IF;

    -- ------------------------------------------------------------
    -- PASO 3: CREAR LA INSCRIPCIÓN (CABECERA)
    -- ------------------------------------------------------------
    SELECT NVL(MAX(numeroinscripcion), 0) + 1 
    INTO v_num_inscripcion 
    FROM Inscripciones 
    WHERE fecha_tour = p_fecha_tour;

    INSERT INTO Inscripciones (
        fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, SYSDATE, 'PENDIENTE', 0
    );

    -- ------------------------------------------------------------
    -- PASO 4: INSERTAR AL PAGADOR (Siempre es el ID 1 del detalle)
    -- ------------------------------------------------------------
    INSERT INTO Detalle_Inscripciones (
        fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan
    ) VALUES (
        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, p_id_cliente_pagador, NULL
    );

    -- ------------------------------------------------------------
    -- PASO 5: BUCLE PARA INSERTAR ACOMPAÑANTES
    -- ------------------------------------------------------------
    IF p_lista_acompanantes IS NOT NULL AND LENGTH(TRIM(p_lista_acompanantes)) > 0 THEN
        
        v_lista_trabajo := v_lista_trabajo || ','; -- Truco para que el loop lea el último
        
        LOOP
            v_pos_coma := INSTR(v_lista_trabajo, ',');
            EXIT WHEN v_pos_coma = 0;
            
            -- Cortamos el bloque "ID:TIPO"
            v_bloque := SUBSTR(v_lista_trabajo, 1, v_pos_coma - 1);
            v_pos_dos_puntos := INSTR(v_bloque, ':');
            
            IF v_pos_dos_puntos > 0 THEN
                v_id_persona := TO_NUMBER(SUBSTR(v_bloque, 1, v_pos_dos_puntos - 1));
                v_tipo       := UPPER(TRIM(SUBSTR(v_bloque, v_pos_dos_puntos + 1)));
                
                v_next_id_detalle := v_next_id_detalle + 1;

                IF v_tipo = 'CLIENTE' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (
                        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, v_id_persona, NULL
                    );
                ELSIF v_tipo = 'FAN' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (
                        p_fecha_tour, v_num_inscripcion, v_next_id_detalle, NULL, v_id_persona
                    );
                ELSE
                     RAISE_APPLICATION_ERROR(-20096, 'Tipo de participante inválido: ' || v_tipo);
                END IF;
            END IF;
            
            v_lista_trabajo := SUBSTR(v_lista_trabajo, v_pos_coma + 1);
        END LOOP;
    END IF;

    -- ------------------------------------------------------------
    -- PASO 6: CALCULAR Y ACTUALIZAR PRECIO FINAL
    -- ------------------------------------------------------------
    -- Usamos la función que calculaba costo * cantidad
    -- Nota: Asegúrate de tener compilada la función fn_calcular_total_inscripcion que hicimos antes
    v_nuevo_total := fn_calcular_total_inscripcion(p_fecha_tour, v_num_inscripcion);

    UPDATE Inscripciones
    SET total = v_nuevo_total
    WHERE fecha_tour = p_fecha_tour 
      AND numeroinscripcion = v_num_inscripcion;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inscripción Grupal #' || v_num_inscripcion || ' Exitosa.');
    DBMS_OUTPUT.PUT_LINE('Personas inscritas: ' || v_personas_total);
    DBMS_OUTPUT.PUT_LINE('Total a Pagar: ' || v_nuevo_total);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error en inscripción: ' || SQLERRM);
END;
/

--Pruebas del procedure
BEGIN
    sp_realizar_inscripcion_grupo(
        p_id_cliente_pagador => 99,
        p_fecha_tour         => TO_DATE('15/12/2025','DD/MM/YYYY'),
        p_lista_acompanantes => '100:CLIENTE, 10:FAN'
    );
END;
/
BEGIN
    sp_realizar_inscripcion_grupo(99, TO_DATE('15/12/2025','DD/MM/YYYY'), NULL);
END;
/
--

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
    FROM Tours t, Inscripciones i
    WHERE t.fecha = i.fecha_tour
    AND i.fecha_tour = p_fecha_tour
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
CREATE OR REPLACE TRIGGER trg_validar_edad_detalle_inscripcion
BEFORE INSERT OR UPDATE ON detalle_inscripciones
FOR EACH ROW

DECLARE
    V_FECHA_NAC DATE;
    V_REPRESENTANTE NUMBER(6);
    V_EDAD NUMBER (2);
    V_FECHA_TOUR DATE := :NEW.FECHA_TOUR_INS;
    V_ID_LEGO_CLI NUMBER (6) := :NEW.ID_LEGO_CLI;
    V_ID_LEGO_FAN NUMBER (6) := :NEW.ID_LEGO_FAN;
BEGIN
    -- Validacion para clientes (id_lego_cli)
    IF :NEW.ID_LEGO_CLI IS NOT NULL THEN
        
        SELECT c.fecha_nacimiento INTO V_FECHA_NAC
        FROM clientes c
        WHERE c.id_lego = V_ID_LEGO_CLI;
        
        V_EDAD := fn_calcular_edad(v_fecha_nac);
        
        IF V_EDAD < 21 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error de Inscripcion: El cliente con ID ' || :NEW.ID_LEGO_CLI || ' tiene ' || V_EDAD || ' años y debe ser mayor de 21 para inscribirse.');
        END IF;
        
    -- Validacion para fans (id_lego_fan)
    ELSIF :NEW.ID_LEGO_FAN IS NOT NULL THEN
        
        SELECT f.fecha_nacimiento, f.id_lego_cliente INTO V_FECHA_NAC, V_REPRESENTANTE
        FROM fan_lego_menores f
        WHERE f.id_lego = V_ID_LEGO_FAN;
        
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
CREATE OR REPLACE TRIGGER trg_validar_menores_entradas
BEFORE INSERT ON Entradas
FOR EACH ROW
DECLARE
    v_fecha DATE;
    v_num   NUMBER (4);
    
    v_cantidad_adultos NUMBER (2);
BEGIN
    v_fecha := :NEW.fecha_tour_ins;
    v_num   := :NEW.numeroinscripcion;

    IF :NEW.tipo = 'MENOR' THEN
        
        SELECT COUNT(*)
        INTO v_cantidad_adultos
        FROM Entradas
        WHERE fecha_tour_ins = v_fecha AND 
        numeroinscripcion = v_num AND 
        tipo = 'ADULTO';

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
