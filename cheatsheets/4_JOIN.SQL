-- ── INNER JOIN — only rows matching in both tables ───────────
SELECT o.CustomerID, OrderID, FirstName, LastName
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID;
-- JOIN = INNER JOIN — keyword INNER is optional
-- always qualify ambiguous columns with table alias

-- with calculated column
SELECT o.OrderID, p.ProductName, o.Quantity, o.UnitPrice,
       (o.Quantity * o.UnitPrice) AS LineTotal
FROM OrderItems o
JOIN Products p ON o.ProductID = p.ProductID;

-- ── LEFT JOIN — all left rows + matching right ───────────────
-- non-matching rows get NULL for right-table columns
SELECT c.CustomerID, c.FirstName, o.OrderID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID;

-- find rows with NO match (anti-join pattern)
SELECT c.CustomerID, c.FirstName
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;               -- customers who never ordered

SELECT p.ProductID, p.ProductName
FROM Products p
LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
WHERE oi.ProductID IS NULL;            -- products never ordered

-- ── RIGHT JOIN — all right rows + matching left ──────────────
-- less intuitive — prefer LEFT JOIN with swapped table order
SELECT p.ProductID, p.ProductName, o.Quantity
FROM OrderItems o
RIGHT JOIN Products p ON o.ProductID = p.ProductID
ORDER BY p.ProductID;

-- identical result using LEFT JOIN (more readable):
SELECT p.ProductID, p.ProductName, o.Quantity
FROM Products p
LEFT JOIN OrderItems o ON p.ProductID = o.ProductID
ORDER BY p.ProductID;

-- ── FULL OUTER JOIN — all rows from both sides ───────────────
-- MySQL doesn't support FULL OUTER JOIN — simulate with UNION
SELECT c.CustomerID, c.FirstName, o.OrderID
FROM Customers c LEFT  JOIN Orders o ON c.CustomerID = o.CustomerID
UNION
SELECT c.CustomerID, c.FirstName, o.OrderID
FROM Customers c RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- ── CROSS JOIN — every combination (Cartesian product) ───────
-- no ON clause — n × m rows returned
SELECT s.Size, c.Color FROM Sizes s CROSS JOIN Colors c;
-- practical: generate all size/colour combinations

-- ── SELF JOIN — table joined to itself ───────────────────────
SELECT e.EmployeeID, e.FirstName, e.LastName,
       m.FirstName AS ManagerFirstName
FROM Employees e
JOIN Employees m ON e.ManagerID = m.EmployeeID;

-- top-level employees (no manager)
SELECT e.EmployeeID, e.FirstName
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID
WHERE m.EmployeeID IS NULL;

-- ── MULTIPLE JOINS ───────────────────────────────────────────
SELECT o.OrderID, o.OrderDate, c.FirstName, c.LastName,
       s.Name AS Shipper, st.Name AS Status
FROM Orders o
JOIN  Customers    c  ON o.CustomerID    = c.CustomerID
LEFT JOIN Shippers s  ON o.ShipperID     = s.ShipperID  -- LEFT: order may have no shipper yet
JOIN  OrderStatuses st ON o.OrderStatusID = st.OrderStatusID
ORDER BY o.OrderDate;

-- ── COMPOUND JOIN — join on multiple columns ─────────────────
-- needed when the key is composite (more than one column)
SELECT *
FROM OrderItems oi
JOIN OrderItemNotes n
    ON oi.OrderID   = n.OrderID
   AND oi.ProductID = n.ProductID;

-- ── CROSS-DATABASE JOIN ──────────────────────────────────────
SELECT * FROM store_db.Customers c1
JOIN archive_db.Customers c2 ON c1.CustomerID = c2.CustomerID;

-- ── IMPLICIT JOIN (avoid) ────────────────────────────────────
SELECT * FROM Orders, Customers
WHERE Orders.CustomerID = Customers.CustomerID;
-- avoid: forgetting WHERE creates a Cartesian product (every row × every row)

-- ── QUICK REFERENCE ──────────────────────────────────────────
-- INNER JOIN      matching rows in BOTH tables
-- LEFT JOIN       ALL left + matching right  (NULL where no match)
-- RIGHT JOIN      ALL right + matching left  (NULL where no match)
-- FULL OUTER JOIN ALL rows from both         (not in MySQL natively)
-- CROSS JOIN      every combination — no ON needed
-- SELF JOIN       table joined to itself — requires two aliases

-- ── USING — shorthand when column names match in both tables ──
-- replaces ON t1.col = t2.col when the column name is identical

SELECT o.OrderID, c.FirstName, c.LastName
FROM Orders o
JOIN Customers c USING (CustomerID);
-- same as: ON o.CustomerID = c.CustomerID

-- with multiple joins
SELECT o.OrderID, c.FirstName, s.Name AS ShipperName
FROM Orders o
JOIN  Customers c USING (CustomerID)
LEFT JOIN Shippers s USING (ShipperID);

-- USING with composite key (multiple columns)
SELECT * FROM OrderItems oi
JOIN OrderItemNotes oin USING (OrderID, ProductID);
-- same as: ON oi.OrderID = oin.OrderID AND oi.ProductID = oin.ProductID

-- mix USING and ON in the same query — fine when column names differ
SELECT p.PaymentDate, c.Name, p.Amount, pm.Name AS PaymentMethod
FROM Payments p
JOIN Clients c       USING (ClientID)
JOIN PaymentMethods pm ON p.PaymentMethodID = pm.PaymentMethodID;

-- USING rules:
-- column must have the SAME name in both tables
-- column appears only once in result (ON keeps both)
-- cannot use table prefix: USING (CustomerID) not USING (o.CustomerID)

-- ── NATURAL JOIN — auto-detect common columns (avoid) ────────
SELECT o.OrderID, c.FirstName FROM Orders o NATURAL JOIN Customers c;
-- automatically joins on ALL columns with matching names
-- dangerous: fragile, breaks silently if schema changes — avoid in production