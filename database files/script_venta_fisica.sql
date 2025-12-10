SET SERVEROUTPUT ON;
SET VERIFY OFF;

PROMPT ==============================================================;
PROMPT               CATALOGO DE TIENDAS DISPONIBLES;
PROMPT ==============================================================;
SELECT t.id AS "ID", t.nombre AS "Nombre Tienda", c.nombre AS "Ciudad", p.nombre AS "Pais"
FROM Paises p, Ciudades c,  Tiendas t   
WHERE p.id = c.id_pais_est AND c.id = t.id_ciudad AND c.id_estado = t.id_estado_ciu AND c.id_pais_est = t.id_pais_ciu
ORDER BY t.id;

ACCEPT v_tienda_input DEFAULT 'LEGO Store Toulon' PROMPT '1. Nombre Tienda: ';
ACCEPT v_ciudad_input PROMPT '2. Ciudad: ';
ACCEPT v_pais_input   PROMPT '3. Pais: ';
ACCEPT v_doc_cliente  PROMPT '4. Doc Identidad Cliente: ';
ACCEPT v_nombre_cli   PROMPT '5. Nombre Cliente (Opcional): ';
ACCEPT v_apellido_cli PROMPT '6. Apellido Cliente (Opcional): ';

PROMPT ==============================================================;
PROMPT               CATALOGO RAPIDO;
PROMPT ==============================================================;
SELECT DISTINCT j.nombre, j.rango_precio
FROM Paises p, Ciudades c, Tiendas t, Inventario_lotes i, Juguetes j
WHERE p.id = c.id_pais_est AND c.id = t.id_ciudad AND c.id_estado = t.id_estado_ciu AND c.id_pais_est = t.id_pais_ciu AND 
t.id = i.id_tienda AND i.id_juguete = j.id AND p.nombre = '&v_pais_input' AND c.nombre = '&v_ciudad_input' AND 
t.nombre = '&v_tienda_input'AND i.cantidad > 0
ORDER BY j.nombre;


PROMPT ;
PROMPT INSTRUCCIONES DE FORMATO:
PROMPT Ingrese los juguetes separados por PUNTO Y COMA (;).
PROMPT Los datos del juguete se separan por COMA (,).
PROMPT Orden: NOMBRE JUGUETE , CANTIDAD , TIPO CLIENTE
PROMPT ;
PROMPT Ejemplo para 2 juguetes:
PROMPT THE CREEPER,2,ADULTO;THE MIGHTY BOWSER,1,MENOR
PROMPT ==============================================================;
PROMPT ;
ACCEPT v_cadena_raw   PROMPT '7. LISTA DE JUGUETES (Formato: Nom,Cant,Tipo;...): ';

DECLARE
    -- Inputs
    p_tienda  VARCHAR2(100) := '&v_tienda_input';
    p_ciudad  VARCHAR2(100) := '&v_ciudad_input';
    p_pais    VARCHAR2(100) := '&v_pais_input';
    p_doc     NUMBER        := TO_NUMBER('&v_doc_cliente');
    p_nom     VARCHAR2(100) := '&v_nombre_cli';
    p_ape     VARCHAR2(100) := '&v_apellido_cli';
    
    -- Variables para el Parsing
    v_texto_completo VARCHAR2(32000) := '&v_cadena_raw';
    v_bloque_actual  VARCHAR2(4000);
    
    v_pos_punto_coma NUMBER; -- Posición del separador de juguetes (;)
    v_pos_coma1      NUMBER; -- Posición primera coma (,)
    v_pos_coma2      NUMBER; -- Posición segunda coma (,)
    
    -- Atributos extraídos
    v_extr_nombre    VARCHAR2(100);
    v_extr_cant      NUMBER;
    v_extr_tipo      VARCHAR2(20);
    
    -- Lista final
    v_lista_juguetes lista_juguetes := lista_juguetes();
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Analizando cadena de entrada...');

    -- Limpiamos espacios y aseguramos que termine en ; para facilitar el bucle
    v_texto_completo := TRIM(v_texto_completo);
    IF SUBSTR(v_texto_completo, -1) != ';' THEN
        v_texto_completo := v_texto_completo || ';';
    END IF;

    -- BUCLE PRINCIPAL (Itera por Juguete buscando ';')
    LOOP
        EXIT WHEN v_texto_completo IS NULL OR LENGTH(v_texto_completo) = 0;
        v_pos_punto_coma := INSTR(v_texto_completo, ';');
        EXIT WHEN v_pos_punto_coma = 0;

        -- 1. Extraemos el bloque de un solo juguete (ej: "THE CREEPER,2,ADULTO")
        v_bloque_actual := TRIM(SUBSTR(v_texto_completo, 1, v_pos_punto_coma - 1));
        
        IF LENGTH(v_bloque_actual) > 0 THEN
            -- 2. Buscamos las comas internas
            v_pos_coma1 := INSTR(v_bloque_actual, ',');
            v_pos_coma2 := INSTR(v_bloque_actual, ',', v_pos_coma1 + 1);
            
            IF v_pos_coma1 > 0 AND v_pos_coma2 > 0 THEN
                -- 3. Cortamos el string en 3 pedazos
                v_extr_nombre := TRIM(SUBSTR(v_bloque_actual, 1, v_pos_coma1 - 1));
                
                v_extr_cant   := TO_NUMBER(TRIM(SUBSTR(v_bloque_actual, 
                                                       v_pos_coma1 + 1, 
                                                       v_pos_coma2 - v_pos_coma1 - 1)));
                                                       
                v_extr_tipo   := TRIM(SUBSTR(v_bloque_actual, v_pos_coma2 + 1));
                
                -- 4. Agregamos a la lista de objetos
                v_lista_juguetes.EXTEND;
                v_lista_juguetes(v_lista_juguetes.LAST) := juguetes_obj(
                    v_extr_nombre, 
                    v_extr_cant, 
                    UPPER(v_extr_tipo)
                );
                
                DBMS_OUTPUT.PUT_LINE('   -> Procesado: ' || v_extr_nombre || ' (x' || v_extr_cant || ') - ' || v_extr_tipo);
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠️ ADVERTENCIA: Formato inválido en bloque "' || v_bloque_actual || '". Se ignoró.');
            END IF;
        END IF;

        -- 5. Cortamos lo ya procesado para seguir con el resto
        v_texto_completo := SUBSTR(v_texto_completo, v_pos_punto_coma + 1);
    END LOOP;

    -- VALIDACION: Si la lista está vacía, no llamamos al procedimiento
    IF v_lista_juguetes.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Llamando al procedimiento de venta...');
        
        sp_fisica_agregar_factura(
            juguetes                => v_lista_juguetes,
            nombre_tienda           => p_tienda,
            nombre_ciudad           => p_ciudad,
            nombre_pais             => p_pais,
            primer_nombre_cliente   => p_nom,
            primer_apellido_cliente => p_ape,
            documento_identidad     => p_doc
        );

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✅ VENTA FINALIZADA CON ÉXITO.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Error: No se detectaron juguetes válidos en la entrada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ ERROR CRÍTICO: ' || SQLERRM);
END;
/
