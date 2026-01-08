# Python Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a Python project.

CRITICAL REQUIREMENTS:
- ALWAYS use Ruff (replaces Black, isort, flake8)
- NEVER ignore errors without justification
- Use pyproject.toml for configuration
- Enforce in CI pipeline

========================================
PHASE 1 - RUFF SETUP
========================================

Install:
```bash
pip install ruff
# Or add to requirements-dev.txt
```

Create pyproject.toml:
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = [
    "E",  # pycodestyle errors
    "W",  # pycodestyle warnings
    "F",  # pyflakes
    "I",  # isort
    "B",  # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (handled by formatter)
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.ruff.lint.isort]
known-first-party = ["myapp"]
```

Run:
```bash
# Lint
ruff check .

# Fix
ruff check --fix .

# Format
ruff format .
```

Deliverable: Ruff configured

========================================
PHASE 2 - TYPE CHECKING
========================================

Install mypy:
```bash
pip install mypy
```

Configure in pyproject.toml:
```toml
[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
exclude = [
    "tests/",
    "migrations/",
]
```

Run:
```bash
mypy .
```

Deliverable: Type checking enabled

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Install dev dependencies
  run: pip install ruff mypy

- name: Lint
  run: ruff check .

- name: Format check
  run: ruff format --check .

- name: Type check
  run: mypy .
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - PRE-COMMIT HOOKS
========================================

Install pre-commit:
```bash
pip install pre-commit
```

Create .pre-commit-config.yaml:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
```

Install:
```bash
pre-commit install
```

Deliverable: Pre-commit checks enabled

========================================
BEST PRACTICES
========================================

- Use Ruff (faster, replaces multiple tools)
- Enable type checking with mypy
- Configure in pyproject.toml
- Add pre-commit hooks
- Fail CI on violations
- Exclude tests from strict typing

========================================
EXECUTION
========================================

START: Configure Ruff (Phase 1)
CONTINUE: Add mypy (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Add pre-commit hooks (Phase 4)
REMEMBER: Use Ruff, enforce types, CI checks
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup with Ruff  
**Time**: 30 minutes  
**Output**: Ruff, mypy, pre-commit hooks, CI integration
