-- 1. Análisis de compras anuales --
SELECT YEAR(o.orderDate) AS anyo,
MONTH(o.orderDate) AS mes,
ROUND(AVG((SELECT SUM(od.quantityOrdered * od.priceEach)
FROM orderdetails od
WHERE od.orderNumber = o.orderNumber)
), 2) AS importe_medio_carrito,
SUM(
(SELECT SUM(od.quantityOrdered)
FROM orderdetails od
WHERE od.orderNumber = o.orderNumber)
) AS total_articulos
FROM orders o
WHERE YEAR(o.orderDate) IN (2004, 2005)
AND o.customerNumber IN (
SELECT c.customerNumber
FROM customers c
WHERE c.salesRepEmployeeNumber IN (
SELECT e.employeeNumber
FROM employees e
WHERE e.lastName = 'Patterson'
)
)
GROUP BY anyo, mes
ORDER BY anyo, mes;
-- 2. Viaje a la oficina --
