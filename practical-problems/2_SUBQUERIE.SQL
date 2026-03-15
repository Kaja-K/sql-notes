-- ══════════════════════════════════════════
--  SQL PRACTICE — SUBQUERIES
-- ══════════════════════════════════════════

-- Second highest salary
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Nth highest salary using DENSE_RANK (more robust)
WITH ranked AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT salary FROM ranked WHERE rnk = 2;

-- Employees earning above the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees above their dept avg but below company avg
SELECT *
FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
)
AND salary < (SELECT AVG(salary) FROM employees);

-- Employees in departments with more than 5 people
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id FROM employees
    GROUP BY department_id
    HAVING COUNT(*) > 5
);

-- Customers who never placed an order (NOT IN)
SELECT customer_id, name
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

-- Same with NOT EXISTS (faster for large tables)
SELECT c.customer_id, c.name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- Customers with orders above the average order value
SELECT * FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- Customers who ordered more than the average number of orders per customer
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM customer_orders
WHERE order_count > (SELECT AVG(order_count) FROM customer_orders);

-- Revenue from first-time (new) customers only
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT SUM(o.total_amount) AS new_customer_revenue
FROM orders o
JOIN first_orders f ON o.customer_id = f.customer_id
   AND o.order_date = f.first_order_date;

-- Products never ordered (LEFT JOIN anti-join)
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.product_id IS NULL;

-- Customers who made purchases but never returned products
SELECT DISTINCT c.customer_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id NOT IN (
    SELECT customer_id FROM returns
);

-- Check if customers exist in orders table (EXISTS)
SELECT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);