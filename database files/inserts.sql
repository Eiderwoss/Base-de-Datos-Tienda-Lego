-- 1. PAISES (7 Países seleccionados)
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (1, 'FRANCIA', 'EUROPA', 'FRANCESA', 'SI');
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (2, 'PORTUGAL', 'EUROPA', 'PORTUGUESA', 'SI');
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (3, 'MALASIA', 'ASIA', 'MALASIA', NULL);
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (4, 'GRECIA', 'EUROPA', 'GRIEGA', 'SI');
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (5, 'HUNGRIA', 'EUROPA', 'HUNGARA', 'SI');
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (6, 'BRASIL', 'AMERICA', 'BRASILERA', NULL);
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (7, 'NUEVA ZELANDA', 'OCEANIA', 'NEOZELANDESA', NULL);
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (8, 'JAPON', 'ASIA', 'JAPONESA', NULL);
INSERT INTO Paises (id, nombre, continente, nacionalidad, union_europea) VALUES (9, 'ESTADOS UNIDOS', 'AMERICA', 'ESTADOUNIDENSE', NULL);
-- 2. ESTADOS (Regiones de las tiendas)
INSERT INTO Estados (id_pais, id, nombre) VALUES (1, 10, 'PROVENZA-ALPES'); -- Toulon
INSERT INTO Estados (id_pais, id, nombre) VALUES (2, 20, 'LISBOA');          -- Lisboa
INSERT INTO Estados (id_pais, id, nombre) VALUES (3, 30, 'KUALA LUMPUR');    -- KL
INSERT INTO Estados (id_pais, id, nombre) VALUES (4, 40, 'ATICA');           -- Atenas
INSERT INTO Estados (id_pais, id, nombre) VALUES (5, 50, 'PEST');            -- Budapest
INSERT INTO Estados (id_pais, id, nombre) VALUES (6, 60, 'RIO DE JANEIRO');  -- Rio
INSERT INTO Estados (id_pais, id, nombre) VALUES (6, 61, 'SAO PAULO');       -- Sao Paulo
INSERT INTO Estados (id_pais, id, nombre) VALUES (7, 70, 'AUCKLAND');        -- Auckland
INSERT INTO Estados (id_pais, id, nombre) VALUES (8, 80, 'KANTO');
-- 3. CIUDADES
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (1, 10, 100, 'LA VALETTE-DU-VAR');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (2, 20, 200, 'LISBOA');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (3, 30, 300, 'KUALA LUMPUR');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (4, 40, 400, 'ATENAS');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (5, 50, 500, 'BUDAPEST');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (6, 60, 600, 'RIO DE JANEIRO');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (6, 61, 601, 'SAO PAULO');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (7, 70, 700, 'NEWMARKET');
INSERT INTO Ciudades (id_pais_est, id_estado, id, nombre) VALUES (8, 80, 800, 'TOKIO');

-- 4. TIENDAS (Las 8 tiendas de tu lista)
INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1001, 'LEGO Store Toulon', 'Centre Commercial Grand Var La Valette-du-Var, 83160, 83160 Toulon, Francia', 1, 10, 100);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1002, 'LEGO Store Lisbon', 'Colombo Shopping Centre, Av. Lusíada Loja 0036/2/3, 1500-392 Lisboa, Portugal', 2, 20, 200);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1003, 'LEGO Pavilion KL', 'Lot 6 . 102 . 00, 168, Bukit Bintang Rd, Bukit Bintang, 55100 Kuala Lumpur, Federal Territory of Kuala Lumpur, Malasia', 3, 30, 300);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1004, 'LEGO River West', 'Par. Leoforou Kifisou 98, Egaleo 122 41, Grecia', 4, 40, 400);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1005, 'LEGO Store Arkad', 'Budapest, Örs vezér tere 25, 1148 Hungría', 5, 50, 500);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1006, 'LEGO Barra Shopping', 'Av. das Américas, 4666 - Barra da Tijuca, Rio de Janeiro - RJ, 22640-102, Brasil', 6, 60, 600);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1007, 'LEGO Analia Franco', 'Av. Reg. Feijó, 1739 - Vila Reg. Feijó, São Paulo - SP, 03342-000, Brasil', 6, 61, 601);

INSERT INTO Tiendas (id, nombre, direccion, id_pais_ciu, id_estado_ciu, id_ciudad) 
VALUES (1008, 'LEGO Newmarket', 'Level 3, Shop S302, Westfield Newmarket 277 Broadway, Newmarket, Auckland 1023, Nueva Zelanda', 7, 70, 700);

COMMIT;

/* TABLA: CLIENTES */
-- Cliente 1: Juan (Brasileño, viviendo en Brasil cerca de la tienda de Rio)
INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais_nac, id_pais_res, segundo_nombre, documento_identidad, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    99, 'JUAN', 'PEREZ', 'LOPEZ', TO_DATE('15/05/1985','DD/MM/YYYY'), 
    6, 6, 'CARLOS', 12345678, 'AV. ATLANTICA 100, RIO DE JANEIRO', 
    'A12345678', TO_DATE('01/01/2030','DD/MM/YYYY')
);

-- Cliente 2: Maria (Portuguesa, viviendo en Francia cerca de la tienda de Toulon)
INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais_nac, id_pais_res, segundo_nombre, documento_identidad, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    88, 'MARIA', 'SILVA', 'SANTOS', TO_DATE('20/10/1990','DD/MM/YYYY'), 
    2, 1, NULL, 87654321, 'RUE DE LA REPUBLIQUE 50, TOULON', 
    'B98765432', TO_DATE('05/05/2028','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    101, 'MICHAEL', 'SMITH', 'BROWN', TO_DATE('10/02/1980','DD/MM/YYYY'), 
    30001, 9, 9, 'JAMES', '123 BROADWAY AVE, NEW YORK', 
    'US100100', TO_DATE('01/01/2030','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    102, 'KENJI', 'TANAKA', 'SATO', TO_DATE('05/05/1995','DD/MM/YYYY'), 
    30002, 8, 8, NULL, 'SHIBUYA CROSSING 5-1, TOKYO', 
    'JP200200', TO_DATE('01/05/2032','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    103, 'ELENA', 'PAPADOPOU', 'GIORGOU', TO_DATE('20/08/1990','DD/MM/YYYY'), 
    30003, 4, 4, 'SOFIA', 'PLAKA DISTRICT 12, ATENAS', 
    'GR300300', TO_DATE('15/06/2029','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    104, 'LASZLO', 'NAGY', 'KOVACS', TO_DATE('12/12/1988','DD/MM/YYYY'), 
    30004, 5, 5, NULL, 'VACI UTCA 45, BUDAPEST', 
    'HU400400', TO_DATE('20/12/2028','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    105, 'SITI', 'OMAR', 'ALI', TO_DATE('14/02/1992','DD/MM/YYYY'), 
    30005, 3, 3, 'NUR', 'PETRONAS TOWERS APT 4, KUALA LUMPUR', 
    'MY500500', TO_DATE('10/10/2030','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    106, 'JOAO', 'FERREIRA', 'COSTA', TO_DATE('30/01/1982','DD/MM/YYYY'), 
    30006, 2, 2, 'PEDRO', 'RUA AUGUSTA 100, LISBOA', 
    'PT600600', TO_DATE('05/05/2027','DD/MM/YYYY')
);

INSERT INTO Clientes (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    documento_identidad, id_pais_nac, id_pais_res, segundo_nombre, direccion, 
    numero_pasaporte, fecha_vencimiento_pasaporte
) VALUES (
    107, 'SOPHIE', 'DUBOIS', 'MARTIN', TO_DATE('11/11/1998','DD/MM/YYYY'), 
    30007, 1, 1, 'MARIE', 'AVENUE DES CHAMPS-ELYSEES 20, PARIS', 
    'FR700700', TO_DATE('14/07/2031','DD/MM/YYYY')
);

COMMIT;

/* TABLA: FAN_LEGO_MENORES */

-- Hijo de Juan (ID 99)
INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    10, 'CARLITOS', 'PEREZ', 'GOMEZ', TO_DATE('01/06/2008','DD/MM/YYYY'), 
    6, NULL, 10001, 'P111222', 
    TO_DATE('01/01/2030','DD/MM/YYYY'), 99
);

-- Hija de Maria (ID 88)
INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    11, 'ANA', 'COSTA', 'SILVA', TO_DATE('15/03/2013','DD/MM/YYYY'), 
    2, 'LUCIA', 20002, 'P333444', 
    TO_DATE('01/01/2031','DD/MM/YYYY'), 88
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    12, 'TOMMY', 'SMITH', 'JONES', TO_DATE('15/05/2012','DD/MM/YYYY'), 
    9, 'LEE', 40001, 'US400400', 
    TO_DATE('01/01/2030','DD/MM/YYYY'), 101
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    13, 'AKIRA', 'SATO', 'YAMAMOTO', TO_DATE('10/01/2006','DD/MM/YYYY'), 
    8, 'KEN', 40002, 'JP400400', 
    TO_DATE('01/05/2032','DD/MM/YYYY'), NULL
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    14, 'NIKOS', 'PAPADOPOU', 'SILVA', TO_DATE('20/02/2009','DD/MM/YYYY'), 
    4, NULL, 40003, 'GR400400', 
    TO_DATE('15/06/2029','DD/MM/YYYY'), 103
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    15, 'JULIA', 'NAGY', 'HORVATH', TO_DATE('01/03/2005','DD/MM/YYYY'), 
    5, 'BEATA', 40004, 'HU400400', 
    TO_DATE('20/12/2028','DD/MM/YYYY'), NULL
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    16, 'CLARA', 'DUBOIS', 'LEFEBVRE', TO_DATE('05/09/2013','DD/MM/YYYY'), 
    1, NULL, 40005, 'FR400400', 
    TO_DATE('14/07/2031','DD/MM/YYYY'), 107
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    17, 'AMIR', 'OMAR', 'RAZAK', TO_DATE('11/11/2007','DD/MM/YYYY'), 
    3, NULL, 40006, 'MY400400', 
    TO_DATE('10/10/2030','DD/MM/YYYY'), NULL
);

INSERT INTO Fan_Lego_Menores (
    id_lego, primer_nombre, primer_apellido, segundo_apellido, fecha_nacimiento, 
    id_pais, segundo_nombre, documento_identidad, numero_pasaporte, 
    fecha_vencimiento_pasaporte, id_lego_cliente
) VALUES (
    18, 'PEDRO', 'FERREIRA', 'LIMA', TO_DATE('04/07/2010','DD/MM/YYYY'), 
    2, 'LUIS', 40007, 'PT400400', 
    TO_DATE('05/05/2027','DD/MM/YYYY'), 106
);

COMMIT;

/* TABLA: TEMAS */

-- ID 1: Minecraft
INSERT INTO Temas (id, nombre, descripcion, tipo, id_tema) 
VALUES (1, 'MINECRAFT', 'Explora el mundo de bloques, construye refugios y lucha contra Creepers con los sets de LEGO Minecraft.', 'TEMA', NULL);

-- ID 2: Star Wars
INSERT INTO Temas (id, nombre, descripcion, tipo, id_tema) 
VALUES (2, 'STAR WARS', 'Revive las batallas galácticas con naves, droides y personajes icónicos de la saga Skywalker.', 'TEMA', NULL);

-- ID 3: Sonic The Hedgehog
INSERT INTO Temas (id, nombre, descripcion, tipo, id_tema) 
VALUES (3, 'SONIC THE HEDGEHOG', 'Velocidad supersónica y anillos dorados con Sonic y sus amigos contra el Dr. Eggman.', 'TEMA', NULL);

-- ID 4: Super Mario
INSERT INTO Temas (id, nombre, descripcion, tipo, id_tema) 
VALUES (4, 'SUPER MARIO', 'Lleva la diversión de Nintendo al mundo real con recorridos interactivos y figuras electrónicas.', 'TEMA', NULL);

COMMIT;

/* TEMA 1: MINECRAFT (ID TEMA = 1) */
INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (101, 'THE CREEPER', 'Figura construible grande de un Creeper icónico de Minecraft con funciones móviles.', '7 A 8', 'B', 'SI', 1, 300, 100101, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (102, 'THE WOLF STRONGHOLD', 'Base de fortaleza lobo con entrada grande y zona de crafteo.', '7 A 8', 'B', 'SI', 1, 312, 100102, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (103, 'THE PICKAXE MINE', 'Mina con forma de pico gigante en el bioma Mesa.', '7 A 8', 'C', 'SI', 1, 500, 100103, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (104, 'THE ENDER DRAGON AND END SHIP', 'Batalla final contra el dragón del Ender con nave del End incluida.', '9 A 11', 'C', 'SI', 1, 657, 100104, NULL);


/* TEMA 2: STAR WARS (ID TEMA = 2) */
INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (201, 'MILLENNIUM FALCON', 'Modelo UCS definitivo del carguero Corelliano de Han Solo. Edición Coleccionista.', 'ADULTOS', 'D', 'SI', 2, 7541, 200201, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (202, 'R2-D2', 'Modelo construible del droide astromecánico favorito de la galaxia.', '9 A 11', 'C', 'SI', 2, 1050, 200202, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (203, 'DARTH VADER HELMET', 'Casco detallado del Lord Sith para exhibición.', 'ADULTOS', 'C', 'SI', 2, 834, 200203, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (204, 'DEATH STAR', 'Estación espacial de combate definitiva con múltiples habitaciones y escenas.', 'ADULTOS', 'D', 'SI', 2, 4016, 200204, NULL);


/* TEMA 3: SONIC (ID TEMA = 3) */
INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (301, 'SHADOW THE HEDGEHOG ESCAPE', 'Set de escape de laboratorio con figura de Shadow y moto.', '7 A 8', 'B', 'SI', 3, 196, 300301, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (302, 'SONIC THE HEDGEHOG KEY CHAIN', 'Llavero con minifigura de Sonic para mochilas o llaves.', '5 A 6', 'A', 'NO', 3, 1, NULL, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (303, 'CYCLONE VS METAL SONIC', 'Vehículo transformable de Tails contra el malvado Metal Sonic.', '7 A 8', 'B', 'SI', 3, 290, 300303, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (304, 'KNUCKLES GUARDIAN MECH', 'Robot mecánico de combate para proteger la Master Emerald.', '7 A 8', 'B', 'SI', 3, 276, 300304, NULL);


/* TEMA 4: SUPER MARIO (ID TEMA = 4) */
INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (401, 'MARIO'|| '&' ||'STANDARD KART', 'Vehículo de Mario Kart listo para correr en pistas de ladrillos.', '7 A 8', 'B', 'SI', 4, 150, 400401, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (402, 'THE MIGHTY BOWSER', 'Figura gigante articulada del Rey de los Koopas con lanzador de fuego.', 'ADULTOS', 'D', 'SI', 4, 2807, 400402, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (403, 'PIRANHA PLANT', 'Planta Piraña articulada saliendo de tubería verde. Modelo de exhibición.', 'ADULTOS', 'B', 'SI', 4, 540, 400403, NULL);

INSERT INTO Juguetes (id, nombre, descripcion, rango_edad, rango_precio, set_lego, id_tema, numero_piezas, instrucciones, id_juguete)
VALUES (404, 'MARIO KART - BOWSER CASTLE', 'Pista de carreras ambientada en el castillo de Bowser con trampas.', '9 A 11', 'C', 'SI', 4, 1000, 400404, NULL);

COMMIT;

/* HISTORICO PRECIOS (Fecha Inicio 01/01/2025 para todos) */

-- Minecraft
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (101, TO_DATE('01/01/2025','DD/MM/YYYY'), 19.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (102, TO_DATE('01/01/2025','DD/MM/YYYY'), 34.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (103, TO_DATE('01/01/2025','DD/MM/YYYY'), 79.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (104, TO_DATE('01/01/2025','DD/MM/YYYY'), 99.99, NULL);

-- Star Wars
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (201, TO_DATE('01/01/2025','DD/MM/YYYY'), 849.99, NULL); -- Rango D
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (202, TO_DATE('01/01/2025','DD/MM/YYYY'), 99.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (203, TO_DATE('01/01/2025','DD/MM/YYYY'), 79.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (204, TO_DATE('01/01/2025','DD/MM/YYYY'), 599.99, NULL); -- Rango D

-- Sonic
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (301, TO_DATE('01/01/2025','DD/MM/YYYY'), 19.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (302, TO_DATE('01/01/2025','DD/MM/YYYY'), 5.99, NULL); -- Rango A
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (303, TO_DATE('01/01/2025','DD/MM/YYYY'), 29.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (304, TO_DATE('01/01/2025','DD/MM/YYYY'), 34.99, NULL);

-- Mario
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (401, TO_DATE('01/01/2025','DD/MM/YYYY'), 49.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (402, TO_DATE('01/01/2025','DD/MM/YYYY'), 269.99, NULL); -- Rango D
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (403, TO_DATE('01/01/2025','DD/MM/YYYY'), 59.99, NULL);
INSERT INTO Historico_Precios (id_juguete, fecha_inicio, precio, fecha_fin) VALUES (404, TO_DATE('01/01/2025','DD/MM/YYYY'), 159.99, NULL);

COMMIT;

/* CATALOGO_PAISES (Con la nueva columna 'limite') */

-- Francia (ID 1): Vende Star Wars y Minecraft
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (201, 1, 2); -- Millennium Falcon (Limitado a 2)
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (202, 1, 5); -- R2-D2
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (101, 1, 5); -- The Creeper

-- Portugal (ID 2): Vende Sonic
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (301, 2, 5); -- Shadow Escape
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (302, 2, 10); -- Llaveros (Limite 10)

-- Malasia (ID 3): Vende Minecraft
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (101, 3, 5);
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (103, 3, 3); -- The Pickaxe Mine

-- Grecia (ID 4): Vende Sonic
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (301, 4, 5);
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (304, 4, 3); -- Knuckles Mech

-- Hungria (ID 5): Vende Mario
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (401, 5, 5); -- Mario Kart
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (402, 5, 1); -- Mighty Bowser (Muy grande, limite 1)

-- Brasil (ID 6): Vende Mario y Star Wars
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (402, 6, 1); -- Mighty Bowser
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (201, 6, 1); -- Millennium Falcon
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (203, 6, 3); -- Casco Vader

-- Nueva Zelanda (ID 7): Vende Minecraft
INSERT INTO Catalogo_Paises (id_juguete, id_pais, limite) VALUES (104, 7, 2); -- Ender Dragon

COMMIT;

/* TOURS (Definidos por Fecha, Cupos y Costo) */

-- Tour A: Fecha en Diciembre 2025
INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 30, 150.00);

-- Tour B: Fecha en Enero 2026
INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 25, 200.00);

-- Tour C: Fecha en Febrero 2026 (Carnaval)
INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 50, 180.00);

-- Tour D: Fecha en Marzo 2026
INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 20, 120.00);

INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 30, 160.00);

INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 25, 175.50);

INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 40, 210.00);

INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 35, 250.00);

INSERT INTO Tours (fecha, cupos_totales, costo) 
VALUES (TO_DATE('05/08/2026','DD/MM/YYYY'), 30, 220.00);

COMMIT;

/* INVENTARIO_LOTES */

-- Tienda 1001 (Francia): Recibe Star Wars y Minecraft
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (201, 1001, 100101, 10); -- 10 Millennium Falcon
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (101, 1001, 100102, 50); -- 50 Creepers

-- Tienda 1002 (Portugal): Recibe Sonic
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (301, 1002, 100201, 20);

-- Tienda 1003 (Malasia): Recibe Minecraft
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (103, 1003, 100301, 15);

-- Tienda 1004 (Grecia): Recibe Sonic
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (301, 1004, 100401, 30);

-- Tienda 1005 (Hungria): Recibe Mario
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (401, 1005, 100501, 25);

-- Tienda 1006 (Brasil Rio): Recibe Mario (Bowser)
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (402, 1006, 100601, 8);

-- Tienda 1007 (Brasil SP): Recibe Star Wars
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (201, 1007, 100701, 5);

-- Tienda 1008 (Nueva Zelanda): Recibe Minecraft (Dragon)
INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (104, 1008, 100801, 12);

INSERT INTO Inventario_Lotes (id_juguete, id_tienda, num_lote, cantidad) 
VALUES (101, 1008, 100802, 20);

COMMIT;

/* -------------------------------------------------------------------------
   22. TABLA HORARIOS
   (Asumimos numerodia: 1=Lunes ... 7=Domingo)
   ------------------------------------------------------------------------- */

-- Horario Tienda Francia (1001) - Lunes a Domingo de 10am a 8pm
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 2, TO_DATE('01/01/2000 10:00','DD/MM/YYYY HH24:MI'), TO_DATE('20:00','HH24:MI'));
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 3, TO_DATE('01/01/2000 10:00','DD/MM/YYYY HH24:MI'), TO_DATE('20:00','HH24:MI'));
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 4, TO_DATE('01/01/2000 10:00','DD/MM/YYYY HH24:MI'), TO_DATE('20:00','HH24:MI'));
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 5, TO_DATE('01/01/2000 10:00','DD/MM/YYYY HH24:MI'), TO_DATE('20:00','HH24:MI'));
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 6, TO_DATE('01/01/2000 10:00','DD/MM/YYYY HH24:MI'), TO_DATE('21:00','HH24:MI')); -- Viernes cierra tarde
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 7, TO_DATE('01/01/2000 09:00','DD/MM/YYYY HH24:MI'), TO_DATE('21:00','HH24:MI')); -- Sabado abre temprano
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1001, 1, TO_DATE('01/01/2000 11:00','DD/MM/YYYY HH24:MI'), TO_DATE('18:00','HH24:MI')); -- Domingo reducido

-- Horario Tienda Brasil Rio (1006) - Lunes a Viernes
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1006, 2, TO_DATE('01/01/2000 09:00','DD/MM/YYYY HH24:MI'), TO_DATE('22:00','HH24:MI')); -- Mall hours
INSERT INTO Horarios (id_tienda, numerodia, hora_inicio, hora_fin) VALUES (1006, 3, TO_DATE('01/01/2000 09:00','DD/MM/YYYY HH24:MI'), TO_DATE('22:00','HH24:MI'));

/* -------------------------------------------------------------------------
   13. FACTURA_VENTAS_TIENDA
   ------------------------------------------------------------------------- */
-- Venta 1: Maria (88) compra en la tienda de Francia (1001)
INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 10001, TO_DATE('15/12/2025 14:00','DD/MM/YYYY HH24:MI'), 88, 19.99);

-- Venta 2: Juan (99) compra en la tienda de Brasil Rio (1006)
INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1006, 20001, TO_DATE('20/01/2026 15:00','DD/MM/YYYY HH24:MI'), 99, 269.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 30001, TO_DATE('16/12/2025 14:00','DD/MM/YYYY HH24:MI'), 101, 19.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 40001, TO_DATE('17/12/2025 14:00','DD/MM/YYYY HH24:MI'), 102, 19.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 50001, TO_DATE('18/12/2025 14:00','DD/MM/YYYY HH24:MI'), 103, 39.98);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 60001, TO_DATE('19/12/2025 14:00','DD/MM/YYYY HH24:MI'), 104, 849.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 70001, TO_DATE('20/12/2025 14:00','DD/MM/YYYY HH24:MI'), 105, 19.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 80001, TO_DATE('21/12/2025 14:00','DD/MM/YYYY HH24:MI'), 106, 19.99);

INSERT INTO Factura_Ventas_Tienda (id_tienda, numeroventa, fecha_venta, id_lego_cliente, total)
VALUES (1001, 90001, TO_DATE('22/12/2025 14:00','DD/MM/YYYY HH24:MI'), 107, 19.99);

/* -------------------------------------------------------------------------
   14. DETALLE_FACTURA_VENTAS_TIENDA
   (OJO: Aquí vinculamos con el LOTE específico del Inventario que creamos antes)
   ------------------------------------------------------------------------- */
-- Detalle Venta 1 (Maria en Francia):
-- Compra 1 'The Creeper' (ID 101).
-- En el paso anterior, dijimos que la Tienda 1001 tiene el Lote 100102 de este juguete.
INSERT INTO Detalle_Factura_Ventas_Tienda (
    id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, 
    id_juguete_inv, id_tienda_inv, num_lote_inv
) VALUES (
    1001, 10001, 1, 1, 'ADULTO', 
    101, 1001, 100102
);

-- Detalle Venta 2 (Juan en Brasil):
-- Compra 1 'The Mighty Bowser' (ID 402).
-- En el paso anterior, la Tienda 1006 tiene el Lote 100601 de este juguete.
INSERT INTO Detalle_Factura_Ventas_Tienda (
    id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, 
    id_juguete_inv, id_tienda_inv, num_lote_inv
) VALUES (
    1006, 20001, 1, 1, 'ADULTO', 
    402, 1006, 100601
);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 30001, 1, 1, 'ADULTO', 101, 1001, 100102);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 40001, 1, 1, 'ADULTO', 101, 1001, 100102);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 50001, 1, 2, 'ADULTO', 101, 1001, 100102);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 60001, 1, 1, 'ADULTO', 201, 1001, 100101);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 70001, 1, 1, 'ADULTO', 101, 1001, 100102);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 80001, 1, 1, 'ADULTO', 101, 1001, 100102);

INSERT INTO Detalle_Factura_Ventas_Tienda (id_tienda_fac, numeroventa, id, cantidad, tipo_cliente, id_juguete_inv, id_tienda_inv, num_lote_inv)
VALUES (1001, 90001, 1, 1, 'ADULTO', 101, 1001, 100102);

/* -------------------------------------------------------------------------
   15. FACTURA_VENTAS_ONLINE
   (Nuevas columnas: gratis, puntos_generados)
   ------------------------------------------------------------------------- */
-- Venta Online 1: Juan (Desde Brasil) compra el Halcón Milenario
-- Precio: 849.99 (Rango D -> Genera 200 puntos)
INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (50001, TO_DATE('05/02/2026','DD/MM/YYYY'), 'NO', 99, 849.99, 200);

-- Venta Online 2: Maria (Desde Francia) compra R2-D2
-- Precio: 99.99 (Rango C -> Genera 50 puntos)
INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (50002, TO_DATE('10/02/2026','DD/MM/YYYY'), 'NO', 88, 99.99, 50);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60001, TO_DATE('15/03/2026','DD/MM/YYYY'), 'NO', 106, 6.29, 5);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60002, TO_DATE('18/03/2026','DD/MM/YYYY'), 'NO', 105, 22.99, 20);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60003, TO_DATE('20/03/2026','DD/MM/YYYY'), 'NO', 103, 20.99, 20);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60004, TO_DATE('22/03/2026','DD/MM/YYYY'), 'NO', 104, 52.49, 20);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60005, TO_DATE('25/03/2026','DD/MM/YYYY'), 'NO', 99, 91.99, 50);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60006, TO_DATE('01/04/2026','DD/MM/YYYY'), 'NO', 88, 104.99, 50);

INSERT INTO Factura_Ventas_Online (numeroventa, fecha_venta, gratis, id_lego_cliente, total, puntos_generados)
VALUES (60007, TO_DATE('05/04/2026','DD/MM/YYYY'), 'NO', 107, 20.99, 20);

/* -------------------------------------------------------------------------
   16. DETALLE_FACTURA_VENTAS_ONLINE
   (Vincula con CATALOGO_PAISES)
   ------------------------------------------------------------------------- */
-- Detalle Juan (Brasil): Compra Halcón Milenario (201).
-- Validamos que el juguete 201 esté en el catálogo de Brasil (Pais 6). ¡Sí está!
INSERT INTO Detalle_Factura_Ventas_Online (
    numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat
) VALUES (
    50001, 1, 1, 'ADULTO', 201, 6
);

-- Detalle Maria (Francia): Compra R2-D2 (202).
-- Validamos que el juguete 202 esté en el catálogo de Francia (Pais 1). ¡Sí está!
INSERT INTO Detalle_Factura_Ventas_Online (
    numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat
) VALUES (
    50002, 1, 1, 'ADULTO', 202, 1
);

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60001, 1, 1, 'ADULTO', 302, 2); -- Catálogo Portugal

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60002, 1, 1, 'ADULTO', 101, 3); -- Catálogo Malasia

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60003, 1, 1, 'ADULTO', 301, 4); -- Catálogo Grecia

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60004, 1, 1, 'ADULTO', 401, 5); -- Catálogo Hungría

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60005, 1, 1, 'ADULTO', 203, 6); -- Catálogo Brasil

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60006, 1, 1, 'ADULTO', 202, 1); -- Catálogo Francia

INSERT INTO Detalle_Factura_Ventas_Online (numeroventa, id, cantidad, tipo_cliente, id_juguete_cat, id_pais_cat)
VALUES (60007, 1, 1, 'ADULTO', 101, 1); -- Catálogo Francia

COMMIT;

/* -------------------------------------------------------------------------
   17. TABLA INSCRIPCIONES
   (Cabecera del grupo. Total calculado según costo del tour * personas)
   ------------------------------------------------------------------------- */
-- Inscripción 1: Para el Tour de Francia (15/12/2025). Costo tour: 150.00.
-- Van 2 personas (Juan y su hijo), Total = 300.00
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 1, TO_DATE('01/11/2025','DD/MM/YYYY'), 'PAGADO', 300.00);

-- Inscripción 2: Para el Tour de Grecia (05/03/2026). Costo tour: 120.00.
-- Va 1 persona (Maria), Total = 120.00
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 1, TO_DATE('01/02/2026','DD/MM/YYYY'), 'PENDIENTE', 120.00);

-- Inscripción 3: Tour Enero (10/01/2026). Cliente Michael (101) + Fan Tommy (12).
-- Costo Tour: 200.00. Total = 400.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 1, TO_DATE('15/12/2025','DD/MM/YYYY'), 'PAGADO', 400.00);

-- Inscripción 4: Tour Febrero (20/02/2026). Cliente Kenji (102) + Fan Akira (13).
-- Costo Tour: 180.00. Total = 360.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 1, TO_DATE('10/01/2026','DD/MM/YYYY'), 'PAGADO', 360.00);

-- Inscripción 5: Tour Marzo (05/03/2026). Cliente Elena (103) + Fan Nikos (14).
-- OJO: Ya existía la inscripción 1 para esta fecha, así que esta es la 2.
-- Costo Tour: 120.00. Total = 240.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 2, TO_DATE('15/01/2026','DD/MM/YYYY'), 'PAGADO', 240.00);

-- Inscripción 6: Tour Abril (15/04/2026). Cliente Laszlo (104) + Fan Julia (15).
-- Costo Tour: 160.00. Total = 320.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 1, TO_DATE('20/02/2026','DD/MM/YYYY'), 'PAGADO', 320.00);

-- Inscripción 7: Tour Mayo (20/05/2026). Cliente Siti (105) + Fan Amir (17).
-- Costo Tour: 175.50. Total = 351.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 1, TO_DATE('25/03/2026','DD/MM/YYYY'), 'PAGADO', 351.00);

-- Inscripción 8: Tour Junio (10/06/2026). Cliente Joao (106) + Fan Pedro (18).
-- Costo Tour: 210.00. Total = 420.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 1, TO_DATE('10/04/2026','DD/MM/YYYY'), 'PAGADO', 420.00);

-- Inscripción 9: Tour Julio (15/07/2026). Cliente Sophie (107) + Fan Clara (16).
-- Costo Tour: 250.00. Total = 500.00.
INSERT INTO Inscripciones (fecha_tour, numeroinscripcion, fecha_inscripcion, estatus, total)
VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 1, TO_DATE('15/05/2026','DD/MM/YYYY'), 'PAGADO', 500.00);

/* -------------------------------------------------------------------------
   18. TABLA ENTRADAS
   (Define el tipo de ticket: ADULTO, JOVEN, MENOR)
   ------------------------------------------------------------------------- */
-- Tickets para la Inscripción 1 (Francia)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo)
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 1, 101, 'ADULTO'); -- Ticket de Juan

INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo)
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 1, 102, 'MENOR'); -- Ticket de Carlitos

-- Tickets para la Inscripción 2 (Grecia)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo)
VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 1, 201, 'ADULTO'); -- Ticket de Maria

-- Entradas Inscripción 3 (10/01/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Michael
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 1, 2, 'JOVEN');  -- Tommy (13)

-- Entradas Inscripción 4 (20/02/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Kenji
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 1, 2, 'ADULTO'); -- Akira (19)

-- Entradas Inscripción 5 (05/03/2026 - Insc #2)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 2, 1, 'ADULTO'); -- Elena
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 2, 2, 'JOVEN');  -- Nikos (16)

-- Entradas Inscripción 6 (15/04/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Laszlo
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 1, 2, 'ADULTO'); -- Julia (20)

-- Entradas Inscripción 7 (20/05/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Siti
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 1, 2, 'ADULTO'); -- Amir (18)

-- Entradas Inscripción 8 (10/06/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Joao
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 1, 2, 'JOVEN');  -- Pedro (15)

-- Entradas Inscripción 9 (15/07/2026)
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 1, 1, 'ADULTO'); -- Sophie
INSERT INTO Entradas (fecha_tour_ins, numeroinscripcion, numeroentrada, tipo) VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 1, 2, 'JOVEN');  -- Clara (12)

/* -------------------------------------------------------------------------
   19. TABLA DETALLE_INSCRIPCIONES
   (Vincula a la persona específica: Cliente O Fan)
   ------------------------------------------------------------------------- */
-- Participantes de la Inscripción 1 (Francia)
-- 1. Juan (Cliente 99)
INSERT INTO Detalle_Inscripciones (fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan)
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 1, 1, 99, NULL);

-- 2. Carlitos (Fan 10)
INSERT INTO Detalle_Inscripciones (fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan)
VALUES (TO_DATE('15/12/2025','DD/MM/YYYY'), 1, 2, NULL, 10);


-- Participantes de la Inscripción 2 (Grecia)
-- 1. Maria (Cliente 88)
INSERT INTO Detalle_Inscripciones (fecha_tour_ins, numeroinscripcion, id, id_lego_cli, id_lego_fan)
VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 1, 1, 88, NULL);

-- Detalle Insc 3 (Michael + Tommy)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 1, 1, 101, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('10/01/2026','DD/MM/YYYY'), 1, 2, NULL, 12);

-- Detalle Insc 4 (Kenji + Akira)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 1, 1, 102, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('20/02/2026','DD/MM/YYYY'), 1, 2, NULL, 13);

-- Detalle Insc 5 (Elena + Nikos - OJO Insc #2)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 2, 1, 103, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('05/03/2026','DD/MM/YYYY'), 2, 2, NULL, 14);

-- Detalle Insc 6 (Laszlo + Julia)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 1, 1, 104, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('15/04/2026','DD/MM/YYYY'), 1, 2, NULL, 15);

-- Detalle Insc 7 (Siti + Amir)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 1, 1, 105, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('20/05/2026','DD/MM/YYYY'), 1, 2, NULL, 17);

-- Detalle Insc 8 (Joao + Pedro)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 1, 1, 106, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('10/06/2026','DD/MM/YYYY'), 1, 2, NULL, 18);

-- Detalle Insc 9 (Sophie + Clara)
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 1, 1, 107, NULL);
INSERT INTO Detalle_Inscripciones VALUES (TO_DATE('15/07/2026','DD/MM/YYYY'), 1, 2, NULL, 16);

COMMIT;

/* -------------------------------------------------------------------------
   20. TABLA DESCUENTO_LOTES
   (Aplicamos descuentos a lotes específicos del inventario existente)
   ------------------------------------------------------------------------- */

-- Descuento del 20% en Francia (Tienda 1001) para el lote de Creepers (101)
-- Lote referenciado: 100102 (creado en el bloque de inventario)
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 1, TO_DATE('01/12/2025','DD/MM/YYYY'), 20.00);

-- Descuento del 15% en Brasil Rio (Tienda 1006) para el lote de Bowser (402)
-- Lote referenciado: 100601
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (402, 1006, 100601, 1, TO_DATE('01/02/2026','DD/MM/YYYY'), 15.00);

-- Descuento del 10% en Grecia (Tienda 1004) para el lote de Sonic (301)
-- Lote referenciado: 100401
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (301, 1004, 100401, 1, TO_DATE('15/04/2026','DD/MM/YYYY'), 10.00);

-- 1. Reserva para la Venta 3 (Michael - Juguete 101 - Lote 100102)
-- ID 2 (Porque el ID 1 ya se usó en el insert anterior para este lote)
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 2, TO_DATE('16/12/2025','DD/MM/YYYY'), 1.00);

-- 2. Reserva para la Venta 4 (Kenji - Juguete 101 - Lote 100102)
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 3, TO_DATE('17/12/2025','DD/MM/YYYY'), 1.00);

-- 3. Reserva para la Venta 5 (Elena - Juguete 101 - Lote 100102)
-- Llevó 2 unidades
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 4, TO_DATE('18/12/2025','DD/MM/YYYY'), 2.00);

-- 4. Reserva para la Venta 6 (Laszlo - Juguete 201 - Lote 100101)
-- Este es el Halcón Milenario. Es el primer descuento de este lote, así que ID = 1.
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (201, 1001, 100101, 1, TO_DATE('19/12/2025','DD/MM/YYYY'), 1.00);

-- 5. Reserva para la Venta 7 (Siti - Juguete 101 - Lote 100102)
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 5, TO_DATE('20/12/2025','DD/MM/YYYY'), 1.00);

-- 6. Reserva para la Venta 8 (Joao - Juguete 101 - Lote 100102)
INSERT INTO Descuento_Lotes (id_juguete_inv, id_tienda_inv, num_lote, id, fecha, cantidad)
VALUES (101, 1001, 100102, 6, TO_DATE('21/12/2025','DD/MM/YYYY'), 1.00);

/* -------------------------------------------------------------------------
   21. TABLA PROD_RELACIONES
   (Productos sugeridos / relacionados por temática)
   ------------------------------------------------------------------------- */

-- Relaciones Minecraft: Si compras el Creeper (101), te sugerimos la Mina (103)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (101, 103);
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (103, 101); -- Relación inversa

-- Relaciones Star Wars: Si compras el Halcón (201), te sugerimos a R2-D2 (202)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (201, 202);
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (204, 203); -- Death Star con Casco Vader

-- Relaciones Mario: Bowser (402) se relaciona con el Castillo de Bowser (404)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (402, 404);
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (401, 404); -- Kart con Pista

-- Relaciones Sonic: Shadow (301) se relaciona con Metal Sonic (303) por rivalidad
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (301, 303);

-- Inversa: Si ves a Metal Sonic (303), te sugerimos a Shadow (301)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (303, 301);

-- Relaciones Star Wars: Si compras el Halcón Milenario (201), quizás quieras la Estrella de la Muerte (204)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (201, 204);

-- Relaciones Minecraft: El Dragón del Ender (104) combina bien con la fortaleza del Lobo (102)
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) VALUES (104, 102);

-- Relaciones Villanos Mario: Bowser -> Planta Piraña
INSERT INTO Prod_Relaciones (id_juguete_1, id_juguete_2) 
VALUES (402, 403);

/* -------------------------------------------------------------------------
   23. TABLA TELEFONOS
   (Códigos de país reales: Francia=33, Portugal=351, Malasia=60, Grecia=30, Brasil=55)
   ------------------------------------------------------------------------- */

-- Francia (1001)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1001, 1, 494, 33, 12345678);

-- Portugal (1002)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1002, 1, 210, 351, 98765432);

-- Malasia (1003)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1003, 1, 3, 60, 21415555);

-- Grecia (1004)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1004, 1, 210, 30, 55566677);

-- Hungria (1005)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1005, 1, 1, 36, 33344455);

-- Brasil Rio (1006)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1006, 1, 21, 55, 99988776);

-- Brasil SP (1007)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1007, 1, 11, 55, 98877665);

-- Auckland Nueva Zelanda (1008)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1008, 1, 9, 64, 52012345);

-- Línea Secundaria/Soporte para la Tienda 1001 (Francia)
INSERT INTO Telefonos (id_tienda, id, cod_area, cod_pais, numero) 
VALUES (1001, 2, 494, 33, 12345679);

COMMIT;