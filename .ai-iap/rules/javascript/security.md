# JavaScript Security

> **Scope**: JavaScript-specific security (browser & Node.js)
> **Extends**: General security rules
> **Applies to**: *.js, *.jsx, *.mjs, *.cjs, *.vue, *.svelte

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use parameterized queries / ORM (Prisma, Sequelize)
> **ALWAYS**: Validate inputs with schema validators (Ajv, Joi, Zod)
> **ALWAYS**: bcrypt/argon2 for password hashing
> **ALWAYS**: httpOnly cookies for auth tokens
> **ALWAYS**: CSP headers (avoid unsafe-inline/unsafe-eval)
> 
> **NEVER**: Concatenate untrusted input into SQL
> **NEVER**: Use eval(), new Function() on user input
> **NEVER**: dangerouslySetInnerHTML without sanitization
> **NEVER**: Store tokens in localStorage
> **NEVER**: Expose stack traces to clients

## 0. Embedded SQL (when SQL appears inside JavaScript)
- Use parameterized queries / prepared statements (or a safe ORM)
- NEVER concatenate or interpolate untrusted input into SQL
- If dynamic table/column names needed: use strict allowlists

## 1. Backend (Node.js) Security

### Input Validation
- **ALWAYS**: Validate all incoming data with a schema validator (e.g. `Ajv`, `Joi`). Validate length, type and ranges.
- **ALWAYS**: Use parameterized queries or an ORM (Prisma, Sequelize) — never concatenate SQL strings.

### Dependency & Supply-Chain
- **ALWAYS**: Keep lockfiles (`package-lock.json` / `pnpm-lock.yaml`) committed and run `npm audit` or `pnpm audit` in CI.
- **ALWAYS**: Pin critical transitive dependencies when required; monitor Dependabot / Snyk alerts.

### Authentication & Sessions
- **ALWAYS**: Use secure, `HttpOnly`, `SameSite` cookies for sessions where possible. Rotate session IDs after privilege changes.
- **ALWAYS**: Hash passwords with `bcrypt`/`argon2` (appropriate cost factor). Avoid custom crypto.

### JWT
- **ALWAYS**: Sign tokens (RS256 or HS256), set short expirations, validate issuer/audience and use refresh tokens safely (store refresh server-side or in `HttpOnly` cookie).

### Runtime Safety
- **NEVER**: Use `eval()`, `new Function()`, or execute untrusted code. Avoid `child_process` with unvalidated input.
- **ALWAYS**: Run Node with minimal privileges and avoid using `--eval` on production commands.

### Error Handling & Logging
- **NEVER**: Expose stack traces or secrets in responses. Redact secrets from logs and use structured logging with scrubbing.

## 2. Frontend (Browser) Security

### XSS & DOM
- **ALWAYS**: Prefer framework auto-escaping (React, Vue). Avoid `dangerouslySetInnerHTML` / direct DOM insertion.
- **WHEN**: You must render HTML, sanitize with a vetted library (e.g. `DOMPurify`) and use a strict CSP.

### Content Security Policy (CSP)
- **ALWAYS**: Serve a restrictive CSP header (avoid `unsafe-inline`); prefer nonces/hashes for approved scripts/styles.

### Token Storage
- **ALWAYS**: Store sensitive tokens in `HttpOnly` cookies when possible. Avoid storing long-lived secrets in `localStorage` or sessionStorage.

### Third-party Scripts
- **ALWAYS**: Minimize third-party scripts; review and pin versions; run integrity checks (SRI) when embedding CDNs.

## 3. CI / Build & Runtime Checks

- **ALWAYS**: Run dependency scans, static analysis (ESLint with security plugins) and unit tests in CI.
- **ALWAYS**: Use `npm ci` in CI to ensure reproducible installs.

## 4. Framework-specific pointers (examples)
- Express: enable `helmet`, `cors` with explicit origins, `express-rate-limit`, and validate body with `ajv`/`joi`. Follow the Express framework guidance (if selected).
- React: prefer JSX escaping, keep DOMPurify usage centralized. Follow the React framework guidance (if selected).

## AI Self-Check

- [ ] Parameterized queries / ORM (not string concatenation in SQL)?
- [ ] Input validation (Ajv, Joi, Zod)?
- [ ] bcrypt/argon2 for passwords?
- [ ] httpOnly cookies for auth tokens?
- [ ] CSP headers configured?
- [ ] npm audit / Dependabot enabled?
- [ ] No eval(), new Function() on user input?
- [ ] No dangerouslySetInnerHTML without DOMPurify?
- [ ] No tokens in localStorage?
- [ ] No stack traces exposed to clients?
- [ ] Helmet middleware (Node.js)?
- [ ] CORS specific origins?
