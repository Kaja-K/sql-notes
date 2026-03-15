# SQL — Theory Notes

---

## SQL Command Categories

**DDL — Data Definition Language** defines the structure of the database. Commands: `CREATE`, `ALTER`, `DROP`, `TRUNCATE`. These change the schema, not the data.

**DML — Data Manipulation Language** deals with the actual data. Commands: `INSERT`, `UPDATE`, `DELETE`. These modify rows.

**DQL — Data Query Language** fetches data. The main command is `SELECT`.

**DCL — Data Control Language** manages permissions. Commands: `GRANT`, `REVOKE`.

**TCL — Transaction Control Language** manages transactions. Commands: `COMMIT`, `ROLLBACK`, `SAVEPOINT`.

---

## Core Database Concepts

**Schema** is the blueprint of a database — it defines tables, columns, data types, relationships and constraints. Think of it as the architecture before any data exists.

**Table** is a structured set of rows and columns. Each table represents one entity, like Customers or Orders.

**Primary Key (PK)** uniquely identifies each row in a table. It cannot be NULL and cannot have duplicates. Usually an auto-incremented integer.

**Foreign Key (FK)** links one table to another by referencing the Primary Key of a related table. It enforces referential integrity — you cannot insert a FK value that doesn't exist in the parent table.

**Composite Key** is a Primary Key made of two or more columns combined. Used when no single column is unique on its own — for example `OrderID + ProductID` in an `OrderItems` table.

**Surrogate Key** is an artificial PK with no business meaning, usually an auto-incremented number. Preferred over natural keys because real-world data changes.

**Natural Key** is a PK made from real data like Email or NationalID. Fragile — real data changes over time.

**Referential Integrity** is the guarantee that every Foreign Key value points to an existing Primary Key. Broken referential integrity means orphaned rows — orders pointing to customers that no longer exist.

**Normalization** is organizing data to eliminate redundancy and avoid update anomalies. The idea is to split one wide table into several smaller related tables.

**Denormalization** is intentionally adding redundancy back to improve read performance. Common in reporting and analytics databases where joins are expensive.

---

## Normalization Forms

**1NF — First Normal Form** requires atomic values. Every cell holds exactly one value. No arrays, no comma-separated lists inside a cell, no repeating column groups.

**2NF — Second Normal Form** requires 1NF plus no partial dependencies. Every non-key column must depend on the entire primary key, not just part of it. This only matters when the PK is composite.

**3NF — Third Normal Form** requires 2NF plus no transitive dependencies. Non-key columns must depend only on the primary key, not on other non-key columns. If City depends on ZipCode and ZipCode depends on CustomerID, that is a transitive dependency — split it out.

In practice, reaching 3NF is the standard goal for most operational databases. Going further (BCNF, 4NF) is rarely necessary.

---

## OLTP vs OLAP

**OLTP (Online Transaction Processing)** handles day-to-day operations. The data is normalized, queries are short and simple, and there are many concurrent transactions. Examples: banking systems, e-commerce platforms.

**OLAP (Online Analytical Processing)** handles analysis and reporting. The data is often denormalized into wide tables for faster reads, queries are complex and slow, and the data is typically historical. Examples: data warehouses, BI tools.

The same database engine can technically do both, but they are optimized differently. Most companies keep them separate.

---

## Query Execution Order

This is the order in which MySQL actually processes a query — not the order you write it:

1. **FROM** — identify the source table
2. **JOIN** — combine with other tables
3. **WHERE** — filter individual rows
4. **GROUP BY** — collapse rows into groups
5. **HAVING** — filter groups
6. **SELECT** — compute the output columns
7. **DISTINCT** — remove duplicates
8. **ORDER BY** — sort the result
9. **LIMIT / OFFSET** — return only N rows

The most important consequence: `WHERE` runs before `SELECT`, so you cannot use a `SELECT` alias in a `WHERE` clause. You can use it in `ORDER BY` because that runs after `SELECT`.

---

## WHERE vs HAVING

`WHERE` filters individual rows **before** any grouping happens. It cannot reference aggregate functions like `COUNT()` or `AVG()` because those have not been calculated yet.

`HAVING` filters groups **after** `GROUP BY` has run. It can use aggregate functions. Think of it as a WHERE for groups.

A common pattern is to use both: WHERE to pre-filter rows (faster, uses indexes), then HAVING to filter the resulting groups.

---

## JOIN Types

**INNER JOIN** returns only rows that have a matching value in both tables. Rows with no match on either side are excluded.

**LEFT JOIN** returns all rows from the left table, plus matching rows from the right. Where there is no match, the right-side columns are NULL. Use this when you want all records regardless of whether a relationship exists.

**RIGHT JOIN** is the mirror of LEFT JOIN. Returns all rows from the right table. In practice, LEFT JOIN is almost always preferred because it reads more naturally.

**FULL OUTER JOIN** returns all rows from both tables, with NULLs filling gaps where there is no match. MySQL does not support this natively — simulate it with LEFT JOIN UNION RIGHT JOIN.

**CROSS JOIN** returns every possible combination of rows from both tables — n × m rows. No join condition needed. Useful for generating combinations like all size/colour pairs.

**SELF JOIN** joins a table to itself using two aliases. Classic use case: employees and their managers stored in the same table.

---

## Subquery Types

**Scalar subquery** returns exactly one value and can be used anywhere a single value is expected — in SELECT, WHERE, or HAVING.

**Inline view (derived table)** is a subquery in the FROM clause. It must have an alias and acts like a temporary table for that query.

**Correlated subquery** references a column from the outer query. It re-executes for every row the outer query processes, which makes it potentially slow on large tables. A JOIN or EXISTS is usually faster.

**EXISTS subquery** checks whether a subquery returns at least one row. It stops at the first match, making it faster than IN for large datasets.

---

## IN vs EXISTS

Both can check if a value appears in a set, but they work differently.

`IN` evaluates the subquery first, loads all results into memory, then checks each outer row against that list. It works well for small static lists.

`EXISTS` runs the subquery for each outer row and stops the moment it finds one match. It is more efficient for large tables because it never fully evaluates the inner query.

A practical rule: use IN for small lists and simple cases, use EXISTS for large tables and correlated checks.

---

## NULL

NULL means the absence of a value — it is not zero, not an empty string, not false. It means unknown.

Because NULL represents unknown, any comparison with NULL returns NULL, not TRUE or FALSE. This is why `WHERE col = NULL` never works — the only correct syntax is `WHERE col IS NULL`.

Any arithmetic operation involving NULL returns NULL. `NULL + 5` is NULL. String concatenation with NULL returns NULL in MySQL.

Aggregate functions like SUM, AVG, MIN, MAX, and COUNT(col) all ignore NULL values. Only COUNT(*) counts NULLs. This is a common source of bugs — AVG of a column with many NULLs is not the same as the average if those were treated as zeros.

`COALESCE(a, b, c)` returns the first non-NULL value from its arguments. It is the standard SQL way to provide a fallback for NULLs. `IFNULL(a, b)` is MySQL's simpler two-argument version.

`NULLIF(a, b)` returns NULL if a equals b, otherwise returns a. Useful for avoiding division by zero.

---

## Indexes

An index is a separate data structure — usually a B-tree — that lets the database find rows without scanning the whole table. Think of it like the index at the back of a book.

Indexes make reads faster but writes slower, because every INSERT, UPDATE, or DELETE must also update the index. Do not over-index.

**Composite index** covers multiple columns. The leftmost prefix rule applies — an index on (City, Points) helps queries filtering on City, or City + Points, but not on Points alone.

**Covering index** means all columns needed by a query are in the index itself — the database never needs to look up the actual table row. This is the fastest possible read.

A function applied to an indexed column in WHERE prevents the index from being used. `WHERE YEAR(OrderDate) = 2026` cannot use an index on OrderDate, but `WHERE OrderDate >= '2026-01-01'` can.

---

## Transactions & ACID

A transaction groups multiple SQL statements into one atomic unit. Either all succeed together or all fail together.

**Atomicity** — all operations in a transaction succeed or all are rolled back. No partial updates.

**Consistency** — the database is always in a valid state before and after a transaction. Constraints are never violated in the committed state.

**Isolation** — concurrent transactions do not see each other's uncommitted changes. The degree of isolation is configurable.

**Durability** — once committed, changes survive system crashes, power failures, or restarts.

Isolation levels control what a transaction can see from other concurrent transactions. MySQL's default is REPEATABLE READ — within a transaction, the same query always returns the same data. SERIALIZABLE is the strictest and slowest. READ COMMITTED is the default in PostgreSQL.

**Deadlock** happens when two transactions each hold a lock the other needs. MySQL automatically detects and kills one of them. Prevention: always access tables in the same order across transactions, and keep transactions short.

---

## PARTITION BY vs GROUP BY

`GROUP BY` collapses rows into groups — you get one row per group in the result. You lose access to individual rows.

`PARTITION BY` divides rows into groups for a window function calculation, but every row stays in the result. You can see both the individual value and the group aggregate side by side.

---

## Views

A view is a saved SELECT query that behaves like a virtual table. No data is stored — the underlying query runs every time the view is accessed.

Views are useful for hiding complexity, security (expose only certain columns to certain users), and maintaining a stable interface when the underlying table structure changes.

A simple view with no GROUP BY, DISTINCT, or aggregates is updatable — you can run INSERT, UPDATE, DELETE directly on it and it affects the base table.

`WITH CHECK OPTION` prevents writes through the view that would make the row invisible in that view.

A **materialized view** physically stores the query results. MySQL does not support this natively — simulate it with a real table that you refresh periodically. PostgreSQL supports materialized views natively.

---

## CTEs

A CTE (Common Table Expression) is a named temporary result set defined at the top of a query with WITH. It exists only for the duration of that query.

CTEs make complex queries readable by breaking them into named steps. You can chain multiple CTEs and each one can reference the previous ones.

A key use case is filtering on window functions — you cannot filter on a window function result directly in WHERE, but you can wrap it in a CTE and then filter.

A **recursive CTE** calls itself to traverse hierarchical data like an org chart or category tree. It has an anchor (starting point) and a recursive member joined with UNION ALL.

---

## Window Functions

Window functions compute values across a set of rows related to the current row without collapsing them. Every row stays in the result.

`PARTITION BY` inside OVER divides rows into groups for the calculation while keeping all rows visible — it is the window equivalent of GROUP BY.

`ROW_NUMBER()` assigns a unique sequential number. `RANK()` assigns the same number to tied rows but skips the next number. `DENSE_RANK()` assigns the same number to ties but does not skip — ties get the same rank and the next rank is consecutive.

`LAG()` and `LEAD()` let you access values from previous or following rows within the partition — useful for calculating change between rows or comparing to the previous period.

---

## Stored Procedures vs Functions

A stored procedure is a saved block of SQL called with CALL. It can return multiple result sets, use OUT parameters, and control transactions.

A stored function returns a single value and can be used directly inside a SELECT statement like a built-in function. It cannot control transactions.

Use a function when you need reusable logic inline in a query. Use a procedure when you need a multi-step operation with side effects.

---

## DELETE vs TRUNCATE vs DROP

**DELETE** removes rows matching a WHERE condition. Without WHERE it removes all rows. It can be rolled back, fires triggers, and does not reset AUTO_INCREMENT.

**TRUNCATE** removes all rows instantly without a WHERE clause. It resets AUTO_INCREMENT, is faster than DELETE, and is harder to roll back.

**DROP** removes the entire table including its structure, indexes, and constraints. Completely gone.

---

## Common Mistakes

**Using `WHERE col = NULL`** — NULL cannot be compared with =. Always use IS NULL or IS NOT NULL.

**Using WHERE for aggregates** — aggregate functions belong in HAVING, not WHERE.

**Running DELETE or UPDATE without WHERE** — always preview with SELECT first, wrap in a transaction, check ROW_COUNT() before committing.

**Forgetting that AVG ignores NULLs** — a column with many NULLs produces a misleading average. Use `COUNT(*) - COUNT(col)` to detect how many NULLs exist.

**Applying a function to an indexed column in WHERE** — `YEAR(date) = 2026` cannot use an index. Rewrite as a range condition.

**Using SELECT *** — always specify columns in production code. SELECT * breaks when columns are added or reordered, and fetches unnecessary data.

**Leading wildcard in LIKE** — `LIKE '%value'` cannot use an index. `LIKE 'value%'` can.

**Implicit JOIN syntax** — the old comma-separated style. If you forget the WHERE it becomes a Cartesian product. Always use explicit JOIN ... ON syntax.
