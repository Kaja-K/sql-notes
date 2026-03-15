-- ── CURRENT DATE / TIME ──────────────────────────────────────
SELECT NOW();               -- '2026-03-14 09:30:00'  current date + time
SELECT CURRENT_TIMESTAMP;   -- same as NOW()
SELECT CURDATE();           -- '2026-03-14'  date only
SELECT CURRENT_DATE;        -- same as CURDATE()
SELECT CURTIME();           -- '09:30:00'    time only
SELECT CURRENT_TIME;        -- same as CURTIME()
SELECT UTC_TIMESTAMP();     -- current UTC datetime

-- ── EXTRACT PARTS ────────────────────────────────────────────
SELECT YEAR(OrderDate)    FROM Orders;   -- 2026
SELECT MONTH(OrderDate)   FROM Orders;   -- 3
SELECT DAY(OrderDate)     FROM Orders;   -- 14
SELECT HOUR(CreatedAt)    FROM Orders;   -- 9
SELECT MINUTE(CreatedAt)  FROM Orders;   -- 30
SELECT SECOND(CreatedAt)  FROM Orders;   -- 0
SELECT DAYOFWEEK(OrderDate) FROM Orders; -- 1=Sunday ... 7=Saturday
SELECT DAYOFYEAR(OrderDate) FROM Orders; -- 1-366
SELECT WEEK(OrderDate)    FROM Orders;   -- week number 0-53
SELECT QUARTER(OrderDate) FROM Orders;   -- 1-4
SELECT DAYNAME(OrderDate) FROM Orders;   -- 'Saturday'
SELECT MONTHNAME(OrderDate) FROM Orders; -- 'March'

-- EXTRACT — standard SQL syntax (portable)
SELECT EXTRACT(YEAR    FROM OrderDate) FROM Orders;
SELECT EXTRACT(QUARTER FROM OrderDate) FROM Orders;
SELECT EXTRACT(HOUR    FROM CreatedAt) FROM Orders;

-- ── DATE ARITHMETIC ──────────────────────────────────────────
SELECT DATE_ADD(OrderDate, INTERVAL 7  DAY)   FROM Orders;  -- add 7 days
SELECT DATE_ADD(OrderDate, INTERVAL 3  MONTH) FROM Orders;  -- add 3 months
SELECT DATE_ADD(OrderDate, INTERVAL 1  YEAR)  FROM Orders;
SELECT DATE_ADD(NOW(),     INTERVAL 30 MINUTE) AS Expiry;
SELECT DATE_SUB(OrderDate, INTERVAL 1  WEEK)  FROM Orders;  -- subtract

-- shorthand (MySQL):
SELECT OrderDate + INTERVAL 7 DAY  FROM Orders;
SELECT OrderDate - INTERVAL 1 YEAR FROM Orders;

-- INTERVAL units: SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, QUARTER, YEAR

-- ── DATEDIFF / TIMESTAMPDIFF ─────────────────────────────────
SELECT DATEDIFF('2026-12-31', '2026-01-01');  -- 364  (date2 - date1 in days)
SELECT DATEDIFF(NOW(), OrderDate) AS DaysAgo FROM Orders;

-- TIMESTAMPDIFF — difference in any unit
SELECT TIMESTAMPDIFF(DAY,   OrderDate, NOW()) AS DaysOld  FROM Orders;
SELECT TIMESTAMPDIFF(MONTH, Birthdate, NOW()) AS AgeMonths FROM Customers;
SELECT TIMESTAMPDIFF(YEAR,  Birthdate, NOW()) AS Age       FROM Customers;

-- ── FORMAT & PARSE ───────────────────────────────────────────
-- DATE_FORMAT — datetime → string
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d');           -- '2026-03-14'
SELECT DATE_FORMAT(NOW(), '%d/%m/%Y');           -- '14/03/2026'
SELECT DATE_FORMAT(NOW(), '%W, %d %M %Y');       -- 'Saturday, 14 March 2026'
SELECT DATE_FORMAT(NOW(), '%H:%i:%s');           -- '09:30:00'
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month  FROM Orders;  -- group by month

-- common format codes:
-- %Y 4-digit year   %y 2-digit   %m month 01-12   %d day 01-31
-- %H hour 00-23     %i minute    %s second
-- %W weekday name   %M month name

-- STR_TO_DATE — string → datetime
SELECT STR_TO_DATE('14/03/2026', '%d/%m/%Y');
SELECT STR_TO_DATE('March 14 2026', '%M %d %Y');

-- ── TRUNCATE TO PERIOD ───────────────────────────────────────
-- get start of the day / month / year
SELECT DATE(NOW());                                 -- date part only
SELECT DATE_FORMAT(NOW(), '%Y-%m-01') AS MonthStart; -- first of month
SELECT DATE_FORMAT(NOW(), '%Y-01-01') AS YearStart;  -- first of year
-- MySQL 8+ alternative: DATE_TRUNC (not available in older MySQL)

-- ── LAST_DAY / MAKEDATE ───────────────────────────────────────
SELECT LAST_DAY('2026-02-01');   -- '2026-02-28'  last day of month
SELECT LAST_DAY(NOW());          -- last day of current month
SELECT MAKEDATE(2026, 100);      -- date from year + day-of-year

-- ── PRACTICAL PATTERNS ───────────────────────────────────────
-- orders from last 30 days
SELECT * FROM Orders WHERE OrderDate >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- orders this month
SELECT * FROM Orders
WHERE YEAR(OrderDate) = YEAR(NOW()) AND MONTH(OrderDate) = MONTH(NOW());

-- better (uses index if one exists on OrderDate):
SELECT * FROM Orders
WHERE OrderDate >= DATE_FORMAT(NOW(), '%Y-%m-01')
  AND OrderDate <  DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 1 MONTH), '%Y-%m-01');

-- monthly revenue report
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
       COUNT(*)    AS Orders,
       SUM(Total)  AS Revenue
FROM Orders
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY Month;

-- customer age
SELECT FirstName,
       TIMESTAMPDIFF(YEAR, Birthdate, CURDATE()) AS Age
FROM Customers
WHERE Birthdate IS NOT NULL;