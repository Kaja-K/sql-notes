-- a transaction groups multiple statements into one atomic unit
-- ACID properties:
--   Atomicity   — all succeed or all fail together
--   Consistency — database stays in valid state
--   Isolation   — concurrent transactions don't interfere
--   Durability  — committed changes survive crashes

-- ── BEGIN / COMMIT / ROLLBACK ────────────────────────────────
START TRANSACTION;           -- or: BEGIN;
    UPDATE Accounts SET Balance = Balance - 500 WHERE AccountID = 1;
    UPDATE Accounts SET Balance = Balance + 500 WHERE AccountID = 2;
COMMIT;                      -- save both changes permanently

-- if anything goes wrong, undo everything:
START TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 500 WHERE AccountID = 1;
    UPDATE Accounts SET Balance = Balance + 500 WHERE AccountID = 2;
ROLLBACK;                    -- undo all changes since START TRANSACTION

-- ── AUTOCOMMIT ───────────────────────────────────────────────
-- MySQL runs each statement in its own transaction by default
SHOW VARIABLES LIKE 'autocommit';   -- ON by default
SET autocommit = OFF;               -- disable — must COMMIT manually
SET autocommit = ON;                -- re-enable

-- ── SAVEPOINT — partial rollback ─────────────────────────────
START TRANSACTION;

    INSERT INTO Orders (CustomerID, Total) VALUES (1, 99.99);
    SAVEPOINT after_order;           -- checkpoint

    INSERT INTO OrderItems (OrderID, ProductID, Quantity) VALUES (LAST_INSERT_ID(), 5, 2);
    -- something goes wrong with items:
    ROLLBACK TO after_order;         -- undo only to savepoint, order stays

    -- continue differently...
    INSERT INTO OrderItems (OrderID, ProductID, Quantity) VALUES (LAST_INSERT_ID(), 3, 1);

COMMIT;

RELEASE SAVEPOINT after_order;      -- optional: free savepoint name

-- ── ERROR HANDLING WITH TRANSACTIONS ─────────────────────────
-- in application code (pseudo-SQL):
START TRANSACTION;
    UPDATE Customers SET Points = Points + 100 WHERE CustomerID = 1;
    -- IF error THEN ROLLBACK ELSE COMMIT END IF;

-- MySQL stored procedure pattern:
DELIMITER //
CREATE PROCEDURE TransferPoints(from_id INT, to_id INT, amount INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;          -- re-raise the error
    END;

    START TRANSACTION;
        UPDATE Customers SET Points = Points - amount WHERE CustomerID = from_id;
        UPDATE Customers SET Points = Points + amount WHERE CustomerID = to_id;
    COMMIT;
END //
DELIMITER ;

-- ── ISOLATION LEVELS ─────────────────────────────────────────
-- control what a transaction can see from other concurrent transactions
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  -- can read uncommitted changes (dirty read)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;    -- only committed data (default in PostgreSQL)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;   -- same read within transaction (MySQL default)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;      -- strictest, transactions run as if sequential

-- set for current session:
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- check current level:
SELECT @@transaction_isolation;

-- isolation level problems:
-- Dirty Read       — read uncommitted data from another transaction
-- Non-repeatable  — same query returns different rows mid-transaction
-- Phantom Read     — new rows appear in a repeated query
--
-- READ UNCOMMITTED → all problems possible
-- READ COMMITTED   → prevents dirty reads
-- REPEATABLE READ  → prevents dirty + non-repeatable (MySQL default)
-- SERIALIZABLE     → prevents all — but slowest

-- ── LOCKING ──────────────────────────────────────────────────
-- SELECT ... FOR UPDATE — lock rows for update, prevent others reading
START TRANSACTION;
SELECT * FROM Inventory WHERE ProductID = 5 FOR UPDATE;
-- other transactions wait until this commits or rolls back
UPDATE Inventory SET Quantity = Quantity - 1 WHERE ProductID = 5;
COMMIT;

-- SELECT ... LOCK IN SHARE MODE — allow others to read, block writes
SELECT * FROM Customers WHERE CustomerID = 1 LOCK IN SHARE MODE;

-- ── DEADLOCK ─────────────────────────────────────────────────
-- occurs when two transactions wait for each other's locks
-- MySQL detects and kills one automatically
-- prevention: always access tables in the same order in all transactions
-- keep transactions short to reduce lock duration
SHOW ENGINE INNODB STATUS;   -- inspect recent deadlocks

-- ── PRACTICAL PATTERN ────────────────────────────────────────
-- preview changes before committing
START TRANSACTION;
DELETE FROM Orders WHERE OrderDate < '2020-01-01';
SELECT ROW_COUNT();    -- check how many rows affected
ROLLBACK;              -- undo — change to COMMIT when confident