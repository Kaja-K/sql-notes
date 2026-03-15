-- ── CONCAT ───────────────────────────────────────────────────
SELECT CONCAT(FirstName, ' ', LastName) AS FullName FROM Customers;
SELECT CONCAT('Hello', ' ', 'World');           -- 'Hello World'
SELECT CONCAT(City, ', ', Country) AS Location FROM Customers;

-- CONCAT_WS — with separator (skips NULLs automatically)
SELECT CONCAT_WS(', ', FirstName, LastName, City) AS Info FROM Customers;
-- if any arg is NULL, separator is skipped — cleaner than CONCAT

-- ── LENGTH ───────────────────────────────────────────────────
SELECT LENGTH('Hello');          -- 5  — bytes (differs for multibyte chars)
SELECT CHAR_LENGTH('Hello');     -- 5  — characters (use this for Unicode)
SELECT CHAR_LENGTH(LastName) AS NameLength FROM Customers;

-- filter by length
SELECT * FROM Customers WHERE CHAR_LENGTH(LastName) > 10;

-- ── CASE ─────────────────────────────────────────────────────
SELECT UPPER('hello');           -- 'HELLO'
SELECT LOWER('HELLO');           -- 'hello'
SELECT UPPER(FirstName) FROM Customers;
SELECT INITCAP(FirstName) FROM Customers;  -- 'anna' → 'Anna' (PostgreSQL/Oracle)
-- MySQL equivalent: no INITCAP — use CONCAT(UPPER(LEFT(s,1)), LOWER(SUBSTRING(s,2)))

-- ── TRIM ─────────────────────────────────────────────────────
SELECT TRIM('  hello  ');        -- 'hello'
SELECT LTRIM('  hello  ');       -- 'hello  '
SELECT RTRIM('  hello  ');       -- '  hello'
SELECT TRIM(LEADING  '0' FROM '00123');   -- '123'   — trim specific character
SELECT TRIM(TRAILING '/' FROM '/path/');  -- '/path'
SELECT TRIM(BOTH     '*' FROM '**star**'); -- 'star'

-- ── SUBSTRING ────────────────────────────────────────────────
-- SUBSTRING(str, start, length) — 1-indexed (not 0)
SELECT SUBSTRING('Hello World', 1, 5);   -- 'Hello'
SELECT SUBSTRING('Hello World', 7);      -- 'World'  (no length = to end)
SELECT SUBSTR('Hello World', -5);        -- 'World'  (negative = from end)

-- extract parts of structured strings
SELECT SUBSTRING(Phone, 1, 3) AS AreaCode FROM Customers;
SELECT SUBSTRING_INDEX('192.168.1.1', '.', 1);  -- '192'  (first segment)
SELECT SUBSTRING_INDEX('192.168.1.1', '.', -1); -- '1'    (last segment)
SELECT SUBSTRING_INDEX(Email, '@', -1) AS Domain FROM Customers;

-- ── REPLACE ──────────────────────────────────────────────────
SELECT REPLACE('Hello World', 'World', 'SQL');  -- 'Hello SQL'
SELECT REPLACE(Phone, '-', '') AS CleanPhone FROM Customers;
SELECT REPLACE(REPLACE(Notes, '\n', ' '), '\r', '') FROM Orders; -- strip newlines

-- ── LEFT / RIGHT ─────────────────────────────────────────────
SELECT LEFT('Hello World', 5);   -- 'Hello'
SELECT RIGHT('Hello World', 5);  -- 'World'
SELECT LEFT(PostalCode, 2) AS Region FROM Customers;

-- ── LOCATE / INSTR — find position of substring ───────────────
SELECT LOCATE('World', 'Hello World');   -- 7  (0 if not found)
SELECT INSTR('Hello World', 'World');    -- 7  (same, different syntax)
SELECT LOCATE('@', Email) AS AtPosition FROM Customers;

-- check if substring exists
SELECT * FROM Customers WHERE LOCATE('gmail', Email) > 0;

-- ── LPAD / RPAD — pad to fixed width ─────────────────────────
SELECT LPAD('42', 6, '0');       -- '000042'  (zero-pad numbers)
SELECT RPAD('hi', 10, '.');      -- 'hi........'
SELECT LPAD(CAST(CustomerID AS CHAR), 5, '0') AS FormattedID FROM Customers;

-- ── REPEAT / REVERSE ─────────────────────────────────────────
SELECT REPEAT('ab', 3);          -- 'ababab'
SELECT REVERSE('Hello');         -- 'olleH'

-- check for palindrome
SELECT LastName, LastName = REVERSE(LastName) AS IsPalindrome FROM Customers;

-- ── FORMAT ───────────────────────────────────────────────────
SELECT FORMAT(1234567.891, 2);   -- '1,234,567.89' (locale-aware)

-- ── REGEXP_REPLACE / REGEXP_SUBSTR (MySQL 8+) ────────────────
SELECT REGEXP_REPLACE('Hello123World', '[0-9]+', '');   -- 'HelloWorld'
SELECT REGEXP_SUBSTR('Order#12345', '[0-9]+');           -- '12345'

-- ── PRACTICAL PATTERNS ───────────────────────────────────────
-- clean up user-entered data
UPDATE Customers
SET Email     = LOWER(TRIM(Email)),
    FirstName = TRIM(FirstName),
    LastName  = TRIM(LastName);

-- extract first word
SELECT SUBSTRING_INDEX(FullName, ' ', 1) AS FirstName FROM Users;

-- mask sensitive data
SELECT CONCAT(LEFT(Email, 2), '***', SUBSTRING_INDEX(Email, '@', -1)) AS MaskedEmail
FROM Customers;
-- anna@gmail.com → an***gmail.com