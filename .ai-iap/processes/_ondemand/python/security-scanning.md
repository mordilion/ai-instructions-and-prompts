# Security Scanning Setup (Python)

> **Goal**: Establish automated security vulnerability scanning in existing Python projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **pip-audit** ⭐ | Dependency | Official, free | `pip install pip-audit` |
| **Safety** | Dependency | Free database | `pip install safety` |
| **Bandit** ⭐ | SAST | Code security | `pip install bandit` |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | `pip install snyk` |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### pip-audit (Official Tool)

```bash
# Install
pip install pip-audit

# Scan for vulnerabilities
pip-audit

# Output as JSON
pip-audit --format json

# Fail on vulnerability
pip-audit --strict
```

**Configuration** (`pyproject.toml`):
```toml
[tool.pip-audit]
# Ignore specific vulnerabilities
ignore-vulns = ["GHSA-xxxx-xxxx-xxxx"]
```

### Safety

```bash
# Install
pip install safety

# Check dependencies
safety check

# Check with policy file
safety check --policy-file .safety-policy.yml

# CI/CD check
safety check --json --output safety-report.json
```

**Configuration** (`.safety-policy.yml`):
```yaml
security:
  ignore-vulnerabilities:
    # Temporary ignore with justification
    39611:
      reason: "Not exploitable in our use case"
      expires: "2025-12-31"
```

---

## Phase 3: SAST Configuration

### Bandit

```bash
# Install
pip install bandit

# Scan project
bandit -r src/

# Generate report
bandit -r src/ -f json -o bandit-report.json

# Exclude tests
bandit -r src/ --exclude '**/tests/*'
```

**Configuration** (`.bandit`):
```yaml
exclude_dirs:
  - /tests
  - /migrations
skips:
  - B101  # assert_used (OK in tests)
  - B601  # paramiko_calls (false positive)
```

### Semgrep

```bash
# Install
pip install semgrep

# Run with Python security rules
semgrep --config=p/python src/

# Run with OWASP Top 10
semgrep --config=p/owasp-top-ten src/

# CI mode
semgrep ci
```

**Configuration** (`.semgrep.yml`):
```yaml
rules:
  - id: hardcoded-password
    pattern: password = "..."
    message: Hardcoded password detected
    severity: ERROR
    languages: [python]
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
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version-file: '.python-version'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pip-audit safety bandit
      
      - name: Run pip-audit
        run: pip-audit
        continue-on-error: true
      
      - name: Run Safety
        run: safety check --json
        continue-on-error: true
      
      - name: Run Bandit
        run: bandit -r src/ -f json -o bandit-report.json
      
      - name: Run Snyk
        uses: snyk/actions/python@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Upload Bandit report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: bandit-report
          path: bandit-report.json
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **pip-audit fails on outdated pip** | Upgrade pip: `python -m pip install --upgrade pip` |
| **Safety database outdated** | Run `safety update` or use `--db` flag |
| **Bandit false positives** | Add to `.bandit` exclude or skip list |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use virtual environments (venv, poetry, pipenv)
> **ALWAYS**: Pin dependency versions in requirements.txt
> **NEVER**: Commit secrets (use environment variables, .env)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] pip-audit or Safety configured?
- [ ] Bandit installed and configured?
- [ ] Snyk or equivalent SAST tool configured?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] requirements.txt with pinned versions?
- [ ] Secrets excluded from repository (.env, environment vars)?
- [ ] Weekly/monthly security scans scheduled?
- [ ] False positives documented?
- [ ] Team trained on vulnerability triage?

---

## Security Checklist

**Dependencies:**
- [ ] `pip-audit` passing
- [ ] `safety check` passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] Bandit security rules enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries, ORM)
- [ ] XSS prevention (template auto-escaping)

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| pip-audit | Free | Dependencies | ✅ | Basic scanning |
| Safety | Free/Paid | Dependencies | ✅ | Quick checks |
| Bandit | Free | Code patterns | ✅ | SAST |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
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
