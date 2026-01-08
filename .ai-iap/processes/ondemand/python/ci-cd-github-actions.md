# Python CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for Python project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a Python project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Python version from .python-version or pyproject.toml
- ALWAYS use caching for pip
- NEVER hardcode secrets in workflows
- Use team's Git workflow

========================================
PHASE 1 - BASIC CI PIPELINE
========================================

Create .github/workflows/ci.yml:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'  # Detect from .python-version
        cache: 'pip'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest pytest-cov
    
    - name: Test
      run: pytest --cov=. --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: coverage.xml
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Lint
      run: |
        pip install ruff
        ruff check .
    
    - name: Format check
      run: |
        pip install black
        black --check .
    
    - name: Type check
      run: |
        pip install mypy
        mypy .
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - DEPLOYMENT (Optional)
========================================

Add deployment:

```yaml
  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    - name: Build package
      run: |
        pip install build
        python -m build
    - name: Publish to PyPI
      uses: pypa/gh-action-pypi-publish@release/v1
      with:
        password: ${{ secrets.PYPI_API_TOKEN }}
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache pip dependencies
- Use pytest for testing
- Run Ruff for linting
- Use Black for formatting
- Use matrix for multi-version testing
- Set up branch protection

========================================
EXECUTION
========================================

START: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
REMEMBER: Detect version, use caching
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with pytest and Python tooling  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
