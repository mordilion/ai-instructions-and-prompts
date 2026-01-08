# Authentication Setup Process - TypeScript/Node.js

> **Purpose**: Implement secure authentication and authorization in TypeScript/Node.js applications

---

## Prerequisites

> **BEFORE starting**:
> - Working application with user model/entity
> - Database configured
> - Environment variables setup (.env)
> - Understanding of JWT vs sessions

---

## Phase 1: JWT Authentication

### 1.1 Install Dependencies

> **ALWAYS use**:
> - **jsonwebtoken** (JWT creation/verification)
> - **bcryptjs** or **argon2** (password hashing)
> - **express-validator** or **zod** (input validation)

> **NEVER**:
> - Store passwords in plain text
> - Use MD5 or SHA1 for passwords
> - Store JWT secret in code

**Install**:
```bash
npm install jsonwebtoken bcryptjs
npm install --save-dev @types/jsonwebtoken @types/bcryptjs
```

### 1.2 Password Hashing & JWT

> **ALWAYS**: Hash with bcrypt (12+ rounds), include user ID in JWT, set expiration (1h access, 7d refresh)
> **NEVER**: Store plain passwords, include sensitive data in JWT, use sync hashing

```typescript
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// Hash password
async function hashPassword(password: string) { return bcrypt.hash(password, 12); }
async function verifyPassword(password: string, hash: string) { return bcrypt.compare(password, hash); }

// Generate JWT
function generateAccessToken(userId: string) {
  return jwt.sign({ sub: userId, type: 'access' }, process.env.JWT_SECRET!, { expiresIn: '1h' });
}

// Auth middleware
function authenticateJWT(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET!);
    next();
  } catch { return res.status(401).json({ error: 'Invalid token' }); }
}
```

**Verify**: POST /auth/register creates user, POST /auth/login returns tokens, protected routes require valid JWT

---

## Phase 2: OAuth 2.0 / Social Login

### 2.1 Install OAuth Library

> **ALWAYS use**:
> - **Passport.js** ⭐ (strategy-based, extensive providers)
> - **@auth/core** (Auth.js, modern, serverless-friendly)
> - **grant** (minimal, OAuth 2.0 only)

**Passport.js Setup**:
```bash
npm install passport passport-google-oauth20 passport-github2
npm install --save-dev @types/passport @types/passport-google-oauth20
```

### 2.2 Configure OAuth (Passport.js)

> **ALWAYS**: Store credentials in env, use HTTPS callbacks, validate state
> **NEVER**: Commit OAuth secrets, trust provider data without validation

```typescript
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID!,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
  callbackURL: '/auth/google/callback'
}, async (accessToken, refreshToken, profile, done) => {
  done(null, await findOrCreateUser(profile));
}));
```

**Verify**: GET /auth/google redirects, callback creates user and issues JWT

---

## Phase 3: Role-Based Access Control (RBAC)

### 3.1 Role-Based Access Control

> **ALWAYS**: Store roles in DB, use permission-based checks, least privilege
> **NEVER**: Hardcode roles, trust client-side checks

```typescript
function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(req.user ? 403 : 401).json({ error: req.user ? 'Forbidden' : 'Unauthorized' });
    }
    next();
  };
}

// Usage: app.delete('/users/:id', authenticateJWT, requireRole('admin'), deleteUser);
```

> **Prefer permissions over roles**: Roles = collection of permissions, check granular actions (read:users, write:posts)

### 3.3 Verify

> - Admin can delete users
> - Regular users cannot
> - 403 returned for insufficient permissions

---

## Phase 4: Security Hardening

### 4.1 Rate Limiting

> **ALWAYS**:
> - Rate limit login endpoint (5 attempts per 15 min)
> - Use express-rate-limit or rate-limiter-flexible
> - Store in Redis for distributed systems

**Rate Limiting**:
```bash
npm install express-rate-limit
```

```typescript
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests
  message: 'Too many login attempts, try again later'
});

app.post('/auth/login', loginLimiter, login);
```

### 4.2 Additional Security

> **ALWAYS**: Refresh token rotation, token revocation, CORS, Helmet.js, HTTPS, HttpOnly cookies, audit logging (login attempts, password changes)
> **NEVER**: JWT in localStorage (XSS risk), long-lived access tokens (>1h)

**Verify**: Rate limiting works, tokens rotate, security headers present

---

## Framework-Specific

| Framework | Tools |
|-----------|-------|
| Express | Passport.js, express-session, cookie-parser |
| NestJS | @nestjs/passport, Guards, @nestjs/jwt |
| Next.js | NextAuth.js ⭐, API routes, middleware.ts |
| Fastify | @fastify/jwt, @fastify/auth |

---

## Common Issues & Solutions

### Issue: JWT secret exposed
- **Solution**: Use strong secret (32+ random bytes), rotate regularly, use env vars

### Issue: Token stolen (XSS)
- **Solution**: Use HttpOnly cookies, not localStorage; implement CSP headers

### Issue: Refresh token reuse
- **Solution**: Implement refresh token rotation, revoke on reuse

### Issue: Password reset vulnerable
- **Solution**: Use time-limited tokens, email verification, rate limiting

---

## AI Self-Check

Before completing this process, verify:

- [ ] Passwords hashed with bcrypt (12+ rounds) or Argon2
- [ ] JWT signed with strong secret from env
- [ ] Access tokens expire in ≤1h
- [ ] Refresh tokens rotate on use
- [ ] Authentication middleware validates JWT
- [ ] Authorization checks permissions/roles
- [ ] Rate limiting on login endpoint
- [ ] OAuth providers configured (if needed)
- [ ] HTTPS enforced in production
- [ ] Security headers configured (Helmet.js)
- [ ] Audit logging implemented
- [ ] No sensitive data in JWT payload
- [ ] Input validation on all auth endpoints
- [ ] Error messages don't leak information
- [ ] Documentation updated

---

## Bug Logging

> **ALWAYS log bugs found during auth setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `security`, `authentication`
> - **NEVER fix production code during auth setup**
> - Link bug to authentication implementation branch

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When implementing authentication system with JWT and OAuth

### Complete Implementation Prompt

```
CONTEXT:
You are implementing authentication system with JWT and OAuth for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use strong JWT secret (min 256 bits, from environment variable)
- ALWAYS set appropriate token expiration (15-60 minutes for access, days for refresh)
- ALWAYS validate tokens on protected endpoints
- ALWAYS hash passwords with bcrypt/Argon2
- NEVER store passwords in plain text
- NEVER commit secrets to version control
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - JWT AUTHENTICATION:
1. Install JWT library
2. Configure JWT secret (from environment variable)
3. Implement token generation (login endpoint)
4. Implement token validation middleware
5. Set up token expiration and refresh mechanism

Deliverable: JWT authentication working

PHASE 2 - USER MANAGEMENT:
1. Create User model/entity
2. Implement password hashing
3. Create registration endpoint
4. Create login endpoint
5. Implement password reset flow

Deliverable: User management complete

PHASE 3 - OAUTH INTEGRATION (Optional):
1. Choose OAuth providers (Google, GitHub, etc.)
2. Register application with providers
3. Implement OAuth callback handling
4. Link OAuth accounts with local users

Deliverable: OAuth authentication working

PHASE 4 - ROLE-BASED ACCESS CONTROL:
1. Define user roles
2. Implement role checking middleware
3. Protect endpoints by role
4. Add role management endpoints

Deliverable: RBAC implemented

SECURITY BEST PRACTICES:
- Use HTTPS only in production
- Implement rate limiting
- Add account lockout after failed attempts
- Log authentication events
- Use secure cookie flags (httpOnly, secure, sameSite)

START: Execute Phase 1. Install JWT library and configure token generation.
```
