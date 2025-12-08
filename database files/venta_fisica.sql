CREATE SEQUENCE seq_descuento_lote
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE seq_factura_venta_tienda
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE seq_detalle_venta_tienda
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE TYPE juguetes_obj AS OBJECT (
    nombre varchar2(60),
    cantidad NUMBER(2),
    tipo_cliente varchar2(6)
);

CREATE OR REPLACE TYPE id_juguetes_obj AS OBJECT (
    id NUMBER(4),
    cantidad NUMBER(2),
    tipo_cliente varchar2(6)
);

CREATE OR REPLACE TYPE lotes_juguetes_cantidades AS OBJECT (
    id NUMBER (4),
    cantidad NUMBER(2),
    num_lote NUMBER (8),
)

CREATE OR REPLACE TYPE lista_juguetes IS TABLE OF juguetes_obj;
CREATE OR REPLACE TYPE lista_id_juguetes IS TABLE OF id_juguetes_obj;
CREATE OR REPLACE TYPE lista_para_detalle IS TABLE OF lotes_juguetes_cantidades;

---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA FÍSICA --
---------------------------------------------

CREATE OR REPLACE FUNCTION fn_fisica_buscar_cliente (primer_nombre IN varchar2(10), primer_apellido IN varchar2(10), documento_identidad IN NUMBER(9))
RETURN NUMBER(6) IS id_encontrado NUMBER(6);
BEGIN
    IF documento_identidad IS NOT NULL THEN
        BEGIN
            SELECT c.id_lego INTO id_encontrado
            FROM Clientes c
            WHERE c.documento_identidad = documento_identidad;
            RETURN id_encontrado;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;

    IF (primer_nombre IS NOT NULL) AND (primer_apellido IS NOT NULL) THEN
        BEGIN
            SELECT c.id_lego INTO id_encontrado
            FROM Clientes c
            WHERE c.primer_nombre = primer_nombre AND
            c.primer_apellido = primer_apellido;
            RETURN id_encontrado;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(-20001, 'Error: Existen múltiples clientes llamados ' || p_nombre || ' ' || p_apellido || '. Se requiere documento de identidad para diferenciar.');
        END;
    END IF;
    
    RETURN NULL;
END fn_fisica_buscar_cliente;

CREATE OR REPLACE FUNCTION fn_fisica_buscar_juguete (nombre_juguete IN varchar2(60))
RETURN NUMBER(4) IS id_juguete NUMBER(4);
BEGIN
    IF nombre_juguete IS NOT NULL THEN
        BEGIN
            SELECT j.id INTO id_juguete
            FROM Juguetes j
            WHERE j.nombre = nombre_juguete;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;

    RETURN NULL;
END fn_fisica_buscar_juguete;

CREATE OR REPLACE FUNCTION fn_fisica_buscar_tienda (nombre_tienda IN varchar2(50),nombre_ciudad IN varchar2(30),nombre_pais IN varchar2(30))
RETURN NUMBER(4) IS
    id_tienda NUMBER(4);
BEGIN
    IF (nombre_tienda IS NOT NULL) AND (nombre_ciudad IS NULL) AND (nombre_pais IS NULL) THEN
        BEGIN
            SELECT t.id INTO id_tienda
            FROM tiendas t
            WHERE t.nombre = nombre_tienda;

            RETURN id_tienda;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Error: Existen muchas tiendas llamadas: '||nombre_tienda||'. Especifique la ciudad y el país por favor');
        END;
    END IF;

    IF (nombre_tienda IS NULL) AND (nombre_ciudad IS NOT NULL) AND (nombre_pais IS NOT NULL) THEN
        BEGIN
            SELECT t.id INTO id_tienda
            FROM paises p, ciudades c, tiendas t
            WHERE p.nombre = nombre_pais AND
            c.nombre = nombre_ciudad AND
            p.id = c.id_pais_est AND
            c.id = t.id_ciudad AND
            c.id_estado = t.id_estado_ciu AND
            c.id_pais_est = t.id_pais_ciu

            SELECT p.id INTO id_pais
            FROM paises p
            WHERE p.nombre = nombre_pais;

            SELECT c.id_estado, c.id INTO id_estado, id_ciudad
            FROM ciudades c
            WHERE c.nombre = nombre_ciudad AND
            c.id_pais_est = id_pais;

            SELECT t.id INTO id_tienda
            FROM tiendas t
            WHERE t.id_ciudad = id_ciudad AND
            t.id_estado_ciu = id_estado AND
            t.id_pais_ciu = id_pais

            RETURN id_tienda;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(-20003, 'Error: Existen muchas tiendas en la ciudad: '||nombre_ciudad||'. Especifique el nombre de la tienda por favor');
        END;
    END IF;

    IF (nombre_tienda IS NOT NULL) AND (nombre_ciudad IS NOT NULL) AND (nombre_pais IS NOT NULL) THEN
        BEGIN
            SELECT t.id INTO id_tienda
            FROM paises p, ciudades c, tiendas t
            WHERE p.nombre = nombre_pais AND
            c.nombre = nombre_ciudad AND
            t.nombre = nombre_tienda AND
            p.id = c.id_pais_est AND
            c.id = t.id_ciudad AND
            c.id_estado = t.id_estado_ciu AND
            c.id_pais_est = t.id_pais_ciu

            RETURN id_tienda;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;

    RETURN NULL;

END fn_fisica_buscar_tienda;

CREATE OR REPLACE FUNCTION fn_fisica_seleccionar_stock (juguetes IN lista_id_juguetes, id_tienda IN NUMBER(4))
RETURN lista_para_detalle IS
CURSOR fila_lote (id_juguete_buscado NUMBER(4)) IS  SELECT i.num_lote, i.cantidad
                                                    FROM inventario_lotes i 
                                                    WHERE i.id_tienda = id_tienda AND 
                                                    i.id_juguete = id_juguete_buscado AND
                                                    i.cantidad > 0
                                                    ORDER BY num_lote ASC;
    lote fila_lote%rowtype;
    cantidad_pendiente NUMBER(3);
    cantidad_tomar     NUMBER(3);
    cantidad_hoy NUMBER(3);
    fecha_hoy date;
    lista_respuesta lista_para_detalle := lista_para_detalle();
BEGIN
    fecha_hoy := TRUNC(SYSDATE);
    FOR i IN 1 .. juguetes.COUNT 
    LOOP
        cantidad_pendiente := juguetes(i).cantidad;
        OPEN fila_lote (juguetes(i).id);
        LOOP
            FETCH fila_lote INTO lote;
            EXIT WHEN fila_lote%NOTFOUND;
            EXIT WHEN cantidad_pendiente = 0;

            SELECT NVL(SUM(d.cantidad), 0) INTO cantidad_hoy
            FROM descuento_lotes d
            WHERE d.num_lote = lote.num_lote AND
            d.id_juguete_inv = juguetes(i).id AND
            d.id_tienda_inv = id_tienda AND
            TRUNC(d.fecha) = fecha_hoy;

            IF (lote.cantidad - cantidad_hoy > 0) THEN
                BEGIN
                    cantidad_tomar := LEAST (lote.cantidad - cantidad_hoy, cantidad_pendiente);
                    lista_respuesta.EXTEND;
                    lista_respuesta(lista_respuesta.LAST) := lotes_juguetes_cantidades(juguetes(i).id, cantidad_tomar, lote.num_lote);
                    INSERT INTO descuento_lotes VALUES (juguetes(i).id, id_tienda, lote.num_lote, seq_descuento_lote.nextval, SYSDATE, cantidad_tomar);

                    cantidad_pendiente := cantidad_pendiente - cantidad_tomar;
                END;
            END IF;
        END LOOP;

        CLOSE fila_lote;
        IF cantidad_pendiente > 0 THEN
            IF fila_lote%ISOPEN THEN CLOSE fila_lote; END IF;
            RAISE_APPLICATION_ERROR(-20004, 
                'Stock insuficiente para el juguete ID ' || juguetes(i).id || 
                '. Se requerían ' || juguetes(i).cantidad || 
                ' pero solo se encontraron ' || (juguetes(i).cantidad - cantidad_pendiente));
        END IF;
    END LOOP; 

    RETURN lista_respuesta;
EXCEPTION
    WHEN OTHERS THEN
        IF fila_lote%ISOPEN THEN 
            CLOSE fila_lote; 
        END IF;
        RAISE;
END fn_fisica_seleccionar_stock;
/

CREATE OR REPLACE PROCEDURE sp_batch_cierre_inventario IS
CURSOR resumen_diario IS
    SELECT  d.id_tienda_inv, 
            d.id_juguete_inv, 
            d.num_lote, 
            SUM(d.cantidad) as total_a_descontar
    FROM descuento_lotes d
    WHERE TRUNC(d.fecha) = TRUNC(SYSDATE)
    GROUP BY d.id_tienda_inv, d.id_juguete_inv, d.num_lote;
    
total_procesado NUMBER (5) := 0;
BEGIN
    FOR r IN resumen_diario LOOP
        
        UPDATE inventario_lotes i
        SET i.cantidad = i.cantidad - r.total_a_descontar
        WHERE i.id_tienda = r.id_tienda_inv AND 
        i.id_juguete = r.id_juguete_inv 
        AND i.num_lote = r.num_lote;

        total_procesado := total_procesado + 1;
        
    END LOOP;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Cierre diario completado. Lotes actualizados: ' || total_procesado);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error crítico en cierre diario: ' || SQLERRM);
END sp_batch_cierre_inventario;
/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_CIERRE_INVENTARIO_DIARIO',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN sp_batch_cierre_inventario; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=22; BYMINUTE=00; BYSECOND=00',
        enabled         => TRUE
    );
END;
/

/*Si quiero modificar el job:

BEGIN
    DBMS_SCHEDULER.SET_ATTRIBUTE (
        name      => 'JOB_CIERRE_INVENTARIO_DIARIO',
        attribute => 'repeat_interval',
        value     => 'FREQ=DAILY; BYHOUR=02; BYMINUTE=00; BYSECOND=00'
    );
END;
*/

CREATE OR REPLACE PROCEDURE sp_fisica_agregar_factura (juguetes IN lista_juguetes, nombre_tienda IN varchar2(50), nombre_ciudad IN varchar2(30), 
nombre_pais varchar2(30), primer_nombre_cliente IN varchar2(10), primer_apellido_cliente IN varchar2(10), documento_identidad IN NUMBER (9)) IS
    id_juguetes lista_id_juguetes := lista_id_juguetes();
    id_temporal_juguete NUMBER(4);
    id_tienda NUMBER(4);
    id_cliente NUMBER(6);
    cantidad_disponible NUMBER(4);
    total NUMBER (6,2);
    id_factura_actual NUMBER(7);
    lista_lotes lista_para_detalle := lista_para_detalle ();
BEGIN
    id_tienda := fn_fisica_buscar_tienda (nombre_tienda, nombre_ciudad, nombre_pais);
    IF id_tienda IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error: La tienda "' || nombre_tienda || '" no existe o no se encuentra en la ubicación indicada.');
    END IF;

    id_cliente := fn_fisica_buscar_cliente (primer_nombre_cliente, primer_apellido_cliente, documento_identidad);
    IF id_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Error: El cliente ' || primer_nombre_cliente || ' ' || primer_apellido_cliente || ' no está registrado.');
    END IF;

    IF juguetes IS NULL OR juguetes.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error: La lista de juguetes está vacía.');
    END IF;

    FOR i IN 1 .. juguetes.COUNT
    LOOP
        id_temporal_juguete := fn_fisica_buscar_juguete(juguetes(i).nombre);
        IF id_temporal_juguete IS NULL THEN
            RAISE_APPLICATION_ERROR(-20013, 'Error: El juguete "' || juguetes(i).nombre || '" no existe en el catálogo.');
        END IF;
        id_juguetes.EXTEND;
        IF  id_temporal_juguete IS NOT NULL THEN
            id_juguetes(i) := id_juguetes_obj(id_temporal_juguete, juguetes(i).cantidad, juguetes(i).tipo_cliente);
        END IF;
    END LOOP;

    INSERT INTO factura_ventas_tienda VALUES (id_tienda, seq_factura_venta_tienda.nextval, SYSDATE, id_cliente, NULL)
    RETURNING numeroventa INTO id_factura_actual;
    lista_lotes := fn_fisica_seleccionar_stock(id_juguetes, id_tienda);
    FOR j IN 1 .. id_juguetes.COUNT
    LOOP
        FOR k in 1 .. lista_lotes.COUNT
        LOOP
            IF lista_lotes(k).id = id_juguetes(j).id THEN
                BEGIN
                    INSERT INTO detalle_factura_ventas_tienda VALUES (id_tienda, id_factura_actual, seq_detalle_venta_tienda.nextval, 
                    lista_lotes(k).cantidad, id_juguete(j).tipo_cliente, id_juguetes(j).id, id_tienda, lista_lotes(k).num_lote);
                END;
            END IF;
        END LOOP;
    END LOOP;
    UPDATE factura_ventas_tienda f
    SET total = (
        SELECT NVL(SUM(d.cantidad * h.precio), 0)
        FROM historico_precios h, detalle_factura_ventas_tienda d
        WHERE h.fecha_fin IS NULL AND
        h.id_juguete = d.id_juguete_inv AND 
        d.numeroventa = f.numeroventa)
    WHERE f.numeroventa = id_factura_actual AND
    f.id_lego_cliente = id_cliente AND
    f.id_tienda = id_tienda;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Fallo en Venta Física: ' || SQLERRM);
END sp_fisica_agregar_factura;

----------------------------
-- TRIGGERS VENTA FÍSICA --
----------------------------
/*No usar new u old en consultas*/
CREATE OR REPLACE TRIGGER trg_validar_horario
BEFORE INSERT ON factura_ventas_tienda
FOR EACH ROW
DECLARE
    dia_semana      NUMBER(1);
    fecha_venta_norm DATE; 
    apertura        DATE;
    cierre          DATE;
    tienda          NUMBER(4) := :NEW.id_tienda;
BEGIN
    dia_semana := TO_NUMBER(TO_CHAR(:NEW.fecha_venta, 'D'));
    fecha_venta_norm := TO_DATE('01/01/2000', 'DD/MM/YYYY') + (:NEW.fecha_venta - TRUNC(:NEW.fecha_venta));
    BEGIN
        SELECT hora_inicio, hora_fin
        INTO apertura, cierre
        FROM horarios
        WHERE id_tienda = AND
        numerodia = dia_semana;

        IF fecha_venta_norm < apertura OR fecha_venta_norm > cierre THEN
            RAISE_APPLICATION_ERROR(-20050, 'La tienda está cerrada. Intente dentro del horario establecido.');
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20051, 'La tienda no abre este día de la semana.');
    END;
END;
/

CREATE OR REPLACE TRIGGER trg_prohibir_eliminar_factura
BEFORE DELETE ON factura_ventas_tienda
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20061, 
        'Error de Auditoría: Las facturas de tienda no pueden ser eliminadas del sistema.');
END;
/