# SQL Security

> **Scope**: SQL security rules  
> **Extends**: General security rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Parameterized queries / prepared statements
> **ALWAYS**: Separate DB users for app vs admin
> **ALWAYS**: Wrap risky migrations in transactions
> 
> **NEVER**: Concatenate untrusted input in SQL
> **NEVER**: Run DROP/mass DELETE without safeguards

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Queries** | `"SELECT * WHERE id=" + input` | `SELECT * WHERE id = ?` (parameterized) |
| **Permissions** | One admin user for all | Separate app user (read/write) vs admin user |
| **Destructive** | Direct `DROP TABLE` | Transaction + backup + safeguards |

## AI Self-Check

- [ ] Parameterized queries used?
- [ ] No SQL concatenation with user input?
- [ ] Separate DB users (app vs admin)?
- [ ] Minimum required permissions?
- [ ] Transactions for risky migrations?
