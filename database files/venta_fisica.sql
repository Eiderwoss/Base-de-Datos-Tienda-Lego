---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA FÍSICA --
---------------------------------------------



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

--9. Trigger Control de lotes
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_control_lotes
BEFORE INSERT ON Inventario_Lotes
FOR EACH ROW
BEGIN
    UPDATE Inventario_Lotes
    SET fecha_fin = SYSDATE
    WHERE id_tienda = :NEW.id_tienda
      AND id_juguete = :NEW.id_juguete
      AND fecha_fin IS NULL;
      
    :NEW.fecha_fin := NULL; 
END;
/

-- 8. Trigger Validar catalogo
-- Creo que Lúcia dijo que esto le valía verga para las tiendas físicas
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_validar_catalogo_pais
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
/