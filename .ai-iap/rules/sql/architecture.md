# SQL Architecture

> **Scope**: SQL usage patterns for apps and migrations  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Version migrations (apply in CI)
> **ALWAYS**: Add indexes intentionally
> **ALWAYS**: Separate DDL from large DML backfills
> **ALWAYS**: Use query plans/EXPLAIN for critical queries
> 
> **NEVER**: Skip migration versioning
> **NEVER**: Large schema changes without testing
> **NEVER**: Indexes without documentation
> **NEVER**: Skip EXPLAIN for critical queries
> **NEVER**: Mix DDL and DML in one migration

## 1. Migrations
- Version migrations; apply in CI before deploy
- Reversible migrations (up/down) preferred
- Small, incremental migrations

## 2. Performance
- Add indexes intentionally
- Use query plans for optimization

## AI Self-Check

- [ ] Migrations versioned?
- [ ] Applied in CI before deploy?
- [ ] Reversible migrations (up/down)?
- [ ] DDL separated from DML backfills?
- [ ] Small, incremental migrations?
- [ ] Indexes documented?
- [ ] EXPLAIN used for critical queries?
- [ ] No large schema changes without testing?
- [ ] No undocumented indexes?
- [ ] Migration strategy documented?

