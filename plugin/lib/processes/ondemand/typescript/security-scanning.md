# TypeScript Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for TypeScript/Node.js project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a TypeScript/Node.js project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities (npm audit)
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (ESLint security + Snyk)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Use npm audit:

```bash
# Check for vulnerabilities
npm audit

# Auto-fix
npm audit fix

# For production only
npm audit --production
```

Add to .github/workflows/security.yml:
```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 1'
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v3
      with:
        node-version: '20'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Security audit
      run: npm audit --audit-level=high || exit 1
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Install ESLint security plugins:

```bash
npm install --save-dev eslint-plugin-security @typescript-eslint/eslint-plugin
```

Update .eslintrc.json:
```json
{
  "plugins": ["security", "@typescript-eslint"],
  "extends": [
    "plugin:security/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "security/detect-object-injection": "warn",
    "security/detect-non-literal-regexp": "warn",
    "security/detect-eval-with-expression": "error"
  }
}
```

Use Snyk:
```yaml
    - name: Run Snyk
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Use SonarQube/SonarCloud:
```yaml
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

Add to GitHub Actions:

```yaml
    - name: Scan for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
```

Deliverable: Secrets scanning active

========================================
PHASE 4 - CODE SECURITY BEST PRACTICES
========================================

Implement security best practices:

```typescript
// Use parameterized queries (TypeORM)
import { getRepository } from 'typeorm';

const user = await getRepository(User).findOne({ 
  where: { email } 
});

// Validate input
import { IsString, Length, Matches } from 'class-validator';

class UserDTO {
  @IsString()
  @Length(3, 50)
  @Matches(/^[a-zA-Z0-9]+$/)
  username: string;
}

// Hash passwords
import bcrypt from 'bcrypt';

const hashedPassword = await bcrypt.hash(password, 12);
const isValid = await bcrypt.compare(inputPassword, hashedPassword);

// Prevent XSS
import DOMPurify from 'isomorphic-dompurify';

const clean = DOMPurify.sanitize(userInput);

// Use helmet for security headers
import helmet from 'helmet';

app.use(helmet());

// Rate limiting
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// CSRF protection
import csrf from 'csurf';

app.use(csrf({ cookie: true }));

// Use HTTPS
if (process.env.NODE_ENV === 'production') {
  app.use((req, res, next) => {
    if (req.header('x-forwarded-proto') !== 'https') {
      res.redirect(`https://${req.header('host')}${req.url}`);
    } else {
      next();
    }
  });
}
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Run npm audit regularly
- Use ESLint security plugin
- Scan with Snyk for vulnerabilities
- Use parameterized queries (TypeORM/Prisma)
- Validate input with class-validator
- Hash passwords with bcrypt
- Sanitize output to prevent XSS
- Use helmet for security headers
- Implement rate limiting
- Use CSRF protection
- Enforce HTTPS
- Keep dependencies up to date

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Set up npm audit (Phase 1)
CONTINUE: Add ESLint security (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with npm audit and ESLint  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
