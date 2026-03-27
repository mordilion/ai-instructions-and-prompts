---
globs: ["**/*.sql", "**/Migrations/**", "**/*Repository*.cs", "**/*Query*.cs"]
alwaysApply: false
---

# MySQL Database Rules

<security>
## NEVER Do These
- NEVER use string concatenation in queries (SQL injection)
- NEVER execute DELETE/UPDATE without WHERE clause
- NEVER expose connection strings in code
- NEVER commit database credentials
- NEVER use `SELECT *` in production code
</security>

<checklist>
## Before Writing Queries
- [ ] Understand data model relationships
- [ ] Check existing indexes (`SHOW INDEX FROM table`)
- [ ] Estimate result set size
- [ ] Check query plan (`EXPLAIN SELECT ...`)
- [ ] Consider pagination for large results
</checklist>

<query-patterns>
## Query Patterns

### SELECT Only Needed Columns
```sql
-- GOOD: Specific columns
SELECT p.Id, p.Name, p.City
FROM Pharmacies p
WHERE p.IsActive = 1;

-- BAD: SELECT *
SELECT * FROM Pharmacies WHERE IsActive = 1;
```

### Parameterized Queries Only
```sql
-- GOOD: Parameterized
SELECT * FROM Pharmacies WHERE Email = @Email;

-- BAD: String concatenation (SQL injection risk!)
SELECT * FROM Pharmacies WHERE Email = '" + email + "';
```

### Pagination with LIMIT/OFFSET
```sql
-- GOOD: Paginated query
SELECT p.Id, p.Name, p.City
FROM Pharmacies p
WHERE p.IsActive = 1
ORDER BY p.Name
LIMIT 20 OFFSET 0;

-- For better performance on large offsets
SELECT p.Id, p.Name, p.City
FROM Pharmacies p
WHERE p.Id > @lastId AND p.IsActive = 1
ORDER BY p.Id
LIMIT 20;
```

### Efficient Existence Check
```sql
-- GOOD: Stops at first match
SELECT 1 FROM Pharmacies WHERE Email = @Email LIMIT 1;

-- Also good: EXISTS
SELECT EXISTS(SELECT 1 FROM Pharmacies WHERE Email = @Email);

-- BAD: Counts all matches
SELECT COUNT(*) FROM Pharmacies WHERE Email = @Email;
```
</query-patterns>

<joins>
## JOIN Optimization

### Use Appropriate JOIN Types
```sql
-- INNER JOIN: Only matching rows
SELECT p.Name, c.Email
FROM Pharmacies p
INNER JOIN Contacts c ON c.PharmacyId = p.Id
WHERE p.IsActive = 1;

-- LEFT JOIN: Include pharmacies without contacts
SELECT p.Name, c.Email
FROM Pharmacies p
LEFT JOIN Contacts c ON c.PharmacyId = p.Id
WHERE p.IsActive = 1;
```

### Avoid N+1 in Application Code
```sql
-- GOOD: Single query with JOIN
SELECT p.Id, p.Name, c.Email, c.Phone
FROM Pharmacies p
LEFT JOIN Contacts c ON c.PharmacyId = p.Id
WHERE p.City = @City;

-- BAD: Query per pharmacy (N+1)
-- Don't do: SELECT * FROM Pharmacies; then loop with SELECT * FROM Contacts WHERE PharmacyId = ?
```
</joins>

<indexes>
## Index Strategy

### Create Indexes for Filtered Columns
```sql
-- Index on frequently filtered column
CREATE INDEX idx_pharmacies_city ON Pharmacies(City);

-- Composite index for common filter combination
CREATE INDEX idx_pharmacies_city_active ON Pharmacies(City, IsActive);

-- Unique index for unique constraints
CREATE UNIQUE INDEX idx_pharmacies_email ON Pharmacies(Email);
```

### Check Query Plan
```sql
-- Analyze query execution
EXPLAIN SELECT p.Id, p.Name
FROM Pharmacies p
WHERE p.City = 'Berlin' AND p.IsActive = 1;

-- Look for:
-- type: ref/range (good) vs ALL (full scan - bad)
-- key: should show index name
-- rows: estimated rows to scan
```

### Show Existing Indexes
```sql
SHOW INDEX FROM Pharmacies;
```
</indexes>

<transactions>
## Transaction Handling

### Use Transactions for Multi-Statement Operations
```sql
START TRANSACTION;

UPDATE Pharmacies SET IsActive = 0 WHERE Id = @Id;
INSERT INTO AuditLog (Action, PharmacyId, Timestamp)
VALUES ('DEACTIVATE', @Id, NOW());

COMMIT;
-- Or ROLLBACK on error
```

### Isolation Levels
```sql
-- Read committed (default) - good for most cases
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable read - for consistent reads in transaction
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```
</transactions>

<performance>
## Performance Tips

### WHERE Clause Optimization
```sql
-- GOOD: Index-friendly conditions
WHERE City = 'Berlin'
WHERE CreatedAt >= '2024-01-01'
WHERE Status IN ('active', 'pending')

-- BAD: Functions on columns prevent index use
WHERE YEAR(CreatedAt) = 2024  -- Use: CreatedAt >= '2024-01-01' AND CreatedAt < '2025-01-01'
WHERE LOWER(Name) = 'test'    -- Use case-insensitive collation instead
```

### ORDER BY with Indexes
```sql
-- GOOD: Index covers ORDER BY
CREATE INDEX idx_pharmacies_name ON Pharmacies(Name);
SELECT Id, Name FROM Pharmacies ORDER BY Name LIMIT 20;

-- Consider covering indexes for common queries
CREATE INDEX idx_pharmacies_covering ON Pharmacies(City, IsActive, Name, Id);
```

### COUNT Optimization
```sql
-- GOOD: Count with conditions
SELECT COUNT(*) FROM Pharmacies WHERE IsActive = 1;

-- For approximate counts on large tables
SELECT TABLE_ROWS FROM information_schema.TABLES
WHERE TABLE_NAME = 'Pharmacies';
```
</performance>

<anti-patterns>
## Anti-Patterns to Avoid
- SELECT * in production queries
- String concatenation for query building
- DELETE/UPDATE without WHERE
- Queries without LIMIT on potentially large results
- Functions on indexed columns in WHERE
- Missing indexes on frequently filtered columns
- N+1 queries in application loops
- Ignoring EXPLAIN output
</anti-patterns>
