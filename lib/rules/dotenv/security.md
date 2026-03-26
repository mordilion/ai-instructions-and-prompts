# dotenv (.env) Security

> **Scope**: Prevent secret leakage and unsafe environment usage  
> **Extends**: General security rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Commit `.env.example` only (no real secrets)
> **ALWAYS**: Use `.gitignore` for `.env` files
> **ALWAYS**: Rotate leaked credentials immediately
> 
> **NEVER**: Commit real `.env` files
> **NEVER**: Put private keys/certificates in `.env`
> **NEVER**: Print environment values in logs

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Git** | `.env` committed | `.env` in `.gitignore`, `.env.example` committed |
| **Secrets** | Private key in `.env` | Use secret store or file references |
| **Production** | `.env` on server | CI/CD secrets, secret managers |

## AI Self-Check

- [ ] `.env` in `.gitignore`?
- [ ] Only `.env.example` committed?
- [ ] No private keys in `.env`?
- [ ] Using secret stores for production?
- [ ] Not printing secrets in logs?

