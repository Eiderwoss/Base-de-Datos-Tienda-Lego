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
BEGIN
    IF UPPER(p_moneda_destino) = 'EURO' THEN RETURN ROUND(p_monto_dolares * 0.92, 2);
    ELSIF UPPER(p_moneda_destino) LIKE 'CORONA%' THEN RETURN ROUND(p_monto_dolares * 6.85, 2);
    ELSE RETURN p_monto_dolares;
    END IF;
END;
/

--------------------------
-- TRIGGERS GENERALES --
--------------------------

--5. Trigger de control de precios
CREATE OR REPLACE TRIGGER trg_control_precios
BEFORE INSERT ON Historico_Precios
FOR EACH ROW
DECLARE
    v_id_juguete NUMBER;
BEGIN
    v_id_juguete := :NEW.id_juguete;

    UPDATE Historico_Precios
    SET fecha_fin = SYSDATE
    WHERE id_juguete = v_id_juguete AND
    fecha_fin IS NULL;
END;
/

CREATE OR REPLACE TRIGGER trg_validar_edad_cliente
BEFORE INSERT OR UPDATE ON clientes
FOR EACH ROW
DECLARE
    edad NUMBER;
BEGIN
    edad := fn_calcular_edad(:NEW.fecha_nacimiento);

    IF edad <= 20 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Error: El cliente debe ser mayor de 20 años. Edad actual: ' || edad);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_validar_lego_menores
BEFORE INSERT OR UPDATE ON fan_lego_menores
FOR EACH ROW
DECLARE
    edad NUMBER;
BEGIN
    edad := fn_calcular_edad(:NEW.fecha_nacimiento);
    IF (edad < 12) OR (edad > 20) THEN
        RAISE_APPLICATION_ERROR(-20030, 'Error: El fan debe tener entre 12 y 20 años. Edad actual: ' || edad);
    END IF;
    IF (edad < 18) AND (:NEW.id_lego_cliente IS NULL)THEN
        RAISE_APPLICATION_ERROR(-20040, 'Error: El fan debe tener un representante obligatoriamente.');
    END IF;
    IF (edad >= 18) AND (:NEW.id_lego_cliente IS NOT NULL)THEN
        RAISE_APPLICATION_ERROR(-20040, 'Error: El fan es mayor de edad, no debe tener un representante.');
    END IF;
END;
/

-------------
-- VISTAS --
-------------

-- Vista de todo el catálogo
CREATE OR REPLACE VIEW catalogo_productos_pais AS
SELECT 
    p.nombre "Pais del Catalogo",
    j.nombre "Nombre juguete",
    j.descripcion Descripcion ,
    j.rango_edad "Rango de Edad",
    j.numero_piezas "Numero de Piezas",
    h.precio Precio,
    c.limite  "Limite Por Cliente"
FROM 
    paises p,
    juguetes j,
    catalogo_paises c,
    historico_precios h
WHERE
    p.id = c.id_pais
    AND j.id = c.id_juguete
    AND j.id = h.id_juguete
    AND h.fecha_fin IS NULL;

-- Vista de disponibilidad de los tours
CREATE OR REPLACE VIEW disponibilidad_tours AS
SELECT 
    t.fecha "Fecha del Tour",
    t.costo Costo,
    (t.cupos_totales - COUNT(d.id)) AS "Cupos disponibles",
    t.cupos_totales "Capacidad Máxima"
FROM 
    tours t, 
    detalle_inscripciones d
WHERE 
    t.fecha = d.fecha_tour_ins (+) 
GROUP BY 
    t.fecha, 
    t.costo, 
    t.cupos_totales;