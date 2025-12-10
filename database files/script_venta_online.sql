SET SERVEROUTPUT ON;
SET VERIFY OFF;
SET PAGESIZE 100;
SET LINESIZE 200;

UNDEFINE v_id_cliente;
UNDEFINE v_lista_productos;
UNDEFINE v_id_pais_residencia;

PROMPT
PROMPT ========================================================================
PROMPT                       CLIENTES DISPONIBLES
PROMPT ========================================================================
COLUMN ID FORMAT 999999
COLUMN NOMBRE FORMAT A15
COLUMN APELLIDO FORMAT A15
COLUMN PUNTOS_DISPONIBLES FORMAT 999
COLUMN PAIS FORMAT A15

SELECT c.id_lego ID,
       c.primer_nombre NOMBRE,
       c.primer_apellido APELLIDO,
       p.nombre PAIS,
       vsc.puntos_disponibles PUNTOS_DISPONIBLES
FROM Clientes c
JOIN Paises p ON c.id_pais_res = p.id
JOIN v_saldo_puntos_cliente vsc ON c.id_lego = vsc.id_cliente
ORDER BY c.id_lego;

PROMPT
PROMPT [ACCION REQUERIDA - ID DE CLIENTE]
ACCEPT v_id_cliente NUMBER PROMPT '>>> Por favor, escriba el ID del Cliente: '

COLUMN ID_PAIS_TEMP NEW_VALUE v_id_pais_residencia NOPRINT
SELECT c.id_pais_res ID_PAIS_TEMP FROM Clientes c WHERE c.id_lego = &v_id_cliente;
COLUMN ID_PAIS_TEMP CLEAR

PROMPT
PROMPT ========================================================================
PROMPT                       CATALOGO DE PRODUCTOS
PROMPT ========================================================================
COLUMN ID_JUGUETE FORMAT 9999
COLUMN NOMBRE_JUGUETE FORMAT A30
COLUMN PRECIO_ACTUAL FORMAT $999.99
COLUMN ID_PAIS FORMAT 999
COLUMN PAIS_DISPONIBLE FORMAT A20
COLUMN LIMITE_POR_PAIS FORMAT 99

-- Muestra solo los juguetes con precio activo
SELECT
    j.id ID_JUGUETE,
    j.nombre NOMBRE_JUGUETE,
    hp.precio PRECIO_ACTUAL,
    p.id ID_PAIS,
    p.nombre PAIS_DISPONIBLE,
    cp.limite LIMITE_POR_PAIS
FROM
    Juguetes j
JOIN
    Historico_Precios hp ON j.id = hp.id_juguete
JOIN
    Catalogo_Paises cp ON j.id = cp.id_juguete
JOIN
    Paises p ON cp.id_pais = p.id
WHERE
    hp.fecha_fin IS NULL
    AND cp.id_pais = &v_id_pais_residencia -- <<< FILTRO APLICADO
ORDER BY
    j.id, p.id;

PROMPT
PROMPT [ACCION REQUERIDA - LISTA DE PRODUCTOS]
ACCEPT v_lista_productos CHAR PROMPT '>>> Escriba la LISTA de productos (Formato: ID:CANTIDAD, ID:CANTIDAD Ejemplo: 201:1, 101:2): '

PROMPT
PROMPT >>> Procesando VENTA Online para el Cliente ID &v_id_cliente...

DECLARE
    v_id_cl      NUMBER := &v_id_cliente;
    v_lista_prod VARCHAR2(4000) := '&v_lista_productos';
BEGIN
    sp_venta_online_txt(
        p_id_cliente      => v_id_cl,
        p_lista_productos => v_lista_prod
    );
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('>>> ERROR FATAL EN VENTA: ' || SQLERRM);
END;
/

PROMPT
PROMPT PROCESO DE VENTA COMPLETADO.
PROMPT

UNDEFINE v_id_cliente;
UNDEFINE v_lista_productos;