# SQL Code Style

> **Scope**: SQL formatting rules  
> **Applies to**: *.sql files  
> **Extends**: General code style  

## CRITICAL REQUIREMENTS

> **ALWAYS**: Uppercase SQL keywords (SELECT, FROM, WHERE, JOIN, ORDER BY)
> **ALWAYS**: Explicit column lists (no `SELECT *` in app queries)
> **ALWAYS**: Consistent indentation for nested queries
> **ALWAYS**: Table aliases for multi-table queries
> **ALWAYS**: Parameterized queries (never interpolate user input)
> **ALWAYS**: WHERE clause before ORDER BY / GROUP BY
> 
> **NEVER**: `SELECT *` in application queries
> **NEVER**: Uncommented risky operations (DELETE, UPDATE without WHERE, DROP)
> **NEVER**: String-concatenated user input in queries

## Query Formatting

```sql
-- ✅ GOOD: Explicit columns, uppercase keywords, alias
SELECT u.id, u.name, u.email
FROM users u
WHERE u.active = 1
ORDER BY u.name ASC;

-- ❌ BAD: Star select, lowercase keywords, no alias
select * from users where active = 1;
```

## JOINs

```sql
-- ✅ GOOD: Explicit JOIN with aliases
SELECT o.id, u.name, o.total
FROM orders o
INNER JOIN users u ON u.id = o.user_id
WHERE o.created_at > '2025-01-01'
ORDER BY o.created_at DESC;

-- ❌ BAD: Implicit join, no aliases
select * from orders, users
where orders.user_id = users.id;
```

## Subqueries & CTEs

```sql
-- ✅ GOOD: CTE for readability
WITH active_users AS (
    SELECT id, name
    FROM users
    WHERE active = 1
)
SELECT au.name, COUNT(o.id) AS order_count
FROM active_users au
LEFT JOIN orders o ON o.user_id = au.id
GROUP BY au.name;
```

## Parameterized Queries

```sql
-- ✅ GOOD: Parameterized (prevents SQL injection)
SELECT id, name FROM users WHERE email = @email;

-- ❌ BAD: String concatenation
SELECT id, name FROM users WHERE email = '" + userInput + "';
```

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Tables | snake_case, plural | `user_roles` |
| Columns | snake_case | `created_at` |
| Aliases | Short, meaningful | `u`, `o`, `ur` |
| Indexes | `idx_{table}_{column}` | `idx_users_email` |
| Constraints | `fk_{table}_{ref}` | `fk_orders_user_id` |

## AI Self-Check

- [ ] SQL keywords uppercase (SELECT, FROM, WHERE, JOIN)?
- [ ] Explicit column lists (no SELECT *)?
- [ ] Table aliases used in multi-table queries?
- [ ] Meaningful, short aliases?
- [ ] Explicit JOIN syntax (not implicit comma joins)?
- [ ] WHERE before ORDER BY / GROUP BY?
- [ ] Parameterized queries (no string concatenation)?
- [ ] Index-friendly WHERE clauses (avoid functions on indexed columns)?
- [ ] snake_case for tables/columns (or project standard)?
- [ ] Comments for risky operations (DELETE, DROP, UPDATE)?
- [ ] CTEs used for complex subqueries?
- [ ] Consistent indentation and formatting?
