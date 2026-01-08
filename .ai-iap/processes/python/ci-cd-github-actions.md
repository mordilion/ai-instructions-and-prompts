# CI/CD Implementation Process - Python (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Python applications

> **Platform**: This guide uses **GitHub Actions** examples.  
> **Adaptation required** for other platforms - see [Git Workflow Adaptation](../_templates/git-workflow-adaptation.md#cicd-platform-adaptation) for:
> - GitLab CI (`.gitlab-ci.yml`)
> - Azure DevOps (`azure-pipelines.yml`)
> - Jenkins (`Jenkinsfile`)
> - CircleCI (`.circleci/config.yml`)

---

## Prerequisites

> **BEFORE starting**:
> - Working Python application
> - Git repository with remote (GitHub)
> - requirements.txt or pyproject.toml configured
> - Tests exist (pytest)
> - Python version defined in pyproject.toml, setup.py, or .python-version

---

## Git Workflow Pattern (All Phases)

> **Standard workflow for each phase**:
> 1. Create branch: `git checkout -b ci/<phase-name>`
> 2. Make changes according to phase requirements
> 3. Commit: `git commit -m "ci: <description>"`
> 4. Push: `git push origin ci/<phase-name>`
> 5. Verify: Check CI/CD pipeline runs successfully

Phases below reference this pattern instead of repeating it.

---

## Phase 1: Basic CI Pipeline

**Branch**: `ci/basic-pipeline`

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - Python version from project (read from `.python-version`, `pyproject.toml`, or `setup.py`)
> - Setup with actions/setup-python@v4
> - Dependency caching (pip cache)
> - Install dependencies (`pip install -r requirements.txt`)
> - Run linter (Ruff, Black, flake8)
> - Run tests with pytest
> - Collect coverage with pytest-cov

> **Version Strategy**:
> - **Best**: Use `.python-version` or `pyproject.toml` python requirement
> - **Good**: Use matrix with supported versions (3.10, 3.11, 3.12)
> - **Avoid**: Hardcoding version without project config

> **NEVER**:
> - Skip virtual environment in CI
> - Use `pip install` without pinned versions
> - Ignore linting errors
> - Run tests without isolation

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Cache: pip cache directory
- Virtual environment: automatic with setup-python

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Use pytest-cov or coverage.py
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
pytest --cov=src --cov-report=xml --cov-report=html --cov-report=term
```

**Verify**: Pipeline runs, linting passes, all tests pass, coverage report generated, pip cache working

---

## Phase 2: Code Quality & Security

**Branch**: `ci/quality-security`

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - Ruff (fast linter/formatter) or flake8 + black
> - mypy for type checking
> - isort for import sorting
> - Fail build on violations

> **NEVER**: Suppress errors globally, skip type hints, allow unused imports

**Tools**:
- **Ruff** ⭐: All-in-one linter (replaces flake8, black, isort)
- **mypy**: Static type checker
- **bandit**: Security linter

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - `pip-audit` or `safety` for vulnerability scanning
> - Fail on known vulnerabilities

**Dependabot Config**:
```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

**Security Commands**:
```bash
pip-audit
# Or: safety check --full-report
```

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: python
> - Run on schedule (weekly) + push to main

> **Optional but recommended**: SonarCloud, Snyk

**Verify**: Linting passes, type checking succeeds, Dependabot creates PRs, CodeQL scan completes, security issues reported

---

## Phase 3: Deployment Pipeline

**Branch**: `ci/deployment`

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (API keys, DB URLs)
> - Use python-dotenv for local .env files

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy on merge to develop), Development (auto-deploy on feature branches)

### 3.2 Build & Package

> **ALWAYS**:
> - Build wheel: `python -m build` or `pip wheel`
> - Create requirements.txt with pinned versions
> - Upload artifacts with retention policy
> - Version with setuptools-scm or bumpversion

> **NEVER**: Include .env files in artifacts, ship dev dependencies, deploy without freezing versions

**Build Commands**:
```bash
python -m build  # Creates dist/*.whl and dist/*.tar.gz
pip freeze > requirements-prod.txt
```

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

| Platform | Tool/Method | Notes |
|----------|-------------|-------|
| **AWS Lambda** | aws-actions/configure-aws-credentials | Package with zappa or AWS SAM |
| **Azure Functions** | azure/functions-action | Deploy Python function apps |
| **Google Cloud Run** | google-github-actions/deploy-cloudrun | Containerize Flask/FastAPI |
| **Heroku** | Heroku CLI | Procfile: `web: gunicorn app:app` |
| **Docker Registry** | docker/build-push-action | Multi-stage Dockerfile |
| **PythonAnywhere / VPS** | SSH deploy | rsync + systemd restart |

### 3.4 Database Migrations

> **ALWAYS**:
> - Use Alembic (SQLAlchemy) or Django migrations
> - Run migrations before app deployment
> - Test migrations in staging first
> - Version control all migration files

> **NEVER**: Run migrations on app start in production, skip migration testing, deploy app before migrations complete

**Migration Commands**:
```bash
# Alembic
alembic upgrade head

# Django
python manage.py migrate --no-input
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint test (`/health`, `/api/health`)
> - Database connectivity check
> - Redis/Celery connectivity (if applicable)
> - External API integration check

**Verify**: Manual trigger works, environment secrets accessible, wheel built successfully, deployment succeeds to staging, migrations applied, smoke tests pass, rollback tested

---

## Phase 4: Advanced Features

**Branch**: `ci/advanced`

### 4.1 Performance Testing

> **ALWAYS**:
> - Load testing with Locust, k6, or Apache Bench
> - Memory profiling with memory_profiler
> - Track response times
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use pytest-docker or testcontainers-python
> - Django: use test database
> - Run on schedule (nightly) + release tags

> **NEVER**: Use real production databases, skip cleanup after tests, run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use python-semantic-release or bump2version
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish to PyPI (if library)

### 4.4 PyPI Publishing

> **If creating packages**:
> - Build with `python -m build`
> - Publish with twine: `twine upload dist/*`
> - Use trusted publishing (no token needed)
> - Validate package with `twine check dist/*`

> **ALWAYS**: Set name, version, description in setup.py/pyproject.toml; Include LICENSE, README.md; Use semantic versioning

### 4.5 Notifications

> **ALWAYS**: Slack/Teams webhook on deploy success/failure, GitHub Status Checks for PR reviews, Email notifications for security alerts

**Verify**: Load tests run and tracked, integration tests pass in isolation, releases created automatically, PyPI publish works (if applicable), notifications received

---

## Framework-Specific Notes

| Framework | Notes |
|-----------|-------|
| **FastAPI** | Health: built-in `/docs`; Deploy: Uvicorn with Gunicorn; Docker: tiangolo/uvicorn-gunicorn image |
| **Django** | Static files: `python manage.py collectstatic`; WSGI: Gunicorn or uWSGI; Migrations: `python manage.py migrate` |
| **Flask** | WSGI server: Gunicorn or Waitress; Blueprints for modular structure; Use Flask-Migrate for DB |
| **Celery** | Background tasks: Deploy workers separately; Use Redis/RabbitMQ; Monitor with Flower |
| **Data Science** | Jupyter notebooks: Convert to scripts with nbconvert; Deploy models: FastAPI + MLflow |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Dependencies not installing in CI** | Use `pip install --upgrade pip`, commit requirements.txt with pinned versions |
| **Tests pass locally but fail in CI** | Check Python version match, timezone, locale, file paths |
| **Coverage not collected** | Install pytest-cov, use `--cov` flag, check coverage config in pytest.ini |
| **Import errors in CI** | Ensure PYTHONPATH set correctly, install package in editable mode: `pip install -e .` |
| **Deployment fails with module not found** | Include all dependencies in requirements.txt, check virtual environment activation |
| **Want to use GitLab CI / Azure Pipelines** | GitLab CI: Use `python:3.11` image; Azure: Use `UsePythonVersion@0` task - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] Python version pinned or matrix tested
- [ ] Linting passes (Ruff/flake8/black)
- [ ] Type checking succeeds (mypy)
- [ ] All tests pass with coverage ≥80%
- [ ] Security scanning enabled (pip-audit, Dependabot, CodeQL)
- [ ] Wheel/package built successfully
- [ ] Deployment to at least one environment works
- [ ] Database migrations tested and automated
- [ ] Smoke tests validate deployment health

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
> - Onboarding guide for new developers

---

## Final Commit

```bash
git checkout main
git merge ci/advanced
git tag -a v1.0.0-ci -m "CI/CD pipeline implemented"
git push origin main --tags
```

---

**Process Complete** ✅
