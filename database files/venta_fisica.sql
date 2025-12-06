---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA FÍSICA --
---------------------------------------------
CREATE OR REPLACE FUNCTION buscar_cliente (primer_nombre IN varchar2(10), primer_apellido IN varchar2(10), documento_identidad IN number(9))
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
END buscar_cliente;

CREATE OR REPLACE FUNCTION buscar_juguete (nombre_juguete IN varchar2(60))
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
END buscar_juguete;

-- Capaz deba agregarle el país tmb
CREATE OR REPLACE FUNCTION buscar_tienda (nombre_tienda IN varchar2(50),nombre_ciudad IN varchar2(30))
RETURN number(4) IS
    id_tienda number(4);
    id_ciudad number(5);
    id_pais   number(3);
    id_estado number(5);
BEGIN
    IF (nombre_tienda IS NOT NULL) AND (nombre_ciudad IS NULL) THEN
        BEGIN
            SELECT t.id INTO id_tienda
            FROM Tienda t
            WHERE t.nombre = nombre_ciudad
            RETURN id_tienda
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
            WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(-20002, 'Error: Existen muchas tiendas llamadas: '||nombre_tienda||'. Especifique la ciudad por favor');
        END;
    END IF;

    IF (nombre_tienda IS NULL) AND (nombre_ciudad IS NOT NULL) THEN
        BEGIN
            SELECT c.id_pais_est INTO id_pais, c.id_estado INTO id_estado, c.id INTO id_ciudad
            FROM Ciudad c
            WHERE c.nombre = nombre_ciudad;

            SELECT t.id INTO id_tienda
            FROM Tienda t
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

    IF (nombre_tienda IS NOT NULL) AND (nombre_ciudad IS NOT NULL) THEN
        BEGIN
            SELECT c.id_pais_est INTO id_pais, c.id_estado INTO id_estado, c.id INTO id_ciudad
            FROM Ciudad c
            WHERE c.nombre = nombre_ciudad;

            SELECT t.id INTO id_tienda
            FROM Tienda t
            WHERE t.nombre = nombre_ciudad AND 
            t.id_ciudad = id_ciudad AND
            t.id_estado_ciu = id_estado AND
            t.id_pais_ciu = id_pais

            RETURN id_tienda;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;
    END IF;

    RETURN NULL;

END buscar_tienda;

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

