-- a subquery is a SELECT nested inside another SQL statement
-- can appear in: WHERE, SELECT, FROM, HAVING, JOIN

-- ── IN CLAUSE — filter using another query's results ─────────
SELECT * FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Orders WHERE Total > 500);

-- NOT IN — customers who never ordered
SELECT * FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);

-- ── EXISTS — true if subquery returns any rows ────────────────
-- faster than IN for large tables — stops at first match
SELECT * FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID
);

-- NOT EXISTS — customers with no orders
SELECT * FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID
);

-- products never ordered
SELECT * FROM Products p
WHERE NOT EXISTS (
    SELECT 1 FROM OrderItems oi WHERE oi.ProductID = p.ProductID
);

-- EXISTS vs IN:
-- IN    loads all results into memory then checks
-- EXISTS stops at first match — better for large tables

-- ── SCALAR SUBQUERY — returns a single value ─────────────────
-- can be used anywhere a single value is expected
SELECT (SELECT MAX(Points) FROM Customers) AS MaxPoints;

-- compare each row against a single aggregated value
SELECT FirstName, Points,
       (SELECT AVG(Points) FROM Customers) AS AvgPoints
FROM Customers;

-- customers above average points
SELECT FirstName, Points
FROM Customers
WHERE Points > (SELECT AVG(Points) FROM Customers);

-- latest order date
SELECT * FROM Orders
WHERE OrderDate = (SELECT MAX(OrderDate) FROM Orders);

-- ── FROM SUBQUERY (inline view / derived table) ───────────────
-- subquery in FROM — must have an alias
SELECT City, AvgPoints
FROM (
    SELECT City, AVG(Points) AS AvgPoints
    FROM Customers
    GROUP BY City
) AS CityStats
WHERE AvgPoints > 2000;

-- find the top customer per city
SELECT cs.City, cs.FirstName, cs.Points
FROM Customers cs
JOIN (
    SELECT City, MAX(Points) AS MaxPoints
    FROM Customers
    GROUP BY City
) AS CityMax ON cs.City = CityMax.City AND cs.Points = CityMax.MaxPoints;

-- ── CORRELATED SUBQUERY — references the outer query ─────────
-- re-executes for every row in outer query — can be slow
-- use EXISTS or a JOIN instead when performance matters

-- customers with points above their city's average
SELECT FirstName, City, Points
FROM Customers c
WHERE Points > (
    SELECT AVG(Points)
    FROM Customers
    WHERE City = c.City     -- references outer query's row
);

-- orders with total above that customer's average order
SELECT o.OrderID, o.CustomerID, o.Total
FROM Orders o
WHERE o.Total > (
    SELECT AVG(Total)
    FROM Orders
    WHERE CustomerID = o.CustomerID
);

-- ── SUBQUERY IN SELECT ────────────────────────────────────────
-- add a calculated column from another table
SELECT
    o.OrderID,
    o.Total,
    (SELECT FirstName FROM Customers WHERE CustomerID = o.CustomerID) AS CustomerName
FROM Orders o;
-- note: a JOIN is usually cleaner and faster for this pattern

-- ── SUBQUERY IN HAVING ────────────────────────────────────────
SELECT City, AVG(Points) AS AvgPoints
FROM Customers
GROUP BY City
HAVING AVG(Points) > (SELECT AVG(Points) FROM Customers);
-- cities where average points beat the overall average

-- ── ALL / ANY — compare against a set ────────────────────────
-- ALL: condition must be true for every value in subquery
SELECT * FROM Products
WHERE Price > ALL (SELECT Price FROM Products WHERE CategoryID = 2);
-- products more expensive than ALL products in category 2

-- ANY (= SOME): condition must be true for at least one value
SELECT * FROM Products
WHERE Price > ANY (SELECT Price FROM Products WHERE CategoryID = 2);
-- products more expensive than at least ONE product in category 2

-- ── WHEN TO USE WHAT ─────────────────────────────────────────
-- IN        → small static list or subquery
-- EXISTS    → large tables, correlated checks — stops at first match
-- JOIN      → usually faster than correlated subquery for aggregation
-- FROM sub  → when you need an intermediate aggregation
-- scalar    → single-value comparisons or adding a column