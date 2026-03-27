# TypeScript Authentication (JWT/OAuth) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Implementing authentication for TypeScript/Node.js API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT AUTHENTICATION - JWT/OAUTH
========================================

CONTEXT:
You are implementing JWT and OAuth authentication for a TypeScript/Node.js application.

CRITICAL REQUIREMENTS:
- ALWAYS use secure password hashing (bcrypt/argon2)
- ALWAYS validate JWT tokens on protected routes
- NEVER store passwords in plain text
- NEVER expose JWT secrets

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - JWT AUTHENTICATION
========================================

Install dependencies:

```bash
npm install jsonwebtoken bcrypt
npm install --save-dev @types/jsonwebtoken @types/bcrypt
```

Create auth service:
```typescript
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const JWT_EXPIRES_IN = '24h';

export class AuthService {
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }

  async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  generateToken(userId: string): string {
    return jwt.sign({ userId }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN
    });
  }

  verifyToken(token: string): { userId: string } {
    return jwt.verify(token, JWT_SECRET) as { userId: string };
  }
}
```

Create auth middleware:
```typescript
import { Request, Response, NextFunction } from 'express';

interface AuthRequest extends Request {
  userId?: string;
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = authService.verifyToken(token);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
```

Deliverable: JWT authentication working

========================================
PHASE 2 - AUTH ENDPOINTS
========================================

Create auth routes:

```typescript
import express from 'express';

const router = express.Router();

// Register
router.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    // Check if user exists
    const existing = await findUserByEmail(email);
    if (existing) {
      return res.status(409).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await authService.hashPassword(password);

    // Create user
    const user = await createUser({ email, password: hashedPassword });

    // Generate token
    const token = authService.generateToken(user.id);

    res.status(201).json({ token, user: { id: user.id, email: user.email } });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isValid = await authService.comparePassword(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = authService.generateToken(user.id);

    res.json({ token, user: { id: user.id, email: user.email } });
  } catch (error) {
    res.status(500).json({ error: 'Login failed' });
  }
});

// Protected route
router.get('/me', authMiddleware, async (req: AuthRequest, res) => {
  const user = await findUserById(req.userId!);
  res.json({ user });
});

export default router;
```

Deliverable: Auth endpoints working

========================================
PHASE 3 - OAUTH 2.0 (OPTIONAL)
========================================

Install Passport.js:

```bash
npm install passport passport-google-oauth20
npm install --save-dev @types/passport @types/passport-google-oauth20
```

Configure Google OAuth:
```typescript
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID!,
    clientIDSecret: process.env.GOOGLE_CLIENT_SECRET!,
    callbackURL: '/auth/google/callback'
  },
  async (accessToken, refreshToken, profile, done) => {
    // Find or create user
    let user = await findUserByGoogleId(profile.id);
    
    if (!user) {
      user = await createUser({
        googleId: profile.id,
        email: profile.emails?.[0].value,
        name: profile.displayName
      });
    }

    done(null, user);
  }
));

// Routes
app.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

app.get('/auth/google/callback',
  passport.authenticate('google', { session: false }),
  (req, res) => {
    const token = authService.generateToken(req.user.id);
    res.redirect(`/auth-success?token=${token}`);
  }
);
```

Deliverable: OAuth login working

========================================
PHASE 4 - SECURITY BEST PRACTICES
========================================

Implement security measures:

```typescript
// Rate limiting
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts'
});

router.post('/login', loginLimiter, async (req, res) => { ... });

// Refresh tokens
interface RefreshToken {
  token: string;
  userId: string;
  expiresAt: Date;
}

function generateRefreshToken(userId: string): string {
  const token = crypto.randomBytes(40).toString('hex');
  // Store in database with expiry
  return token;
}

// Password reset
import crypto from 'crypto';

async function requestPasswordReset(email: string) {
  const user = await findUserByEmail(email);
  if (!user) return;

  const token = crypto.randomBytes(32).toString('hex');
  await savePasswordResetToken(user.id, token, Date.now() + 3600000);
  
  await sendPasswordResetEmail(user.email, token);
}
```

Deliverable: Enhanced security

========================================
BEST PRACTICES
========================================

- Hash passwords with bcrypt (12 rounds)
- Use secure JWT secrets (environment variables)
- Set reasonable token expiry
- Implement refresh tokens
- Add rate limiting on auth endpoints
- Validate input thoroughly
- Use HTTPS only
- Implement password reset flow
- Consider OAuth for social login
- Store tokens securely (httpOnly cookies)

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Implement JWT authentication (Phase 1)
CONTINUE: Create auth endpoints (Phase 2)
OPTIONAL: Add OAuth (Phase 3)
CONTINUE: Add security measures (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never store plain passwords, use secure secrets, document for catch-up
```

---

## Quick Reference

**What you get**: Complete JWT/OAuth authentication system  
**Time**: 3-4 hours  
**Output**: Auth service, protected routes, OAuth integration
