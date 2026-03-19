-- ── CAST ─────────────────────────────────────────────────────
CAST(expr AS type)                      -- standard SQL, works everywhere
SELECT CAST('123' AS UNSIGNED);         -- '123'  → 123
SELECT CAST('3.14' AS DECIMAL(5,2));    -- '3.14' → 3.14
SELECT CAST(255 AS CHAR);               -- 255    → '255'
SELECT CAST('2024-01-15' AS DATE);      -- string → DATE
SELECT CAST(NOW() AS DATE);             -- DATETIME → DATE (drops time)
SELECT CAST(1 AS BOOLEAN);             -- 1 → TRUE (MySQL: TINYINT(1))

-- ── CONVERT ──────────────────────────────────────────────────
CONVERT(expr, type)                     -- MySQL syntax (same as CAST)
SELECT CONVERT('99', SIGNED);
SELECT CONVERT(3.99, UNSIGNED);         -- 3.99 → 3 (truncates)
SELECT CONVERT(NOW(), DATE);

-- CONVERT with charset (MySQL-specific)
SELECT CONVERT('hello' USING utf8mb4);
SELECT CONVERT('tekst' USING latin1);

-- ── IMPLICIT CONVERSION (automatic) ──────────────────────────
SELECT '5' + 3;                         -- → 8   (string → number)
SELECT '5abc' + 3;                      -- → 8   (partial parse, no error)
SELECT 'abc' + 3;                       -- → 3   (non-numeric → 0)
SELECT TRUE + TRUE;                     -- → 2   (bool → int)
-- Implicit conversion is risky — prefer CAST for clarity

-- ── CHAR / ASCII ──────────────────────────────────────────────
SELECT ASCII('A');                      -- → 65  (first char → ASCII code)
SELECT ASCII('hello');                  -- → 104 (only first char: 'h')
SELECT CHAR(65);                        -- → 'A' (ASCII code → character)
SELECT CHAR(72, 101, 108, 108, 111);   -- → 'Hello'
SELECT CHAR(65 USING utf8mb4);         -- with explicit charset

-- ── HEX / UNHEX ───────────────────────────────────────────────
SELECT HEX('A');                        -- → '41'   (char → hex)
SELECT HEX(255);                        -- → 'FF'   (int → hex)
SELECT HEX('SQL');                      -- → '53514C'
SELECT UNHEX('41');                     -- → 'A'    (hex → char)
SELECT UNHEX('53514C');                 -- → 'SQL'
SELECT CONV(255, 10, 16);              -- → 'FF'   (base 10 → base 16)
SELECT CONV('FF', 16, 10);             -- → '255'  (base 16 → base 10)
SELECT CONV('1111', 2, 10);            -- → '15'   (binary → decimal)

-- ── BIN / OCT ─────────────────────────────────────────────────
SELECT BIN(10);                         -- → '1010'  (decimal → binary)
SELECT OCT(8);                          -- → '10'    (decimal → octal)
SELECT CONV(10, 10, 2);                -- same as BIN(10)

-- ── STRING → NUMBER ───────────────────────────────────────────
SELECT CAST('42' AS SIGNED);           -- signed integer (negative allowed)
SELECT CAST('42' AS UNSIGNED);         -- unsigned integer (no negatives)
SELECT CAST('3.14' AS DECIMAL(10,4));  -- exact decimal
SELECT CAST('3.14' AS FLOAT);          -- floating point
SELECT '007' + 0;                       -- quick implicit trick → 7

-- ── NUMBER → STRING ───────────────────────────────────────────
SELECT CAST(123 AS CHAR);              -- → '123'
SELECT CONVERT(3.14, CHAR);           -- → '3.14'
SELECT FORMAT(1234567.891, 2);         -- → '1,234,567.89' (with commas)
SELECT FORMAT(price, 2) FROM Products; -- format column for display

-- ── DATE ↔ STRING ─────────────────────────────────────────────
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d');          -- DATE → '2024-01-15'
SELECT DATE_FORMAT(NOW(), '%d/%m/%Y');          -- DATE → '15/01/2024'
SELECT DATE_FORMAT(NOW(), '%W, %M %d %Y');      -- 'Monday, January 15 2024'
SELECT DATE_FORMAT(NOW(), '%H:%i:%s');          -- → '14:30:00' (time only)

SELECT STR_TO_DATE('15/01/2024', '%d/%m/%Y');  -- string → DATE
SELECT STR_TO_DATE('Jan 15 2024', '%b %d %Y'); -- → '2024-01-15'

SELECT CAST('2024-01-15' AS DATE);             -- ISO format string → DATE
SELECT CAST('2024-01-15 10:30:00' AS DATETIME);

-- ── DATE ↔ NUMBER ─────────────────────────────────────────────
SELECT TO_DAYS('2024-01-15');           -- → days since year 0
SELECT FROM_DAYS(739261);               -- → '2024-01-15'
SELECT UNIX_TIMESTAMP('2024-01-15');    -- → Unix epoch (seconds)
SELECT FROM_UNIXTIME(1705276800);       -- epoch → DATETIME
SELECT FROM_UNIXTIME(1705276800, '%Y-%m-%d'); -- epoch → formatted string

-- ── NUMERIC ROUNDING / PRECISION ──────────────────────────────
SELECT ROUND(3.14159, 2);              -- → 3.14   (round to N decimals)
SELECT FLOOR(3.99);                    -- → 3      (round down)
SELECT CEIL(3.01);                     -- → 4      (round up)
SELECT TRUNCATE(3.99999, 2);           -- → 3.99   (cut, don't round)
SELECT ABS(-42);                       -- → 42     (absolute value)

-- ── BOOLEAN CONVERSIONS ───────────────────────────────────────
SELECT TRUE, FALSE;                    -- → 1, 0  (MySQL stores as TINYINT)
SELECT CAST(1 AS BOOLEAN);            -- → 1
SELECT IF(1, 'yes', 'no');            -- → 'yes'
SELECT IF(0, 'yes', 'no');            -- → 'no'
SELECT IF(NULL, 'yes', 'no');         -- → 'no'  (NULL is falsy)

-- ── NULLIF / COALESCE (type-safe NULL handling) ───────────────
SELECT NULLIF(10, 10);                 -- → NULL  (equal → NULL)
SELECT NULLIF(10, 0);                  -- → 10    (not equal → first arg)
SELECT NULLIF(price, 0) FROM Products; -- treat 0 as NULL (e.g. for division)

SELECT COALESCE(NULL, NULL, 'fallback'); -- → 'fallback' (first non-NULL)
SELECT COALESCE(phone, email, 'N/A') FROM Customers;

-- ── PRACTICAL EXAMPLES ────────────────────────────────────────
-- Safe division (avoid divide-by-zero)
SELECT total / NULLIF(qty, 0) AS unit_price FROM Orders;

-- Extract year as integer from date string
SELECT CAST(DATE_FORMAT(order_date, '%Y') AS UNSIGNED) AS yr FROM Orders;

-- Store phone digits only
SELECT CAST(REGEXP_REPLACE(phone, '[^0-9]', '') AS UNSIGNED) FROM Customers;

-- Convert price string with currency symbol to decimal
SELECT CAST(REPLACE(REPLACE(price_str, '$', ''), ',', '') AS DECIMAL(10,2))
FROM Products;