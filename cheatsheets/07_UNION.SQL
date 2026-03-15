-- UNION stacks result sets vertically — combines rows from multiple SELECT statements
-- rules:
--   same number of columns in each SELECT
--   compatible data types per column
--   column names come from the FIRST SELECT
--   UNION removes duplicates — UNION ALL keeps them

-- ── UNION — combine, remove duplicates ───────────────────────
SELECT FirstName FROM Customers
UNION
SELECT FirstName FROM Shippers;
-- unique first names from both tables

-- label rows with a literal column
SELECT OrderID, OrderDate, 'Active'   AS Status FROM Orders WHERE OrderDate >= '2023-01-01'
UNION
SELECT OrderID, OrderDate, 'Archived' AS Status FROM Orders WHERE OrderDate <  '2023-01-01';

-- UNION with ORDER BY — only one ORDER BY at the end, applies to full result
SELECT CustomerID, FirstName, Points, 'Bronze' AS Tier FROM Customers WHERE Points < 2000
UNION
SELECT CustomerID, FirstName, Points, 'Silver' AS Tier FROM Customers WHERE Points BETWEEN 2000 AND 3000
UNION
SELECT CustomerID, FirstName, Points, 'Gold'   AS Tier FROM Customers WHERE Points > 3000
ORDER BY FirstName;

-- ── UNION ALL — keep duplicates ───────────────────────────────
-- faster than UNION — no deduplication step
SELECT OrderID, OrderDate, 'Active'   AS Status FROM Orders WHERE OrderDate >= '2023-01-01'
UNION ALL
SELECT OrderID, OrderDate, 'Archived' AS Status FROM Orders WHERE OrderDate <  '2023-01-01';

-- combine monthly snapshots — duplicates expected, keep them
SELECT * FROM Sales_Jan
UNION ALL
SELECT * FROM Sales_Feb
UNION ALL
SELECT * FROM Sales_Mar;

-- ── INTERSECT — rows that appear in BOTH results ─────────────
-- MySQL does not support INTERSECT natively — simulate with INNER JOIN or IN
SELECT CustomerID FROM Customers WHERE City = 'Warsaw'
INTERSECT
SELECT CustomerID FROM Orders WHERE Total > 500;
-- customers in Warsaw who also have orders > 500

-- MySQL equivalent:
SELECT DISTINCT c.CustomerID
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City = 'Warsaw' AND o.Total > 500;

-- ── EXCEPT / MINUS — rows in first but NOT in second ─────────
-- MySQL uses EXCEPT (8.0+), older versions need LEFT JOIN trick
SELECT CustomerID FROM Customers
EXCEPT
SELECT CustomerID FROM Orders;
-- customers who have never placed an order

-- MySQL equivalent (all versions):
SELECT c.CustomerID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- ── UPSERT — insert or update on duplicate key ───────────────
-- MySQL: INSERT ... ON DUPLICATE KEY UPDATE
INSERT INTO Products (ProductID, Name, Price)
VALUES (1, 'Widget', 9.99)
ON DUPLICATE KEY UPDATE
    Name  = VALUES(Name),
    Price = VALUES(Price);
-- if ProductID=1 exists → update; otherwise → insert

-- ── COMMON MISTAKES ──────────────────────────────────────────
-- column count mismatch → error
-- SELECT FirstName, LastName FROM Customers
-- UNION SELECT FirstName FROM Shippers;   -- ERROR: different column count

-- data type mismatch → silent coercion (be careful)
-- SELECT OrderID FROM Orders UNION SELECT CustomerName FROM Customers; -- works but wrong

-- ORDER BY column name must match first SELECT's column names
SELECT FirstName AS Name FROM Customers
UNION
SELECT Name FROM Shippers
ORDER BY Name;                             -- uses alias from first SELECT