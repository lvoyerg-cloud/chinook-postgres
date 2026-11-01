# Proyecto Chinook: Control Transaccional y Consultas SQL en PostgreSQL

Este repositorio contiene la solución completa a la evaluación de **Control Transaccional (Venta Atómica)** y las consultas de análisis sobre la base de datos **Chinook** utilizando **PostgreSQL 16** y la herramienta cliente **pgAdmin 4** (o la herramienta CLI `psql`).

---

## 🛠️ Entorno y Preparación

* **Motor de Base de Datos:** PostgreSQL 16 (verificado mediante `SELECT version();`)
* **Cliente GUI / CLI:** pgAdmin 4 / `psql`
* **Base de Datos:** Local dedicada `chinook`
* **Esquema / Script de Importación:** Variante oficial `Chinook_PostgreSql_SerialPKs.sql` (tablas utilizadas: `customer`, `invoice`, `invoice_line` y `track`).

### Pasos de Importación (pgAdmin 4)
1. Abrir **pgAdmin 4** y conectar al servidor local `PostgreSQL 16`.
2. Crear una base de datos vacía llamada `chinook` (o usar la base predeterminada `postgres`).
3. Abrir la herramienta **Query Tool** (`CTRL + SHIFT + Q`) sobre la base de datos.
4. Abrir el archivo ejecutable `Chinook_PostgreSql_SerialPKs.sql`.
5. Ejecutar la estructura e inserción de datos iniciales (`F5`).

---

## ⚡ Guía de Control Transaccional (Escenarios 1 al 4)

### ⚙️ Configuración de Conexiones y Autocommit
* **Sesiones:** Para realizar las demostraciones de aislamiento y visibilidad, se requieren **dos conexiones independientes** (Conexión A y Conexión B). En pgAdmin 4 se obtienen abriendo dos pestañas independientes de **Query Tool** conectadas a la base de datos `chinook`.
* **Modo de Autocommit:** Desactivado explícitamente en el bloque transaccional mediante el uso de límites explícitos `BEGIN;` ... `COMMIT;` / `ROLLBACK;`.
* **Nivel de Aislamiento:** `Read Committed` (nivel predeterminado en PostgreSQL).

---

### 📋 Orden de Ejecución y Repetición de Pruebas

Los scripts de control transaccional deben ejecutarse en el orden indicado a continuación. Cada script es autosuficiente y está preparado para repetirse sobre la copia limpia de Chinook.

#### 1. `01_venta_exitosa.sql` (Escenario 1: Venta Completa y Coherencia del Total)
* **Objetivo:** Registrar una venta atómica completa con cabecera y 3 detalles válidos, garantizando el cálculo dinámico del total y confirmando con `COMMIT`.
* **Conexión:** Conexión A.
* **Sustitución / Parámetros:** El script utiliza la sentencia `RETURNING invoice_id` al insertar la factura. Si ejecuta el script por bloques, reemplace manualmente la variable de `invoice_id` (por ejemplo, `413`) en las inserciones de `invoice_line` y en el `UPDATE`.
* **Verificación:** Ejecutar la consulta final del script. Debe retornar `cantidad_detalles = 3` y la coincidencia exacta entre `total_registrado` y `suma_detalles`.

#### 2. `02_rollback_total.sql` (Escenario 2: Error por FK y Reversión Completa)
* **Objetivo:** Demostrar la propiedad de Atomicidad mediante la reversión total (`ROLLBACK`) al provocar una falla real de Foreign Key (`track_id` inexistente `999999`).
* **Conexión:** Conexión A.
* **Comportamiento en pgAdmin:** Al fallar la inserción de la Foreign Key, PostgreSQL marca la transacción en estado abortado (`INERROR`). Se ejecuta `ROLLBACK;` para limpiar la sesión.
* **Verificación:** La consulta `SELECT * FROM invoice WHERE invoice_id = currval('invoice_invoice_id_seq');` debe devolver exactamente **0 filas**, demostrando que no quedaron registros huérfanos de la cabecera.

#### 3. `03_savepoint.sql` (Escenario 3: Recuperación Parcial con SAVEPOINT)
* **Objetivo:** Demostrar la conservación de operaciones válidas previas mediante un `SAVEPOINT` ante un error en un detalle.
* **Conexión:** Conexión A.
* **Instrucciones de Ejecución:**
  1. Se crea la cabecera y 2 detalles válidos.
  2. Se establece `SAVEPOINT sp_detalle_riesgoso;`.
  3. Se intenta insertar una canción inexistente (`track_id = 999999`) y ocurre el error de FK.
  4. Se ejecuta `ROLLBACK TO SAVEPOINT sp_detalle_riesgoso;` para deshacer únicamente el intento fallido.
  5. Se inserta un detalle válido corregido, se actualiza el total calculado y se finaliza con `COMMIT;`.
* **Diferencia Técnica:** `RELEASE SAVEPOINT` elimina la marca del punto de restauración sin aplicar ni confirmar cambios; **no equivale a `COMMIT`**, ya que solo `COMMIT` persiste permanentemente los datos en disco.

#### 4. `04_validaciones.sql` (Escenario 4: Visibilidad entre Sesiones)
* **Objetivo:** Comprobar el aislamiento de datos no confirmados entre dos sesiones independientes.
* **Pasos de Ejecución:**
  1. **Conexión A:** Iniciar transacción (`BEGIN;`) e insertar cabecera (ej. Factura `416`). **NO ejecutar COMMIT todavía.**
  2. **Conexión B:** Consultar `SELECT * FROM invoice WHERE invoice_id = 416;`. **Resultado:** 0 filas (Los datos en transacción no son visibles para otros usuarios).
  3. **Conexión A:** Ejecutar `COMMIT;`.
  4. **Conexión B:** Repetir la consulta `SELECT * FROM invoice WHERE invoice_id = 416;`. **Resultado:** 1 fila visible.

---

## 🧠 Explicación Técnica (Propiedades ACID y PostgreSQL)

* **Atomicidad (A):** Todo o nada. Si una sola sentencia dentro del bloque `BEGIN ... COMMIT` falla, toda la transacción debe revertirse (`ROLLBACK`), impidiendo que queden cabeceras de facturas sin detalles.
* **Consistencia (C):** Se garantiza mediante las restricciones de integridad referencial (`FOREIGN KEY`) entre `invoice_line` y `track`, y reglas numéricas. El total registrado coincide con la suma aritmética real de sus líneas.
* **Aislamiento (I):** En el nivel `Read Committed`, las lecturas sucias (*dirty reads*) son imposibles. Los cambios realizados por la Conexión A permanecen invisibles para la Conexión B hasta que la Conexión A ejecute `COMMIT`.
* **Durabilidad (D):** Una vez ejecutado `COMMIT`, los cambios quedan guardados permanentemente en las tablas físicas mediante el registro de escritura previa en disco (*Write-Ahead Logging* - WAL).
* **Comportamiento de Secuencias:** Las secuencias (`sequences`) operan fuera del control de las transacciones para evitar bloqueos concurrentes. Si una transacción aborta o ejecuta `ROLLBACK`, los valores tomados de la secuencia **no se devuelven**, generando huecos naturales en la correlación de identificadores (`invoice_id`).

---

## 📊 Consultas SQL de Análisis e Información General

### Apartado 1: Directorio de Clientes
**Pregunta de negocio:** ¿Cuál es el directorio de contacto principal de los clientes registrados?

```sql
SELECT customer_id AS id_cliente, first_name AS nombre, last_name AS apellido, email AS correo_electronico FROM customer;
