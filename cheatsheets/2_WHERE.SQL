-- ── COMPARISON OPERATORS ─────────────────────────────────────
-- =  !=  <  <=  >  >=
SELECT * FROM Customers WHERE Age > 30;
SELECT * FROM Customers WHERE State != 'California';
SELECT * FROM Customers WHERE Birthdate < '1990-01-01';  -- dates in quotes 'YYYY-MM-DD'

-- ── AND / OR / NOT ───────────────────────────────────────────
-- order of evaluation: Parentheses → NOT → AND → OR
SELECT * FROM Customers WHERE Birthdate < '1990-01-01' AND Points > 3000;
SELECT * FROM Customers WHERE Birthdate < '1990-01-01' OR  Points > 3000;
SELECT * FROM Customers WHERE NOT Birthdate < '1990-01-01';

-- use parentheses to control evaluation order
SELECT * FROM Customers WHERE (Birthdate < '1990-01-01' AND Points > 3000) OR City = 'New York';
SELECT * FROM Customers WHERE NOT (Birthdate < '1990-01-01' OR Points > 3000);
-- De Morgan: NOT(A OR B) = NOT A AND NOT B

-- calculated expression in WHERE
SELECT *, (Quantity * Price) AS TotalPrice
FROM OrderItems
WHERE OrderID = 6 AND (Quantity * Price) > 30;

-- ── IN ───────────────────────────────────────────────────────
SELECT * FROM Customers WHERE City     IN ('New York', 'Los Angeles', 'Chicago');
SELECT * FROM Customers WHERE City NOT IN ('New York', 'Los Angeles', 'Chicago');
SELECT * FROM Products  WHERE StockQuantity IN (49, 38, 72);

-- IN with subquery — dynamic list
SELECT * FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Orders WHERE Total > 500);

-- ── BETWEEN ──────────────────────────────────────────────────
SELECT * FROM Customers WHERE Points   BETWEEN 1000     AND 5000;
SELECT * FROM Customers WHERE Points   NOT BETWEEN 1000 AND 5000;
SELECT * FROM Customers WHERE Birthdate BETWEEN '1980-01-01' AND '1990-12-31';
-- BETWEEN is inclusive on both ends

-- ── LIKE ─────────────────────────────────────────────────────
-- %  = zero or more characters
-- _  = exactly one character
SELECT * FROM Customers WHERE LastName LIKE 'B%';       -- starts with B
SELECT * FROM Customers WHERE LastName LIKE '%b%';      -- contains b anywhere
SELECT * FROM Customers WHERE LastName LIKE '%y';       -- ends with y
SELECT * FROM Customers WHERE LastName LIKE 'B__%';     -- starts B, at least 4 chars
SELECT * FROM Customers WHERE LastName LIKE '_____y';   -- exactly 6 chars, ends y
SELECT * FROM Customers WHERE LastName NOT LIKE 'B%y';

SELECT * FROM Customers
WHERE (Address LIKE '%trail%' OR Address LIKE '%avenue%')
  AND Phone LIKE '%9';                                   -- ends with 9

-- ── IS NULL ──────────────────────────────────────────────────
SELECT * FROM Customers WHERE Phone IS NULL;
SELECT * FROM Customers WHERE Phone IS NOT NULL;
-- tip: NULL = NULL is false in SQL — always use IS NULL

-- ── EXISTS — check if subquery returns any rows ───────────────
-- faster than IN for large datasets — stops at first match
SELECT * FROM Customers c
WHERE EXISTS (SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID);
-- customers who have placed at least one order

SELECT * FROM Products p
WHERE NOT EXISTS (SELECT 1 FROM OrderItems oi WHERE oi.ProductID = p.ProductID);
-- products that have never been ordered