-- CTE = named temporary result set defined at the top of a query
-- lives only for the duration of the query
-- makes complex queries readable by breaking them into named steps
-- syntax: WITH cte_name AS ( SELECT ... ) SELECT ... FROM cte_name

-- ── BASIC CTE ────────────────────────────────────────────────
WITH HighValueCustomers AS (
    SELECT CustomerID, FirstName, City, Points
    FROM Customers
    WHERE Points > 3000
)
SELECT * FROM HighValueCustomers WHERE City = 'Warsaw';

-- ── MULTIPLE CTEs ────────────────────────────────────────────
-- chain with commas — each can reference previous CTEs
WITH
ActiveOrders AS (
    SELECT * FROM Orders WHERE Status = 'Active'
),
OrderTotals AS (
    SELECT o.CustomerID, SUM(oi.Quantity * oi.UnitPrice) AS Total
    FROM ActiveOrders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY o.CustomerID
)
SELECT c.FirstName, c.City, ot.Total
FROM OrderTotals ot
JOIN Customers c ON ot.CustomerID = c.CustomerID
ORDER BY ot.Total DESC;

-- ── CTE vs SUBQUERY ──────────────────────────────────────────
-- subquery version (harder to read):
SELECT c.FirstName, sub.AvgPoints
FROM Customers c
JOIN (SELECT City, AVG(Points) AS AvgPoints FROM Customers GROUP BY City) sub
  ON c.City = sub.City;

-- CTE version (same result, cleaner):
WITH CityAvg AS (
    SELECT City, AVG(Points) AS AvgPoints
    FROM Customers
    GROUP BY City
)
SELECT c.FirstName, ca.AvgPoints
FROM Customers c
JOIN CityAvg ca ON c.City = ca.City;

-- ── CTE WITH WINDOW FUNCTIONS ────────────────────────────────
-- CTEs are great for wrapping window functions then filtering on them
WITH RankedCustomers AS (
    SELECT CustomerID, FirstName, City, Points,
           RANK() OVER (PARTITION BY City ORDER BY Points DESC) AS CityRank
    FROM Customers
)
SELECT * FROM RankedCustomers WHERE CityRank = 1;
-- top customer per city — cannot filter on window function directly in WHERE

-- top 3 per city
WITH RankedOrders AS (
    SELECT OrderID, CustomerID, Total, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY Total DESC) AS rn
    FROM Orders
)
SELECT * FROM RankedOrders WHERE rn <= 3;
-- 3 biggest orders per customer

-- ── RECURSIVE CTE ────────────────────────────────────────────
-- calls itself — for hierarchical / tree data
-- structure: anchor member UNION ALL recursive member
WITH RECURSIVE OrgChart AS (
    -- anchor: start with top-level employees (no manager)
    SELECT EmployeeID, FirstName, ManagerID, 1 AS Level
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- recursive: add employees whose manager is already in CTE
    SELECT e.EmployeeID, e.FirstName, e.ManagerID, oc.Level + 1
    FROM Employees e
    JOIN OrgChart oc ON e.ManagerID = oc.EmployeeID
)
SELECT * FROM OrgChart ORDER BY Level, EmployeeID;

-- generate a number series (no table needed)
WITH RECURSIVE Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Numbers WHERE n < 100
)
SELECT * FROM Numbers;

-- generate date series
WITH RECURSIVE DateSeries AS (
    SELECT DATE('2026-01-01') AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM DateSeries WHERE d < '2026-12-31'
)
SELECT * FROM DateSeries;

-- ── CTE vs VIEW vs SUBQUERY ───────────────────────────────────
-- CTE      → named, readable, single-query scope, can be recursive
-- VIEW     → saved, reusable across queries, no recursion
-- Subquery → inline, no reuse, can get messy when nested deeply
-- use CTE when you need to reference the same subquery more than once in a query