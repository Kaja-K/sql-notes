-- ── ROUNDING ─────────────────────────────────────────────────
SELECT ROUND(3.14159, 2);    -- 3.14   — round to N decimal places
SELECT ROUND(3.14159, 0);    -- 3      — round to integer
SELECT ROUND(3.5);           -- 4      — rounds half up
SELECT ROUND(2.5);           -- 3      -- consistent half-up in MySQL
SELECT ROUND(-3.5);          -- -4     -- rounds away from zero

SELECT FLOOR(3.9);           -- 3      — always round down
SELECT FLOOR(-3.1);          -- -4     — floor goes more negative
SELECT CEIL(3.1);            -- 4      — always round up (CEILING also works)
SELECT CEIL(-3.9);           -- -3

SELECT TRUNCATE(3.999, 2);   -- 3.99   — truncate (no rounding) to N places
SELECT TRUNCATE(123.456, 0); -- 123    -- chop decimals off
SELECT TRUNCATE(123.456, -1);-- 120    -- negative: truncate left of decimal

-- ── ABSOLUTE VALUE ───────────────────────────────────────────
SELECT ABS(-42);             -- 42
SELECT ABS(42);              -- 42
SELECT ABS(Total - Budget) AS Variance FROM Projects;

-- ── MODULO — remainder ───────────────────────────────────────
SELECT 17 % 5;               -- 2
SELECT MOD(17, 5);           -- 2  (same)
SELECT CustomerID % 2 AS IsEven FROM Customers;  -- 0=even, 1=odd
-- useful for: pagination, alternating rows, bucketing

-- ── POWER / SQRT / EXP / LOG ─────────────────────────────────
SELECT POWER(2, 10);         -- 1024  (2^10)
SELECT POW(2, 10);           -- same
SELECT SQRT(144);            -- 12.0
SELECT EXP(1);               -- 2.718...  (e^1)
SELECT LOG(EXP(1));          -- 1.0        natural log
SELECT LOG(10, 100);         -- 2.0        log base 10 of 100
SELECT LOG10(1000);          -- 3.0        base-10 log
SELECT LOG2(8);              -- 3.0        base-2 log

-- ── RANDOM ───────────────────────────────────────────────────
SELECT RAND();               -- random float 0.0 to 1.0 (exclusive)
SELECT RAND() * 100;         -- 0 to 100
SELECT FLOOR(RAND() * 6) + 1 AS DiceRoll;       -- random integer 1-6
SELECT FLOOR(RAND() * (max - min + 1)) + min;   -- random between min and max

-- random sample of rows
SELECT * FROM Customers ORDER BY RAND() LIMIT 10;
-- note: ORDER BY RAND() is slow on large tables — use alternative for big data

-- ── SIGN / GREATEST / LEAST ──────────────────────────────────
SELECT SIGN(-42);            -- -1
SELECT SIGN(0);              -- 0
SELECT SIGN(42);             -- 1
SELECT GREATEST(3, 7, 1, 9, 4);  -- 9   — max across multiple values
SELECT LEAST(3, 7, 1, 9, 4);     -- 1   — min across multiple values
SELECT GREATEST(Price, MinPrice) AS EffectivePrice FROM Products;

-- ── PI / TRIG ────────────────────────────────────────────────
SELECT PI();                 -- 3.14159265358979
SELECT SIN(PI() / 2);        -- 1.0
SELECT COS(0);               -- 1.0
SELECT RADIANS(180);         -- 3.14159...  degrees → radians
SELECT DEGREES(PI());        -- 180.0       radians → degrees

-- ── FORMAT / CONV ────────────────────────────────────────────
SELECT FORMAT(1234567.89, 2);   -- '1,234,567.89'  (locale-aware string)
SELECT CONV(255, 10, 16);       -- 'FF'    decimal → hex
SELECT CONV('FF', 16, 10);      -- '255'   hex → decimal
SELECT BIN(10);                 -- '1010'  decimal → binary string
SELECT HEX(255);                -- 'FF'
SELECT OCT(8);                  -- '10'

-- ── PRACTICAL PATTERNS ───────────────────────────────────────
-- round prices for display
SELECT ProductName, ROUND(Price, 2) AS Price FROM Products;

-- discount calculation
SELECT ProductName, Price,
       ROUND(Price * 0.85, 2)      AS DiscountedPrice,
       ROUND(Price * 0.15, 2)      AS Saving
FROM Products;

-- percentage of total
SELECT City,
       COUNT(*) AS Count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Customers), 1) AS Pct
FROM Customers
GROUP BY City
ORDER BY Count DESC;