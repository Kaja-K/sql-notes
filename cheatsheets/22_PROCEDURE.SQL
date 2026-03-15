-- stored procedure = saved SQL block, called with CALL
-- stored function  = like procedure but returns a value, usable in SELECT
-- both live in the database — no need to send SQL over network each time

-- ── DELIMITER ────────────────────────────────────────────────
-- change delimiter so semicolons inside the body don't end the CREATE
DELIMITER //

-- ── BASIC PROCEDURE ──────────────────────────────────────────
CREATE PROCEDURE GetActiveCustomers()
BEGIN
    SELECT * FROM Customers WHERE Status = 'Active';
END //

DELIMITER ;

CALL GetActiveCustomers();       -- execute it

-- ── PROCEDURE WITH PARAMETERS ────────────────────────────────
DELIMITER //
CREATE PROCEDURE GetCustomersByCity(IN city_name VARCHAR(50))
BEGIN
    SELECT CustomerID, FirstName, LastName, Points
    FROM Customers
    WHERE City = city_name;
END //
DELIMITER ;

CALL GetCustomersByCity('Warsaw');

-- IN / OUT / INOUT parameters
DELIMITER //
CREATE PROCEDURE GetCustomerStats(
    IN  city_name   VARCHAR(50),
    OUT total_count INT,
    OUT avg_points  DECIMAL(10,2)
)
BEGIN
    SELECT COUNT(*), AVG(Points)
    INTO total_count, avg_points
    FROM Customers
    WHERE City = city_name;
END //
DELIMITER ;

CALL GetCustomerStats('Warsaw', @count, @avg);
SELECT @count, @avg;             -- read OUT parameter values

-- ── VARIABLES ────────────────────────────────────────────────
DELIMITER //
CREATE PROCEDURE AdjustPoints(IN customer_id INT, IN adjustment INT)
BEGIN
    DECLARE current_points INT;
    DECLARE new_points     INT;

    SELECT Points INTO current_points
    FROM Customers WHERE CustomerID = customer_id;

    SET new_points = current_points + adjustment;

    UPDATE Customers SET Points = new_points
    WHERE CustomerID = customer_id;

    SELECT new_points AS UpdatedPoints;
END //
DELIMITER ;

-- ── IF / ELSEIF / ELSE ───────────────────────────────────────
DELIMITER //
CREATE PROCEDURE ClassifyCustomer(IN customer_id INT)
BEGIN
    DECLARE pts INT;
    SELECT Points INTO pts FROM Customers WHERE CustomerID = customer_id;

    IF pts > 3000 THEN
        SELECT 'Gold' AS Tier;
    ELSEIF pts > 1000 THEN
        SELECT 'Silver' AS Tier;
    ELSE
        SELECT 'Bronze' AS Tier;
    END IF;
END //
DELIMITER ;

-- ── CASE ─────────────────────────────────────────────────────
DELIMITER //
CREATE PROCEDURE GetDiscount(IN customer_id INT, OUT discount DECIMAL(5,2))
BEGIN
    DECLARE pts INT;
    SELECT Points INTO pts FROM Customers WHERE CustomerID = customer_id;

    SET discount = CASE
        WHEN pts > 3000 THEN 0.20
        WHEN pts > 1000 THEN 0.10
        ELSE 0.05
    END;
END //
DELIMITER ;

-- ── LOOPS ────────────────────────────────────────────────────
DELIMITER //
CREATE PROCEDURE GenerateNumbers(IN n INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= n DO
        INSERT INTO Numbers (Value) VALUES (i);
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- REPEAT ... UNTIL
DELIMITER //
CREATE PROCEDURE RepeatDemo()
BEGIN
    DECLARE i INT DEFAULT 1;
    REPEAT
        SET i = i + 1;
    UNTIL i > 10 END REPEAT;
END //
DELIMITER ;

-- LOOP with LEAVE (like break)
DELIMITER //
CREATE PROCEDURE LoopDemo()
BEGIN
    DECLARE i INT DEFAULT 0;
    my_loop: LOOP
        SET i = i + 1;
        IF i = 5 THEN LEAVE my_loop; END IF;
    END LOOP my_loop;
END //
DELIMITER ;

-- ── ERROR HANDLING ───────────────────────────────────────────
DELIMITER //
CREATE PROCEDURE SafeTransfer(IN from_id INT, IN to_id INT, IN amount INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        UPDATE Customers SET Points = Points - amount WHERE CustomerID = from_id;
        UPDATE Customers SET Points = Points + amount WHERE CustomerID = to_id;
    COMMIT;
END //
DELIMITER ;

-- ── STORED FUNCTION — returns a single value ─────────────────
DELIMITER //
CREATE FUNCTION CustomerTier(points INT)
RETURNS VARCHAR(10)
DETERMINISTIC                    -- same input always returns same output
BEGIN
    IF points > 3000 THEN RETURN 'Gold';
    ELSEIF points > 1000 THEN RETURN 'Silver';
    ELSE RETURN 'Bronze';
    END IF;
END //
DELIMITER ;

-- use in SELECT like a built-in function
SELECT FirstName, Points, CustomerTier(Points) AS Tier FROM Customers;
SELECT * FROM Customers WHERE CustomerTier(Points) = 'Gold';

-- ── MANAGE PROCEDURES ────────────────────────────────────────
DROP PROCEDURE IF EXISTS GetActiveCustomers;
DROP FUNCTION  IF EXISTS CustomerTier;

SHOW PROCEDURE STATUS WHERE Db = 'sql_store';
SHOW FUNCTION  STATUS WHERE Db = 'sql_store';
SHOW CREATE PROCEDURE GetActiveCustomers;    -- see definition

SELECT * FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'sql_store';