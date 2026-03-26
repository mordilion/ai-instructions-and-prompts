# dotenv (.env) Code Style

> **Scope**: Formatting rules for `.env` files

## CRITICAL REQUIREMENTS

> **ALWAYS**: `KEY=VALUE` (no spaces around `=`)
> **ALWAYS**: Uppercase keys with underscores (DATABASE_URL)
> **ALWAYS**: One key per line
> 
> **NEVER**: Shell-specific syntax
> **NEVER**: Spaces around `=`

## Format

```bash
# ✅ Correct
DATABASE_URL=postgres://localhost:5432/db
JWT_SECRET="my secret value"

# ❌ Wrong
database_url = postgres://localhost:5432/db
```

## AI Self-Check

- [ ] `KEY=VALUE` format (no spaces)?
- [ ] Uppercase keys with underscores?
- [ ] Values with spaces quoted?
- [ ] No shell-specific syntax?

