-- ── CAST — standard SQL, portable ────────────────────────────
SELECT CAST('42'       AS UNSIGNED);       -- '42'        → 42
SELECT CAST('3.14'     AS DECIMAL(10,2));  -- '3.14'      → 3.14
SELECT CAST(42         AS CHAR);           -- 42          → '42'
SELECT CAST('2026-03-14' AS DATE);         -- string      → DATE
SELECT CAST('2026-03-14 09:30' AS DATETIME);
SELECT CAST(1          AS BOOLEAN);        -- 1           → TRUE (TINYINT)
SELECT CAST('hello'    AS BINARY);         -- string      → binary

-- CAST types: BINARY, CHAR, DATE, DATETIME, DECIMAL, DOUBLE,
--             FLOAT, JSON, SIGNED, TIME, UNSIGNED, YEAR (MySQL 8.0.17+)

-- ── CONVERT — MySQL alternative, same result ─────────────────
SELECT CONVERT('42',       UNSIGNED);      -- string → int
SELECT CONVERT(42,         CHAR);          -- int    → string
SELECT CONVERT('3.14',     DECIMAL(10,2));

-- CONVERT also handles character set conversion:
SELECT CONVERT('hello' USING utf8mb4);
SELECT CONVERT(col USING latin1) FROM Customers;

-- ── IMPLICIT CONVERSION — MySQL does it automatically ────────
SELECT '5' + 3;           -- 8    (string coerced to number)
SELECT '5abc' + 3;        -- 8    (leading digits used, rest ignored)
SELECT 'abc' + 3;         -- 3    (non-numeric string → 0)
-- implicit conversion is unpredictable — always cast explicitly

-- ── STRING ↔ NUMBER ──────────────────────────────────────────
SELECT CAST('123.45' AS DECIMAL(10,2));   -- 123.45
SELECT CAST(123.45   AS CHAR);            -- '123.45'
SELECT CAST('abc'    AS SIGNED);          -- 0  (non-numeric → 0, no error)

-- safe string-to-number (returns NULL instead of 0 for non-numeric):
SELECT CASE WHEN '42' REGEXP '^[0-9.]+$' THEN CAST('42' AS DECIMAL) ELSE NULL END;
-- or in MySQL 8+ use CAST with error handling patterns

-- ── STRING ↔ DATE ─────────────────────────────────────────────
SELECT CAST('2026-03-14' AS DATE);
SELECT STR_TO_DATE('14/03/2026', '%d/%m/%Y');       -- custom format → DATE
SELECT STR_TO_DATE('March 14 2026', '%M %d %Y');
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d');               -- DATE → formatted string
SELECT UNIX_TIMESTAMP('2026-03-14');                 -- DATE → Unix timestamp
SELECT FROM_UNIXTIME(1741910400);                    -- Unix timestamp → DATETIME

-- ── NUMBER ↔ DATE ─────────────────────────────────────────────
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP());  -- current unix ts → datetime
SELECT UNIX_TIMESTAMP(NOW());            -- now → seconds since epoch

-- ── JSON CONVERSION (MySQL 5.7+) ─────────────────────────────
SELECT CAST('{"a":1}' AS JSON);
SELECT JSON_TYPE(CAST('"hello"' AS JSON));   -- 'STRING'
SELECT JSON_EXTRACT('{"name":"Anna"}', '$.name');     -- 'Anna'
SELECT JSON_UNQUOTE(JSON_EXTRACT(col, '$.name')) FROM t; -- unquoted value
SELECT col->>'$.name' FROM t;                -- shorthand for JSON_UNQUOTE + extract

-- ── NUMERIC CONVERSIONS ───────────────────────────────────────
SELECT CAST(3.9 AS SIGNED);      -- 4   (rounds in CAST — unlike TRUNCATE)
SELECT CAST(3.1 AS SIGNED);      -- 3
SELECT CAST(-3.9 AS SIGNED);     -- -4

-- between integer sizes:
SELECT CAST(col AS UNSIGNED);    -- removes negative sign (wraps for negatives)
SELECT CAST(col AS SIGNED);      -- allows negatives

-- ── BOOLEAN CONVERSION ───────────────────────────────────────
SELECT CAST(1 AS BOOLEAN);       -- 1 (TRUE)
SELECT CAST(0 AS BOOLEAN);       -- 0 (FALSE)
SELECT CAST(NULL AS BOOLEAN);    -- NULL
-- MySQL stores BOOLEAN as TINYINT(1): 0=false, non-zero=true
SELECT IF(IsActive, 'Yes', 'No') FROM Customers;  -- int → readable label

-- ── PRACTICAL PATTERNS ────────────────────────────────────────
-- fix mixed types in a column before aggregating
SELECT SUM(CAST(Revenue AS DECIMAL(15,2))) FROM RawData;

-- compare a VARCHAR id column to an integer safely
SELECT * FROM Orders WHERE CAST(OrderRef AS UNSIGNED) = 1001;

-- store and retrieve JSON
UPDATE Products SET Metadata = JSON_SET(Metadata, '$.color', 'red') WHERE ProductID = 1;
SELECT ProductID, Metadata->>'$.color' AS Color FROM Products;

-- standardise date formats from imported CSV
UPDATE Imports SET OrderDate = STR_TO_DATE(RawDate, '%m/%d/%Y')
WHERE RawDate IS NOT NULL;