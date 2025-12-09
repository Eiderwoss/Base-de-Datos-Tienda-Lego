-----------------------------------------
-- PROCEDIMIENTOS/FUNCIONES PARA TOURS--
-----------------------------------------

CREATE OR REPLACE FUNCTION fn_verificar_cupos (
    p_fecha_tour DATE
) RETURN NUMBER IS
    v_cupos_totales  NUMBER(2);
    v_ocupados       NUMBER(2);
BEGIN
    -- Obtenemos capacidad total
    BEGIN
        SELECT cupos_totales INTO v_cupos_totales FROM Tours WHERE fecha = p_fecha_tour;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN -1; -- Código de error: Tour no existe
    END;

    -- Contamos ocupados
    SELECT COUNT(*) INTO v_ocupados 
    FROM Detalle_Inscripciones WHERE fecha_tour_ins = p_fecha_tour;

    RETURN v_cupos_totales - v_ocupados;
END;
/

CREATE OR REPLACE PROCEDURE sp_gestion_tour_completo (
    p_id_pagador     IN NUMBER,       
    p_fecha_tour     IN DATE,
    p_lista_personas IN VARCHAR2 -- '100:CLIENTE, 10:FAN'
) IS
    -- Variables de Flujo
    v_cupos_libres   NUMBER;
    v_num_personas   NUMBER := 1; -- Empieza en 1 por el pagador
    v_num_inscripcion NUMBER;
    v_total_pagar    NUMBER;
    
    -- Variables Auxiliares
    v_eur            NUMBER;
    v_dkk            NUMBER;
    
    -- Variables para Parsing (Leer la lista)
    v_lista          VARCHAR2(4000) := p_lista_personas;
    v_pos_coma       NUMBER;
    v_bloque         VARCHAR2(100);
    v_pos_dos_puntos NUMBER;
    v_id_persona     NUMBER;
    v_tipo           VARCHAR2(20);
    v_next_id        NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DEL PROCESO DE GESTIÓN DE TOUR ===');

    -- 1. VERIFICACIÓN (Usando Funciones)
    -- Calcular cantidad de personas en la lista
    IF p_lista_personas IS NOT NULL THEN
        v_num_personas := v_num_personas + REGEXP_COUNT(p_lista_personas, ',') + 1;
    END IF;

    -- Llamar función de cupos
    v_cupos_libres := fn_verificar_cupos(p_fecha_tour);

    IF v_cupos_libres = -1 THEN
        RAISE_APPLICATION_ERROR(-20000, 'El Tour para la fecha indicada no existe.');
    ELSIF v_cupos_libres < v_num_personas THEN
        RAISE_APPLICATION_ERROR(-20090, 'Cupos insuficientes. Solicitados: ' || v_num_personas || '. Disponibles: ' || v_cupos_libres);
    END IF;

    DBMS_OUTPUT.PUT_LINE('[OK] Disponibilidad confirmada.');

    -- 2. REGISTRO (PENDIENTE)
    SELECT NVL(MAX(numeroinscripcion), 0) + 1 INTO v_num_inscripcion 
    FROM Inscripciones WHERE fecha_tour = p_fecha_tour;

    -- Creamos Cabecera
    INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
    VALUES (p_fecha_tour, v_num_inscripcion, SYSDATE, 'PENDIENTE', 0);

    -- Insertamos Pagador
    INSERT INTO Detalle_Inscripciones (fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan)
    VALUES (p_fecha_tour, v_num_inscripcion, v_next_id, p_id_pagador, NULL);

    -- Insertamos Acompañantes (Parsing)
    IF p_lista_personas IS NOT NULL THEN
        v_lista := v_lista || ',';
        LOOP
            v_pos_coma := INSTR(v_lista, ',');
            EXIT WHEN v_pos_coma = 0;
            
            v_bloque := SUBSTR(v_lista, 1, v_pos_coma - 1);
            v_pos_dos_puntos := INSTR(v_bloque, ':');
            
            IF v_pos_dos_puntos > 0 THEN
                v_id_persona := TO_NUMBER(SUBSTR(v_bloque, 1, v_pos_dos_puntos - 1));
                v_tipo       := UPPER(TRIM(SUBSTR(v_bloque, v_pos_dos_puntos + 1)));
                v_next_id    := v_next_id + 1;

                IF v_tipo = 'CLIENTE' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (p_fecha_tour, v_num_inscripcion, v_next_id, v_id_persona, NULL);
                ELSIF v_tipo = 'FAN' THEN
                    INSERT INTO Detalle_Inscripciones VALUES (p_fecha_tour, v_num_inscripcion, v_next_id, NULL, v_id_persona);
                END IF;
            END IF;
            v_lista := SUBSTR(v_lista, v_pos_coma + 1);
        END LOOP;
    END IF;

    -- 3. CÁLCULO DE TOTAL (Usando Función)
    v_total_pagar := fn_calcular_costo_total(p_fecha_tour, v_num_personas);
    
    -- Actualizamos cabecera
    UPDATE Inscripciones SET total = v_total_pagar 
    WHERE fecha_tour = p_fecha_tour AND numeroinscripcion = v_num_inscripcion;

    DBMS_OUTPUT.PUT_LINE('[OK] Registro creado (PENDIENTE). Total calculado.');

    -- 4. MOSTRAR PRESUPUESTO (Usando Funciones de Moneda)
    v_eur := fn_convertir_moneda(v_total_pagar, 'EURO');
    v_dkk := fn_convertir_moneda(v_total_pagar, 'CORONA DANESA');
    
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE(' CONFIRMACIÓN DE COSTOS (Insc #' || v_num_inscripcion || ')');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE(' USD: $' || v_total_pagar);
    DBMS_OUTPUT.PUT_LINE(' EUR: €' || v_eur);
    DBMS_OUTPUT.PUT_LINE(' DKK: kr' || v_dkk);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

    -- 5. PROCESAR PAGO
    -- Al hacer esto, el Trigger 'trg_generar_entradas_automatico' se dispara y crea los tickets
    UPDATE Inscripciones 
    SET estatus = 'PAGADO' 
    WHERE fecha_tour = p_fecha_tour AND numeroinscripcion = v_num_inscripcion;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('[EXITO] Pago procesado. Estatus: PAGADO.');
    DBMS_OUTPUT.PUT_LINE('[EXITO] Tickets generados automáticamente en tabla ENTRADAS.');
    DBMS_OUTPUT.PUT_LINE('=== FIN DEL PROCESO ===');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('!!! ERROR EN EL PROCESO: ' || SQLERRM);
END;
/

--

--Calcular el total de la inscripcion
-- 2. Función: ¿Cuánto debe pagar este grupo?
CREATE OR REPLACE FUNCTION fn_calcular_costo_total (
    p_fecha_tour DATE,
    p_cantidad_personas NUMBER
) RETURN NUMBER IS
    v_costo_unitario NUMBER(5, 2);
BEGIN
    SELECT costo INTO v_costo_unitario FROM Tours WHERE fecha = p_fecha_tour;
    RETURN v_costo_unitario * p_cantidad_personas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END;
/

-------------------------------
-- TRIGGERS PARA LOS TOURS --
-------------------------------

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

CREATE OR REPLACE TRIGGER trg_generar_entradas_automatico
AFTER UPDATE OF estatus ON Inscripciones
FOR EACH ROW
WHEN (NEW.estatus = 'PAGADO') -- Solo se dispara al pagar
DECLARE
    -- Cursor para recorrer a los participantes de ESA inscripción
    CURSOR c_gente IS
        SELECT id, id_lego_cli, id_lego_fan
        FROM Detalle_Inscripciones
        WHERE fecha_tour_ins = :NEW.fecha_tour 
          AND numeroinscripcion = :NEW.numeroinscripcion;
          
    v_fecha_nac DATE;
    v_edad      NUMBER;
    v_tipo      VARCHAR2(10);
BEGIN
    FOR r IN c_gente LOOP
        -- 1. Calcular Edad para definir tipo de entrada
        IF r.id_lego_cli IS NOT NULL THEN
            SELECT fecha_nacimiento INTO v_fecha_nac FROM Clientes WHERE id_lego = r.id_lego_cli;
        ELSE
            SELECT fecha_nacimiento INTO v_fecha_nac FROM Fan_Lego_Menores WHERE id_lego = r.id_lego_fan;
        END IF;
        
        v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac)/12);
        
        IF v_edad >= 18 THEN v_tipo := 'ADULTO';
        ELSIF v_edad >= 12 THEN v_tipo := 'JOVEN';
        ELSE v_tipo := 'MENOR';
        END IF;
        
        -- 2. Crear la Entrada (Ticket)
        INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo)
        VALUES (:NEW.fecha_tour, :NEW.numeroinscripcion, r.id, v_tipo);
    END LOOP;
END;
/