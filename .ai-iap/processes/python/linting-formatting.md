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

**Ruff** ⭐ (All-in-one): `pip install ruff`, `ruff check .`, `ruff check --fix`, `ruff format .`  
**Config** (`pyproject.toml`): Set `line-length=100`, `target-version="py311"`, select rules (E/W/F/I/N/UP/B/C4), ignore E501

**flake8** (Alternative): `pip install flake8`, `flake8 .`, config `.flake8` (max-line-length, ignore E203/W503)

---

## Phase 3: Formatter Configuration

**Ruff Format** ⭐: `ruff format .`, `ruff format --check` (built-in with Ruff)  
**Black** (Alternative): `pip install black`, `black .`, `black --check`, config `[tool.black]` (line-length, target-version, exclude)

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

**VS Code**: Extensions (`charliermarsh.ruff`), settings (`formatOnSave: true`, `defaultFormatter: "charliermarsh.ruff"`, `codeActionsOnSave`)

**Pre-commit**: `pip install pre-commit && pre-commit install`  
**Config** (`.pre-commit-config.yaml`): Add ruff hooks (`ruff`, `ruff-format`), standard hooks (trailing-whitespace, end-of-file-fixer)

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

