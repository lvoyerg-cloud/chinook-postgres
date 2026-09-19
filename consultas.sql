-- Apartado 1: Directorio de Clientes
SELECT customer_id AS id_cliente, first_name AS nombre, last_name AS apellido, email AS correo_electronico FROM customer;

-- Apartado 2: Paises Representados
SELECT DISTINCT country AS pais FROM customer ORDER BY pais ASC;

-- Apartado 3: Criterio Numerico
SELECT track_id, name, milliseconds, unit_price FROM track WHERE milliseconds > 240000 AND unit_price = 0.99;

-- Apartado 4: Alternativas Controladas
SELECT customer_id, first_name, country, company FROM customer WHERE (country = 'Brazil' OR country = 'Argentina') AND company IS NULL;

-- Apartado 5: Pertenencia
SELECT customer_id, first_name, last_name, country FROM customer WHERE country IN ('Brazil', 'Argentina', 'Chile');

-- Apartado 6: Intervalo
SELECT track_id, name, milliseconds FROM track WHERE milliseconds BETWEEN 180000 AND 300000;

-- Apartado 7: Patrones
SELECT track_id, name FROM track WHERE name LIKE 'Love%%';
SELECT track_id, name FROM track WHERE name ILIKE 'love%%';

-- Apartado 8: Ausencias
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NULL;
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NOT NULL;

-- Apartado 9: Ranking
SELECT track_id, name, milliseconds FROM track ORDER BY milliseconds DESC, track_id ASC LIMIT 10;

-- Apartado 10: Paginacion
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 0;
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 5;
