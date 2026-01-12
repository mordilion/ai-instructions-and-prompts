# TypeScript Security

> **Scope**: TypeScript-specific security (frontend & backend)
> **Extends**: General security rules
> **Applies to**: *.ts, *.tsx files

## 0. Embedded SQL (when SQL appears inside TypeScript)
- **ALWAYS**: Use parameterized queries / prepared statements (or a safe ORM). This applies to any SQL you embed in TS code.
- **NEVER**: Concatenate or interpolate untrusted input into SQL (including template literals).
- **If** you must select dynamic table/column names: use strict allowlists (do not pass user input through).

## 1. Frontend Security

### XSS Prevention
- **ALWAYS**: Use framework escaping (React JSX, Angular templates auto-escape).
- **NEVER**: `dangerouslySetInnerHTML`, `innerHTML`, `eval()`, `Function()`.
- **Sanitize**: Use DOMPurify if HTML rendering required.
- **CSP**: Configure `Content-Security-Policy` headers.

### Client Storage
- **ALWAYS**: `httpOnly` cookies for auth tokens. Use `sessionStorage` for non-sensitive temp data.
- **NEVER**: `localStorage` for tokens, passwords, PII.

### URL Handling
- **ALWAYS**: Validate/sanitize URLs before navigation or API calls.
- **NEVER**: Direct user input to `window.location` or `<a href>`.

## 2. Backend Security (Node.js)

### Environment Variables
- **ALWAYS**: Validate with Zod/Yup at startup. Fail if missing critical vars.
- **Tools**: `dotenv` (dev), environment vars (prod).

### SQL Injection Prevention
- **ALWAYS**: Parameterized queries (Prisma, TypeORM, pg with `$1`, `$2`).
- **NEVER**: Template literals in SQL (`` `SELECT * FROM users WHERE id = ${id}` ``).

### Input Validation
- **ALWAYS**: Validate with Zod, Yup, class-validator, or Joi.
- **Express**: Validate in middleware before controller.
- **NestJS**: Use `@IsEmail()`, `@IsString()`, `@Min()` decorators + `ValidationPipe`.

### Authentication
- **Passwords**: `bcrypt.hash(password, 12)`. Verify with `bcrypt.compare()`.
- **JWT**: `jsonwebtoken` with `expiresIn: '15m'`. Sign with strong secret (32+ chars).
- **Sessions**: `express-session` with Redis store. Secure, HttpOnly, SameSite cookies.

### Rate Limiting
- **ALWAYS**: `express-rate-limit` on auth/API routes.
- **Config**: `max: 5, windowMs: 900000` (5 requests/15 min for login).

### CORS
- **ALWAYS**: Specific origins (`https://yourapp.com`). NEVER `origin: '*'` with `credentials: true`.

## 3. TypeScript-Specific

### Type Safety
- **ALWAYS**: Strict mode (`"strict": true` in tsconfig.json).
- **NEVER**: `any` for user input. Use `unknown` and validate.
- **Types**: Define types for API requests/responses. Validate at runtime.

### Dependency Security
- **ALWAYS**: `npm audit fix`, `pnpm audit`, or `yarn audit`.
- **ALWAYS**: Snyk, Dependabot for automated CVE scanning.

## 4. Framework-Specific

### React
- **NEVER**: `dangerouslySetInnerHTML` without DOMPurify.
- **NEVER**: User input directly in `<a href>`, `<img src>`.

### Next.js
- **ALWAYS**: Server Components for sensitive data fetching.
- **ALWAYS**: API routes for backend logic. NEVER expose secrets to client.
- **Environment**: `NEXT_PUBLIC_*` only for non-sensitive client vars.

### Express
- **ALWAYS**: `helmet()` middleware for security headers.
- **ALWAYS**: `express.json({ limit: '1mb' })` to prevent DoS.

### NestJS
- **ALWAYS**: Guards (`@UseGuards(AuthGuard)`) for protected routes.
- **ALWAYS**: `ValidationPipe` globally configured.

## AI Self-Check

Before generating TypeScript code:
- [ ] Parameterized queries (no template literals in SQL)?
- [ ] `bcrypt` for passwords (12 rounds)?
- [ ] Zod/Yup validation on all inputs?
- [ ] JWT with expiration?
- [ ] HTTPS + secure cookies?
- [ ] No `any` on user input (use `unknown`)?
- [ ] No `dangerouslySetInnerHTML` without sanitization?
- [ ] Rate limiting configured?
- [ ] CORS origins specific?
- [ ] Secrets in env vars (validated at startup)?
