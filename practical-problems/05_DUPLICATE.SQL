-- ══════════════════════════════════════════
--  SQL PRACTICE — DUPLICATES & DATA CLEANING
-- ══════════════════════════════════════════

-- Find duplicate records (on one column)
SELECT email, COUNT(*) AS cnt
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Find duplicates on multiple columns
SELECT first_name, last_name, email, COUNT(*) AS cnt
FROM customers
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- Show all duplicate rows in full
SELECT *
FROM customers
WHERE email IN (
    SELECT email FROM customers GROUP BY email HAVING COUNT(*) > 1
)
ORDER BY email;

-- Delete duplicates — keep the row with the lowest ID
DELETE FROM customers
WHERE customer_id NOT IN (
    SELECT MIN(customer_id)
    FROM customers
    GROUP BY email
);

-- Remove duplicate rows permanently using ROW_NUMBER
WITH cte AS (
    SELECT customer_id,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
)
DELETE FROM customers
WHERE customer_id IN (SELECT customer_id FROM cte WHERE rn > 1);

-- Count NULLs per column
SELECT
    COUNT(*) - COUNT(email)  AS null_email,
    COUNT(*) - COUNT(phone)  AS null_phone,
    COUNT(*) - COUNT(city)   AS null_city
FROM customers;

-- Replace NULL discounts with 0 using COALESCE
SELECT order_id, total_amount,
       COALESCE(discount, 0) AS discount
FROM orders;

-- Replace empty strings with NULL
UPDATE customers SET phone = NULL WHERE TRIM(phone) = '';
UPDATE customers SET city  = NULL WHERE city IN ('N/A', 'Unknown', '-', '');

-- Fill NULL salary with department average
UPDATE employees e
JOIN (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees
    WHERE salary IS NOT NULL
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
SET e.salary = dept_avg.avg_sal
WHERE e.salary IS NULL;

-- Standardise case and trim whitespace
UPDATE customers
SET email     = LOWER(TRIM(email)),
    first_name = TRIM(first_name),
    last_name  = TRIM(last_name);

-- Find gaps in sequential IDs
SELECT id + 1 AS gap_start
FROM orders o
WHERE NOT EXISTS (
    SELECT 1 FROM orders WHERE id = o.id + 1
)
AND id < (SELECT MAX(id) FROM orders);