CREATE TABLE Paises (
    id              number(3) constraint pk_paises primary key,
    nombre          varchar2(30) not null unique,
    continente      varchar2(8) not null,
    nacionalidad    varchar2(30) not null,
    union_europea   char(2),
    constraint ck_union_europea check (union_europea IN ('SI') OR union_europea IS NULL),
    constraint ck_continente check (continente IN ('AMERICA','EUROPA','AFRICA','ASIA','OCEANIA'))
);

CREATE TABLE Estados (
    id_pais         number(3) not null,
    id              number(5) not null,
    nombre          varchar2(30) not null,
    constraint fk_estados_paises foreign key (id_pais) references Paises(id),
    constraint pk_estados primary key (id_pais, id)
);

CREATE TABLE Ciudades (
    id_pais_est     number(3) not null,
    id_estado       number(5) not null,
    id              number(5) not null,
    nombre          varchar2(30) not null,
    constraint fk_ciudades_estados foreign key (id_pais_est,id_estado) references Estados(id_pais,id),
    constraint pk_ciudades primary key (id_pais_est, id_estado, id)
);

CREATE TABLE Tiendas (
    id              number(4) constraint pk_tiendas primary key,
    nombre          varchar2(50) not null,
    direccion       varchar2(120) not null,
    id_pais_ciu     number(3) not null,
    id_estado_ciu   number(5) not null,
    id_ciudad       number(5) not null,
    constraint fk_tiendas_ciudades foreign key (id_pais_ciu,id_estado_ciu,id_ciudad) references Ciudades(id_pais_est,id_estado,id)
);

CREATE TABLE Telefonos (
    id_tienda       number(4) not null,
    id              number(4) not null,
    cod_area        number(3) not null,
    cod_pais        number(3) not null,
    numero          number(10) not null,
    constraint fk_telefonos_tiendas foreign key (id_tienda) references Tiendas(id),
    constraint pk_telefonos primary key (id_tienda,id),
    -- Asegura que la misma tienda no tenga el mismo número duplicado
    constraint uq_telefono unique (id_tienda, cod_area, cod_pais, numero)
);

/*El formateo de las horas en un trigger? Si, al hacer un insert se formatea*/
/*Faltan reglas de negocio respecto a numerodia en triggers*/
CREATE TABLE Horarios (
    id_tienda       number(4) not null,
    numerodia       number(1) not null,
    hora_inicio     date not null,
    hora_fin        date not null,
    constraint fk_horarios_tiendas foreign key (id_tienda) references Tiendas(id),
    constraint pk_horarios primary key (id_tienda, numerodia)
);

/*Falta Regla de negocio de >= 21*/
/*Faltan el resto de reglas de negocio con triggers/programas*/
/*¿El pasaporte es tipo varchar2? ¿Cuántos caracteres debería tomar?*/
CREATE TABLE Clientes (
    id_lego         number(6) constraint pk_clientes primary key,
    primer_nombre   varchar2(10) not null,
    primer_apellido varchar2(10) not null,
    segundo_apellido varchar2(10) not null,
    fecha_nacimiento date not null,
    id_pais_nac     number(3) not null,
    id_pais_res     number(3) not null,
    segundo nombre varchar2(10),
    documento_identidad number(9),
    direccion       varchar2(120),
    numero_pasaporte varchar(16),
    fecha_vencimiento_pasaporte date,
    constraint fk_pais_nac foreign key (id_pais_nac) references Paises (id),
    constraint fk_pais_res foreign key (id_pais_res) references Paises (id) 
);

/*Faltan los constrains de FK*/
/*Regla de negocio de fans entre 12-20 y que si son mayores a 18 no tienen representante*/
/*Faltan el resto de reglas de negocio con triggers/programas*/
CREATE TABLE Fan_Lego_Menores (
    id_lego         number(6) constraint pk_fan_lego_menores primary key,
    primer_nombre   varchar2(10) not null,
    primer_apellido varchar2(10) not null,
    segundo_apellido varchar2(10) not null,
    fecha_nacimiento date not null,
    id_pais         number(3) not null,
    segundo_nombre  varchar2(10),
    documento_identidad number(9),
    numero_pasaporte varchar(16),
    fecha_vencimiento_pasaporte date,
    id_lego_cliente number(6),
    constraint fk_pais_nac_fan foreign key (id_pais) references Paises (id),
    constraint fk_fan_lego_clientes foreign key (id_lego_cliente) references Clientes (id_lego)
);

CREATE TABLE Temas (
    id              number(2) constraint pk_temas primary key,
    nombre          varchar2(30) not null,
    descripcion     varchar2(2000) not null,
    tipo            varchar2(5) not null,
    id_tema         number(2),
    constraint fk_tema_padre foreign key (id_tema) references Temas (id),
    constraint ck_tipo check (tipo IN ('SERIE','TEMA'))
);

CREATE TABLE Juguetes (
    id              number(4) constraint pk_juguetes primary key,
    nombre          varchar2(60) not null,
    descripcion     varchar2(2000) not null,
    rango_edad      varchar2(7) not null,
    rango_precio    varchar2(1) not null,
    set_lego        varchar2(2) not null,
    id_tema         number(2) not null,
    numero_piezas   number(4),
    instrucciones   number(7),
    id_juguete      number(4),
    constraint fk_juguete_padre foreign key (id_juguete) references Juguetes(id),
    constraint fk_juguetes_temas foreign key (id_tema) references Temas(id),
    constraint ck_rango_edad check (rango_edad IN ('0 A 2','3 A 4','5 A 6','7 A 8','9 A 11','12P','ADULTOS')),
    constraint ck_rango_precio check (rango_precio IN ('A','B','C','D')),
    constraint ck_set_lego check (set_lego IN ('SI','NO'))
);

/*Faltan los triggers/programas de las reglas de negocio*/
CREATE TABLE Historico_Precios (
    id_juguete      number(4) not null,
    fecha_inicio    date not null,
    precio          number(5, 2) not null,
    fecha_fin       date,
    constraint fk_historico_juguetes foreign key (id_juguete) references Juguetes (id),
    constraint pk_historico_precios primary key (id_juguete, fecha_inicio),
);

/*Buscar mejores nombre para los ID y los constraints FK*/
CREATE TABLE Prod_Relaciones (
    id_juguete_1    number(4) not null,
    id_juguete_2    number(4) not null,
    constraint fk_juguete_1 foreign key (id_juguete_1) references Juguetes (id),
    constraint fk_juguete_2 foreign key (id_juguete_2) references Juguetes (id),
    constraint pk_prod_relaciones primary key (id_juguete_1,id_juguete_2)
);

/*Aplicarle el trigger para descontarle la cantidad al lote según el descuento_lotes*/
CREATE TABLE Inventario_Lotes (
    id_juguete      number(4) not null,
    id_tienda       number(4) not null,
    num_lote        number(6) not null,
    cantidad        number(4) not null,
    constraint fk_inventario_juguetes foreign key (id_juguete) references Juguetes(id),
    constraint fk_inventario_tiendas foreign key (id_tienda) references Tiendas(id),
    constraint pk_inventario_lotes primary key (id_juguete, id_tienda, num_lote),
)

/*Faltan las reglas de negocio respectivas*/
CREATE TABLE Descuento_Lotes (
    id_juguete_inv  number(4) not null,
    id_tienda_inv   number(4) not null,
    num_lote        number(8) not null,
    id              number(4) not null,
    fecha           date not null,
    cantidad        number(4,2) not null,
    constraint fk_descuento_inventario foreign key (id_juguete_inv, id_tienda_inv, num_lote) references Inventario_Lotes(id_juguete, id_tienda, num_lote),
    constraint pk_descuento_lotes primary key (id_juguete_inv,id_tienda_inv,num_lote,id)
);

CREATE TABLE Catalogo_Paises (
    id_juguete      number(4) not null,
    id_pais         number(3) not null,
    limite          number(2) not null,
    constraint fk_catalogo_paises_paises foreign key (id_pais) references Paises (id),
    constraint fk_catalogo_juguetes foreign key (id_juguete) references Juguetes (id),
    constraint pk_catalogo_paises primary key (id_juguete,id_pais)
);

/*Faltan las reglas de negocio respectivas*/
CREATE TABLE Factura_Ventas_Online (
    numeroventa     number(7) not null constraint pk_factura_ventas_online primary key,
    fecha_venta     date not null,
    gratis          varchar2(2) not null,
    id_lego_cliente number(6) not null,
    total           number(6,2),
    puntos_generados number(3),
    constraint ck_gratis check (gratis IN ('SI','NO')),
    constraint fk_factura_online_clientes foreign key (id_lego_cliente) references Clientes (id_lego)
);

/*Faltan las reglas de negocio respectivas*/
CREATE TABLE Detalle_Factura_Ventas_Online (
    numeroventa     number(7) not null,
    id              number(2) not null,
    cantidad        number(2) not null,
    tipo_cliente    varchar2(6)  not null,
    id_juguete_cat  number(4) not null,
    id_pais_cat     number(3) not null,
    constraint ck_tipo_cliente_detalle_online check (tipo_cliente IN ('ADULTO','JOVEN','MENOR')),
    constraint fk_detalle_online_factura_online foreign key (numeroventa) references Factura_Ventas_Online (numeroventa),
    constraint fk_detalle_online_catalogo_paises foreign key (id_juguete_cat,id_pais_cat) references Catalogo_Paises (id_juguete,id_pais),
    constraint pk_detalle_factura_ventas_online primary key (numeroventa,id)
);

/*Faltan las reglas de negocio*/
CREATE TABLE Factura_Ventas_Tienda (
    id_tienda       number(4) not null,
    numeroventa     number(7) not null,
    fecha_venta     date not null,
    id_lego_cliente number(6) not null,
    total           number(6,2),
    constraint fk_factura_tienda_tiendas foreign key (id_tienda) references Tiendas (id),
    constraint fk_factura_tienda_clientes foreign key (id_lego_cliente) references Clientes (id_lego),
    constraint pk_factura_ventas_tiendas primary key (id_tienda,numeroventa)
);

/*Faltan las reglas de negocio*/
CREATE TABLE Detalle_Factura_Ventas_Tienda (
    id_tienda_fac   number(4) not null,
    numeroventa     number(7) not null,
    id              number(2) not null,
    cantidad        number(2) not null,
    tipo_cliente    varchar2(6) not null,
    id_juguete_inv  number(4) not null,
    id_tienda_inv   number(4) not null,
    num_lote_inv    number(6) not null,
    constraint ck_tipo_cliente_detalle_tienda check (tipo_cliente IN ('ADULTO','JOVEN','MENOR')),
    constraint fk_detalle_tienda_factura_tienda foreign key (id_tienda_fac,numeroventa) references Factura_Ventas_Tienda (id_tienda,numeroventa),
    constraint fk_detalle_tienda_inventario_lotes foreign key (id_juguete_inv,id_tienda_inv,num_lote_inv) references Inventario_Lotes (id_juguete,id_tienda,num_lote),
    constraint pk_detalle_factura_ventas_tienda primary key (id_tienda_fac,numeroventa,id)
);

CREATE TABLE Tours (
    fecha           date constraint pk_tours primary key,
    cupos_totales   number(2) not null,
    costo           number(5,2) not null,
)

/*Faltan las reglas de negocio respectivas*/
CREATE TABLE Inscripciones (
    fecha_tour      date not null,
    numeroinscripcion number(4) not null,
    fecha_inscripcion date not null,
    estatus         varchar2(9) not null,
    total           number(6,2),
    constraint ck_estatus check (estatus IN ('PENDIENTE','PAGADO')),
    constraint fk_inscripciones_tours foreign key (fecha_tour) references Tours (fecha),
    constraint pk_inscripciones primary key (fecha_tour,numeroinscripcion)

);

CREATE TABLE Entradas (
    fecha_tour_ins  date not null,
    numeroinscripcion number(4) not null,
    numeroentrada   number(7) not null,
    tipo            varchar2(6) not null,
    constraint ck_tipo_entrada check (tipo IN ('ADULTO','JOVEN','MENOR')),
    constraint fk_entradas_inscripciones foreign key (fecha_tour_ins,numeroinscripcion) references Inscripciones (fecha_tour,numeroinscripcion),
    constraint pk_entradas primary key (fecha_tour_ins,numeroinscripcion,numeroentrada)
);

CREATE TABLE Detalle_Inscripciones (
    fecha_tour_ins  date not null,
    numeroinscripcion number(4) not null,
    id              number(7) not null,
    id_lego_cli     number(6),
    id_lego_fan     number(6),
    constraint ck_arco_participante check ((id_lego_cli IS NULL AND id_lego_fan IS NOT NULL) OR (id_lego_cli IS NOT NULL AND id_lego_fan IS NULL)),
    constraint fk_detalle_inscripciones_inscripciones foreign key (fecha_tour_ins,numeroinscrion) references Inscripciones (fecha_tour,numeroinscripcion),
    constraint fk_detalle_inscripciones_clientes foreign key (id_lego_cli) references Clientes (id_lego),
    constraint fk_detalle_inscripciones_fan foreign key (id_lego_fan) references Fan_Lego_Menores (id_lego),
    constraint pk_detalle_inscripciones primary key (fecha_tour_ins,numeroinscripcion,id)
);