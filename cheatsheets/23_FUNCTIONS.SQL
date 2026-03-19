-- ══════════════════════════════════════════════════════════════
--  FUNCTIONS  cheatsheet
--  A function returns a value and can be used directly in SQL
-- ══════════════════════════════════════════════════════════════

-- ── FUNCTION vs PROCEDURE ────────────────────────────────────
--
--  FUNCTION                          PROCEDURE
--  ────────────────────────────────  ──────────────────────────
--  Returns ONE value (RETURNS)       Can have OUT / INOUT params
--  Used in SELECT / WHERE / SET      Called with CALL
--  Cannot contain transactions *     Can contain transactions
--  Must be DETERMINISTIC or not      No DETERMINISTIC requirement
--  Does not return a result set      Can return multiple columns
--
--  * in MySQL functions cannot COMMIT / ROLLBACK

-- ── CREATE FUNCTION SYNTAX ───────────────────────────────────
DELIMITER //

CREATE FUNCTION function_name(param1 TYPE, param2 TYPE, ...)
RETURNS RETURN_TYPE
-- one of these characteristics is required:
DETERMINISTIC        -- same input always returns same output (e.g. calculations)
-- or:
-- NOT DETERMINISTIC -- result may vary (e.g. reads from table, uses NOW())
-- READS SQL DATA    -- function only reads data (SELECT), does not modify
-- MODIFIES SQL DATA -- function modifies data (INSERT / UPDATE / DELETE)
BEGIN
    DECLARE variable TYPE;
    -- logic...
    RETURN value;
END //

DELIMITER ;

-- ── FUNCTION TYPES ───────────────────────────────────────────

-- 1) SCALAR — returns a single value (int, varchar, decimal…)
-- ─────────────────────────────────────────────────────────────
DELIMITER //
CREATE FUNCTION CustomerTier(points INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF points > 3000     THEN RETURN 'Gold';
    ELSEIF points > 1000 THEN RETURN 'Silver';
    ELSE                      RETURN 'Bronze';
    END IF;
END //
DELIMITER ;

-- use it like any built-in function:
SELECT FirstName, Points, CustomerTier(Points) AS Tier
FROM Customers;

SELECT * FROM Customers
WHERE CustomerTier(Points) = 'Gold';

SELECT CustomerID,
       CustomerTier(Points) AS Tier,
       CASE CustomerTier(Points)
           WHEN 'Gold'   THEN 0.20
           WHEN 'Silver' THEN 0.10
           ELSE               0.05
       END AS Discount
FROM Customers;

-- ─────────────────────────────────────────────────────────────
-- 2) TABLE-VALUED — returns a set of rows
--    MySQL does not support native TVFs like MSSQL / PostgreSQL,
--    but results can be returned via a temp table or view.
--    In PostgreSQL / MSSQL the syntax looks like this:
--
--    CREATE FUNCTION GetCustomersByCity(city VARCHAR)
--    RETURNS TABLE AS
--    RETURN (SELECT * FROM Customers WHERE City = city);
--
--    In MySQL the usual alternatives are a VIEW or PROCEDURE.
-- ─────────────────────────────────────────────────────────────

-- 3) AGGREGATE — operates on a set of rows
--    MySQL does not support CREATE AGGREGATE FUNCTION in standard SQL,
--    but MySQL 8+ allows custom aggregates via a C++ plugin.
--    Examples of built-in aggregate functions:
--      COUNT(), SUM(), AVG(), MAX(), MIN(), GROUP_CONCAT()
--
--    Custom aggregation in pure SQL → typically done with CTE + GROUP BY.

-- ── DECLARE + SET inside a function ──────────────────────────
DELIMITER //
CREATE FUNCTION DiscountedPrice(price DECIMAL(10,2), points INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE discount    DECIMAL(5,2);
    DECLARE final_price DECIMAL(10,2);

    SET discount = CASE
        WHEN points > 3000 THEN 0.20
        WHEN points > 1000 THEN 0.10
        ELSE 0.05
    END;

    SET final_price = price * (1 - discount);
    RETURN final_price;
END //
DELIMITER ;

SELECT ProductName,
       Price,
       DiscountedPrice(Price, 2500) AS AfterDiscount
FROM Products;

-- ── FUNCTION READING FROM A TABLE ────────────────────────────
DELIMITER //
CREATE FUNCTION GetCustomerPoints(cust_id INT)
RETURNS INT
READS SQL DATA          -- function reads data → implicitly NOT DETERMINISTIC
BEGIN
    DECLARE pts INT;
    SELECT Points INTO pts
    FROM Customers
    WHERE CustomerID = cust_id;
    RETURN IFNULL(pts, 0);
END //
DELIMITER ;

SELECT CustomerID,
       FirstName,
       GetCustomerPoints(CustomerID) AS Points
FROM Customers;

-- ── MANAGING FUNCTIONS ────────────────────────────────────────
DROP FUNCTION IF EXISTS CustomerTier;
DROP FUNCTION IF EXISTS DiscountedPrice;
DROP FUNCTION IF EXISTS GetCustomerPoints;

SHOW FUNCTION STATUS WHERE Db = 'sql_store';
SHOW CREATE FUNCTION CustomerTier;           -- view function definition

-- list all functions in the database:
SELECT ROUTINE_NAME, ROUTINE_TYPE, DATA_TYPE, IS_DETERMINISTIC
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'sql_store'
  AND ROUTINE_TYPE   = 'FUNCTION';