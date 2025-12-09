-----------------------------------------
-- PROCEDIMIENTOS/FUNCIONES PARA TOURS--
-----------------------------------------

create or replace NONEDITIONABLE FUNCTION fn_verificar_cupos (
    p_fecha_tour DATE
) RETURN NUMBER IS
    v_cupos_totales  NUMBER;
    v_ocupados       NUMBER;
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


--Calcular el total de la inscripcion
-- 2. Función: ¿Cuánto debe pagar este grupo?
create or replace NONEDITIONABLE FUNCTION fn_calcular_costo_total (
    p_fecha_tour DATE,
    p_cantidad_personas NUMBER
) RETURN NUMBER IS
    v_costo_unitario NUMBER;
BEGIN
    SELECT costo INTO v_costo_unitario FROM Tours WHERE fecha = p_fecha_tour;
    RETURN v_costo_unitario * p_cantidad_personas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END;


CREATE OR REPLACE PROCEDURE sp_gestion_tour_completo (
    p_fecha_tour     DATE,
    p_id_responsable NUMBER, 
    p_lista_personas VARCHAR2
) IS
    -- Variables Financieras
    v_cupos_disponibles NUMBER;
    v_num_inscripcion   NUMBER;
    v_total_usd         NUMBER; 
    v_total_eur         NUMBER;
    v_total_dkk         NUMBER;
    
    -- Variables de Parsing
    v_lista             VARCHAR2(32000) := p_lista_personas;
    v_bloque            VARCHAR2(100);
    v_pos_coma          NUMBER;
    v_pos_dos_puntos    NUMBER;
    v_id_persona        NUMBER;
    v_tipo              VARCHAR2(50); -- Aumentado por seguridad
    v_next_id           NUMBER := 0;
    v_count_personas    NUMBER := 0;
    
    -- Variables de Seguridad y Validación
    v_fecha_nac_check   DATE;
    v_edad_check        NUMBER;
    v_hay_adulto_resp   BOOLEAN := FALSE; 
    v_hay_nino          BOOLEAN := FALSE;
    v_check_tour        NUMBER; -- Variable para verificar si existe el tour

BEGIN
    -- 0. VALIDACIÓN DE FECHA (No permite hoy ni pasado)
    IF TRUNC(p_fecha_tour) <= TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20007, 'Error: Las reservaciones deben hacerse con al menos un día de antelación.');
    END IF;

    -- =========================================================
    -- 0.1 VALIDACIÓN DE EXISTENCIA DEL TOUR (NUEVO)
    -- =========================================================
    SELECT COUNT(*) INTO v_check_tour 
    FROM Tours 
    WHERE fecha = p_fecha_tour;

    IF v_check_tour = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Error: No existe ningún tour programado para la fecha ' || TO_CHAR(p_fecha_tour, 'DD/MM/YYYY'));
    END IF;
    -- =========================================================

    -- 1. VALIDAR CUPOS
    v_cupos_disponibles := fn_verificar_cupos(p_fecha_tour);
    IF v_cupos_disponibles <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'No hay cupos disponibles.');
    END IF;

    -- 2. CREAR CABECERA (PENDIENTE)
    SELECT NVL(MAX(numeroinscripcion), 0) + 1 INTO v_num_inscripcion FROM Inscripciones WHERE fecha_tour = p_fecha_tour;
    INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
    VALUES (p_fecha_tour, v_num_inscripcion, SYSDATE, 'PENDIENTE', 0);

    -- 3. PROCESAR LISTA (Parsing y Lógica)
    IF v_lista IS NOT NULL THEN
        IF SUBSTR(v_lista, -1) != ',' THEN v_lista := v_lista || ','; END IF;

        LOOP
            EXIT WHEN v_lista IS NULL OR LENGTH(TRIM(v_lista)) = 0;
            v_pos_coma := INSTR(v_lista, ',');
            EXIT WHEN v_pos_coma = 0;

            v_bloque := TRIM(SUBSTR(v_lista, 1, v_pos_coma - 1));
            IF LENGTH(v_bloque) > 0 THEN
                v_pos_dos_puntos := INSTR(v_bloque, ':');
                IF v_pos_dos_puntos > 0 THEN
                    v_id_persona := TO_NUMBER(TRIM(SUBSTR(v_bloque, 1, v_pos_dos_puntos - 1)));
                    v_tipo       := UPPER(TRIM(SUBSTR(v_bloque, v_pos_dos_puntos + 1)));
                    
                    -- Protección de sintaxis básica
                    IF v_tipo NOT IN ('CLIENTE', 'FAN') THEN
                         RAISE_APPLICATION_ERROR(-20008, 'Tipo inválido en la lista: ' || v_tipo || '. Verifique comas.');
                    END IF;

                    v_next_id    := v_next_id + 1;
                    v_count_personas := v_count_personas + 1;
                    
                    -- A. VERIFICAR EDAD Y ROL
                    BEGIN
                        IF v_tipo = 'CLIENTE' THEN
                            SELECT fecha_nacimiento INTO v_fecha_nac_check FROM Clientes WHERE id_lego = v_id_persona;
                        ELSIF v_tipo = 'FAN' THEN
                            SELECT fecha_nacimiento INTO v_fecha_nac_check FROM Fan_Lego_Menores WHERE id_lego = v_id_persona;
                        END IF;
                        
                        -- Usamos fn_edad estándar
                        v_edad_check := fn_calcular_edad(v_fecha_nac_check);
                        
                        -- REGLA DE SEGURIDAD:
                        IF v_edad_check >= 18 THEN 
                            v_hay_adulto_resp := TRUE;
                        ELSE 
                            v_hay_nino := TRUE;
                        END IF;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20005, 'Persona ID ' || v_id_persona || ' no encontrada.');
                    END;

                    -- B. INSERTAR DETALLE
                    IF v_tipo = 'CLIENTE' THEN
                        INSERT INTO Detalle_Inscripciones VALUES (p_fecha_tour, v_num_inscripcion, v_next_id, v_id_persona, NULL);
                    ELSIF v_tipo = 'FAN' THEN
                        INSERT INTO Detalle_Inscripciones VALUES (p_fecha_tour, v_num_inscripcion, v_next_id, NULL, v_id_persona);
                    END IF;
                END IF;
            END IF;
            v_lista := SUBSTR(v_lista, v_pos_coma + 1);
        END LOOP;
    END IF;

    -- 4. VALIDACIONES FINALES
    IF v_count_personas > v_cupos_disponibles THEN
        ROLLBACK; RAISE_APPLICATION_ERROR(-20004, 'Cupos insuficientes.');
    END IF;
    
    -- Si hay niños (<18), DEBE haber un responsable (>=18)
    IF v_hay_nino AND NOT v_hay_adulto_resp THEN
        ROLLBACK; 
        RAISE_APPLICATION_ERROR(-20006, 'Regla violada: Menores de 18 años deben ir acompañados de un representante (Mayor de 18).');
    END IF;

    -- 5. CÁLCULOS Y PAGO
    v_total_usd := fn_calcular_costo_total(p_fecha_tour, v_count_personas);
    v_total_eur := fn_convertir_moneda(v_total_usd, 'EURO');
    v_total_dkk := fn_convertir_moneda(v_total_usd, 'CORONA DANESA');

    -- Guardar totales
    UPDATE Inscripciones SET total = v_total_usd 
    WHERE fecha_tour = p_fecha_tour AND numeroinscripcion = v_num_inscripcion;
    
    COMMIT; -- Guardamos PENDIENTE antes de mostrar factura

    -- =========================================================
    -- 6. FACTURA EN PANTALLA (SIN ID)
    -- =========================================================
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('       FACTURA DE INSCRIPCIÓN #' || v_num_inscripcion);
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(' Fecha:      ' || p_fecha_tour);
    DBMS_OUTPUT.PUT_LINE(' Estado:     PENDIENTE');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' TOTAL A PAGAR:');
    DBMS_OUTPUT.PUT_LINE('   USD: $  ' || v_total_usd || ' (Base)');
    DBMS_OUTPUT.PUT_LINE('   DKK: kr ' || v_total_dkk);
    DBMS_OUTPUT.PUT_LINE('   EUR: €  ' || v_total_eur);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' VISITANTES:');
    -- CAMBIO: Se quitó la columna ID
    DBMS_OUTPUT.PUT_LINE(' NOMBRE               | TIPO TICKET (Tarifa)');
    DBMS_OUTPUT.PUT_LINE('----------------------|---------------------');

    FOR r IN (
        SELECT d.id, 
               CASE WHEN d.id_lego_cli IS NOT NULL THEN c.primer_nombre || ' ' || c.primer_apellido
                    WHEN d.id_lego_fan IS NOT NULL THEN f.primer_nombre || ' ' || f.primer_apellido
               END as nombre_completo,
               CASE 
                   WHEN fn_calcular_edad(NVL(c.fecha_nacimiento, f.fecha_nacimiento)) >= 21 THEN 'ADULTO'
                   ELSE 'JOVEN'
               END as tipo_tarifa
        FROM Detalle_Inscripciones d
        LEFT JOIN Clientes c ON d.id_lego_cli = c.id_lego
        LEFT JOIN Fan_Lego_Menores f ON d.id_lego_fan = f.id_lego
        WHERE d.fecha_tour_ins = p_fecha_tour AND d.numeroinscripcion = v_num_inscripcion
        ORDER BY d.id
    ) LOOP
        -- CAMBIO: Se quitó la impresión del ID
        DBMS_OUTPUT.PUT_LINE(RPAD(SUBSTR(r.nombre_completo,1,20), 21) || '| ' || r.tipo_tarifa);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('==================================================');

    -- 7. EJECUTAR PAGO
    UPDATE Inscripciones SET estatus = 'PAGADO' 
    WHERE fecha_tour = p_fecha_tour AND numeroinscripcion = v_num_inscripcion;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('[EXITO] Pago procesado y Entradas generadas.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('>>> ERROR: ' || SQLERRM);
        RAISE;
END;

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
WHEN (NEW.estatus = 'PAGADO')
DECLARE
    CURSOR c_detalle IS
        SELECT id, id_lego_cli, id_lego_fan
        FROM Detalle_Inscripciones
        WHERE fecha_tour_ins = :NEW.fecha_tour 
          AND numeroinscripcion = :NEW.numeroinscripcion;
          
    v_fecha_nac DATE;
    v_edad      NUMBER;
    v_tipo      VARCHAR2(20);
    v_num_entrada NUMBER;
BEGIN
    FOR r IN c_detalle LOOP
        IF r.id_lego_cli IS NOT NULL THEN
            SELECT fecha_nacimiento INTO v_fecha_nac FROM Clientes WHERE id_lego = r.id_lego_cli;
        ELSIF r.id_lego_fan IS NOT NULL THEN
            SELECT fecha_nacimiento INTO v_fecha_nac FROM Fan_Lego_Menores WHERE id_lego = r.id_lego_fan;
        END IF;

        v_edad := fn_calcular_edad(v_fecha_nac);

        -- CAMBIO AQUI: Umbral de Adulto sube a 21
        -- Así el de 19 años tendrá ticket JOVEN
        IF v_edad >= 21 THEN 
            v_tipo := 'ADULTO';
        ELSE 
            v_tipo := 'JOVEN'; 
        END IF;

        SELECT NVL(MAX(numeroentrada), 0) + 1 INTO v_num_entrada 
        FROM Entradas 
        WHERE fecha_tour_ins = :NEW.fecha_tour AND numeroinscripcion = :NEW.numeroinscripcion;

        INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo)
        VALUES (:NEW.fecha_tour, :NEW.numeroinscripcion, v_num_entrada, v_tipo);
    END LOOP;
END;
