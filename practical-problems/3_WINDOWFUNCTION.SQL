-- ══════════════════════════════════════════
--  SQL PRACTICE — WINDOW FUNCTIONS
-- ══════════════════════════════════════════

-- Rank employees by salary within each department
-- RANK: gaps after ties (1,2,2,4)
SELECT employee_id, department_id, salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees;

-- DENSE_RANK: no gaps (1,2,2,3)
SELECT employee_id, department_id, salary,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_dense_rank
FROM employees;

-- ROW_NUMBER: always unique (1,2,3,4)
SELECT employee_id, department_id, salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num
FROM employees;

-- Top 1 employee per department (handles ties with RANK)
WITH ranked AS (
    SELECT name, department_id, salary,
        DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT * FROM ranked WHERE rnk = 1;

-- Top 3 salespeople per region
WITH ranked AS (
    SELECT name, region, total_sales,
        RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rnk
    FROM salespeople
)
SELECT * FROM ranked WHERE rnk <= 3;

-- Rank products by total sales
SELECT product_id, SUM(total_sales) AS revenue,
    RANK() OVER (ORDER BY SUM(total_sales) DESC) AS sales_rank
FROM sales_data
GROUP BY product_id;

-- Running total of sales by date
SELECT order_date, amount,
    SUM(amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM transactions;

-- Cumulative revenue by day
SELECT order_date,
    SUM(total_amount) OVER (ORDER BY order_date) AS cumulative_revenue
FROM orders;

-- Running total per customer
SELECT customer_id, order_date, total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS customer_running_total
FROM orders;

-- 3-day moving average of sales
SELECT order_date, total_amount,
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3d
FROM orders;

-- Month-over-month revenue growth %
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100
    , 2) AS growth_pct
FROM monthly_revenue;

-- Year-over-year revenue growth (MySQL)
SELECT
    DATE_FORMAT(order_date, '%Y') AS yr,
    SUM(total_amount) AS revenue,
    SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y')) AS yoy_growth
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y');

-- Compare each employee salary to department average
SELECT name, department_id, salary,
    ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) AS dept_avg,
    ROUND(salary - AVG(salary) OVER (PARTITION BY department_id), 2) AS diff
FROM employees;

-- Last purchase per customer with order amount
WITH ranked_orders AS (
    SELECT customer_id, order_id, total_amount,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
)
SELECT customer_id, order_id, total_amount
FROM ranked_orders WHERE rn = 1;

-- Consecutive purchases (orders 1 day apart)
WITH cte AS (
    SELECT customer_id, order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id, order_date, prev_date
FROM cte
WHERE DATEDIFF(order_date, prev_date) = 1;

-- Average days between purchases per customer
WITH cte AS (
    SELECT customer_id, order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id,
    ROUND(AVG(DATEDIFF(order_date, prev_date)), 1) AS avg_gap_days
FROM cte
WHERE prev_date IS NOT NULL
GROUP BY customer_id;

-- Longest gap between orders per customer
WITH cte AS (
    SELECT customer_id, order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
)
SELECT customer_id,
    MAX(DATEDIFF(order_date, prev_date)) AS max_gap_days
FROM cte
WHERE prev_date IS NOT NULL
GROUP BY customer_id;

-- Customers in 90th percentile of spending (top decile)
WITH ranked_orders AS (
    SELECT customer_id, order_id, total_amount,
        NTILE(10) OVER (PARTITION BY customer_id ORDER BY total_amount) AS decile
    FROM orders
)
SELECT customer_id, order_id, total_amount
FROM ranked_orders WHERE decile = 10;

-- Product sales as % of total revenue
WITH total AS (SELECT SUM(quantity * price) AS grand_total FROM sales)
SELECT s.product_id,
       SUM(s.quantity * s.price) AS revenue,
       ROUND(SUM(s.quantity * s.price) * 100.0 / t.grand_total, 2) AS revenue_pct
FROM sales s
CROSS JOIN total t
GROUP BY s.product_id, t.grand_total
ORDER BY revenue DESC;

-- Products contributing to 80% of revenue (Pareto / 80-20 rule)
WITH sales_cte AS (
    SELECT product_id, SUM(quantity * price) AS revenue
    FROM sales GROUP BY product_id
),
with_running AS (
    SELECT product_id, revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
        SUM(revenue) OVER () AS grand_total
    FROM sales_cte
)
SELECT product_id, revenue, running_total
FROM with_running
WHERE running_total <= grand_total * 0.8;

-- Users active 3 consecutive days
WITH cte AS (
    SELECT user_id, activity_date,
        LAG(activity_date, 1) OVER (PARTITION BY user_id ORDER BY activity_date) AS d1,
        LAG(activity_date, 2) OVER (PARTITION BY user_id ORDER BY activity_date) AS d2
    FROM user_activity
)
SELECT DISTINCT user_id
FROM cte
WHERE DATEDIFF(activity_date, d1) = 1
  AND DATEDIFF(d1, d2) = 1;