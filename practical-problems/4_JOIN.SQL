-- ══════════════════════════════════════════
--  SQL PRACTICE — JOINS
-- ══════════════════════════════════════════

-- INNER JOIN: sales with product names
SELECT s.sale_id, p.product_name, s.quantity, s.amount
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- LEFT JOIN: all sales records including those without a matching product
SELECT s.sale_id, s.amount, p.product_name
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id;

-- Employees without a department (anti-join using LEFT JOIN)
SELECT e.*
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Self-join: employees with their managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Employees who earn more than their manager
SELECT e.name AS employee, e.salary,
       m.name AS manager,  m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- Customers with no orders (anti-join)
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Three-table join: order details
SELECT o.order_id, c.name AS customer, p.product_name,
       oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN customers  c  ON o.customer_id  = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id;

-- Department headcount including departments with 0 employees
SELECT d.department_name, COUNT(e.employee_id) AS headcount
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY headcount DESC;

-- Recursive CTE: full employee-manager hierarchy
WITH RECURSIVE org AS (
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL          -- top of hierarchy

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id, o.level + 1
    FROM employees e
    JOIN org o ON e.manager_id = o.employee_id
)
SELECT * FROM org ORDER BY level, employee_id;