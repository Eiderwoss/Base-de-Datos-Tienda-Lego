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
    cantidad number(2),
    tipo_cliente varchar2(6)
);

CREATE OR REPLACE TYPE id_juguetes_obj AS OBJECT (
    id number(4),
    cantidad number(2),
    tipo_cliente varchar2(6)
);

CREATE OR REPLACE TYPE lotes_juguetes_cantidades AS OBJECT (
    id number (4),
    cantidad number(2),
    num_lote number (8),
)

CREATE OR REPLACE TYPE lista_juguetes IS TABLE OF juguetes_obj;
CREATE OR REPLACE TYPE lista_id_juguetes IS TABLE OF id_juguetes_obj;
CREATE OR REPLACE TYPE lista_para_detalle IS TABLE OF lotes_juguetes_cantidades;

---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA FÍSICA --
---------------------------------------------

CREATE OR REPLACE FUNCTION fn_fisica_buscar_cliente (primer_nombre IN varchar2(10), primer_apellido IN varchar2(10), documento_identidad IN number(9))
RETURN number(6) IS id_encontrado number(6);
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
RETURN number(4) IS id_juguete number(4);
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
RETURN number(4) IS
    id_tienda number(4);
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

CREATE OR REPLACE FUNCTION fn_fisica_descontar_stock (juguetes IN lista_id_juguetes, id_tienda IN number(4))
RETURN lista_para_detalle IS
CURSOR fila_lote (id_juguete_buscado number(4)) IS  SELECT i.num_lote, i.cantidad
                                                    FROM inventario_lotes i 
                                                    WHERE i.id_tienda = id_tienda AND 
                                                    i.id_juguete = id_juguete_buscado AND
                                                    i.cantidad > 0
                                                    ORDER BY num_lote ASC;
    lote fila_lote%rowtype;
    cantidad_pendiente NUMBER;
    cantidad_tomar     NUMBER;
    lista_respuesta lista_para_detalle := lista_para_detalle();
BEGIN
    FOR i IN 1 .. juguetes.COUNT 
    LOOP
        cantidad_pendiente := juguetes(i).cantidad;
        OPEN fila_lote (juguetes(i).id);
        LOOP
            FETCH fila_lote INTO lote;
            EXIT WHEN fila_lote%NOTFOUND;
            EXIT WHEN cantidad_pendiente = 0;
            
            cantidad_tomar := LEAST (lote.cantidad,cantidad_pendiente);
            lista_respuesta.EXTEND;
            lista_respuesta(i) := lotes_juguetes_cantidades(juguetes(i).id, cantidad_tomar, lote.num_lote);
            INSERT INTO descuento_lotes VALUES (juguetes(i).id, id_tienda, lote.num_lote, seq_descuento_lote.nextval, SYSDATE, cantidad_tomar);
            
            /*Trigger para validar cantidades negativas*/
            UPDATE inventario_lotes
            SET cantidad = cantidad - cantidad_tomar
            WHERE num_lote = lote.num_lote;

            cantidad_pendiente := cantidad_pendiente - cantidad_tomar;
        END LOOP;

        CLOSE fila_lote;
        IF cantidad_pendiente > 0 THEN
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
END pr_fisica_descontar_stock;
/

CREATE OR REPLACE PROCEDURE pr_fisica_agregar_factura (juguetes IN lista_juguetes, nombre_tienda IN varchar2(50), nombre_ciudad IN varchar2(30), 
nombre_pais varchar2(30), primer_nombre_cliente IN varchar2(10), primer_apellido_cliente IN varchar2(10) documento_identidad IN number (9)) IS
    id_juguetes lista_id_juguetes := lista_id_juguetes();
    id_temporal_juguete number(4);
    id_tienda number(4);
    id_cliente number(6);
    cantidad_disponible number(4);
    total number (6,2);
    id_factura_actual number(7);
    lista_lotes lotes_juguetes_cantidades: = lotes_juguetes_cantidades ();
    precio_total number (6, 2);
BEGIN
    id_tienda := fn_fisica_buscar_tienda (nombre_tienda, nombre_ciudad, nombre_pais);
    id_cliente := fn_fisica_buscar_cliente (primer_nombre_cliente, primer_apellido_cliente, documento_identidad);
    IF (id_tienda IS NOT NULL) AND (id_cliente IS NOT NULL) AND (juguetes IS NOT NULL)THEN
        BEGIN
            FOR i IN 1 .. juguetes.COUNT
            LOOP
                id_juguetes.EXTEND;
                id_temporal_juguete := fn_fisica_buscar_juguete(juguetes(i).nombre);
                IF  id_temporal_juguete IS NOT NULL THEN
                    BEGIN
                        SELECT SUM(i.cantidad) INTO cantidad_disponible;
                        FROM inventario_lotes i
                        WHERE i.id_tienda = id_tienda AND
                        i.id_juguete = id_temporal_juguete;
                        
                        IF cantidad_disponible > 0 THEN
                            BEGIN
                                id_juguetes(i) = id_juguetes_obj(id_temporal_juguete, juguetes(i).cantidad, juguetes(i).tipo_cliente);
                            END;
                        END IF;
                    END;
                END IF;
            END LOOP;

            INSERT INTO factura_ventas_tienda VALUES (id_tienda, seq_factura_venta_tienda.nextval, SYSDATE, id_cliente, NULL);
            id_factura_actual := seq_factura_venta_tienda.currval;
            lista_lotes = fn_fisica_descontar_stock(id_juguetes, id_tienda);
            FOR j IN 1 .. id_juguetes.COUNT
            LOOP
                FOR k in 1 .. lista_lotes.COUNT
                LOOP
                    IF lista_lotes(k).id = id_juguetes(j).id THEN
                        BEGIN
                            INSERT INTO detalle_factura_ventas_tienda VALUES (id_tienda, id_factura_actual, seq_detalle_venta_tienda.nextval, 
                            lista_lotes(k).cantidad, id_juguete(j).tipo_cliente, id_juguete(j).id, id_tienda, lista_lotes(k).num_lote);
                        END;
                    END IF;
                END LOOP;

                SELECT h.precio INTO precio_total
                FROM historico_precios h
                WHERE h.id_juguete = id_juguetes(j).id AND
                h.fecha_fin = NULL;

                precio_total := precio_total * id_juguetes(j).cantidad;
            EXCEPTION
            END LOOP;
            UPDATE factura_ventas_tienda f 
            SET total = precio_total 
            WHERE f.numeroventa = id_factura_actual AND f.id_lego_cliente = id_cliente AND f.id_tienda = id_tienda;
        END;
    END IF;
EXCEPTION
END;

----------------------------
-- TRIGGERS VENTA FÍSICA --
----------------------------

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

-- 8. Trigger Validar catalogo
-- Creo que Lúcia dijo que esto le valía verga para las tiendas físicas
-- No usar eventos cómo new u old en consultas.
/*CREATE OR REPLACE TRIGGER trg_validar_catalogo_pais
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
/ */