USE sql_store;

-- ── BASIC SELECT ─────────────────────────────────────────────
SELECT col1, col2 FROM table;           -- specific columns
SELECT * FROM Customers;                -- all columns (avoid in production)

-- ── CALCULATIONS & EXPRESSIONS ───────────────────────────────
SELECT LastName, FirstName, Points, (Points + 10) * 100 AS 'Discount Factor'
FROM Customers;

SELECT name, UnitPrice, (UnitPrice * 1.1) AS 'New Price' FROM Products;
SELECT *, (Quantity * Price) AS TotalPrice FROM OrderItems;

-- ── ALIASES ──────────────────────────────────────────────────
SELECT col AS alias FROM table;
SELECT col AS 'Column With Spaces' FROM table;

-- ── DISTINCT ─────────────────────────────────────────────────
SELECT DISTINCT State FROM Customers;
SELECT DISTINCT City, State FROM Customers;  -- unique combinations

-- ── NULL ─────────────────────────────────────────────────────
SELECT * FROM Customers WHERE Email IS NULL;
SELECT * FROM Customers WHERE Email IS NOT NULL;
-- WHERE col = NULL never works — always use IS NULL

SELECT FirstName, IFNULL(Phone, 'N/A') AS Phone FROM Customers;
-- IFNULL — replace NULL with a default (MySQL)

-- COMMENTS
-- single line comment
/* multi
   line comment */