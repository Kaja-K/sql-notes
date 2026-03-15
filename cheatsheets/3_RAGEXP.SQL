-- REGEXP is more powerful than LIKE
-- MySQL/MariaDB only — PostgreSQL uses ~, SQL Server uses LIKE only

-- ── SPECIAL CHARACTERS ───────────────────────────────────────
-- ^        start of string
-- $        end of string
-- .        any single character
-- |        OR (alternation)
-- []       character class
-- [a-z]    range
-- ()       grouping
-- {n}      exactly n repetitions
-- {n,}     n or more
-- {n,m}    between n and m
-- *        zero or more
-- +        one or more
-- ?        zero or one

-- ── BASIC ────────────────────────────────────────────────────
SELECT * FROM Customers WHERE LastName REGEXP 'field';    -- contains "field"
SELECT * FROM Customers WHERE LastName REGEXP '^field';   -- starts with "field"
SELECT * FROM Customers WHERE LastName REGEXP 'field$';   -- ends with "field"

-- ── ALTERNATION | ────────────────────────────────────────────
SELECT * FROM Customers WHERE LastName REGEXP 'field|mac|rose';
SELECT * FROM Customers WHERE LastName REGEXP '^field|mac|rose'; -- starts with "field" OR contains others
SELECT * FROM Customers WHERE LastName REGEXP 'ey$|on$';         -- ends with "ey" or "on"
SELECT * FROM Customers WHERE LastName REGEXP '^Elka$|^Ambur$';  -- exact match

-- ── CHARACTER CLASSES [] ─────────────────────────────────────
SELECT * FROM Customers WHERE LastName REGEXP '[gim]e';   -- ge, ie, or me
SELECT * FROM Customers WHERE LastName REGEXP 'e[gim]';   -- eg, em, or ei
SELECT * FROM Customers WHERE LastName REGEXP 'B[RU]';    -- BR or BU
SELECT * FROM Customers WHERE LastName REGEXP '[a-h]e';   -- ae, be, ce ... he
SELECT * FROM Customers WHERE LastName REGEXP '[^aeiou]e'; -- consonant + e

-- ── GROUPING () ──────────────────────────────────────────────
SELECT * FROM Customers WHERE LastName REGEXP 'f(ield|ild)'; -- field or fild
-- f(ield|ild) is cleaner than field|fild — shares the "f"

-- ── QUANTIFIERS ──────────────────────────────────────────────
SELECT * FROM Customers WHERE LastName REGEXP 'f{2}ield';    -- "ffield"
SELECT * FROM Customers WHERE LastName REGEXP 'f{2,}ield';   -- "ff" or more before "ield"
SELECT * FROM Customers WHERE LastName REGEXP 'f{2,4}ield';  -- ff, fff, or ffff before "ield"
SELECT * FROM Customers WHERE LastName REGEXP 'colou?r';     -- "color" or "colour"
SELECT * FROM Customers WHERE LastName REGEXP 'fo+';         -- "fo", "foo", "fooo"...

-- ── PRACTICAL PATTERNS ───────────────────────────────────────
SELECT * FROM Customers WHERE Phone   REGEXP '^\+48';         -- Polish numbers
SELECT * FROM Customers WHERE Email   REGEXP '^[^@]+@[^@]+\.[a-z]{2,}$'; -- basic email
SELECT * FROM Customers WHERE LastName REGEXP '[aeiou]{2,}';  -- consecutive vowels
SELECT * FROM Customers WHERE LastName REGEXP '^.{5,10}$';    -- 5 to 10 chars long

-- LIKE vs REGEXP
-- LIKE    → simple, portable, fast
-- REGEXP  → complex patterns, multiple alternatives — MySQL only