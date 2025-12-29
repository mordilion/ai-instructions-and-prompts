# CI/CD Implementation Process - Python

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Python applications

---

## Prerequisites

> **BEFORE starting**:
> - Working Python application (3.9+ recommended)
> - Git repository with remote (GitHub)
> - Dependency management (requirements.txt, pyproject.toml, or poetry)
> - Tests exist (pytest, unittest)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `python.yml` or `ci.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - Python version matrix (3.9, 3.10, 3.11, 3.12)
> - Setup with actions/setup-python@v4
> - Dependency caching (pip, poetry, pipenv)
> - Install dependencies (`pip install -r requirements.txt` or `poetry install`)
> - Run linter (ruff, flake8, pylint)
> - Run tests with pytest
> - Collect coverage with pytest-cov

> **NEVER**:
> - Use `pip install` without pinning versions
> - Skip virtual environment in local dev
> - Ignore linter errors
> - Run without specifying Python version

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Setup: actions/setup-python@v4
- Cache: pip cache by requirements.txt hash

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Use pytest-cov or coverage.py
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
pytest --cov=src --cov-report=xml --cov-report=html --cov-fail-under=80
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic Python build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed across Python versions
> - Tests execute with results
> - Coverage report generated
> - Cache working (check run times)

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - Ruff (fast linter + formatter, replaces Flake8 + Black + isort)
> - mypy for type checking
> - Fail build on violations

> **NEVER**:
> - Ignore type errors globally
> - Skip formatter configuration
> - Allow critical issues in new code

**Ruff Configuration**:
```toml
# pyproject.toml
[tool.ruff]
line-length = 120
select = ["E", "F", "I", "N", "W", "B", "UP"]
ignore = []
```

**mypy Configuration**:
```ini
# mypy.ini
[mypy]
python_version = 3.11
strict = True
warn_return_any = True
warn_unused_configs = True
```

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - pip-audit or safety for vulnerability scanning
> - Fail on known vulnerabilities

> **Dependabot Config**:
> - Package ecosystem: pip
> - Directory: "/" (or specific path)
> - Schedule: weekly
> - Open PR limit: 5

**Vulnerability Scanning**:
```bash
pip install pip-audit
pip-audit --desc --fix
# Or: safety check --json
```

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: python
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - Bandit for security linting
> - SonarCloud integration
> - Snyk for dependency scanning

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml pyproject.toml
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - Ruff and mypy run during CI
> - Violations cause build failures
> - Dependabot creates update PRs
> - CodeQL scan completes
> - Vulnerabilities reported

---

## Phase 3: Deployment Pipeline

### Branch Strategy
```
main → ci/deployment
```

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: development, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (DB credentials, API keys)
> - Use python-dotenv for local .env files

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Development: auto-deploy on feature branches

### 3.2 Build & Package Artifacts

> **ALWAYS**:
> - Create requirements.txt from poetry/pipenv (if using)
> - Package as wheel (`python -m build`)
> - Version with setuptools-scm or poetry
> - Upload artifacts with retention policy

> **NEVER**:
> - Include .env files in artifacts
> - Ship development dependencies
> - Package __pycache__ directories

**Package Commands**:
```bash
# Poetry
poetry build

# setuptools
python -m build

# Output: dist/*.whl and dist/*.tar.gz
```

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

**AWS (Elastic Beanstalk / Lambda / ECS)**:
- Use aws-actions/configure-aws-credentials
- Package with Zappa (Lambda) or Chalice
- Deploy to Elastic Beanstalk with eb deploy
- Or containerize and deploy to ECS

**Azure (App Service / Functions / Container Apps)**:
- Use azure/webapps-deploy@v2
- Upload via FTP or Azure CLI
- Deploy to Azure Functions (Python runtime)

**Google Cloud (App Engine / Cloud Run / Functions)**:
- Use google-github-actions/setup-gcloud
- Deploy to App Engine: `gcloud app deploy`
- Cloud Run: containerize and deploy
- Cloud Functions: `gcloud functions deploy`

**Heroku**:
- Use Procfile: `web: gunicorn app:app` or `uvicorn main:app`
- Deploy with Heroku CLI or GitHub integration
- Include runtime.txt for Python version

**Docker Registry**:
- Build Dockerfile (multi-stage: deps → app)
- Push to Docker Hub, GHCR, ECR, GCR
- Tag with git SHA + semver

### 3.4 Database Migrations

> **ALWAYS**:
> - Use Alembic (SQLAlchemy) or Django migrations
> - Run migrations before app deployment
> - Test migrations in staging first
> - Version control all migration files

> **NEVER**:
> - Run migrations on app start in production
> - Skip migration testing
> - Deploy app before migrations complete

**Alembic Commands**:
```bash
alembic upgrade head
# Rollback: alembic downgrade -1
```

**Django Commands**:
```bash
python manage.py migrate
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint test (`/health` or `/healthz`)
> - Database connectivity check
> - Redis/Celery connectivity check
> - External API integration check

> **NEVER**:
> - Run full E2E tests in deployment job
> - Block rollback on smoke test failures

### 3.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/deploy*.yml
> git commit -m "ci: add deployment pipeline with database migrations"
> git push origin ci/deployment
> ```

> **Verify**:
> - Manual trigger works (workflow_dispatch)
> - Environment secrets accessible
> - Artifacts packaged correctly
> - Deployment succeeds to staging
> - Migrations applied
> - Smoke tests pass
> - Rollback procedure tested

---

## Phase 4: Advanced Features

### Branch Strategy
```
main → ci/advanced
```

### 4.1 Performance Testing

> **ALWAYS**:
> - pytest-benchmark for micro-benchmarks
> - Locust or k6 for load testing
> - Track response times and memory usage
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use pytest-docker or testcontainers-python
> - Run on schedule (nightly) + release tags
> - Separate test database

> **NEVER**:
> - Use real production databases
> - Skip cleanup after tests
> - Run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use python-semantic-release
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish to PyPI (if library)

### 4.4 PyPI Package Publishing

> **If creating libraries**:
> - Build with poetry or setuptools
> - Publish to PyPI with twine or poetry publish
> - Include README.md, LICENSE
> - Configure PyPI trusted publishing (OIDC)

> **ALWAYS**:
> - Set version, author, description in pyproject.toml
> - Include classifiers (Python version, license)
> - Test on TestPyPI first

### 4.5 Notifications

> **ALWAYS**:
> - Slack/Teams webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for security alerts

> **NEVER**:
> - Expose webhook URLs in public repos
> - Spam notifications for every commit

### 4.6 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add performance tests, integration tests, and release automation"
> git push origin ci/advanced
> ```

> **Verify**:
> - Benchmarks run and tracked
> - Integration tests pass in isolation
> - Releases created automatically
> - PyPI package published (if applicable)
> - Notifications received

---

## Framework-Specific Notes

### Django
- Collect static: `python manage.py collectstatic --noinput`
- Migrations: `python manage.py migrate`
- WSGI: gunicorn with Procfile
- Health check: django-health-check app

### FastAPI
- ASGI server: uvicorn or hypercorn
- Startup: `uvicorn main:app --host 0.0.0.0 --port 8000`
- Health: custom `/health` endpoint
- OpenAPI auto-generated

### Flask
- WSGI server: gunicorn or waitress
- Startup: `gunicorn app:app -w 4`
- Health: custom `/health` route
- Production: never use `flask run`

### Celery (Background Jobs)
- Start worker: `celery -A app worker -l info`
- Beat scheduler: `celery -A app beat -l info`
- Monitor with Flower: `celery -A app flower`

---

## Common Issues & Solutions

### Issue: Dependencies fail to install in CI
- **Solution**: Pin versions in requirements.txt, use pip-tools for compilation

### Issue: Tests pass locally but fail in CI
- **Solution**: Check timezone, file paths, environment variables

### Issue: Coverage not collected
- **Solution**: Install pytest-cov, use `--cov` flag, check .coveragerc

### Issue: Deployment fails with "module not found"
- **Solution**: Verify PYTHONPATH, check installed packages, use absolute imports

### Issue: Database migrations timeout
- **Solution**: Increase timeout, optimize migration SQL, check firewall

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Python version pinned (in workflow + runtime.txt)
- [ ] Dependencies pinned in requirements.txt
- [ ] All tests pass with coverage ≥80%
- [ ] Linting enforced (Ruff, mypy)
- [ ] Security scanning enabled (CodeQL, Dependabot, pip-audit)
- [ ] Dependencies up to date
- [ ] Artifacts packaged with correct versioning
- [ ] Deployment to at least one environment works
- [ ] Database migrations tested and automated
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment health
- [ ] Rollback procedure documented
- [ ] Performance benchmarks tracked (if applicable)
- [ ] Notifications configured
- [ ] All workflows have timeout limits
- [ ] Documentation updated (README.md)

---

## Bug Logging

> **ALWAYS log bugs found during CI setup**:
> - Create ticket/issue for each bug
> - Tag with `bug`, `ci`, `infrastructure`
> - **NEVER fix production code during CI setup**
> - Link bug to CI implementation branch

---

## Documentation Updates

> **AFTER all phases complete**:
> - Update README.md with CI/CD badges
> - Document deployment process
> - Add runbook for common issues
> - Link to workflow files
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

