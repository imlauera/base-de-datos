/*
  Trabajo Práctico Nº 3.
*/

CREATE DATABASE `TP3`;
USE `TP3`

/*
  Ejercicio 1.
*/

CREATE TABLE `autor` (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nombre` varchar(30) NOT NULL,
  `apellido` varchar(30) NOT NULL,
  `nacionalidad` varchar(50) NOT NULL,
  `residencia` varchar(50) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `libro` (
  `isbn` varchar(50) NOT NULL PRIMARY KEY,
  `titulo` varchar(100) NOT NULL,
  `editorial` varchar(50) NOT NULL,
  `precio` float,
  `moneda` varchar(10) NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `escribe` (
  `id_autor` int NOT NULL,
  `id_isbn` varchar(50) NOT NULL,
  `year` int,
  FOREIGN KEY (`id_autor`) REFERENCES `autor`(`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`id_isbn`)  REFERENCES `libro`(`isbn`) ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* 
  Ejercicio 2.
*/
ALTER TABLE libro ADD INDEX (titulo);
ALTER TABLE autor ADD INDEX (apellido);


/*
  Ejercicio 3.
*/
INSERT INTO autor (nombre,apellido,nacionalidad,residencia) VALUES ('Andrew Stuart','Tanenbaum','Países Bajos','Ámsterdam');
INSERT INTO libro (isbn,titulo,editorial,precio,moneda) VALUES ('978-0133591620','Modern Operating Systems','Prentice Hall',199.74,'dólar');
INSERT INTO escribe (id_autor,id_isbn,year) VALUES (1,'978-0133591620','1998');

/*
  Ejercicio 4.
*/
/* a. El autor Aberlardo Castillo se mudó a Buenos Aires. */
UPDATE autor SET residencia="Buenos Aires" WHERE nombre="Aberlardo" and apellido="Castillo";
/* b. Todos los libros de la editorial UNR aumentan un 10% */
UPDATE libro SET precio=(precio+((10*precio)/100)) WHERE editorial="UNR";
/* c. Todos los libros de los autores extranjeros aumentan su precio en un 20%, excepto si éste ya es mayor
a $200, en tal caso el aumento es del 10%. */

CREATE VIEW autores_extranjeros AS
SELECT id FROM autor WHERE autor.nacionalidad <> "Argentina";

UPDATE libro SET libro.precio = libro.precio*1.1
WHERE libro.isbn IN (SELECT id_isbn FROM autores_extranjeros,escribe WHERE autores_extranjeros.id = escribe.id_autor) and libro.precio > 200;

UPDATE libro SET libro.precio = libro.precio*1.2
WHERE libro.isbn IN (SELECT id_isbn FROM autores_extranjeros,escribe WHERE autores_extranjeros.id = escribe.id_autor) and libro.precio <= 200;

/* d. Borrar todos los libros publicados en el año 1988. */
DELETE FROM libro WHERE isbn in (SELECT id_isbn FROM escribe WHERE year = 1988)

/*
  Ejercicio 5.
*/ 

/* a. Obtener los nombres de los dueños de los inmuebles. */ 
SELECT nombre,apellido FROM Persona,Propietario WHERE Persona.codigo=Propietario.codigo;
/* b. Obtener todos los códigos de los inmuebles cuyo precio está en el intervalo 600.000 a 700.000 inclusive.*/
SELECT codigo FROM Inmueble AS inm WHERE inm.precio >= 600000 and inm.precio <= 700000
/* c. Obtener los nombres de los clientes que prefieran inmuebles sólo en la zona Norte de Santa Fé.*/
SELECT nombre,apellido FROM Persona,Cliente WHERE Persona.codigo=Cliente.codigo and
Cliente.codigo in (SELECT codigo_cliente FROM PrefiereZona WHERE PrefiereZona.nombre_zona = "Norte" and PrefiereZona.nombre_poblacion = "Santa Fe");
/* d. Obtener los nombres de los empleados que atiendan a algún cliente que prefiera la zona Centro de Rosario.*/
SELECT Persona.nombre,Persona.apellido FROM Persona,Vendedor WHERE Persona.codigo=Vendedor.codigo and
Vendedor.codigo in (SELECT DISTINCT vendedor FROM Cliente WHERE Cliente.codigo in (SELECT codigo_cliente FROM PrefiereZona
WHERE PrefiereZona.nombre_zona = "Centro" and PrefiereZona.nombre_poblacion = "Rosario"));

/* e. Obtener los nombres de los vendedores que atienden a otros vendedores.*/

/* Cálculo auxiliar: El código del cliente tiene que formar parte de la tabla de vendedores. */
SELECT vendedor from Cliente where Cliente.codigo IN (SELECT Vendedor.codigo from Vendedor);
/* Resultado: Obtengo el nombre completo del vendedor que atiende a dicho cliente/vendedor. */
SELECT nombre,apellido from Persona where Persona.codigo IN (SELECT vendedor from Cliente where Cliente.codigo IN (SELECT Vendedor.codigo from Vendedor));

/* f. Obtener los nombres de los clientes que prefieran únicamente inmuebles en TODAS las zonas de Rosario. Es decir un cliente 
que prefiera Centro,Sur,Norte,Oeste a la vez. */

/* El cliente que prefiere Rosario debería tener 4 zonas preferidas. Las contamos así:  */
CREATE VIEW ClientesTodasLasZonas AS 
SELECT codigo_cliente,COUNT(*) FROM PrefiereZona where nombre_poblacion="Rosario" GROUP BY codigo_cliente HAVING COUNT(*) = 4;

/* El código del cliente tiene que formar parte de la vista/tabla de los clientes que prefieren todas las zonas.*/
SELECT nombre,apellido FROM Persona WHERE Persona.codigo IN (SELECT Cliente.codigo from Cliente,ClientesTodasLasZonas where Cliente.codigo IN (SELECT codigo_cliente FROM ClientesTodasLasZonas));


/* g. Hay clientes que ya visitaron o tienen programado visitar los inmuebles de sus zonas favoritas 
(un cliente que no tenga zonas de preferencia no entrará en esta categoría).
Para cada uno de ellos, obtener su nombre junto con información de los inmuebles (código,zona y precio)
ubicados en zonas no preferidas por ellos pero sí limítrofes a alguna de ellas.*/

/* un cliente que no tenga zonas de prefierencia no entrará en esta categoría.*/
CREATE VIEW Cliente_ZonaPreferencia AS
SELECT DISTINCT codigo_cliente,nombre_poblacion,nombre_zona FROM Cliente,PrefiereZona WHERE Cliente.codigo=PrefiereZona.codigo_cliente;

CREATE VIEW ClientePrefiereZona_Nombre AS
SELECT DISTINCT codigo_cliente,nombre_poblacion,nombre_zona,nombre,apellido FROM Cliente_ZonaPreferencia,Persona WHERE Persona.codigo=Cliente_ZonaPreferencia.codigo_cliente;

/* Hacemos una tabla auxiliar para ayudarnos en el cálculo de las zonas limítrofes. */
CREATE VIEW LimitaFix AS
SELECT * FROM Limita  UNION  SELECT nombre_poblacion_2, nombre_zona_2, nombre_poblacion, nombre_zona  FROM Limita;

/* Calculamos zonas limítrofes a las zonas de preferencia del cliente.*/
CREATE VIEW ClienteFinal AS
SELECT DISTINCT codigo_cliente,nombre,apellido,nombre_poblacion_2,nombre_zona_2 FROM LimitaFix,ClientePrefiereZona_Nombre WHERE ClientePrefiereZona_Nombre.nombre_poblacion=LimitaFix.nombre_poblacion and ClientePrefiereZona_Nombre.nombre_zona=LimitaFix.nombre_zona;

/* Para cada uno de ellos, obtener su nombre, junto con la información de los inmuebles(código, zona y precio) ubicados en zonas limítrofes a las prefereidas por el cliente.*/
SELECT DISTINCT nombre,apellido,codigo,precio,nombre_poblacion,nombre_zona FROM Inmueble,ClienteFinal WHERE ClienteFinal.nombre_poblacion_2=Inmueble.nombre_poblacion and ClienteFinal.nombre_zona_2 = Inmueble.nombre_zona ORDER BY nombre;

