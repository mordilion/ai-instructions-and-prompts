# Security Guidelines (General)

> **Scope**: Baseline security for ALL languages. Language-specific rules take precedence.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Validate ALL user input (length, format, type, range)
> **ALWAYS**: Use parameterized queries / ORM (not string concatenation)
> **ALWAYS**: Hash passwords (BCrypt/Argon2, 12+ cost)
> **ALWAYS**: HTTPS in production (TLS 1.2+)
> **ALWAYS**: Verify permissions on every protected resource
> 
> **NEVER**: Trust user input (GET, POST, headers, cookies)
> **NEVER**: String concatenation in SQL
> **NEVER**: Use MD5/SHA1 for passwords
> **NEVER**: Hardcode secrets or commit to Git
> **NEVER**: Expose stack traces to clients

## 1. OWASP Top 10 Protection

### Input Validation
- Validate ALL user input (length, format, type, range)
- Use allowlists over denylists
- **SQL Injection**: Parameterized queries/ORM ONLY
- **XSS**: Auto-escape output by default
- **Path Traversal**: Validate file paths, generate safe filenames

### Authentication
- **ALWAYS**: Hash passwords (BCrypt/Argon2, 12+ cost). NEVER MD5/SHA1/plaintext.
- **ALWAYS**: Use framework authentication (Spring Security, Django Auth, Passport.js).
- **ALWAYS**: Multi-factor authentication for sensitive operations.
- **Session**: Secure, HttpOnly, SameSite=Strict cookies. Rotate session IDs after login.
- **JWT**: Sign tokens (HS256/RS256). Set expiration (≤15 min). Store secret securely.

### Authorization
- **ALWAYS**: Verify permissions on EVERY protected resource.
- **ALWAYS**: Use role-based (RBAC) or attribute-based (ABAC) access control.
- **NEVER**: Trust client-side checks. Validate server-side.

### Secrets Management
- **ALWAYS**: Environment variables or secret managers (Vault, AWS Secrets Manager).
- **NEVER**: Hardcode secrets, commit to Git, log secrets.
- **Rotation**: Regular rotation for API keys, tokens, certificates.

## 2. Transport & Communication

### HTTPS/TLS
- **ALWAYS**: HTTPS in production. TLS 1.2+ only.
- **ALWAYS**: Redirect HTTP → HTTPS.
- **ALWAYS**: HSTS headers (`Strict-Transport-Security: max-age=31536000`).
- **Certificate**: Valid certificates. Pin certificates for critical APIs.

### CORS
- **ALWAYS**: Restrictive origins. NEVER `*` with credentials.
- **ALWAYS**: Specific methods (GET, POST). Avoid OPTIONS if possible.

## 3. Data Protection

### Sensitive Data
- **ALWAYS**: Encrypt at rest (database, files) and in transit (TLS).
- **ALWAYS**: Use platform keychains (iOS Keychain, Android Keystore, OS credential managers).
- **NEVER**: Store in plaintext, logs, browser localStorage (for tokens/secrets).

### File Uploads
- **ALWAYS**: Validate type (magic bytes), size limit, sanitize filename.
- **ALWAYS**: Store outside webroot. Serve via separate domain/CDN.
- **NEVER**: Execute uploaded files.

## 4. API Security

### Rate Limiting
- **ALWAYS**: Rate limit by IP/user. Strict on auth endpoints (5/15min).
- **Tools**: Express Rate Limit, Flask-Limiter, Spring Rate Limiting.

### Error Handling
- **ALWAYS**: Generic error messages to clients. Log details server-side.
- **NEVER**: Expose stack traces, SQL queries, internal paths.

## 5. Security Headers

- **CSP**: `Content-Security-Policy: default-src 'self'`.
- **X-Frame-Options**: `DENY` or `SAMEORIGIN`.
- **X-Content-Type-Options**: `nosniff`.
- **Referrer-Policy**: `strict-origin-when-cross-origin`.

## 6. Testing & Monitoring

### Testing
- **ALWAYS**: Test authentication, authorization, input validation.
- **ALWAYS**: Security scanning (OWASP ZAP, Snyk, npm audit, pip-audit).
- **ALWAYS**: Dependency updates. Automated CVE alerts.

### Monitoring
- **ALWAYS**: Log security events (failed auth, privilege escalation attempts).
- **ALWAYS**: Anomaly detection (unusual access patterns).

## 7. Anti-Patterns (MUST Avoid)

- **Eval/Exec**: NEVER with user input (`eval()`, `exec()`, `Function()`).
- **Deserialization**: NEVER untrusted data (pickle, yaml.unsafe_load).
- **Debug Mode**: NEVER in production.
- **Default Credentials**: Change immediately.
- **Client-Side Validation Only**: Always validate server-side.

## AI Self-Check

Before generating code:
## AI Self-Check

- [ ] Parameterized queries (no string concatenation)?
- [ ] Password hashing (BCrypt/Argon2, 12+ rounds)?
- [ ] Input validation on ALL user data?
- [ ] HTTPS enforced?
- [ ] Secrets in environment variables?
- [ ] CSRF protection enabled?
- [ ] Security headers configured?
- [ ] Rate limiting on auth endpoints?
- [ ] Error messages don't expose internals?
- [ ] File uploads validated (type, size)?
- [ ] Authorization checks on every protected resource?
- [ ] Dependency scanning enabled?
