-- Escenario 2: Error por Foreign Key y reversión completa (Rollback)
BEGIN;

-- 1. Insertar cabecera
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_country, total)
VALUES (1, CURRENT_TIMESTAMP, 'Prueba Rollback', 'Guatemala', 'Guatemala', 0.00);

-- 2. Insertar detalle válido
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (currval('invoice_invoice_id_seq'), 1, 0.99, 1);

-- 3. Provocar violación de FK con un track_id inexistente (999999)
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
VALUES (currval('invoice_invoice_id_seq'), 999999, 0.99, 1);
-- Error capturado: insert or update on table "invoice_line" violates foreign key constraint

-- 4. Revertir totalmente la transacción abortada
ROLLBACK;

-- 5. Comprobar que no existe la factura ni sus detalles (debe retornar 0 filas)
SELECT * 
FROM invoice 
WHERE invoice_id = currval('invoice_invoice_id_seq');
