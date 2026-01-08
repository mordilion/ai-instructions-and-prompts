# Code Coverage Setup (Python)

> **Goal**: Establish automated code coverage tracking in existing Python projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Coverage.py** ⭐ | Coverage tool | Industry standard | `pip install coverage` |
| **pytest-cov** ⭐ | pytest plugin | pytest integration | `pip install pytest-cov` |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### pytest-cov Setup (Recommended)

```bash
# Install
pip install pytest pytest-cov

# Run tests with coverage
pytest --cov=src --cov-report=html --cov-report=term

# Generate specific formats
pytest --cov=src --cov-report=xml --cov-report=html
```

**Configuration** (`pyproject.toml`):
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = [
    "--cov=src",
    "--cov-report=html",
    "--cov-report=term",
    "--cov-report=xml",
    "--cov-fail-under=80"
]

[tool.coverage.run]
source = ["src"]
omit = [
    "*/tests/*",
    "*/migrations/*",
    "*/__init__.py",
    "*/venv/*",
    "*/.venv/*"
]
branch = true

[tool.coverage.report]
precision = 2
show_missing = true
skip_covered = false
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if TYPE_CHECKING:",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:"
]

[tool.coverage.html]
directory = "htmlcov"
```

### Coverage.py Setup (Alternative)

```bash
# Install
pip install coverage

# Run tests with coverage
coverage run -m pytest
coverage report
coverage html
```

**Configuration** (`.coveragerc`):
```ini
[run]
source = src
omit =
    */tests/*
    */migrations/*
    */__init__.py
branch = True

[report]
precision = 2
show_missing = True
fail_under = 80
exclude_lines =
    pragma: no cover
    def __repr__
    if TYPE_CHECKING:
    raise AssertionError
    raise NotImplementedError

[html]
directory = htmlcov
```

---

## Phase 3: Coverage Thresholds & Reporting

### Set Thresholds

**pytest-cov**:
```bash
# Fail if coverage below 80%
pytest --cov=src --cov-fail-under=80
```

**Coverage.py**:
```bash
# Fail if coverage below 80%
coverage run -m pytest
coverage report --fail-under=80
```

### Exclude Code from Coverage

```python
# Exclude entire block
def debug_only():  # pragma: no cover
    print("Debug info")

# Exclude if statement
if TYPE_CHECKING:  # pragma: no cover
    from typing import Optional
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
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
          pip install pytest pytest-cov
      
      - name: Run tests with coverage
        run: pytest --cov=src --cov-report=xml --cov-report=html
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage.xml
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: htmlcov/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Generate HTML report
pytest --cov=src --cov-report=html

# Open report (macOS)
open htmlcov/index.html

# Open report (Windows)
start htmlcov/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (services, domain)
2. Data validation (validators, serializers)
3. Error handling
4. API endpoints (FastAPI, Flask, Django)
5. Database models

### Incremental Improvement

```toml
# pyproject.toml - Ratcheting approach
[tool.coverage.report]
fail_under = 80  # Start at current coverage
# Increase by 5% every sprint
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage reports empty** | Check `source` and `omit` paths in config |
| **Slow test runs** | Use `pytest -n auto` (pytest-xdist) for parallel tests |
| **False low coverage** | Exclude test files, `__init__.py`, migrations |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Exclude test files, migrations, `__init__.py`
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip edge cases and error paths

---

## AI Self-Check

- [ ] pytest-cov or Coverage.py configured?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Test files excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] `# pragma: no cover` used appropriately?
- [ ] Critical business logic covered?
- [ ] Uncovered code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Function Coverage** | % of functions called | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| pytest-cov | Fast | Easy | ✅ | pytest users |
| Coverage.py | Fast | Easy | ✅ | Any test runner |
| Codecov | N/A | Easy | ✅ | Reporting |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When configuring code coverage tracking and reporting

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code coverage tracking for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS configure coverage thresholds (recommended: 80% line, 75% branch)
- ALWAYS integrate with CI/CD pipeline
- NEVER lower coverage thresholds without justification

IMPLEMENTATION STEPS:

1. DETECT VERSION:
   Scan project files for language/framework version

2. CHOOSE COVERAGE TOOL:
   Select appropriate tool for the language (see Tech Stack section above)

3. CONFIGURE TOOL:
   Add coverage configuration to project
   Set thresholds (line, branch, function)

4. INTEGRATE WITH CI/CD:
   Add coverage step to pipeline
   Configure to fail build if below thresholds

5. CONFIGURE REPORTING:
   Generate coverage reports (HTML, XML, lcov)
   Optional: Upload to coverage service (Codecov, Coveralls)

DELIVERABLE:
- Coverage tool configured
- Thresholds enforced in CI/CD
- Coverage reports generated

START: Detect language version and configure coverage tool.
```
