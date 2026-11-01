-- Escenario 3: Recuperación parcial con SAVEPOINT
BEGIN;

-- 1. Insertar cabecera
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_country, total)
VALUES (3, CURRENT_TIMESTAMP, 'Prueba Savepoint', 'Guatemala', 'Guatemala', 0.00);

-- 2. Insertar dos detalles válidos
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES 
    (currval('invoice_invoice_id_seq'), 10, 0.99, 1),
    (currval('invoice_invoice_id_seq'), 11, 0.99, 1);

-- 3. Crear punto de restauración previo a la operación de riesgo
SAVEPOINT sp_detalle_riesgoso;

-- 4. Intentar inserción inválida que falla
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (currval('invoice_invoice_id_seq'), 999999, 0.99, 1);

-- 5. Revertir únicamente hasta el SAVEPOINT
ROLLBACK TO SAVEPOINT sp_detalle_riesgoso;

-- 6. Insertar detalle corregido válido
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (currval('invoice_invoice_id_seq'), 12, 1.99, 1);

-- 7. Actualizar el total de la factura
UPDATE invoice
SET total = (
    SELECT SUM(unit_price * quantity)
    FROM invoice_line
    WHERE invoice_id = currval('invoice_invoice_id_seq')
)
WHERE invoice_id = currval('invoice_invoice_id_seq');

-- 8. Confirmar permanentemente la transacción
COMMIT;

-- 9. Consulta de comprobación final (Evidencia Factura 415)
SELECT 
    i.invoice_id,
    i.customer_id,
    i.total AS total_registrado,
    COUNT(l.invoice_line_id) AS cantidad_detalles,
    SUM(l.unit_price * l.quantity) AS suma_detalles
FROM invoice i
JOIN invoice_line l ON i.invoice_id = l.invoice_id
WHERE i.invoice_id = currval('invoice_invoice_id_seq')
GROUP BY i.invoice_id, i.customer_id, i.total;
