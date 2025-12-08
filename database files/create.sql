CREATE TABLE paises (
    id            NUMBER(3)
        CONSTRAINT pk_paises PRIMARY KEY,
    nombre        VARCHAR2(30) NOT NULL UNIQUE,
    continente    VARCHAR2(8) NOT NULL,
    nacionalidad  VARCHAR2(30) NOT NULL,
    union_europea CHAR(2),
    CONSTRAINT ck_union_europea
        CHECK ( union_europea IN ( 'SI' )
                OR union_europea IS NULL ),
    CONSTRAINT ck_continente
        CHECK ( continente IN ( 'AMERICA', 'EUROPA', 'AFRICA', 'ASIA', 'OCEANIA' ) )
);

CREATE TABLE estados (
    id_pais NUMBER(3) NOT NULL,
    id      NUMBER(5) NOT NULL,
    nombre  VARCHAR2(30) NOT NULL,
    CONSTRAINT fk_estados_paises FOREIGN KEY ( id_pais )
        REFERENCES paises ( id ),
    CONSTRAINT pk_estados PRIMARY KEY ( id_pais,
                                        id )
);

CREATE TABLE ciudades (
    id_pais_est NUMBER(3) NOT NULL,
    id_estado   NUMBER(5) NOT NULL,
    id          NUMBER(5) NOT NULL,
    nombre      VARCHAR2(30) NOT NULL,
    CONSTRAINT fk_ciudades_estados
        FOREIGN KEY ( id_pais_est,
                      id_estado )
            REFERENCES estados ( id_pais,
                                 id ),
    CONSTRAINT pk_ciudades PRIMARY KEY ( id_pais_est,
                                         id_estado,
                                         id )
);

CREATE TABLE tiendas (
    id            NUMBER(4)
        CONSTRAINT pk_tiendas PRIMARY KEY,
    nombre        VARCHAR2(50) NOT NULL,
    direccion     VARCHAR2(120) NOT NULL,
    id_pais_ciu   NUMBER(3) NOT NULL,
    id_estado_ciu NUMBER(5) NOT NULL,
    id_ciudad     NUMBER(5) NOT NULL,
    CONSTRAINT fk_tiendas_ciudades
        FOREIGN KEY ( id_pais_ciu,
                      id_estado_ciu,
                      id_ciudad )
            REFERENCES ciudades ( id_pais_est,
                                  id_estado,
                                  id )
);

CREATE TABLE telefonos (
    id_tienda NUMBER(4) NOT NULL,
    id        NUMBER(4) NOT NULL,
    cod_area  NUMBER(3) NOT NULL,
    cod_pais  NUMBER(3) NOT NULL,
    numero    NUMBER(10) NOT NULL,
    CONSTRAINT fk_telefonos_tiendas FOREIGN KEY ( id_tienda )
        REFERENCES tiendas ( id ),
    CONSTRAINT pk_telefonos PRIMARY KEY ( id_tienda,
                                          id ),
    -- Asegura que la misma tienda no tenga el mismo número duplicado
    CONSTRAINT uq_telefono UNIQUE ( id_tienda,
                                    cod_area,
                                    cod_pais,
                                    numero )
);

/*El formateo de las horas en un trigger? Si, al hacer un insert se formatea*/
/*Faltan reglas de negocio respecto a numerodia en triggers*/
-- CHECK hora_fin siempre es > a hora_inicio
CREATE TABLE horarios (
    id_tienda   NUMBER(4) NOT NULL,
    numerodia   NUMBER(1) NOT NULL,
    hora_inicio DATE NOT NULL,
    hora_fin    DATE NOT NULL,
    CONSTRAINT fk_horarios_tiendas FOREIGN KEY ( id_tienda )
        REFERENCES tiendas ( id ),
    CONSTRAINT pk_horarios PRIMARY KEY ( id_tienda,
                                         numerodia )
);

/*Falta Regla de negocio de >= 21*/
/*Faltan el resto de reglas de negocio con triggers/programas*/
/*¿El pasaporte es tipo varchar2? ¿Cuántos caracteres debería tomar?*/
CREATE TABLE clientes (
    id_lego                     NUMBER(6)
        CONSTRAINT pk_clientes PRIMARY KEY,
    primer_nombre               VARCHAR2(10) NOT NULL,
    primer_apellido             VARCHAR2(10) NOT NULL,
    segundo_apellido            VARCHAR2(10) NOT NULL,
    fecha_nacimiento            DATE NOT NULL,
    documento_identidad         NUMBER(9) NOT NULL,
    id_pais_nac                 NUMBER(3) NOT NULL,
    id_pais_res                 NUMBER(3) NOT NULL,
    segundo_nombre              VARCHAR2(10),
    direccion                   VARCHAR2(120),
    numero_pasaporte            VARCHAR(16),
    fecha_vencimiento_pasaporte DATE,
    CONSTRAINT fk_pais_nac FOREIGN KEY ( id_pais_nac )
        REFERENCES paises ( id ),
    CONSTRAINT fk_pais_res FOREIGN KEY ( id_pais_res )
        REFERENCES paises ( id )
);

/*Faltan los constrains de FK*/
/*Regla de negocio de fans entre 12-20 y que si son mayores a 18 no tienen representante*/
/*Faltan el resto de reglas de negocio con triggers/programas*/
CREATE TABLE fan_lego_menores (
    id_lego                     NUMBER(6)
        CONSTRAINT pk_fan_lego_menores PRIMARY KEY,
    primer_nombre               VARCHAR2(10) NOT NULL,
    primer_apellido             VARCHAR2(10) NOT NULL,
    segundo_apellido            VARCHAR2(10) NOT NULL,
    fecha_nacimiento            DATE NOT NULL,
    id_pais                     NUMBER(3) NOT NULL,
    segundo_nombre              VARCHAR2(10),
    documento_identidad         NUMBER(9),
    numero_pasaporte            VARCHAR(16),
    fecha_vencimiento_pasaporte DATE,
    id_lego_cliente             NUMBER(6),
    CONSTRAINT fk_pais_nac_fan FOREIGN KEY ( id_pais )
        REFERENCES paises ( id ),
    CONSTRAINT fk_fan_lego_clientes FOREIGN KEY ( id_lego_cliente )
        REFERENCES clientes ( id_lego )
);

CREATE TABLE temas (
    id          NUMBER(2)
        CONSTRAINT pk_temas PRIMARY KEY,
    nombre      VARCHAR2(30) NOT NULL,
    descripcion VARCHAR2(2000) NOT NULL,
    tipo        VARCHAR2(5) NOT NULL,
    id_tema     NUMBER(2),
    CONSTRAINT fk_tema_padre FOREIGN KEY ( id_tema )
        REFERENCES temas ( id ),
    CONSTRAINT ck_tipo CHECK ( tipo IN ( 'SERIE', 'TEMA' ) )
);

-- Instrucciones UQ
CREATE TABLE juguetes (
    id            NUMBER(4)
        CONSTRAINT pk_juguetes PRIMARY KEY,
    nombre        VARCHAR2(60) NOT NULL,
    descripcion   VARCHAR2(2000) NOT NULL,
    rango_edad    VARCHAR2(7) NOT NULL,
    rango_precio  VARCHAR2(1) NOT NULL,
    set_lego      VARCHAR2(2) NOT NULL,
    id_tema       NUMBER(2) NOT NULL,
    numero_piezas NUMBER(4),
    instrucciones NUMBER(7),
    id_juguete    NUMBER(4),
    CONSTRAINT fk_juguete_padre FOREIGN KEY ( id_juguete )
        REFERENCES juguetes ( id ),
    CONSTRAINT fk_juguetes_temas FOREIGN KEY ( id_tema )
        REFERENCES temas ( id ),
    CONSTRAINT ck_rango_edad
        CHECK ( rango_edad IN ( '0 A 2', '3 A 4', '5 A 6', '7 A 8', '9 A 11',
                                '12P', 'ADULTOS' ) ),
    CONSTRAINT ck_rango_precio
        CHECK ( rango_precio IN ( 'A', 'B', 'C', 'D' ) ),
    CONSTRAINT ck_set_lego CHECK ( set_lego IN ( 'SI', 'NO' ) )
);

/*Faltan los triggers/programas de las reglas de negocio*/
-- CONSTRAINT PRECIO NO PUEDE SER 0 ni negativo
-- constraint fecha fin > a fecha inicio
CREATE TABLE historico_precios (
    id_juguete   NUMBER(4) NOT NULL,
    fecha_inicio DATE NOT NULL,
    precio       NUMBER(5, 2) NOT NULL,
    fecha_fin    DATE,
    CONSTRAINT fk_historico_juguetes FOREIGN KEY ( id_juguete )
        REFERENCES juguetes ( id ),
    CONSTRAINT pk_historico_precios PRIMARY KEY ( id_juguete,
                                                  fecha_inicio )
);

/*Buscar mejores nombre para los ID y los constraints FK*/
CREATE TABLE prod_relaciones (
    id_juguete_1 NUMBER(4) NOT NULL,
    id_juguete_2 NUMBER(4) NOT NULL,
    CONSTRAINT fk_juguete_1 FOREIGN KEY ( id_juguete_1 )
        REFERENCES juguetes ( id ),
    CONSTRAINT fk_juguete_2 FOREIGN KEY ( id_juguete_2 )
        REFERENCES juguetes ( id ),
    CONSTRAINT pk_prod_relaciones PRIMARY KEY ( id_juguete_1,
                                                id_juguete_2 )
);

/*Aplicarle el trigger para descontarle la cantidad al lote según el descuento_lotes*/
-- Cantidad no puede ser negativa CONSTRAINT
CREATE TABLE inventario_lotes (
    id_juguete NUMBER(4) NOT NULL,
    id_tienda  NUMBER(4) NOT NULL,
    num_lote   NUMBER(6) NOT NULL,
    cantidad   NUMBER(4) NOT NULL,
    CONSTRAINT fk_inventario_juguetes FOREIGN KEY ( id_juguete )
        REFERENCES juguetes ( id ),
    CONSTRAINT fk_inventario_tiendas FOREIGN KEY ( id_tienda )
        REFERENCES tiendas ( id ),
    CONSTRAINT pk_inventario_lotes PRIMARY KEY ( id_juguete,
                                                 id_tienda,
                                                 num_lote )
);

/*Faltan las reglas de negocio respectivas*/
-- Cantidad no puede ser negativa CONSTRAINT
CREATE TABLE descuento_lotes (
    id_juguete_inv NUMBER(4) NOT NULL,
    id_tienda_inv  NUMBER(4) NOT NULL,
    num_lote       NUMBER(8) NOT NULL,
    id             NUMBER(4) NOT NULL,
    fecha          DATE NOT NULL,
    cantidad       NUMBER(4, 2) NOT NULL,
    CONSTRAINT fk_descuento_inventario
        FOREIGN KEY ( id_juguete_inv,
                      id_tienda_inv,
                      num_lote )
            REFERENCES inventario_lotes ( id_juguete,
                                          id_tienda,
                                          num_lote ),
    CONSTRAINT pk_descuento_lotes
        PRIMARY KEY ( id_juguete_inv,
                      id_tienda_inv,
                      num_lote,
                      id )
);

-- constraints limite > 0
CREATE TABLE catalogo_paises (
    id_juguete NUMBER(4) NOT NULL,
    id_pais    NUMBER(3) NOT NULL,
    limite     NUMBER(2) NOT NULL,
    CONSTRAINT fk_catalogo_paises_paises FOREIGN KEY ( id_pais )
        REFERENCES paises ( id ),
    CONSTRAINT fk_catalogo_juguetes FOREIGN KEY ( id_juguete )
        REFERENCES juguetes ( id ),
    CONSTRAINT pk_catalogo_paises PRIMARY KEY ( id_juguete,
                                                id_pais )
);

/*Faltan las reglas de negocio respectivas*/
-- constraint total > 0
CREATE TABLE factura_ventas_online (
    numeroventa      NUMBER(7) NOT NULL
        CONSTRAINT pk_factura_ventas_online PRIMARY KEY,
    fecha_venta      DATE NOT NULL,
    gratis           VARCHAR2(2) NOT NULL,
    id_lego_cliente  NUMBER(6) NOT NULL,
    total            NUMBER(6, 2),
    puntos_generados NUMBER(3),
    CONSTRAINT ck_gratis CHECK ( gratis IN ( 'SI', 'NO' ) ),
    CONSTRAINT fk_factura_online_clientes FOREIGN KEY ( id_lego_cliente )
        REFERENCES clientes ( id_lego )
);

/*Faltan las reglas de negocio respectivas*/
-- cantidad > 0
CREATE TABLE detalle_factura_ventas_online (
    numeroventa    NUMBER(7) NOT NULL,
    id             NUMBER(2) NOT NULL,
    cantidad       NUMBER(2) NOT NULL,
    tipo_cliente   VARCHAR2(6) NOT NULL,
    id_juguete_cat NUMBER(4) NOT NULL,
    id_pais_cat    NUMBER(3) NOT NULL,
    CONSTRAINT ck_tipo_cliente_detalle_online
        CHECK ( tipo_cliente IN ( 'ADULTO', 'JOVEN', 'MENOR' ) ),
    CONSTRAINT fk_detalle_online_factura_online FOREIGN KEY ( numeroventa )
        REFERENCES factura_ventas_online ( numeroventa ),
    CONSTRAINT fk_detalle_online_catalogo_paises
        FOREIGN KEY ( id_juguete_cat,
                      id_pais_cat )
            REFERENCES catalogo_paises ( id_juguete,
                                         id_pais ),
    CONSTRAINT pk_detalle_factura_ventas_online PRIMARY KEY ( numeroventa,
                                                              id )
);

/*Faltan las reglas de negocio*/
-- total > 0
CREATE TABLE factura_ventas_tienda (
    id_tienda       NUMBER(4) NOT NULL,
    numeroventa     NUMBER(7) NOT NULL,
    fecha_venta     DATE NOT NULL,
    id_lego_cliente NUMBER(6) NOT NULL,
    total           NUMBER(6, 2),
    CONSTRAINT fk_factura_tienda_tiendas FOREIGN KEY ( id_tienda )
        REFERENCES tiendas ( id ),
    CONSTRAINT fk_factura_tienda_clientes FOREIGN KEY ( id_lego_cliente )
        REFERENCES clientes ( id_lego ),
    CONSTRAINT pk_factura_ventas_tiendas PRIMARY KEY ( id_tienda,
                                                       numeroventa )
);

/*Faltan las reglas de negocio*/
-- cantidad > 0
CREATE TABLE detalle_factura_ventas_tienda (
    id_tienda_fac  NUMBER(4) NOT NULL,
    numeroventa    NUMBER(7) NOT NULL,
    id             NUMBER(2) NOT NULL,
    cantidad       NUMBER(2) NOT NULL,
    tipo_cliente   VARCHAR2(6) NOT NULL,
    id_juguete_inv NUMBER(4) NOT NULL,
    id_tienda_inv  NUMBER(4) NOT NULL,
    num_lote_inv   NUMBER(6) NOT NULL,
    CONSTRAINT ck_tipo_cliente_detalle_tienda
        CHECK ( tipo_cliente IN ( 'ADULTO', 'JOVEN', 'MENOR' ) ),
    CONSTRAINT fk_detalle_tienda_factura_tienda
        FOREIGN KEY ( id_tienda_fac,
                      numeroventa )
            REFERENCES factura_ventas_tienda ( id_tienda,
                                               numeroventa ),
    CONSTRAINT fk_detalle_tienda_inventario_lotes
        FOREIGN KEY ( id_juguete_inv,
                      id_tienda_inv,
                      num_lote_inv )
            REFERENCES inventario_lotes ( id_juguete,
                                          id_tienda,
                                          num_lote ),
    CONSTRAINT pk_detalle_factura_ventas_tienda PRIMARY KEY ( id_tienda_fac,
                                                              numeroventa,
                                                              id )
);

-- Costo del tour no puede ser negativo ni 0
-- Cupos disponibles no pueden ser menores a 0
CREATE TABLE tours (
    fecha         DATE
        CONSTRAINT pk_tours PRIMARY KEY,
    cupos_totales NUMBER(2) NOT NULL,
    costo         NUMBER(5, 2) NOT NULL
);

/*Faltan las reglas de negocio respectivas*/
CREATE TABLE inscripciones (
    fecha_tour        DATE NOT NULL,
    numeroinscripcion NUMBER(4) NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    estatus           VARCHAR2(9) NOT NULL,
    total             NUMBER(6, 2),
    CONSTRAINT ck_estatus CHECK ( estatus IN ( 'PENDIENTE', 'PAGADO' ) ),
    CONSTRAINT fk_inscripciones_tours FOREIGN KEY ( fecha_tour )
        REFERENCES tours ( fecha ),
    CONSTRAINT pk_inscripciones PRIMARY KEY ( fecha_tour,
                                              numeroinscripcion )
);

CREATE TABLE entradas (
    fecha_tour_ins    DATE NOT NULL,
    numeroinscripcion NUMBER(4) NOT NULL,
    numeroentrada     NUMBER(7) NOT NULL,
    tipo              VARCHAR2(6) NOT NULL,
    CONSTRAINT ck_tipo_entrada
        CHECK ( tipo IN ( 'ADULTO', 'JOVEN', 'MENOR' ) ),
    CONSTRAINT fk_entradas_inscripciones
        FOREIGN KEY ( fecha_tour_ins,
                      numeroinscripcion )
            REFERENCES inscripciones ( fecha_tour,
                                       numeroinscripcion ),
    CONSTRAINT pk_entradas PRIMARY KEY ( fecha_tour_ins,
                                         numeroinscripcion,
                                         numeroentrada )
);

CREATE TABLE detalle_inscripciones (
    fecha_tour_ins    DATE NOT NULL,
    numeroinscripcion NUMBER(4) NOT NULL,
    id                NUMBER(7) NOT NULL,
    id_lego_cli       NUMBER(6),
    id_lego_fan       NUMBER(6),
    CONSTRAINT ck_arco_participante
        CHECK ( ( id_lego_cli IS NULL
                  AND id_lego_fan IS NOT NULL )
                OR ( id_lego_cli IS NOT NULL
                     AND id_lego_fan IS NULL ) ),
    CONSTRAINT fk_detalle_inscripciones_inscripciones
        FOREIGN KEY ( fecha_tour_ins,
                      numeroinscripcion )
            REFERENCES inscripciones ( fecha_tour,
                                       numeroinscripcion ),
    CONSTRAINT fk_detalle_inscripciones_clientes FOREIGN KEY ( id_lego_cli )
        REFERENCES clientes ( id_lego ),
    CONSTRAINT fk_detalle_inscripciones_fan FOREIGN KEY ( id_lego_fan )
        REFERENCES fan_lego_menores ( id_lego ),
    CONSTRAINT pk_detalle_inscripciones PRIMARY KEY ( fecha_tour_ins,
                                                      numeroinscripcion,
                                                      id )
);