-- ── ORDER BY ─────────────────────────────────────────────────
SELECT * FROM Customers ORDER BY LastName;               -- ASC is default
SELECT * FROM Customers ORDER BY Points DESC;            -- largest first
SELECT * FROM Customers ORDER BY LastName ASC, FirstName ASC;  -- primary + secondary key
SELECT * FROM Customers ORDER BY 1, 2;                   -- by column position (fragile — avoid)

-- sort by expression
SELECT FirstName, LastName, (Points * 1.1) AS NewPoints
FROM Customers
ORDER BY NewPoints DESC;

-- sort by alias defined in SELECT (MySQL allows this)
SELECT City, COUNT(*) AS Total FROM Customers
GROUP BY City
ORDER BY Total DESC;

-- NULLs sort last in ASC, first in DESC (MySQL behaviour)
-- force NULLs last in DESC:
SELECT * FROM Customers ORDER BY Phone IS NULL, Phone DESC;

-- ── LIMIT & OFFSET ───────────────────────────────────────────
SELECT * FROM Customers LIMIT 10;                        -- first 10 rows
SELECT * FROM Customers ORDER BY Points DESC LIMIT 3;    -- top 3
SELECT * FROM Customers LIMIT 10 OFFSET 20;              -- rows 21-30
SELECT * FROM Customers LIMIT 20, 10;                    -- shorthand: LIMIT offset, count

-- ── GROUP BY ─────────────────────────────────────────────────
-- every SELECT column must be in GROUP BY or inside an aggregate
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City;

-- multi-column grouping
SELECT State, City, COUNT(*) AS Count
FROM Customers
GROUP BY State, City
ORDER BY State, City;

-- group by with expression
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month,
       COUNT(*) AS Orders, SUM(Total) AS Revenue
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

-- group by with JOIN
SELECT c.City, COUNT(o.OrderID) AS Orders,
       SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM Customers c
LEFT JOIN Orders o      ON c.CustomerID = o.CustomerID
LEFT JOIN OrderItems oi ON o.OrderID    = oi.OrderID
GROUP BY c.City
ORDER BY Revenue DESC;

-- ── HAVING — filter groups after aggregation ─────────────────
-- WHERE  → filters rows   BEFORE GROUP BY
-- HAVING → filters groups AFTER  GROUP BY
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City
HAVING COUNT(*) > 5;

-- WHERE + HAVING together
SELECT City, AVG(Points) AS AvgPoints
FROM Customers
WHERE Status = 'Active'             -- row-level filter first
GROUP BY City
HAVING AVG(Points) > 2000;          -- group-level filter after

-- common mistake: using WHERE instead of HAVING for aggregates
-- WRONG: WHERE COUNT(*) > 5
-- RIGHT: HAVING COUNT(*) > 5

-- ── WITH ROLLUP — subtotals and grand total ──────────────────
SELECT City, SUM(Points) AS TotalPoints
FROM Customers
GROUP BY City WITH ROLLUP;
-- adds extra rows: subtotal per group + grand total (NULL in grouping column)

-- multi-level rollup
SELECT State, City, SUM(Points)
FROM Customers
GROUP BY State, City WITH ROLLUP;
-- row per city → subtotal per state → grand total

-- ── GROUPING() — detect rollup rows ─────────────────────────
-- GROUPING(col) returns 1 for rollup-generated rows, 0 for real data
SELECT
    IF(GROUPING(City), 'ALL CITIES', City) AS City,
    SUM(Points) AS TotalPoints
FROM Customers
GROUP BY City WITH ROLLUP;