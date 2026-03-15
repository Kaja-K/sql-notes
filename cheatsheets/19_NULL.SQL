-- NULL = absence of value — not zero, not empty string, not false
-- NULL is not equal to anything, including itself
-- NULL comparisons always return NULL (unknown), not TRUE or FALSE

-- ── IS NULL / IS NOT NULL ────────────────────────────────────
SELECT * FROM Customers WHERE Phone IS NULL;
SELECT * FROM Customers WHERE Phone IS NOT NULL;

-- common mistake — these never match anything:
-- WHERE Phone = NULL     -- always FALSE
-- WHERE Phone != NULL    -- always FALSE

-- ── COALESCE — first non-NULL value ──────────────────────────
SELECT COALESCE(Phone, Mobile, Email, 'No Contact') AS ContactInfo
FROM Customers;
-- returns first non-NULL — tries each arg left to right

SELECT COALESCE(Discount, 0) AS Discount FROM Orders;  -- default 0
SELECT COALESCE(Notes, 'No notes') FROM Orders;

-- ── IFNULL — MySQL shorthand for two-arg COALESCE ────────────
SELECT IFNULL(Phone, 'N/A')   AS Phone    FROM Customers;
SELECT IFNULL(Discount, 0)    AS Discount FROM Orders;
-- IFNULL(a, b) = COALESCE(a, b)

-- ── NULLIF — turn a value INTO NULL ──────────────────────────
SELECT NULLIF('', 'N/A');     -- NULL if value = second arg, else value itself
SELECT NULLIF(col, '');       -- turn empty string into NULL
SELECT NULLIF(col, 0);        -- turn zero into NULL (useful before division)

-- avoid division by zero using NULLIF
SELECT TotalRevenue / NULLIF(TotalOrders, 0) AS AvgOrderValue FROM Stats;
-- if TotalOrders = 0, returns NULL instead of error

-- ── COUNT NULLS ──────────────────────────────────────────────
SELECT COUNT(*)     AS TotalRows    FROM Customers;
SELECT COUNT(Phone) AS WithPhone    FROM Customers;   -- NULL rows excluded
SELECT COUNT(*) - COUNT(Phone) AS MissingPhone FROM Customers;

-- count NULLs per column
SELECT
    COUNT(*) - COUNT(Phone)   AS NullPhone,
    COUNT(*) - COUNT(Email)   AS NullEmail,
    COUNT(*) - COUNT(City)    AS NullCity
FROM Customers;

-- ── NULL IN EXPRESSIONS ──────────────────────────────────────
SELECT NULL + 5;          -- NULL  (any arithmetic with NULL = NULL)
SELECT NULL || 'hello';   -- NULL  (string concat with NULL = NULL)
SELECT CONCAT('hi', NULL);-- NULL  in MySQL
SELECT CONCAT_WS(',', 'a', NULL, 'b');  -- 'a,b' — CONCAT_WS skips NULLs

-- ── NULL IN AGGREGATE FUNCTIONS ──────────────────────────────
-- all aggregate functions (SUM, AVG, MIN, MAX, COUNT(col)) ignore NULLs
-- COUNT(*) counts all rows including NULLs
SELECT AVG(Discount) FROM Orders;  -- NULL rows excluded from average
-- be aware: AVG of (10, NULL, NULL) = 10, not 3.33

-- ── NULL IN ORDER BY ─────────────────────────────────────────
SELECT * FROM Customers ORDER BY Phone ASC;   -- NULLs sort LAST in ASC
SELECT * FROM Customers ORDER BY Phone DESC;  -- NULLs sort FIRST in DESC

-- force NULLs always last:
SELECT * FROM Customers ORDER BY Phone IS NULL ASC, Phone ASC;
-- IS NULL returns 0 (not null) or 1 (null) — so NULLs go to end

-- ── NULL IN JOINs ────────────────────────────────────────────
-- NULL FK values never match any row — they're excluded from INNER JOIN
-- use LEFT JOIN + IS NULL to find unmatched rows:
SELECT c.CustomerID, c.FirstName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;   -- customers with no orders

-- ── CASE WITH NULL ───────────────────────────────────────────
SELECT FirstName,
    CASE
        WHEN Phone IS NULL THEN 'Missing'
        WHEN Phone = ''    THEN 'Empty'
        ELSE Phone
    END AS PhoneStatus
FROM Customers;

-- ── PRACTICAL CLEANUP ────────────────────────────────────────
-- replace empty strings with NULL (standardise missing data)
UPDATE Customers SET Phone = NULL WHERE TRIM(Phone) = '';
UPDATE Customers SET City  = NULL WHERE City IN ('N/A', 'Unknown', '-');

-- fill NULLs with a default
UPDATE Customers SET Points = 0 WHERE Points IS NULL;