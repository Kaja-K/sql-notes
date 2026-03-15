-- window functions compute a value across a set of rows related to current row
-- unlike GROUP BY they do NOT collapse rows — every row stays in the result
-- syntax: function() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)

-- ── ROW_NUMBER — unique sequential number per partition ───────
SELECT CustomerID, FirstName, City, Points,
    ROW_NUMBER() OVER (ORDER BY Points DESC) AS GlobalRank,
    ROW_NUMBER() OVER (PARTITION BY City ORDER BY Points DESC) AS CityRank
FROM Customers;
-- PARTITION BY restarts numbering for each City

-- ── RANK — rank with gaps for ties ───────────────────────────
-- tied values get the same rank, next rank skips (1,2,2,4)
SELECT FirstName, Points,
    RANK() OVER (ORDER BY Points DESC) AS Rank
FROM Customers;

-- ── DENSE_RANK — rank without gaps ───────────────────────────
-- tied values get the same rank, next rank is consecutive (1,2,2,3)
SELECT FirstName, Points,
    DENSE_RANK() OVER (ORDER BY Points DESC) AS DenseRank
FROM Customers;

-- RANK vs DENSE_RANK:
-- Points: 3000, 2500, 2500, 1000
-- RANK:         1,    2,    2,    4   (gap after tie)
-- DENSE_RANK:   1,    2,    2,    3   (no gap)

-- ── NTILE — divide rows into N buckets ───────────────────────
SELECT FirstName, Points,
    NTILE(4) OVER (ORDER BY Points DESC) AS Quartile
FROM Customers;
-- Quartile 1 = top 25%, 4 = bottom 25%

-- ── LAG — access previous row's value ────────────────────────
SELECT OrderID, OrderDate, Total,
    LAG(Total, 1) OVER (ORDER BY OrderDate)          AS PrevTotal,
    Total - LAG(Total, 1, 0) OVER (ORDER BY OrderDate) AS Change
FROM Orders;
-- LAG(col, offset, default) — default returned when no previous row

-- ── LEAD — access next row's value ───────────────────────────
SELECT OrderID, OrderDate, Total,
    LEAD(Total, 1) OVER (ORDER BY OrderDate) AS NextTotal
FROM Orders;

-- LAG/LEAD with PARTITION — compare within groups
SELECT CustomerID, OrderDate, Total,
    LAG(Total) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PrevOrderTotal
FROM Orders;

-- ── RUNNING TOTAL (cumulative sum) ───────────────────────────
SELECT OrderDate, Total,
    SUM(Total) OVER (ORDER BY OrderDate
                     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Orders;
-- ROWS UNBOUNDED PRECEDING = from first row to current row

-- running total per customer
SELECT CustomerID, OrderDate, Total,
    SUM(Total) OVER (PARTITION BY CustomerID ORDER BY OrderDate
                     ROWS UNBOUNDED PRECEDING) AS CustomerRunningTotal
FROM Orders;

-- ── MOVING AVERAGE ───────────────────────────────────────────
SELECT OrderDate, Total,
    AVG(Total) OVER (ORDER BY OrderDate
                     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg3
FROM Orders;
-- average of current row + 2 previous rows (3-row window)

-- ── FRAME CLAUSES ────────────────────────────────────────────
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  → cumulative
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW          → last 3 rows
-- ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING  → forward cumulative
-- ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING          → centered 3-row window
-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW → same as ROWS for most cases

-- ── AGGREGATE AS WINDOW FUNCTION ─────────────────────────────
-- compare each row against group aggregate without collapsing rows
SELECT FirstName, City, Points,
    AVG(Points) OVER (PARTITION BY City) AS CityAvg,
    Points - AVG(Points) OVER (PARTITION BY City) AS DiffFromCityAvg,
    SUM(Points) OVER ()                            AS GrandTotal
FROM Customers;
-- OVER () with no arguments = entire result set as window

-- ── FIRST_VALUE / LAST_VALUE ─────────────────────────────────
SELECT FirstName, City, Points,
    FIRST_VALUE(FirstName) OVER (PARTITION BY City ORDER BY Points DESC) AS TopCustomer,
    LAST_VALUE(Points) OVER (PARTITION BY City ORDER BY Points DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS MinPoints
FROM Customers;
-- LAST_VALUE needs explicit frame — default frame stops at current row

-- ── NTH_VALUE — Nth value in window ──────────────────────────
SELECT FirstName, City, Points,
    NTH_VALUE(Points, 2) OVER (PARTITION BY City ORDER BY Points DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS SecondHighest
FROM Customers;

-- ── PERCENT_RANK / CUME_DIST ─────────────────────────────────
SELECT FirstName, Points,
    PERCENT_RANK() OVER (ORDER BY Points) AS PercentRank,  -- 0 to 1
    CUME_DIST()    OVER (ORDER BY Points) AS CumeDist       -- fraction of rows <= current
FROM Customers;

-- ── NAMED WINDOW — reuse window definition ───────────────────
SELECT FirstName, Points,
    RANK()       OVER w AS Rank,
    DENSE_RANK() OVER w AS DenseRank,
    NTILE(4)     OVER w AS Quartile
FROM Customers
WINDOW w AS (ORDER BY Points DESC);
-- define once, reference by name — cleaner for multiple functions