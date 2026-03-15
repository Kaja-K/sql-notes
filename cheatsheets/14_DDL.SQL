-- DDL = Data Definition Language — creates/modifies/removes database structure

-- ── CREATE TABLE ─────────────────────────────────────────────
CREATE TABLE Customers (
    CustomerID   INT           PRIMARY KEY AUTO_INCREMENT,
    FirstName    VARCHAR(50)   NOT NULL,
    LastName     VARCHAR(50)   NOT NULL,
    Email        VARCHAR(100)  NOT NULL UNIQUE,
    Phone        VARCHAR(20),             -- NULL allowed by default
    City         VARCHAR(50),
    Points       INT           DEFAULT 0,
    Status       ENUM('Active','Inactive','Suspended') DEFAULT 'Active',
    CreatedAt    DATETIME      DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt    DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CREATE TABLE AS — create from a query (copies data too)
CREATE TABLE ArchivedOrders AS
SELECT * FROM Orders WHERE OrderDate < '2025-01-01';

-- CREATE TABLE IF NOT EXISTS — no error if already exists
CREATE TABLE IF NOT EXISTS TempLogs (LogID INT PRIMARY KEY, Message TEXT);

-- ── COMMON DATA TYPES ────────────────────────────────────────
-- INT, BIGINT, TINYINT, SMALLINT       — whole numbers
-- DECIMAL(p,s), NUMERIC                — exact decimals (use for money)
-- FLOAT, DOUBLE                        — approximate (avoid for money)
-- VARCHAR(n)                           — variable-length string, max n chars
-- CHAR(n)                              — fixed-length string (padded with spaces)
-- TEXT, MEDIUMTEXT, LONGTEXT           — long strings (no default, no index)
-- DATE                                 -- 'YYYY-MM-DD'
-- DATETIME                             -- 'YYYY-MM-DD HH:MM:SS'
-- TIMESTAMP                            -- like DATETIME but stored as UTC
-- BOOLEAN / TINYINT(1)                 -- 0 or 1
-- ENUM('a','b','c')                    -- one value from a fixed list
-- JSON                                 -- structured JSON (MySQL 5.7+)

-- ── DROP TABLE ───────────────────────────────────────────────
DROP TABLE Customers;
DROP TABLE IF EXISTS TempLogs;       -- no error if table doesn't exist

-- ── ALTER TABLE — modify existing table ──────────────────────
ALTER TABLE Customers ADD COLUMN BirthDate DATE;
ALTER TABLE Customers ADD COLUMN Score DECIMAL(5,2) DEFAULT 0 AFTER Points;

ALTER TABLE Customers DROP COLUMN Phone;

ALTER TABLE Customers RENAME COLUMN FirstName TO GivenName;  -- MySQL 8.0+
ALTER TABLE Customers CHANGE FirstName GivenName VARCHAR(50);  -- older MySQL

ALTER TABLE Customers MODIFY COLUMN City VARCHAR(100) NOT NULL;  -- change type/constraint

ALTER TABLE Customers RENAME TO Clients;  -- rename the table

-- ── PRIMARY KEY ──────────────────────────────────────────────
-- defined inline:
CustomerID INT PRIMARY KEY AUTO_INCREMENT

-- or separately (required for composite PK):
PRIMARY KEY (OrderID, ProductID)

-- add after creation:
ALTER TABLE Orders ADD PRIMARY KEY (OrderID);

-- ── FOREIGN KEY ──────────────────────────────────────────────
CREATE TABLE Orders (
    OrderID     INT          PRIMARY KEY AUTO_INCREMENT,
    CustomerID  INT          NOT NULL,
    OrderDate   DATE         NOT NULL,
    Total       DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE CASCADE      -- delete order when customer deleted
        ON UPDATE CASCADE      -- update FK when PK changes
);

-- ON DELETE options:
-- CASCADE      → delete child rows automatically
-- SET NULL     → set FK to NULL
-- RESTRICT     → block deletion if child rows exist (default)
-- NO ACTION    → same as RESTRICT in MySQL

-- add FK to existing table:
ALTER TABLE Orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
ON DELETE RESTRICT;

-- drop FK:
ALTER TABLE Orders DROP FOREIGN KEY fk_customer;

-- ── TRUNCATE vs DROP ─────────────────────────────────────────
TRUNCATE TABLE TempData;   -- delete all rows, keep structure, reset AUTO_INCREMENT
DROP TABLE TempData;       -- delete table entirely

-- ── INSPECT TABLE STRUCTURE ──────────────────────────────────
DESCRIBE Customers;             -- columns, types, nullability, keys
SHOW CREATE TABLE Customers;    -- full CREATE TABLE statement
SHOW TABLES;                    -- all tables in current database
SHOW DATABASES;

-- ── GENERATED COLUMNS ────────────────────────────────────────
-- computed from other columns — stored or virtual
ALTER TABLE Customers
ADD COLUMN FullName VARCHAR(101)
    GENERATED ALWAYS AS (CONCAT(FirstName, ' ', LastName)) VIRTUAL;
-- VIRTUAL = computed on read, not stored
-- STORED  = computed on write, takes space but can be indexed