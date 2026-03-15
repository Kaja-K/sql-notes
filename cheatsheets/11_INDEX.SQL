-- an index is a separate data structure (B-tree by default) that lets MySQL
-- find rows without scanning the whole table
-- trade-off: faster reads, slower writes (INSERT/UPDATE/DELETE must update index too)

-- ── CREATE INDEX ─────────────────────────────────────────────
CREATE INDEX idx_city     ON Customers(City);
CREATE INDEX idx_lastname ON Customers(LastName);
CREATE INDEX idx_orderdate ON Orders(OrderDate);

-- ── UNIQUE INDEX — enforces uniqueness + speeds up lookups ────
CREATE UNIQUE INDEX idx_email ON Customers(Email);
-- duplicate emails will be rejected on INSERT/UPDATE

-- ── COMPOSITE INDEX — multiple columns ───────────────────────
CREATE INDEX idx_city_points ON Customers(City, Points);
-- efficient for: WHERE City = 'Warsaw' AND Points > 1000
-- also helps: WHERE City = 'Warsaw'  (leftmost prefix rule)
-- does NOT help: WHERE Points > 1000  alone (not leftmost)

-- column order matters — put the most selective column first
CREATE INDEX idx_status_date ON Orders(Status, OrderDate);

-- ── FULL-TEXT INDEX — search inside text columns ─────────────
CREATE FULLTEXT INDEX idx_ft_notes ON Orders(Notes);
-- used with MATCH ... AGAINST instead of LIKE
SELECT * FROM Orders
WHERE MATCH(Notes) AGAINST('urgent delivery' IN BOOLEAN MODE);
-- much faster than LIKE '%urgent delivery%'

-- ── DROP INDEX ───────────────────────────────────────────────
DROP INDEX idx_city ON Customers;
ALTER TABLE Customers DROP INDEX idx_city;  -- alternative syntax

-- ── INSPECT INDEXES ──────────────────────────────────────────
SHOW INDEXES FROM Customers;               -- all indexes on a table
SHOW INDEX  FROM Orders;
SELECT * FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'sql_store' AND TABLE_NAME = 'Customers';

-- ── EXPLAIN — show query execution plan ──────────────────────
EXPLAIN SELECT * FROM Customers WHERE City = 'Warsaw';
-- key columns to check:
--   type:     ALL = full scan (bad), ref/range/const = index used (good)
--   key:      which index was used (NULL = no index)
--   rows:     estimated rows examined (lower = better)
--   Extra:    'Using index' = covered index (fastest)

EXPLAIN SELECT c.FirstName, o.Total
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City = 'Warsaw';

-- ── EXPLAIN ANALYZE — run query + show actual timings ─────────
EXPLAIN ANALYZE SELECT * FROM Orders WHERE OrderDate > '2026-01-01';
-- shows both estimated and actual rows + execution time

-- ── INDEX USAGE TIPS ─────────────────────────────────────────
-- index IS used:
SELECT * FROM Customers WHERE City = 'Warsaw';         -- equality
SELECT * FROM Customers WHERE Points > 2000;           -- range
SELECT * FROM Customers WHERE City LIKE 'War%';        -- prefix LIKE

-- index is NOT used (common mistakes):
SELECT * FROM Customers WHERE YEAR(Birthdate) = 1990;  -- function on column
SELECT * FROM Customers WHERE Points + 10 > 2000;      -- expression on column
SELECT * FROM Customers WHERE City LIKE '%saw';        -- leading wildcard
-- fix: use generated columns or rewrite the condition

-- ── PREFIX INDEX — index only first N chars of a string ──────
-- saves space for long VARCHAR/TEXT columns
CREATE INDEX idx_email_prefix ON Customers(Email(20));
-- indexes only first 20 characters

-- ── COVERING INDEX — query satisfied entirely from index ──────
-- no need to read the actual table row — fastest possible read
CREATE INDEX idx_cover ON Orders(CustomerID, OrderDate, Total);
SELECT CustomerID, OrderDate, Total FROM Orders
WHERE CustomerID = 5;
-- all needed columns are in the index — Extra shows 'Using index'

-- ── WHEN TO ADD AN INDEX ─────────────────────────────────────
-- columns frequently used in WHERE, JOIN ON, ORDER BY
-- foreign keys (MySQL does not auto-index them)
-- columns with high cardinality (many unique values)
-- do NOT index: columns with few unique values (boolean, status with 3 values)
-- do NOT over-index: every index slows down INSERT/UPDATE/DELETE