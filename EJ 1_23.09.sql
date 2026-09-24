SELECT officeCode, phone FROM classicmodels.offices;
SELECT employeeNumber, firstname, lastname, email FROM employees WHERE email like '%.es';
SELECT customerNumber, customerName, country, state FROM customers WHERE state IS NULL or state = '';
SELECT customerNumber, checkNumber, paymentDate, amount FROM payments WHERE amount > 20000 ORDER BY amount DESC;
SELECT customerNumber, checkNumber, paymentDate, amount FROM payments WHERE amount > 20000 and YEAR(paymentDate) = 2005 ORDER BY amount DESC;
SELECT DISTINCT productcode FROM orderdetails;
SELECT c.country, COUNT(o.orderNumber) AS total_compras FROM customers c JOIN orders o ON c.customerNumber = o.customerNumber GROUP BY c.country ORDER BY total_compras DESC;