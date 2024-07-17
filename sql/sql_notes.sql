## choose the database
USE sql_store;

## select all from certain table, order by
SELECT *
FROM customers
-- WHERE customer_id = 1
ORDER BY first_name;

## set the name of new columns: AS
USE sql_store;
SELECT 	first_name, points, points +100 AS discount_facts
FROM customers;

SELECT name, unit_price, unit_price*1.1 AS "new price"
FROM products;

## distince selection
SELECT DISTINCT state
FROM customers;


## set the conditions when selecting
SELECT *
FROM orders
WHERE order_date >= "2018-01-01" AND order_date < "2019-01-01";

SELECT *
FROM order_items
WHERE order_id = 6 AND unit_price*quantity > 30;

SELECT *
FROM customers
WHERE state IN ("VA","GA");

SELECT *
FROM customers
WHERE state NOT IN ("VA","GA");

SELECT *
FROM customers
WHERE birth_date BETWEEN "1990-01-01" AND "2000-01-01";




## pattern of strings
-- % means unlimited numbers of characters
-- _ means one character
SELECT *
FROM customers
WHERE last_name LIKE "b%";

SELECT *
FROM customers
WHERE last_name LIKE "%b%"; -- selece those with a b inside the string

SELECT *
FROM customers
WHERE last_name LIKE "b____y"; 

SELECT *
FROM customers
WHERE address LIKE "%avenue%" OR address LIKE "%trail%" OR phone LIKE "%9" ;

SELECT *
FROM customers
WHERE phone NOT LIKE "%9" ;

-- regular expression
-- ^ means the beginning of the string, $ means the end
 	e.g. WHERE last_name REGEXP "field$"
-- | means "or" when indicating patterns here
	e.g. WHERE last_name REGEXP "field|mac"
SELECT *
FROM customers
WHERE last_name REGEXP "field" ;

SELECT *
FROM customers
WHERE last_name REGEXP "field|mac";

SELECT *
FROM customers
WHERE last_name REGEXP "field$|mac|rose";

SELECT *
FROM customers
WHERE last_name REGEXP "[i,g,m]e"; 
-- find all that has a "ie" or "ge" or"me" in the celected string

SELECT *
FROM customers
WHERE last_name REGEXP "[a-g]e"; 

-- exercise: 
-- first-name are elka or ambur
SELECT*
FROM customers
WHERE first_name REGEXP "elka|ambur";

-- last name end with ey or on
SELECT*
FROM customers
WHERE last_name REGEXP "ey$|on$";

-- last name start with my or contain se
SELECT*
FROM customers
WHERE last_name REGEXP "^my|se";

-- last contain b followed by r oru
SELECT*
FROM customers
WHERE last_name REGEXP "b[r,u]";




## null
SELECT *
FROM orders
WHERE shipped_date IS NULL;




## change the order/ show it reversely
SELECT *
FROM customers
ORDER BY first_name;

SELECT *
FROM customers
ORDER BY first_name DESC;




## sort first by xx then by yy, ORDER BY xx,yy
SELECT *
FROM customers
ORDER BY state,first_name;

SELECT *
FROM order_items
WHERE order_id = 2
ORDER BY quantity*unit_price DESC;




## limit the result shown
SELECT *
FROM customers
LIMIT 4;

SELECT *
FROM customers
LIMIT 6,3;  -- this means skip first 6, then get 3

SELECT *
FROM customers
ORDER BY points DESC
LIMIT 3;  




## the order of sentences example:
SELECT *
FROM customers
WHERE last_name REGEXP "e"
ORDER BY points
LIMIT 5;





## inner join
SELECT order_id,orders.customer_id
FROM orders
JOIN customers
	ON orders.customer_id=customers.customer_id;

SELECT o.product_id, o.unit_price
FROM order_items o
JOIN products
	ON products.product_id=o.product_id;
    
SELECT *
FROM order_items o
JOIN sql_inventory.products p
	ON p.product_id = o.product_id;
    
USE sql_hr;
SELECT e.employee_id, e,first_name, m.first_name
FROM employees e
JOIN employees m
	ON e.reports_to = m.employee_id; 
    
SELECT order_id, first_name, last_name, os.name
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
JOIn order_statuses os
	ON o.order_id = os.order_status_id;


-- from multiple tables
SELECT o.order_id, c.first_name, c.last_name, os.name AS status
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
JOIN order_statuses os
	ON o.status = os.order_status_id
ORDER BY order_id;

SELECT c.client_id, c.name, p.date, p.amount, pm.name AS method
FROM clients c
JOIN payments p
	ON c.client_id = p.client_id
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id




USE sql_store;

## insert new row
INSERT INTO customers
VALUES (DEFAULT, 'John','Smith','1990-03-24', NULL,'address','city','state');

## no need to type in valuses that are not specified
INSERT INTO customers(first_name,last_name,brith_date)
VALUES ('John','SMith','1990-03-03');



-- insert multical rows into one table
INSERT INTO shippers(name)
VALUES ('shippers1','shippers2','shippers3');

-- insert data into multiple table
INSERT INTO orders(customer_id,order_date,status)
VALUES(1,'2019-02-12',1);     -- creat new row in the mother table
-- add data in children table
INSERT INTO order_items
VALUES
	  (LAST_INSERT_ID(),1,1,2.94),
	  (LAST_INSERT_ID(),2,1,3.23);
      
-- copy data into another table
CREATE TABLE order_archived AS
SELECT * FROM orders
WHERE order_date<'2019-02-01';

USE sql_invoicing;
CREATE TABLE  invoices_archived as
SELECT i.invoice_id,i.number,c.name AS client,i.invoice_total,i.payment_date
FROM invoices i
JOIN clients c
	ON i.client_id = c.client_id
WHERE payment_date IS NOT NULL;

-- update data
UPDATE invoices
SET payment_total=10, payment_date='2019-01-23'
WHERE invoice_id =1;

UPDATE invoices
SET payment_total= invoice_total*0.5, 
	payment_date=due_date
WHERE client_id IN (SELECT client_id FROM clients WHERE state IN ('CA','NY'));

-- update multiple rows
USE sql_store;
UPDATE customers
SET points = points+50
WHERE birth_date> '1990-01-01';

UPDATE orders
SET comments = 'gold customers'
WHERE customer_id IN (SELECT customer_id FROM customers WHERE points >=3000);

-- delete data
USE sql_invoicing;
DELETE FROM invoices_archivedinvoices_archived;



USE sql_invoicing;

SELECT p.date, pm.name AS payment_method, SUM(amount) AS total_payments
FROM payments p
JOIN payment_methods pm
ON p.payment_method = pm.payment_method_id
GROUP BY p.date, pm.name
ORDER BY p.date;

-- having (filter after aggregating)
SELECT client_id, SUM(invoice_total) AS total_sales
FROM invoices
GROUP BY client_id
HAVING total_sales >500;

USE sql_store;
SELECT c.first_name AS name,
	   oi.quantity*oi.unit_price AS spent,
       c.state
FROM order_items oi
JOIN orders o USING(order_id)
JOIN customers c ON o.customer_id=c.customer_id
WHERE c.state="VA"
GROUP BY order_id
HAVING spent >100;

-- select customers who live in VA or GA with total spent more than 100
SELECT 
	c.first_name AS name,
    c.state AS state,
    SUM(oi.quantity*oi.unit_price) AS total_spent
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE c.state IN ('VA','GA')
GROUP BY c.first_name,c.state
HAVING total_spent >100;

-- subquery
-- find products that are more expensive than lettuce(id=3)
USE sql_store;
SELECT *
FROM products 
WHERE unit_price > (SELECT unit_price FROM products WHERE product_id = 3);


-- find employees who earn more than average
USE sql_hr;
SELECT first_name
FROM employees
WHERE salary > (SELECT avg(salary) FROM employees);

-- find products that have never been ordered
USE sql_store;
SELECT *
FROM products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- find clients withour invoices
USE sql_invoicing;
SELECT client_id 
FROM clients
WHERE client_id NOT IN (SELECT distinct client_id FROM invoices);

-- find customers who have ordered lettuce(id=3)
USE sql_store;
SELECT DISTINCT (c.customer_id), c.first_name, c.last_name
FROM customers c
JOIN orders o USING (customer_id)
WHERE o.order_id IN (SELECT order_id FROM order_items WHERE product_id = 3);

SELECT DISTINCT (c.customer_id), c.first_name, c.last_name
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE oi.product_id = 3;

-- select invoices larger than all invoices of client 3
USE sql_invoicing;
SELECT *
FROM invoices
WHERE invoice_total >(SELECT MAX(invoice_total) FROM invoices WHERE client_id =3);

-- select clients with at least two invoices
SELECT client_id
FROM invoices
GROUP BY client_id
HAVING COUNT(*) >=2;

-- correlated subqueries
-- select employee whose salaty is more than average in this office 
USE sql_hr;
SELECT *
FROM employees e
WHERE salary > (
SELECT AVG(salary) 
FROM employees 
WHERE office_id = e. office_id);

USE sql_invoicing;
-- find invoices that are larger than the client's average invoice amount
SELECT *
FROM invoices i
WHERE invoice_total > (SELECT AVG(invoice_total) FROM invoices WHERE client_id = i.client_id);

-- subquery in SELECT
SELECT 
	invoice_id,invoice_total, 
    (SELECT AVG(invoice_total) FROM invoices) AS invoice_avg,
    invoice_total- (SELECT invoice_avg) AS difference
FROM invoices;


SELECT 
	DISTINCT c.client_id, 
    c.name,
    (SELECT SUM(invoice_total) FROM invoices WHERE client_id = c.client_id) AS total_sales,
    (SELECT AVG(invoice_total) FROM invoices ) AS average, 
    (SELECT total_sales)- (SELECT average) AS difference
FROM clients c
JOIN invoices i USING(client_id);

-- IF function
-- IF(expression, what to return if true, what to return if faulse)alter
USE sql_store;
SELECT 
	order_id,
    order_date, 
    IF (
		YEAR(order_date) = YEAR(NOW()),
        "ACTIVE", "NOT ACTIVE")
FROM orders;

SELECT p.product_id, p.name, COUNT(*) AS orders, IF(COUNT(*)>1,"many times","once") AS frequency
FROM products p
JOIN order_items oi USING(product_id)
GROUP BY p.product_id, p.name;

-- CASE: multiple conditions
SELECT 
	CONCAT(first_name,' ',last_name) AS name,
    points,
    CASE
		WHEN points >3000 THEN "GOLD"
        WHEN points >= 2000 THEN "SILVER"
        ELSE "BRONZE"
	END AS category
FROM customers;


-- VIEW
-- CREATE VIEW ...(name of the table) AS 

CREATE VIEW sales_by_client AS
SELECT c.client,c.name,SUM(invoice_total) AS total_sale
FROM clients c
JOIN invoices i USING(client_id)
GROUP BY client_id, name;

-- delete view
DROP VIEW sales_by_client;
-- OR: 
-- CREATE OR REPLACE VIEW sales_by_client AS;



