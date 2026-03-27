# Python Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for Python project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a Python project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities (pip-audit/safety)
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (bandit + Snyk)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Install pip-audit:

```bash
pip install pip-audit
```

Run:
```bash
# Check for vulnerabilities
pip-audit

# Or use safety
pip install safety
safety check
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
    - uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install pip-audit
        pip install -r requirements.txt
    
    - name: Security audit
      run: pip-audit || exit 1
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Install and configure bandit:

```bash
pip install bandit
```

Create .bandit:
```yaml
exclude_dirs:
  - /tests/
  - /venv/
skips:
  - B101  # assert_used (only if needed)
```

Run:
```bash
bandit -r . -c .bandit
```

Add to CI:
```yaml
    - name: Run bandit
      run: |
        pip install bandit
        bandit -r . -c .bandit -ll
```

Use Snyk:
```yaml
    - name: Run Snyk
      uses: snyk/actions/python@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
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

```python
# Use parameterized queries
from sqlalchemy import text

result = session.execute(
    text("SELECT * FROM users WHERE email = :email"),
    {"email": email}
)

# Validate input
from pydantic import BaseModel, Field, validator

class User(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, regex="^[a-zA-Z0-9]+$")
    
    @validator('username')
    def validate_username(cls, v):
        # Additional validation
        return v

# Hash passwords
from passlib.hash import argon2

hashed = argon2.hash(password)
argon2.verify(password, hashed)

# Prevent XSS
import html

safe_output = html.escape(user_input)

# Use secrets module for tokens
import secrets

token = secrets.token_urlsafe(32)

# Enforce HTTPS (Flask)
from flask_talisman import Talisman

talisman = Talisman(app, force_https=True)
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Use pip-audit or safety for vulnerability scanning
- Use bandit for SAST
- Scan with Snyk for comprehensive analysis
- Use parameterized queries (SQLAlchemy)
- Validate input with Pydantic
- Hash passwords with Argon2 or Bcrypt
- Escape output to prevent XSS
- Use secrets module for tokens
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
CONTINUE: Set up pip-audit (Phase 1)
CONTINUE: Add bandit (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with pip-audit and bandit  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
