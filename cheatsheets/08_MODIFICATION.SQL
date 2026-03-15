-- ── INSERT ───────────────────────────────────────────────────
INSERT INTO Customers (FirstName, LastName, Email, City, Points)
VALUES ('Anna', 'Kowalski', 'anna@example.com', 'Warsaw', 1500);

-- DEFAULT lets MySQL auto-generate the primary key (AUTO_INCREMENT)
INSERT INTO Customers VALUES (DEFAULT, 'Jan', 'Nowak', 'jan@example.com', 'Krakow', 2000);

-- multiple rows in one statement — faster than separate inserts
INSERT INTO Customers (FirstName, LastName, City, Points)
VALUES
    ('Eva',  'Smith',  'Gdansk',  1200),
    ('Tom',  'Brown',  'Poznan',  3400),
    ('Kate', 'Wilson', 'Wroclaw',  800);

-- INSERT ... SELECT — copy rows from another table
INSERT INTO ArchivedOrders (OrderID, CustomerID, Total, OrderDate)
SELECT OrderID, CustomerID, Total, OrderDate
FROM Orders
WHERE OrderDate < '2025-01-01';

-- get auto-generated ID of the last insert
SELECT LAST_INSERT_ID();

-- UPSERT — insert or update on duplicate key
INSERT INTO Products (ProductID, Name, Price)
VALUES (1, 'Widget', 9.99)
ON DUPLICATE KEY UPDATE
    Name  = VALUES(Name),
    Price = VALUES(Price);

-- ── UPDATE ───────────────────────────────────────────────────
-- ALWAYS use WHERE — without it every row is updated
UPDATE Customers
SET Email  = 'new@example.com',
    City   = 'Warsaw',
    Points = Points + 100          -- relative update
WHERE CustomerID = 1;

-- update with expression
UPDATE OrderItems
SET UnitPrice = UnitPrice * 1.10   -- 10% price increase
WHERE ProductID = 5;

-- update with subquery
UPDATE Orders
SET Comments = 'VIP customer'
WHERE CustomerID IN (
    SELECT CustomerID FROM Customers WHERE Points > 3000
);

-- update with JOIN (MySQL syntax)
UPDATE Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
SET o.Comments = 'Gold tier'
WHERE c.Points > 3000;

-- ── DELETE ───────────────────────────────────────────────────
-- ALWAYS use WHERE — without it every row is deleted
DELETE FROM Customers WHERE CustomerID = 5;
DELETE FROM Orders    WHERE OrderDate < '2020-01-01';

-- delete with subquery
DELETE FROM Orders
WHERE CustomerID IN (
    SELECT CustomerID FROM Customers WHERE Status = 'Inactive'
);

-- delete with JOIN (MySQL syntax)
DELETE o
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Status = 'Inactive';

-- ── TRUNCATE — delete all rows, keep table structure ─────────
TRUNCATE TABLE TempData;
-- faster than DELETE with no WHERE
-- resets AUTO_INCREMENT counter (DELETE does not)
-- cannot be rolled back in some storage engines

-- ── SAFETY PATTERN ───────────────────────────────────────────
-- step 1: preview rows before touching them
SELECT * FROM Customers WHERE Points < 100;

-- step 2: wrap in transaction to allow rollback
START TRANSACTION;
DELETE FROM Customers WHERE Points < 100;
SELECT ROW_COUNT();    -- how many rows were affected
ROLLBACK;              -- undo — change to COMMIT when sure

-- ROW_COUNT() — rows affected by last write statement
UPDATE Customers SET Points = 0 WHERE City = 'Warsaw';
SELECT ROW_COUNT();    -- e.g. 12