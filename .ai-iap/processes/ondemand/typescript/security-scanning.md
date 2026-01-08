# Security Scanning Setup (TypeScript)

> **Goal**: Establish automated security vulnerability scanning in existing TypeScript projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **npm audit** ⭐ | Dependency | Built-in, free | `npm audit` |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | `npm i -g snyk` |
| **ESLint Security Plugin** | SAST | Code patterns | `npm i -D eslint-plugin-security` |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **OWASP Dependency-Check** | Dependencies | Java/JS/etc | CLI tool |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### npm audit (Built-in)

```json
// package.json
{
  "scripts": {
    "security:audit": "npm audit --audit-level=moderate",
    "security:audit:fix": "npm audit fix",
    "security:audit:ci": "npm audit --audit-level=high --production"
  }
}
```

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test project
snyk test

# Monitor (CI/CD)
snyk monitor
```

**Configuration** (`.snyk`):
```yaml
# Snyk configuration
version: v1.22.0
ignore:
  'SNYK-JS-AXIOS-1234567':
    - '*':
        reason: 'False positive - not exploitable in our context'
        expires: '2025-12-31'
```

---

## Phase 3: SAST Configuration

### ESLint Security Plugin

```bash
npm install --save-dev eslint-plugin-security eslint-plugin-no-secrets
```

**Configuration** (`.eslintrc.json`):
```json
{
  "extends": ["plugin:security/recommended"],
  "plugins": ["security", "no-secrets"],
  "rules": {
    "security/detect-object-injection": "warn",
    "security/detect-non-literal-regexp": "warn",
    "security/detect-unsafe-regex": "error",
    "security/detect-buffer-noassert": "error",
    "security/detect-child-process": "warn",
    "security/detect-disable-mustache-escape": "error",
    "security/detect-eval-with-expression": "error",
    "security/detect-no-csrf-before-method-override": "error",
    "security/detect-non-literal-fs-filename": "warn",
    "security/detect-non-literal-require": "warn",
    "security/detect-possible-timing-attacks": "warn",
    "security/detect-pseudoRandomBytes": "error",
    "no-secrets/no-secrets": "error"
  }
}
```

### SonarQube Setup (Optional)

```yaml
# sonar-project.properties
sonar.projectKey=my-typescript-project
sonar.projectName=My TypeScript Project
sonar.sources=src
sonar.tests=tests
sonar.typescript.lcov.reportPaths=coverage/lcov.info
sonar.exclusions=**/node_modules/**,**/dist/**
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 0 * * 1' # Weekly

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run npm audit
        run: npm audit --audit-level=high --production
        continue-on-error: true
      
      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Run ESLint Security
        run: npm run lint
      
      - name: Upload Snyk results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: snyk.sarif
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **npm audit finds too many issues** | Start with `--audit-level=high`, fix critical first |
| **Snyk rate limiting** | Use `SNYK_TOKEN`, authenticate properly |
| **False positives** | Add to `.snyk` ignore file with expiration |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Review and update dependencies monthly
> **ALWAYS**: Use lock files (`package-lock.json`)
> **NEVER**: Commit secrets (use `.env`, environment variables)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] npm audit configured in package.json?
- [ ] Snyk or equivalent SAST tool configured?
- [ ] ESLint security plugin installed?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] Lock files committed?
- [ ] Secrets excluded from repository?
- [ ] Weekly/monthly security scans scheduled?
- [ ] False positives documented?
- [ ] Team trained on vulnerability triage?

---

## Security Checklist

**Dependencies:**
- [ ] `npm audit` passing (high/critical only)
- [ ] Snyk test passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] ESLint security rules enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitize outputs)

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| npm audit | Free | Dependencies | ✅ | Basic scanning |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
| ESLint Security | Free | Code patterns | ✅ | Code quality |
| SonarQube | Free/Paid | Comprehensive | ✅ | Enterprise |
| Semgrep | Free/Paid | Custom rules | ✅ | Advanced |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up security vulnerability scanning

### Complete Implementation Prompt

```
CONTEXT:
You are configuring security vulnerability scanning for this project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for known vulnerabilities
- ALWAYS integrate with CI/CD pipeline
- ALWAYS configure to fail on high/critical vulnerabilities
- ALWAYS keep scanning tools updated

IMPLEMENTATION STEPS:

1. CHOOSE SCANNING TOOLS:
   Select tools for the language (see Tech Stack section):
   - Dependency scanning (npm audit, safety, etc.)
   - SAST (CodeQL, Snyk, SonarQube)
   - Container scanning (Trivy, Grype)

2. CONFIGURE DEPENDENCY SCANNING:
   Enable dependency vulnerability scanning
   Set severity thresholds
   Configure auto-fix for known vulnerabilities

3. CONFIGURE SAST:
   Set up static application security testing
   Configure scan rules
   Integrate with CI/CD

4. CONFIGURE CONTAINER SCANNING:
   Scan Docker images for vulnerabilities
   Fail builds on critical issues

5. SET UP MONITORING:
   Configure security alerts
   Set up regular scanning schedule
   Create remediation workflow

DELIVERABLE:
- Dependency scanning active
- SAST integrated
- Container scanning configured
- Security alerts enabled

START: Choose scanning tools and configure dependency scanning.
```
