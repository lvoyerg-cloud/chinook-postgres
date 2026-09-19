-- ============================================================================
-- TAREA CHINOOK: CONSULTAS SOBRE UNA TABLA (PostgreSQL)
-- ============================================================================

-- 1. Directorio de clientes
SELECT customer_id AS id_cliente, first_name AS nombre, last_name AS apellido, email AS correo_electronico FROM customer;

-- 2. Países representados
SELECT DISTINCT country AS pais FROM customer ORDER BY pais ASC;

-- 3. Criterio numérico
SELECT track_id, name, milliseconds, unit_price FROM track WHERE milliseconds > 240000 AND unit_price = 0.99;

-- 4. Alternativas controladas
SELECT customer_id, first_name, country, company FROM customer WHERE (country = 'Brazil' OR country = 'Argentina') AND company IS NULL;

-- 5. Pertenencia
SELECT customer_id, first_name, last_name, country FROM customer WHERE country IN ('Brazil', 'Argentina', 'Chile');

-- 6. Intervalo
SELECT track_id, name, milliseconds FROM track WHERE milliseconds BETWEEN 180000 AND 300000;

-- 7. Patrones (LIKE / ILIKE)
SELECT track_id, name FROM track WHERE name LIKE 'Love%';
SELECT track_id, name FROM track WHERE name ILIKE 'love%';

-- 8. Ausencias (IS NULL / IS NOT NULL)
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NULL;
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NOT NULL;

-- 9. Ranking
SELECT track_id, name, milliseconds FROM track ORDER BY milliseconds DESC, track_id ASC LIMIT 10;

-- 10. Paginación
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 0;
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 5;
