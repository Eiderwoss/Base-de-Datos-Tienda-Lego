---------------------------------------------
-- PROCEDIMIENTOS/FUNCIONES VENTA ONLINE --
---------------------------------------------

--10. Funcion de otorgar puntos
CREATE OR REPLACE FUNCTION fn_calcular_puntos (p_monto_total NUMBER) 
RETURN NUMBER IS
    v_puntos NUMBER := 0;
BEGIN
    -- Rango A: Menos de 10
    IF p_monto_total < 10 THEN
        v_puntos := 5;
        
    -- Rango B: Entre 10 y 70
    ELSIF p_monto_total >= 10 AND p_monto_total <= 70 THEN
        v_puntos := 20;
        
    -- Rango C: Más de 70 hasta 200
    ELSIF p_monto_total > 70 AND p_monto_total <= 200 THEN
        v_puntos := 50;
        
    -- Rango D: Más de 200 (El documento dice "+ de 200")
    ELSE
        v_puntos := 200;
    END IF;
    
    RETURN v_puntos;
END;
/

-----------------------------
-- TRIGGERS VENTA ONLINE --
-----------------------------