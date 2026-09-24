SELECT productLine, CHAR_LENGTH(textDescription) AS longitud FROM productlines ORDER BY longitud DESC LIMIT 1;
SELECT o.officeCode, o.city, COUNT(c.customerNumber) AS num_clientes FROM offices o LEFT JOIN employees e ON e.officeCode = o.officeCode LEFT JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber GROUP BY o.officeCode, o.city ORDER BY num_clientes DESC;
