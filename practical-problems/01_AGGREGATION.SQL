-- ══════════════════════════════════════════
--  SQL PRACTICE — AGGREGATION & GROUPING
-- ══════════════════════════════════════════

-- Count orders per customer
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;

-- Average order value per customer
SELECT customer_id, AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY customer_id;

-- Customers who ordered more than 3 times in the last month
SELECT customer_id, COUNT(*) AS purchase_count
FROM orders
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
GROUP BY customer_id
HAVING COUNT(*) > 3;

-- Count how many customers placed more than 5 orders
SELECT COUNT(*) AS customer_count
FROM (
    SELECT customer_id FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 5
) AS sub;

-- Total revenue per product
SELECT product_id, SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY product_id;

-- Total revenue and order count per region
SELECT region,
       SUM(total_amount) AS total_revenue,
       COUNT(*)          AS order_count
FROM orders
GROUP BY region;

-- Monthly sales revenue and order count (MySQL)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(total_amount) AS total_revenue,
       COUNT(order_id)   AS order_count
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Top 3 departments by average salary
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC
LIMIT 3;
-- tip: use DENSE_RANK() when ties need to be handled

-- Maximum salary difference within each department
SELECT department_id,
       MAX(salary) - MIN(salary) AS salary_diff
FROM employees
GROUP BY department_id;

-- Percentage of employees in each department
SELECT department_id,
       COUNT(*) AS emp_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS pct
FROM employees
GROUP BY department_id;

-- First and last order date per customer
SELECT customer_id,
       MIN(order_date) AS first_order,
       MAX(order_date) AS last_order
FROM orders
GROUP BY customer_id;

-- Customers who ordered every month in 2026
SELECT customer_id
FROM orders
WHERE YEAR(order_date) = 2026
GROUP BY customer_id
HAVING COUNT(DISTINCT DATE_FORMAT(order_date, '%Y-%m')) = 12;

-- Segment customers by order frequency
SELECT customer_id,
       COUNT(*) AS order_count,
       CASE
           WHEN COUNT(*) >= 10 THEN 'High'
           WHEN COUNT(*) >= 5  THEN 'Medium'
           ELSE 'Low'
       END AS segment
FROM orders
GROUP BY customer_id;