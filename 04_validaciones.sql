-- Escenario 4: Visibilidad entre sesiones (Read Committed)

-- --- DESDE CONEXIÓN A ---
BEGIN;
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_country, total)
VALUES (1, CURRENT_TIMESTAMP, 'Prueba Visibilidad A/B', 'Guatemala', 'Guatemala', 0.00);
-- Transacción abierta sin COMMIT

-- --- DESDE CONEXIÓN B ---
-- Consulta antes del COMMIT en A (retorna 0 filas)
SELECT * FROM invoice WHERE invoice_id = 416;

-- --- DESDE CONEXIÓN A ---
COMMIT;

-- --- DESDE CONEXIÓN B ---
-- Consulta después del COMMIT en A (retorna 1 fila)
SELECT * FROM invoice WHERE invoice_id = 416;
