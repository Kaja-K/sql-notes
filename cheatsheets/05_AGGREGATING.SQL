-- ══════════════════════════════════════════════════════════════
-- SQL NOTATKI
-- ══════════════════════════════════════════════════════════════

-- ── COMPARISON OPERATORS ─────────────────────────────────────
-- =  !=  <  <=  >  >=
SELECT * FROM Customers WHERE Age > 30;
SELECT * FROM Customers WHERE State != 'California';
SELECT * FROM Customers WHERE Birthdate < '1990-01-01';  -- dates in quotes 'YYYY-MM-DD'

-- ── AND / OR / NOT ───────────────────────────────────────────
-- order of evaluation: Parentheses → NOT → AND → OR
SELECT * FROM Customers WHERE Birthdate < '1990-01-01' AND Points > 3000;
SELECT * FROM Customers WHERE Birthdate < '1990-01-01' OR  Points > 3000;
SELECT * FROM Customers WHERE NOT Birthdate < '1990-01-01';
-- use parentheses to control evaluation order
SELECT * FROM Customers WHERE (Birthdate < '1990-01-01' AND Points > 3000) OR City = 'New York';
SELECT * FROM Customers WHERE NOT (Birthdate < '1990-01-01' OR Points > 3000);
-- De Morgan: NOT(A OR B) = NOT A AND NOT B
-- calculated expression in WHERE
SELECT *, (Quantity * Price) AS TotalPrice
FROM OrderItems
WHERE OrderID = 6 AND (Quantity * Price) > 30;

-- ── IN ───────────────────────────────────────────────────────
SELECT * FROM Customers WHERE City     IN ('New York', 'Los Angeles', 'Chicago');
SELECT * FROM Customers WHERE City NOT IN ('New York', 'Los Angeles', 'Chicago');
SELECT * FROM Products  WHERE StockQuantity IN (49, 38, 72);
-- IN with subquery — dynamic list
SELECT * FROM Customers
WHERE CustomerID IN (SELECT CustomerID FROM Orders WHERE Total > 500);

-- ── BETWEEN ──────────────────────────────────────────────────
SELECT * FROM Customers WHERE Points    BETWEEN 1000     AND 5000;
SELECT * FROM Customers WHERE Points    NOT BETWEEN 1000 AND 5000;
SELECT * FROM Customers WHERE Birthdate BETWEEN '1980-01-01' AND '1990-12-31';
-- BETWEEN is inclusive on both ends

-- ── LIKE ─────────────────────────────────────────────────────
-- %  = zero or more characters
-- _  = exactly one character
SELECT * FROM Customers WHERE LastName LIKE 'B%';       -- starts with B
SELECT * FROM Customers WHERE LastName LIKE '%b%';      -- contains b anywhere
SELECT * FROM Customers WHERE LastName LIKE '%y';       -- ends with y
SELECT * FROM Customers WHERE LastName LIKE 'B__%';     -- starts B, at least 4 chars
SELECT * FROM Customers WHERE LastName LIKE '_____y';   -- exactly 6 chars, ends y
SELECT * FROM Customers WHERE LastName NOT LIKE 'B%y';
SELECT * FROM Customers
WHERE (Address LIKE '%trail%' OR Address LIKE '%avenue%')
AND Phone LIKE '%9';                                    -- ends with 9

-- ── IS NULL ──────────────────────────────────────────────────
SELECT * FROM Customers WHERE Phone IS NULL;
SELECT * FROM Customers WHERE Phone IS NOT NULL;
-- tip: NULL = NULL is false in SQL — always use IS NULL

-- ── EXISTS — check if subquery returns any rows ───────────────
-- faster than IN for large datasets — stops at first match
SELECT * FROM Customers c
WHERE EXISTS (SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID);
-- customers who have placed at least one order
SELECT * FROM Products p
WHERE NOT EXISTS (SELECT 1 FROM OrderItems oi WHERE oi.ProductID = p.ProductID);
-- products that have never been ordered


-- ══════════════════════════════════════════════════════════════
-- AGGREGATE FUNCTIONS & GROUP BY
-- ══════════════════════════════════════════════════════════════

-- aggregate functions collapse many rows into a single value
-- they ignore NULLs (except COUNT(*))

-- ── COUNT ────────────────────────────────────────────────────
SELECT COUNT(*)     FROM Customers;         -- total rows, including NULLs
SELECT COUNT(Email) FROM Customers;         -- rows where Email is NOT NULL
SELECT COUNT(DISTINCT City) FROM Customers; -- number of unique cities

-- ── SUM ──────────────────────────────────────────────────────
SELECT SUM(Points)  FROM Customers;
SELECT SUM(Quantity * UnitPrice) AS Revenue FROM OrderItems; -- expression inside SUM

-- ── AVG ──────────────────────────────────────────────────────
SELECT AVG(Points)           FROM Customers;
SELECT ROUND(AVG(Points), 2) FROM Customers;  -- round to 2 decimal places

-- ── MIN / MAX ────────────────────────────────────────────────
SELECT MIN(Points)    FROM Customers;
SELECT MAX(Points)    FROM Customers;
SELECT MIN(Birthdate) FROM Customers;    -- works on dates too
SELECT MAX(Birthdate) FROM Customers;

-- multiple aggregates in one query
SELECT
    COUNT(*)         AS TotalCustomers,
    COUNT(Email)     AS WithEmail,
    AVG(Points)      AS AvgPoints,
    MIN(Points)      AS MinPoints,
    MAX(Points)      AS MaxPoints,
    SUM(Points)      AS TotalPoints
FROM Customers;

-- ── GROUP BY ─────────────────────────────────────────────────
-- splits rows into groups, applies aggregate to each group
-- every column in SELECT must be in GROUP BY or inside an aggregate
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City;

SELECT City, AVG(Points) AS AvgPoints, MAX(Points) AS MaxPoints
FROM Customers
GROUP BY City
ORDER BY AvgPoints DESC;

-- group by multiple columns
SELECT City, State, COUNT(*) AS Count
FROM Customers
GROUP BY State, City
ORDER BY State, City;

-- group by with JOIN
SELECT c.City, SUM(oi.Quantity * oi.UnitPrice) AS Revenue
FROM Orders o
JOIN Customers c   ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID    = oi.OrderID
GROUP BY c.City
ORDER BY Revenue DESC;

-- ── HAVING — filter AFTER grouping ───────────────────────────
-- WHERE filters rows BEFORE grouping
-- HAVING filters groups AFTER aggregation
SELECT City, COUNT(*) AS CustomerCount
FROM Customers
GROUP BY City
HAVING COUNT(*) > 5;                  -- only cities with more than 5 customers

SELECT City, AVG(Points) AS AvgPoints
FROM Customers
GROUP BY City
HAVING AvgPoints > 2000;              -- alias works in HAVING (MySQL)

-- WHERE + HAVING together
SELECT City, COUNT(*) AS ActiveCount
FROM Customers
WHERE Status = 'Active'               -- filter rows first
GROUP BY City
HAVING COUNT(*) > 3;                  -- then filter groups

-- ── WITH ROLLUP — subtotals & grand total ────────────────────
SELECT City, SUM(Points) AS TotalPoints
FROM Customers
GROUP BY City WITH ROLLUP;
-- adds an extra row at the bottom with the grand total (NULL in City column)

-- ── BOOL_AND / BOOL_OR — boolean aggregates (PostgreSQL) ─────
-- BOOL_AND — returns TRUE only if ALL rows in the group satisfy the condition
-- BOOL_OR  — returns TRUE if AT LEAST ONE row in the group satisfies the condition
-- both ignore NULLs

-- example: per actor, check if ALL their films are not NC-17
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    BOOL_AND(f.rating != 'NC-17') AS all_films_family_friendly,
    BOOL_OR(f.rating  = 'G')      AS has_any_g_rated_film
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f        ON f.film_id   = fa.film_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- filter with HAVING — only actors where ALL films are family friendly
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
JOIN film f        ON f.film_id   = fa.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING BOOL_AND(f.rating != 'NC-17');

-- MySQL equivalent — no BOOL_AND/BOOL_OR, use MIN/MAX on a boolean expression
-- MIN(condition) = 1  means ALL rows matched  (like BOOL_AND)
-- MAX(condition) = 1  means AT LEAST ONE matched (like BOOL_OR)
SELECT
    actor_id,
    MIN(rating != 'NC-17') AS all_family_friendly,  -- BOOL_AND equivalent
    MAX(rating  = 'G')     AS has_g_rated            -- BOOL_OR  equivalent
FROM film_actor
JOIN film USING (film_id)
GROUP BY actor_id;

-- ── ORDER OF CLAUSES ─────────────────────────────────────────
-- SELECT → FROM → JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
-- execution order: FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT