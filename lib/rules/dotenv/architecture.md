# dotenv (.env) Architecture

> **Scope**: `.env` file usage patterns and layering  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Provide `.env.example` with keys (no real secrets)
> **ALWAYS**: Document precedence rules in README
> 
> **NEVER**: Use `.env` for production secrets
> **NEVER**: Commit `.env` files with real credentials

## Layering Pattern

`.env` (defaults) → `.env.local` (local overrides) → `.env.<env>` (environment-specific)

## AI Self-Check

- [ ] `.env.example` provided?
- [ ] Precedence rules documented?
- [ ] Using secret managers for production?
- [ ] No `.env` files in git?

