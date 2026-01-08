# Linting & Formatting Setup (Python)

> **Goal**: Establish automated code linting and formatting in existing Python projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Ruff** ⭐ | Linter + Formatter | All-in-one, fast | `pip install ruff` |
| **Black** | Formatter | Code style | `pip install black` |
| **isort** | Import sorter | Import organization | `pip install isort` |
| **flake8** | Linter | Code quality | `pip install flake8` |
| **mypy** | Type checker | Type safety | `pip install mypy` |

---

## Phase 2: Linter Configuration

**Ruff** ⭐ (All-in-one):
```bash
pip install ruff
ruff check .           # Lint
ruff check --fix .     # Auto-fix
ruff format .          # Format
```

**Configuration** (`pyproject.toml`):
```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "C4"]
ignore = ["E501"]  # line too long (handled by formatter)

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]  # Unused imports OK
"tests/**/*.py" = ["S101"]  # assert OK in tests
```

**flake8** (Alternative):
```bash
pip install flake8
flake8 .
```

**Configuration** (`.flake8`):
```ini
[flake8]
max-line-length = 100
ignore = E203,W503
exclude = .git,__pycache__,venv
```

---

## Phase 3: Formatter Configuration

**Ruff Format** ⭐ (built-in):
```bash
ruff format .           # Format
ruff format --check .   # Check only
```

**Black** (Alternative):
```bash
pip install black
black .                 # Format
black --check .         # Check only
```

**Configuration** (`pyproject.toml`):
```toml
[tool.black]
line-length = 100
target-version = ['py311']
```

### isort Setup (Import Sorting)

```bash
# Install
pip install isort

# Sort imports
isort .

# Check sorting
isort --check-only .
```

**Configuration** (`pyproject.toml`):
```toml
[tool.isort]
profile = "black"
line_length = 100
skip_gitignore = true
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

**VS Code** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.fixAll": true,
      "source.organizeImports": true
    }
  }
}
```

**Pre-commit Hooks**:
```bash
pip install pre-commit
pre-commit install
```

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
```

---

## Phase 5: CI/CD Integration

**GitHub Actions**: Install `ruff` + `mypy`, run `ruff check .`, `ruff format --check .`, `mypy src/`  
**Key Commands**: `pip install ruff mypy`, cache pip dependencies

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Ruff not found** | Install: `pip install ruff` |
| **Black conflicts with isort** | Use Ruff (includes both) or set `profile = "black"` in isort |
| **mypy type errors** | Add `# type: ignore` comments or configure `mypy.ini` |
| **CI fails on formatting** | Run `ruff format .` locally before commit |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Fix all linter errors before merge
> **ALWAYS**: Use type hints and mypy
> **NEVER**: Disable linter rules without justification
> **NEVER**: Commit code with linter errors
> **NEVER**: Mix tabs and spaces (use spaces)

---

## AI Self-Check

- [ ] Ruff or flake8 configured and passing?
- [ ] Ruff format or Black configured?
- [ ] isort configured (or Ruff with import sorting)?
- [ ] mypy configured for type checking?
- [ ] Pre-commit hooks installed?
- [ ] VS Code extensions configured?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All linter errors fixed?
- [ ] Type hints added to functions?
- [ ] Team trained on coding standards?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| Ruff | Both | Very Fast | ⭐⭐ | All-in-one |
| Black | Formatter | Fast | ⭐ | Code style |
| flake8 | Linter | Medium | ⭐⭐⭐ | Code quality |
| mypy | Type checker | Medium | ⭐⭐ | Type safety |

