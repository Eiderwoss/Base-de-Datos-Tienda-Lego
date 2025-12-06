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

    IF primer_nombre IS NOT NULL AND primer_apellido IS NOT NULL THEN
        BEGIN
            SELECT c.id_lego INTO id_encontrado
            FROM Clientes c
            WHERE c.primer_nombre = primer_nombre AND
            c.primer_apellido = primer_apellido;
            RETURN id_encontrado;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN NULL;
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

