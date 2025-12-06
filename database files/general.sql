------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES GENERALES --
------------------------------------------

-- 3. Funcion para validar edad
CREATE OR REPLACE FUNCTION fn_calcular_edad (p_fecha_nac DATE) 
RETURN NUMBER IS
BEGIN
    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, p_fecha_nac) / 12);
END;
/

-- 4.    Funcion para conversion de las moendas
CREATE OR REPLACE FUNCTION fn_convertir_moneda (
    p_monto_dolares NUMBER, 
    p_moneda_destino VARCHAR2
) RETURN NUMBER IS
    v_resultado NUMBER;
BEGIN
    IF UPPER(p_moneda_destino) = 'EURO' THEN
        v_resultado := p_monto_dolares * 0.92; -- 1 USD = 0.92 EUR
    ELSIF UPPER(p_moneda_destino) LIKE 'CORONA%' THEN
        v_resultado := p_monto_dolares * 6.85; -- 1 USD = 6.85 DKK
    ELSE
        v_resultado := p_monto_dolares;
    END IF;
    
    RETURN ROUND(v_resultado, 2);
END;
/

--------------------------
-- TRIGGERS GENERALES --
--------------------------

--5. Trigger de control de precios
-- No usar eventos cómo new u old en consultas.
CREATE OR REPLACE TRIGGER trg_control_precios
BEFORE INSERT ON Historico_Precios
FOR EACH ROW
DECLARE
    v_id_juguete NUMBER;
BEGIN
    v_id_juguete := :NEW.id_juguete;

    UPDATE Historico_Precios
    SET fecha_fin = SYSDATE
    WHERE id_juguete = v_id_juguete
      AND fecha_fin IS NULL;

END;
/
