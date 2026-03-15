-- aggregate functions collapse many rows into a single value
-- they ignore NULLs (except COUNT(*))

-- ── COUNT ────────────────────────────────────────────────────
SELECT COUNT(*)     FROM Customers;      -- total rows, including NULLs
SELECT COUNT(Email) FROM Customers;      -- rows where Email is NOT NULL
SELECT COUNT(DISTINCT City) FROM Customers; -- number of unique cities

-- ── SUM ──────────────────────────────────────────────────────
SELECT SUM(Points)  FROM Customers;
SELECT SUM(Quantity * UnitPrice) AS Revenue FROM OrderItems; -- expression inside SUM

-- ── AVG ──────────────────────────────────────────────────────
SELECT AVG(Points)              FROM Customers;
SELECT ROUND(AVG(Points), 2)    FROM Customers;  -- round to 2 decimal places

-- ── MIN / MAX ────────────────────────────────────────────────
SELECT MIN(Points)    FROM Customers;
SELECT MAX(Points)    FROM Customers;
SELECT MIN(Birthdate) FROM Customers;    -- works on dates too
SELECT MAX(Birthdate) FROM Customers;

-- multiple aggregates in one query
SELECT
    COUNT(*)            AS TotalCustomers,
    COUNT(Email)        AS WithEmail,
    AVG(Points)         AS AvgPoints,
    MIN(Points)         AS MinPoints,
    MAX(Points)         AS MaxPoints,
    SUM(Points)         AS TotalPoints
FROM Customers;

-- ── GROUP BY ─────────────────────────────────────────────────
-- splits rows into groups, applies aggregate to each group
-- every column in SELECT must be in GROUP BY or inside an aggregate
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City;

SELECT City, AVG(Points) AS AvgPoints, MAX(Points) AS MaxPoints
FROM Customers
GROUP BY City
ORDER BY AvgPoints DESC;

-- group by multiple columns
SELECT City, State, COUNT(*) AS Count
FROM Customers
GROUP BY State, City
ORDER BY State, City;

-- group by with JOIN
SELECT c.City, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM Orders o
JOIN Customers c  ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID   = oi.OrderID
GROUP BY c.City
ORDER BY Revenue DESC;

-- ── HAVING — filter AFTER grouping ───────────────────────────
-- WHERE filters rows BEFORE grouping
-- HAVING filters groups AFTER aggregation
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City
HAVING COUNT(*) > 5;                  -- only cities with more than 5 customers

SELECT City, AVG(Points) AS AvgPoints
FROM Customers
GROUP BY City
HAVING AvgPoints > 2000;              -- alias works in HAVING (MySQL)

-- WHERE + HAVING together
SELECT City, COUNT(*) AS ActiveCount
FROM Customers
WHERE Status = 'Active'               -- filter rows first
GROUP BY City
HAVING COUNT(*) > 3;                  -- then filter groups

-- ── WITH ROLLUP — subtotals & grand total ────────────────────
SELECT City, SUM(Points) AS TotalPoints
FROM Customers
GROUP BY City WITH ROLLUP;
-- adds an extra row at the bottom with the grand total (NULL in City column)

-- ── FILTER INSIDE AGGREGATE (MySQL 8+) ───────────────────────
-- count only rows matching a condition — without subquery
SELECT
    COUNT(*) AS Total,
    SUM(Points > 3000) AS HighValueCount   -- MySQL trick: boolean is 0 or 1
FROM Customers;

-- ── ORDER OF CLAUSES ─────────────────────────────────────────
-- SELECT → FROM → JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
-- execution order: FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT