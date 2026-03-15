-- a VIEW is a saved SELECT query treated as a virtual table
-- no data is stored — runs the underlying query each time
-- benefits: reusability, security (hide columns), simplify complex queries

-- ── CREATE VIEW ───────────────────────────────────────────────
CREATE VIEW ActiveCustomers AS
SELECT CustomerID, FirstName, LastName, City, Points
FROM Customers
WHERE Status = 'Active';

-- complex view — join + aggregation
CREATE VIEW CustomerOrderSummary AS
SELECT c.CustomerID, c.FirstName, c.LastName,
       COUNT(o.OrderID)          AS TotalOrders,
       SUM(o.Total)              AS TotalSpent,
       MAX(o.OrderDate)          AS LastOrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;

-- ── QUERY A VIEW ─────────────────────────────────────────────
-- use exactly like a regular table
SELECT * FROM ActiveCustomers;
SELECT * FROM ActiveCustomers WHERE City = 'Warsaw';
SELECT * FROM CustomerOrderSummary WHERE TotalSpent > 500 ORDER BY TotalSpent DESC;

-- join a view with a table
SELECT v.FirstName, v.TotalSpent, o.OrderID
FROM CustomerOrderSummary v
JOIN Orders o ON v.CustomerID = o.CustomerID;

-- ── CREATE OR REPLACE — update definition in place ────────────
CREATE OR REPLACE VIEW ActiveCustomers AS
SELECT CustomerID, FirstName, LastName, City, Points, Email  -- added Email
FROM Customers
WHERE Status = 'Active';

-- ── DROP VIEW ────────────────────────────────────────────────
DROP VIEW IF EXISTS ActiveCustomers;     -- IF EXISTS prevents error if missing

-- ── UPDATABLE VIEWS ──────────────────────────────────────────
-- simple views (no GROUP BY, DISTINCT, aggregates, subqueries, UNION)
-- can be used with INSERT / UPDATE / DELETE directly
UPDATE ActiveCustomers
SET City = 'Krakow'
WHERE CustomerID = 5;
-- updates the underlying Customers table

-- WITH CHECK OPTION — prevents writes that would make row invisible in view
CREATE OR REPLACE VIEW ActiveCustomers AS
SELECT CustomerID, FirstName, Status
FROM Customers
WHERE Status = 'Active'
WITH CHECK OPTION;
-- UPDATE that sets Status = 'Inactive' will be rejected
-- because the row would no longer be visible through this view

-- ── INSPECT VIEWS ────────────────────────────────────────────
SHOW FULL TABLES WHERE Table_type = 'VIEW';  -- list all views in database
SHOW CREATE VIEW ActiveCustomers;            -- see view definition
SELECT * FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'sql_store';

-- ── MATERIALIZED VIEW ────────────────────────────────────────
-- stores results physically — NOT natively supported in MySQL
-- PostgreSQL syntax (for reference):
-- CREATE MATERIALIZED VIEW SalesSummary AS
-- SELECT City, SUM(Total) AS Revenue FROM Orders GROUP BY City;
-- REFRESH MATERIALIZED VIEW SalesSummary;  -- recompute cached data

-- MySQL workaround — use a real table + scheduled refresh:
CREATE TABLE SalesSummary AS
SELECT City, SUM(Total) AS Revenue FROM Orders GROUP BY City;
-- refresh manually or via event:
-- TRUNCATE TABLE SalesSummary;
-- INSERT INTO SalesSummary SELECT City, SUM(Total) FROM Orders GROUP BY City;

-- ── WHEN TO USE VIEWS ─────────────────────────────────────────
-- reuse complex JOINs without rewriting them
-- restrict columns for security (e.g. hide salary, SSN)
-- present a consistent interface when tables change underneath
-- simplify reporting queries for non-technical users
-- NOT a performance optimisation in MySQL — reruns every time