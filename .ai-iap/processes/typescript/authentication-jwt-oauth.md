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

### Branch Strategy
```
main → auth/jwt-setup
```

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

### 1.2 Password Hashing

> **ALWAYS**:
> - Hash passwords with bcrypt (10+ rounds) or Argon2
> - Salt automatically (bcrypt does this)
> - Validate password strength (min 8 chars, complexity)

> **NEVER**:
> - Use synchronous hashing (blocks event loop)
> - Store password in plain text anywhere
> - Log passwords

**Hash Implementation**:
```typescript
import bcrypt from 'bcryptjs';

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12); // 12 rounds
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### 1.3 JWT Token Generation

> **ALWAYS include in JWT**:
> - User ID (subject)
> - Expiration time (1h for access, 7d for refresh)
> - Issued at timestamp
> - Token type (access/refresh)

> **NEVER include in JWT**:
> - Password or password hash
> - Sensitive PII
> - Permissions (use claims sparingly)

**JWT Implementation**:
```typescript
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;

function generateAccessToken(userId: string): string {
  return jwt.sign({ sub: userId, type: 'access' }, JWT_SECRET, { 
    expiresIn: '1h' 
  });
}

function generateRefreshToken(userId: string): string {
  return jwt.sign({ sub: userId, type: 'refresh' }, JWT_REFRESH_SECRET, { 
    expiresIn: '7d' 
  });
}
```

### 1.4 Authentication Middleware

> **ALWAYS**:
> - Verify JWT signature
> - Check expiration
> - Attach user to request object
> - Handle errors gracefully

**Middleware**:
```typescript
function authenticateJWT(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### 1.5 Commit & Verify

> **Git workflow**:
> ```
> git add src/auth/
> git commit -m "feat: add JWT authentication"
> git push origin auth/jwt-setup
> ```

> **Verify**:
> - POST /auth/register creates user with hashed password
> - POST /auth/login returns access + refresh tokens
> - Protected routes require valid JWT
> - Invalid/expired tokens rejected

---

## Phase 2: OAuth 2.0 / Social Login

### Branch Strategy
```
main → auth/oauth
```

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

### 2.2 Configure OAuth Providers

> **ALWAYS**:
> - Store client ID/secret in environment variables
> - Use HTTPS callback URLs (production)
> - Validate state parameter (CSRF protection)
> - Handle email verification

> **NEVER**:
> - Commit OAuth credentials
> - Trust provider data without validation
> - Skip email verification

**Google OAuth**:
```typescript
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID!,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
  callbackURL: '/auth/google/callback'
}, async (accessToken, refreshToken, profile, done) => {
  // Find or create user
  const user = await findOrCreateUser(profile);
  done(null, user);
}));
```

### 2.3 OAuth Routes

> **ALWAYS**:
> - Redirect to provider for authentication
> - Handle callback with user creation/update
> - Issue JWT after OAuth success
> - Link existing accounts by email

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/auth/
> git commit -m "feat: add OAuth 2.0 authentication (Google, GitHub)"
> git push origin auth/oauth
> ```

> **Verify**:
> - GET /auth/google redirects to Google login
> - Callback creates/finds user and issues JWT
> - Users can link multiple providers
> - Email uniqueness enforced

---

## Phase 3: Role-Based Access Control (RBAC)

### Branch Strategy
```
main → auth/rbac
```

### 3.1 Define Roles & Permissions

> **ALWAYS**:
> - Store roles in database (User, Admin, Moderator)
> - Use permission-based checks (not just roles)
> - Apply least privilege principle
> - Document permission matrix

> **NEVER**:
> - Hardcode roles in middleware
> - Trust client-side role checks
> - Skip authorization after authentication

**Role Middleware**:
```typescript
function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    
    next();
  };
}

// Usage
app.delete('/users/:id', authenticateJWT, requireRole('admin'), deleteUser);
```

### 3.2 Permission-Based Authorization

> **ALWAYS prefer permissions over roles**:
> - Roles: collection of permissions
> - Permissions: granular actions (read:users, write:posts)
> - Check permissions, not roles

### 3.3 Commit & Verify

> **Git workflow**:
> ```
> git add src/auth/
> git commit -m "feat: add role-based access control"
> git push origin auth/rbac
> ```

> **Verify**:
> - Admin can delete users
> - Regular users cannot
> - 403 returned for insufficient permissions
> - Permissions documented

---

## Phase 4: Security Hardening

### Branch Strategy
```
main → auth/security
```

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

### 4.2 Additional Security Measures

> **ALWAYS implement**:
> - Refresh token rotation
> - Token revocation/blacklist
> - CORS configuration
> - Helmet.js security headers
> - HTTPS only (production)
> - HttpOnly cookies for tokens (web apps)

> **NEVER**:
> - Store JWT in localStorage (XSS risk for web)
> - Use long-lived access tokens (>1h)
> - Skip input validation

### 4.3 Audit Logging

> **ALWAYS log**:
> - Login attempts (success/failure)
> - Password changes
> - Permission elevation
> - Suspicious activity

### 4.4 Commit & Verify

> **Git workflow**:
> ```
> git add src/auth/
> git commit -m "feat: add authentication security hardening"
> git push origin auth/security
> ```

> **Verify**:
> - Rate limiting blocks brute force
> - Refresh tokens rotate on use
> - Security headers present
> - Audit log captures auth events

---

## Framework-Specific Notes

### Express.js
- Use Passport.js for OAuth
- express-session for session-based auth
- cookie-parser for HttpOnly cookies

### NestJS
- @nestjs/passport for authentication
- Guards for authorization
- @nestjs/jwt for JWT
- Built-in validation pipes

### Next.js
- NextAuth.js ⭐ (built-in OAuth, JWT, sessions)
- API routes for auth endpoints
- middleware.ts for protected routes

### Fastify
- @fastify/jwt for JWT
- @fastify/auth for strategies
- Faster performance than Express

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

## Final Commit

```bash
git checkout main
git merge auth/security
git tag -a v1.0.0-auth -m "Authentication system implemented"
git push origin main --tags
```

---

**Process Complete** ✅

