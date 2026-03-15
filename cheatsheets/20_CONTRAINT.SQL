-- constraints enforce rules at the database level
-- they fire on INSERT, UPDATE, DELETE before data is written
-- better than enforcing rules only in application code

-- ── PRIMARY KEY ──────────────────────────────────────────────
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT  -- inline
);

-- or separately (required for composite PK):
CREATE TABLE OrderItems (
    OrderID   INT,
    ProductID INT,
    Quantity  INT,
    PRIMARY KEY (OrderID, ProductID)           -- composite PK
);

ALTER TABLE Customers ADD PRIMARY KEY (CustomerID);
ALTER TABLE Customers DROP PRIMARY KEY;

-- ── FOREIGN KEY ──────────────────────────────────────────────
CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE CASCADE    -- delete orders when customer deleted
        ON UPDATE CASCADE    -- update FK when PK changes
);

-- ON DELETE options:
-- CASCADE     → delete child rows automatically
-- SET NULL    → set FK to NULL (column must allow NULL)
-- RESTRICT    → block delete if child rows exist (default)
-- NO ACTION   → same as RESTRICT in MySQL
-- SET DEFAULT → set to column default (not supported in InnoDB)

ALTER TABLE Orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Orders DROP FOREIGN KEY fk_orders_customers;

-- ── UNIQUE ───────────────────────────────────────────────────
CREATE TABLE Customers (
    Email VARCHAR(100) UNIQUE               -- inline
);

CREATE TABLE Customers (
    Email   VARCHAR(100),
    Phone   VARCHAR(20),
    UNIQUE (Email),                         -- separate
    UNIQUE (Phone)
);

-- composite unique — combination must be unique, not individual values
CREATE TABLE TeamMembers (
    TeamID  INT,
    UserID  INT,
    UNIQUE (TeamID, UserID)                 -- same user can be in different teams
);

ALTER TABLE Customers ADD UNIQUE (Email);
ALTER TABLE Customers DROP INDEX Email;     -- drop unique constraint

-- ── NOT NULL ─────────────────────────────────────────────────
CREATE TABLE Customers (
    FirstName VARCHAR(50) NOT NULL,
    LastName  VARCHAR(50) NOT NULL,
    Phone     VARCHAR(20)                   -- NULL allowed (default)
);

ALTER TABLE Customers MODIFY COLUMN FirstName VARCHAR(50) NOT NULL;

-- ── DEFAULT ──────────────────────────────────────────────────
CREATE TABLE Orders (
    Status      VARCHAR(20)  DEFAULT 'Pending',
    Points      INT          DEFAULT 0,
    CreatedAt   DATETIME     DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE Orders ALTER COLUMN Status SET DEFAULT 'Pending';
ALTER TABLE Orders ALTER COLUMN Status DROP DEFAULT;

-- ── CHECK — enforce a condition ──────────────────────────────
CREATE TABLE Customers (
    Age     INT  CHECK (Age >= 18),
    Points  INT  CHECK (Points >= 0 AND Points <= 100000),
    Email   VARCHAR(100) CHECK (Email LIKE '%@%')
);

-- named constraint (better for error messages):
CREATE TABLE Products (
    Price DECIMAL(10,2),
    CONSTRAINT chk_price CHECK (Price > 0)
);

-- multi-column check:
CREATE TABLE Discounts (
    StartDate DATE,
    EndDate   DATE,
    CONSTRAINT chk_dates CHECK (EndDate > StartDate)
);

ALTER TABLE Customers ADD CONSTRAINT chk_age CHECK (Age >= 0);
ALTER TABLE Customers DROP CHECK chk_age;

-- ── INSPECT CONSTRAINTS ──────────────────────────────────────
SELECT * FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'sql_store' AND TABLE_NAME = 'Orders';

SELECT * FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'sql_store';

SHOW CREATE TABLE Orders;    -- shows all constraints in DDL form