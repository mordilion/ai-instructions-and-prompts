# Security Scanning Setup (PHP)

> **Goal**: Establish automated security vulnerability scanning in existing PHP projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Composer Audit** ⭐ | Dependency | Built-in, free | `composer audit` |
| **Local PHP Security Checker** | Dependency | Security advisories | `composer require --dev enlightn/security-checker` |
| **Psalm** ⭐ | SAST | Type safety + security | `composer require --dev vimeo/psalm` |
| **PHPStan** | SAST | Static analysis | `composer require --dev phpstan/phpstan` |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | CLI or plugin |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |

---

## Phase 2: Dependency Scanning Setup

### Composer Audit (Built-in)

```bash
# Check for known vulnerabilities
composer audit

# Audit with specific format
composer audit --format=json

# Audit in CI/CD
composer audit --no-dev
```

### Local PHP Security Checker

```bash
# Install
composer require --dev enlightn/security-checker

# Check vulnerabilities
./vendor/bin/security-checker security:check

# CI/CD
./vendor/bin/security-checker security:check --format=json
```

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test Composer project
snyk test --file=composer.lock

# Monitor (CI/CD)
snyk monitor
```

---

## Phase 3: SAST Configuration

### Psalm with Security Rules

```bash
# Install
composer require --dev vimeo/psalm

# Initialize
./vendor/bin/psalm --init

# Run analysis
./vendor/bin/psalm

# Generate baseline (ignore existing issues)
./vendor/bin/psalm --set-baseline=psalm-baseline.xml
```

**Configuration** (`psalm.xml`):
```xml
<?xml version="1.0"?>
<psalm
    errorLevel="4"
    resolveFromConfigFile="true"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="https://getpsalm.org/schema/config"
    xsi:schemaLocation="https://getpsalm.org/schema/config vendor/vimeo/psalm/config.xsd"
>
    <projectFiles>
        <directory name="src"/>
        <ignoreFiles>
            <directory name="vendor"/>
        </ignoreFiles>
    </projectFiles>
    
    <issueHandlers>
        <TaintedInput errorLevel="error"/>
        <TaintedSql errorLevel="error"/>
        <TaintedHtml errorLevel="error"/>
    </issueHandlers>
</psalm>
```

### PHPStan

```bash
# Install
composer require --dev phpstan/phpstan

# Run analysis
./vendor/bin/phpstan analyse src tests

# Generate baseline
./vendor/bin/phpstan analyse --generate-baseline
```

**Configuration** (`phpstan.neon`):
```neon
parameters:
    level: 8
    paths:
        - src
        - tests
    excludePaths:
        - vendor
    checkMissingIterableValueType: false
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
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version-file: 'composer.json'
          tools: composer
          coverage: none
      
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      
      - name: Run Composer Audit
        run: composer audit
        continue-on-error: true
      
      - name: Run Security Checker
        run: ./vendor/bin/security-checker security:check
        continue-on-error: true
      
      - name: Run Psalm
        run: ./vendor/bin/psalm --output-format=github
      
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse --error-format=github
      
      - name: Run Snyk
        uses: snyk/actions/php@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Composer audit fails** | Update composer: `composer self-update` |
| **Psalm false positives** | Add to baseline or suppress with `@psalm-suppress` |
| **PHPStan memory limit** | Increase: `php -d memory_limit=1G vendor/bin/phpstan` |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable PHP version (8.2+)
> **ALWAYS**: Update dependencies monthly
> **NEVER**: Commit secrets (use .env, environment variables)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] Composer audit configured?
- [ ] Psalm or PHPStan installed?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] Taint analysis enabled (Psalm)?
- [ ] Weekly/monthly security scans scheduled?
- [ ] Secrets excluded from repository (.env)?
- [ ] Team trained on vulnerability triage?
- [ ] PHP version up-to-date (8.2+)?
- [ ] Dependencies updated regularly?

---

## Security Checklist

**Dependencies:**
- [ ] `composer audit` passing
- [ ] Security Checker passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] Psalm taint analysis enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (PDO prepared statements, Eloquent ORM)
- [ ] XSS prevention (Blade/Twig auto-escaping)

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| Composer Audit | Free | Dependencies | ✅ | Basic scanning |
| Security Checker | Free | Dependencies | ✅ | Quick checks |
| Psalm | Free | Taint analysis | ✅ | Security SAST |
| PHPStan | Free | Static analysis | ✅ | Type safety |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |


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
