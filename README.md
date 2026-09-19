# Proyecto Chinook: Consultas SQL en PostgreSQL

Este repositorio contiene la solucion a las consultas sobre la base de datos **Chinook** utilizando PostgreSQL, Docker y DataGrip.

---

### Apartado 1: Directorio de Clientes
**Pregunta de negocio:** ¿Cual es el directorio de contacto principal de los clientes registrados?

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

### Apartado 2: Paises Representados
**Pregunta de negocio:** ¨En que paises se encuentran distribuidos nuestros clientes sin repetir ubicaciones?

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

### Apartado 3: Criterio Numerico
**Pregunta de negocio:** ¨Que pistas duran mas de 4 minutos (240,000 ms) y tienen un precio estandar de $0.99?

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
**Pregunta de negocio:** ¨Que clientes son de Brasil o Argentina pero no tienen una compania registrada?

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
**Pregunta de negocio:** ¨Quienes son los clientes que residen en mercados clave de Latinoamerica (Brasil, Argentina y Chile)?

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
**Pregunta de negocio:** ¨Que canciones tienen una duracion estandar comercial de entre 3 y 5 minutos (180,000 a 300,000 milisegundos)?

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
**Pregunta de negocio:** ¨Que pistas contienen la palabra 'love' al inicio del titulo (Sensible e insensible a mayusculas)?

```sql
-- 7a) Case-sensitive
SELECT track_id, name FROM track WHERE name LIKE 'Love%%';

-- 7b) Case-insensitive
SELECT track_id, name FROM track WHERE name ILIKE 'love%%';
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
**Pregunta de negocio:** ¨Que clientes omitieron registrar su numero de Fax frente a los que si lo proporcionaron?

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
**Pregunta de negocio:** ¨Cuales son las 10 pistas de mayor duracion de todo el catalogo?

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

### Apartado 10: Paginacion
**Pregunta de negocio:** ¨Como obtener la primera y segunda pagina de clientes navegando de 5 en 5?

```sql
-- Pagina 1 (Registros del 1 al 5)
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 0;

-- Pagina 2 (Registros del 6 al 10)
SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC LIMIT 5 OFFSET 5;
```

**Resultado de la consulta (Pagina 2):**

| customer_id | first_name | last_name |
| :--- | :--- | :--- |
| 6 | Helena | Holy |
| 7 | Astrid | Gruber |
| 8 | Daan | Peeters |
| 9 | Kara | Nielsen |
| 10 | Eduardo | Martins |
