-- Escenario 1: Venta exitosa y comprobación de total
BEGIN;

-- 1. Insertar factura y obtener su ID dinámicamente
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_country, total)
VALUES (1, CURRENT_TIMESTAMP, 'Prueba Venta Exitosa', 'Guatemala', 'Guatemala', 0.00)
RETURNING invoice_id;

-- 2. Insertar detalles
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES 
    (413, 1, 0.99, 1),
    (413, 2, 0.99, 1),
    (413, 3, 2.98, 1);

-- 3. Actualizar el total calculado mediante la suma de detalles
UPDATE invoice
SET total = (
    SELECT SUM(unit_price * quantity)
    FROM invoice_line
    WHERE invoice_id = 413
)
WHERE invoice_id = 413;

-- 4. Confirmar transacción
COMMIT;

-- 5. Consulta de comprobación final (Evidencia)
SELECT 
    i.invoice_id,
    i.customer_id,
    i.total AS total_registrado,
    COUNT(l.invoice_line_id) AS cantidad_detalles,
    SUM(l.unit_price * l.quantity) AS suma_detalles
FROM invoice i
JOIN invoice_line l ON i.invoice_id = l.invoice_id
WHERE i.invoice_id = 413
GROUP BY i.invoice_id, i.customer_id, i.total;
