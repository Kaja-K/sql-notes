-- ══════════════════════════════════════════
--  SQL PRACTICE — CTE & ADVANCED PATTERNS
-- ══════════════════════════════════════════

-- CTE for high-value sales
WITH high_value_sales AS (
    SELECT * FROM sales WHERE amount > 1000
)
SELECT product_id, SUM(amount) AS total
FROM high_value_sales
GROUP BY product_id;

-- Churned customers: no orders in last 6 months
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING MAX(order_date) < DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Employees hired in last 6 months
SELECT * FROM employees
WHERE hire_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- Employees hired on weekends (MySQL)
SELECT * FROM employees
WHERE DAYOFWEEK(hire_date) IN (1, 7);   -- 1=Sunday, 7=Saturday

-- Names starting with 'A' using LIKE
SELECT * FROM employees WHERE name LIKE 'A%';

-- Pivot monthly sales into columns (MySQL conditional aggregation)
SELECT
    product_id,
    SUM(CASE WHEN MONTH(sale_date) = 1  THEN amount ELSE 0 END) AS jan,
    SUM(CASE WHEN MONTH(sale_date) = 2  THEN amount ELSE 0 END) AS feb,
    SUM(CASE WHEN MONTH(sale_date) = 3  THEN amount ELSE 0 END) AS mar,
    SUM(CASE WHEN MONTH(sale_date) = 4  THEN amount ELSE 0 END) AS apr
FROM sales
GROUP BY product_id;

-- WHERE vs HAVING example
-- WHERE: filter rows before grouping (uses index, faster)
SELECT city, COUNT(*) FROM customers
WHERE status = 'Active'         -- row filter BEFORE group
GROUP BY city
HAVING COUNT(*) > 5;            -- group filter AFTER aggregation

-- UNION: unique cities from customers and vendors
SELECT city FROM customers
UNION
SELECT city FROM vendors;

-- UNION ALL: all cities including duplicates (faster)
SELECT city FROM customers
UNION ALL
SELECT city FROM vendors;

-- CTE: customers who ordered more than average
WITH order_counts AS (
    SELECT customer_id, COUNT(*) AS cnt
    FROM orders GROUP BY customer_id
)
SELECT * FROM order_counts
WHERE cnt > (SELECT AVG(cnt) FROM order_counts);

-- Temporary table for analysis
CREATE TEMPORARY TABLE temp_high_orders AS
SELECT customer_id, COUNT(*) AS order_count, SUM(total_amount) AS revenue
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;

SELECT * FROM temp_high_orders ORDER BY revenue DESC;

-- Optimize a slow query checklist:
-- 1. Run EXPLAIN to see execution plan
-- 2. Check if the WHERE column has an index
-- 3. Avoid SELECT * — fetch only needed columns
-- 4. Avoid functions on indexed columns in WHERE
-- 5. Replace correlated subqueries with JOINs or CTEs
-- 6. Use LIMIT when only a few rows are needed

EXPLAIN SELECT * FROM orders WHERE customer_id = 5 AND order_date > '2026-01-01';