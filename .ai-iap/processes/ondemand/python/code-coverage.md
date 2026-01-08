# Python Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for Python project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON CODE COVERAGE - PYTEST-COV
========================================

CONTEXT:
You are implementing code coverage measurement for a Python project using pytest-cov.

CRITICAL REQUIREMENTS:
- ALWAYS use pytest-cov (standard tool)
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude tests and migrations from coverage

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Install coverage tools:
```bash
pip install pytest pytest-cov
# Or add to requirements-dev.txt
```

Run tests with coverage:
```bash
pytest --cov=. --cov-report=html --cov-report=term

# View HTML report
open htmlcov/index.html
```

Update .gitignore:
```
htmlcov/
.coverage
.coverage.*
coverage.xml
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Create .coveragerc:
```ini
[run]
source = .
omit =
    */tests/*
    */test_*.py
    */__pycache__/*
    */venv/*
    */migrations/*
    */settings.py
    */manage.py
    */wsgi.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod
```

Or use pyproject.toml:
```toml
[tool.coverage.run]
source = ["."]
omit = [
    "*/tests/*",
    "*/test_*.py",
    "*/migrations/*"
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if __name__ == .__main__.:"
]
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Install dependencies
      run: |
        pip install pytest pytest-cov
        pip install -r requirements.txt
    
    - name: Test with coverage
      run: pytest --cov=. --cov-report=xml
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage.xml
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Add to .coveragerc or pyproject.toml:
```ini
[report]
fail_under = 80
```

Run:
```bash
pytest --cov=. --cov-fail-under=80
# Exits with code 2 if below 80%
```

Or use pre-commit hook:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest-cov
        name: pytest with coverage
        entry: pytest --cov=. --cov-fail-under=80
        language: system
        pass_filenames: false
```

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Exclude tests, migrations, and config
- Use pytest-cov for consistency
- Focus on business logic
- Test error paths and edge cases
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Install pytest-cov (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude tests and migrations
```

---

## Quick Reference

**What you get**: Complete code coverage setup with pytest-cov  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
