SET SERVEROUTPUT ON;
SET VERIFY OFF;
SET PAGESIZE 100;
SET LINESIZE 200;

UNDEFINE v_fecha_seleccionada;
UNDEFINE v_lista_participantes;
UNDEFINE v_dummy_id;

PROMPT
PROMPT ========================================================================
PROMPT                       TOURS DISPONIBLES
PROMPT ========================================================================
COLUMN FECHA FORMAT A15
COLUMN COSTO_USD FORMAT $999.99
COLUMN CAPACIDAD FORMAT 9999

SELECT TO_CHAR(t.fecha, 'DD/MM/YYYY') FECHA_SALIDA,
       t.cupos_totales CAPACIDAD,
       t.costo COSTO_USD
FROM Tours t
WHERE t.fecha > SYSDATE
ORDER BY t.fecha ASC;

PROMPT
PROMPT [ACCIÓN REQUERIDA]
ACCEPT v_fecha_seleccionada PROMPT '>>> Por favor, escriba la FECHA del Tour (DD/MM/YYYY) y presione Enter: '

PROMPT
PROMPT ========================================================================
PROMPT                        CLIENTES
PROMPT ========================================================================
COLUMN ID FORMAT 999999
COLUMN NOMBRE FORMAT A15
COLUMN APELLIDO FORMAT A15

SELECT id_lego ID, 
       primer_nombre NOMBRE, 
       primer_apellido APELLIDO
FROM Clientes
ORDER BY id_lego;

PROMPT
PROMPT ========================================================================
PROMPT                        FANS (MENORES)
PROMPT ========================================================================
COLUMN ID_PADRE FORMAT 99999

SELECT id_lego ID, 
       primer_nombre NOMBRE, 
       primer_apellido APELLIDO,
       id_lego_cliente ID_PADRE
FROM Fan_Lego_Menores
ORDER BY id_lego;

PROMPT
PROMPT [ACCIÓN REQUERIDA]
ACCEPT v_lista_participantes PROMPT '>>> Escriba la LISTA de participantes (Formato: ID:TIPO, ID:TIPO Ejemplo: 99:CLIENTE, 10:FAN) y presione Enter: '

DEFINE v_dummy_id = 99;

PROMPT
PROMPT >>> Procesando inscripción para el dia &v_fecha_seleccionada...

DECLARE
    v_fecha_str VARCHAR2(50)   := '&v_fecha_seleccionada';
    v_lista_str VARCHAR2(4000) := '&v_lista_participantes';
    v_id_resp   NUMBER         := &v_dummy_id;
BEGIN
    sp_gestion_tour_completo(
        TO_DATE(v_fecha_str, 'DD/MM/YYYY'), 
        v_id_resp, 
        v_lista_str
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('>>> ERROR FATAL: ' || SQLERRM);
END;