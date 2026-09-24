-- 1. ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT s.customer_id, SUM(m.price) AS total_gastado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
-- 2. ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT customer_id, COUNT(DISTINCT order_date) AS dias_visitados
FROM sales
GROUP BY customer_id
ORDER BY customer_id;
-- 3. ¿Cuál fue el primer artículo del menú comprado por cada cliente?
WITH ranked AS (
SELECT s.customer_id, m.product_name, s.order_date,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
FROM sales s
JOIN menu m ON s.product_id = m.product_id)
SELECT DISTINCT customer_id, product_name
FROM ranked
WHERE rn = 1;
-- 4. ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
SELECT m.product_name, COUNT(*) AS veces_comprado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY veces_comprado DESC
LIMIT 1;
-- 5. ¿Qué artículo fue el más popular para cada cliente?
WITH conteo AS (
SELECT s.customer_id, m.product_name, COUNT(*) AS veces,
RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, veces
FROM conteo
WHERE rn = 1;
-- 6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
WITH post AS (
    SELECT s.customer_id, m.product_name, s.order_date,
           DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN menu m  ON s.product_id = m.product_id
    JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date >= mb.join_date
)
SELECT DISTINCT customer_id, product_name, order_date
FROM post
WHERE rn = 1;
-- 7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
WITH pre AS (
    SELECT s.customer_id, m.product_name, s.order_date,
           DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn
    FROM sales s
    JOIN menu m  ON s.product_id = m.product_id
    JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date < mb.join_date
)
SELECT DISTINCT customer_id, product_name, order_date
FROM pre
WHERE rn = 1;
-- 8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
SELECT s.customer_id,
       COUNT(*) AS total_articulos,
       SUM(m.price) AS total_gastado
FROM sales s
JOIN menu m  ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;
-- 9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿Cuántos puntos tendría cada cliente?
SELECT s.customer_id,
       SUM(CASE WHEN m.product_name = 'sushi'
                THEN m.price * 10 * 2
                ELSE m.price * 10 END) AS puntos
FROM sales s
JOIN menu m  ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
GROUP BY s.customer_id
ORDER BY puntos DESC;
-- 10. En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi. ¿Cuántos puntos tienen los clientes A y B a fines de enero?
SELECT s.customer_id,
       SUM(CASE
             WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 6 DAY)
                  THEN m.price * 10 * 2
             WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
             ELSE m.price * 10
           END) AS puntos
FROM sales s
JOIN menu m  ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
  AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY puntos DESC;