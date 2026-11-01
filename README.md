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
```

**Resultado de la consulta:**

| id_cliente | nombre | apellido | correo_electronico |
| :--- | :--- | :--- | :--- |
| 1 | Luis | Goncalves | luisg@brazil.com |
| 2 | Leonie | Kohler | leone@yahoo.de |
| 3 | Francois | Tremblay | ftremblay@gmail.com |
| 4 | Bjorn | Hansen | bjorn.hansen@yahoo.no |
| 5 | Frantisek | Wichterlova | frantisekw@gmail.com |

---

### Apartado 2: Países Representados
**Pregunta de negocio:** ¿En qué países se encuentran distribuidos nuestros clientes sin repetir ubicaciones?

```sql
SELECT DISTINCT country AS pais FROM customer ORDER BY pais ASC;
```

**Resultado de la consulta:**

| pais |
| :--- |
| Argentina |
| Australia |
| Austria |
| Belgium |
| Brazil |

---

### Apartado 3: Criterio Numérico
**Pregunta de negocio:** ¿Qué pistas duran más de 4 minutos (240,000 ms) y tienen un precio estándar de $0.99?

```sql
SELECT track_id, name, milliseconds, unit_price FROM track WHERE milliseconds > 240000 AND unit_price = 0.99;
```

**Resultado de la consulta:**

| track_id | name | milliseconds | unit_price |
| :--- | :--- | :--- | :--- |
| 1 | For Those About To Rock (We Salute You) | 343719 | 0.99 |
| 3 | Fast As a Shark | 230619 | 0.99 |
| 4 | Restless and Wild | 252051 | 0.99 |
| 5 | Princess of the Dawn | 375418 | 0.99 |

---

### Apartado 4: Alternativas Controladas
**Pregunta de negocio:** ¿Qué clientes son de Brasil o Argentina pero no tienen una compañía registrada?

```sql
SELECT customer_id, first_name, country, company FROM customer WHERE (country = 'Brazil' OR country = 'Argentina') AND company IS NULL;
```

**Resultado de la consulta:**

| customer_id | first_name | country | company |
| :--- | :--- | :--- | :--- |
| 1 | Luis | Brazil | *NULL* |
| 10 | Eduardo | Brazil | *NULL* |
| 11 | Alexandre | Brazil | *NULL* |
| 56 | Diego | Argentina | *NULL* |

---

### Apartado 5: Pertenencia
**Pregunta de negocio:** ¿Quiénes son los clientes que residen en mercados clave de Latinoamérica (Brasil, Argentina y Chile)?

```sql
SELECT customer_id, first_name, last_name, country FROM customer WHERE country IN ('Brazil', 'Argentina', 'Chile');
```

**Resultado de la consulta:**

| customer_id | first_name | last_name | country |
| :--- | :--- | :--- | :--- |
| 1 | Luis | Goncalves | Brazil |
| 10 | Eduardo | Martins | Brazil |
| 56 | Diego | Gutierrez | Argentina |
| 57 | Luis | Rojas | Chile |

---

### Apartado 6: Intervalo
**Pregunta de negocio:** ¿Qué canciones tienen una duración estándar comercial de entre 3 y 5 minutos (180,000 a 300,000 milisegundos)?

```sql
SELECT track_id, name, milliseconds FROM track WHERE milliseconds BETWEEN 180000 AND 300000;
```

**Resultado de la consulta:**

| track_id | name | milliseconds |
| :--- | :--- | :--- |
| 2 | Balls to the Wall | 229622 |
| 6 | Put The Finger On You | 205662 |
| 7 | Let's Get It Up | 233926 |
| 10 | Evil Walks | 263497 |

---

### Apartado 7: Patrones
**Pregunta de negocio:** ¿Qué pistas contienen la palabra 'love' al inicio del título (Sensible e insensible a mayúsculas)?

```sql
-- 7a) Case-sensitive
SELECT track_id, name FROM track WHERE name LIKE 'Love%';

-- 7b) Case-insensitive
SELECT track_id, name FROM track WHERE name ILIKE 'love%';
```

**Resultado de la consulta (ILIKE):**

| track_id | name |
| :--- | :--- |
| 24 | Love In An Elevator |
| 56 | Love, Hate, Love |
| 433 | Love Child |
| 1135 | Love Is Strong |

---

### Apartado 8: Ausencias
**Pregunta de negocio:** ¿Qué clientes omitieron registrar su número de Fax frente a los que sí lo proporcionaron?

```sql
-- 8a) Registro nulo
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NULL;

-- 8b) Registro existente
SELECT customer_id, first_name, fax FROM customer WHERE fax IS NOT NULL;
```

**Resultado de la consulta (IS NOT NULL):**

| customer_id | first_name | fax |
| :--- | :--- | :--- |
| 5 | Frantisek | +420 221 572 211 |
| 7 | Astrid | +43 1 22334455 |
| 22 | Niklas | +46 08-667 3022 |

---

### Apartado 9: Ranking
**Pregunta de negocio:** ¿Cuáles son las 10 pistas de mayor duración de todo el catálogo?

```sql
SELECT track_id, name, milliseconds FROM track ORDER BY milliseconds DESC, track_id ASC LIMIT 10;
```

**Resultado de la consulta:**

| track_id | name | milliseconds |
| :--- | :--- | :--- |
| 2820 | Occupation / Precipice | 5286953 |
| 3224 | Through a Looking Glass | 5088838 |
| 3244 | Greetings from Earth (Part 1) | 2960293 |
| 3222 | The Enterprise Experiment | 2952708 |

---

### Apartado 10: Paginación
**Pregunta de negocio:** ¿Cómo obtener la primera y segunda página de clientes navegando de 5 en 5?

```sql
-- Página 1 (Registros del 1 al 5)
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 0;

-- Página 2 (Registros del 6 al 10)
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 5;
```

**Resultado de la consulta (Página 2):**

| customer_id | first_name | last_name |
| :--- | :--- | :--- |
| 6 | Helena | Holy |
| 7 | Astrid | Gruber |
| 8 | Daan | Peeters |
| 9 | Kara | Nielsen |
| 10 | Eduardo | Martins |
