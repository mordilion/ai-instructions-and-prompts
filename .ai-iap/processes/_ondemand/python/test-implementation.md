# Python Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for Python projects

## Critical Requirements

> **ALWAYS**: Detect Python version from `pyproject.toml`, `setup.py`, or `.python-version`
> **ALWAYS**: Match detected version in Docker images, pipelines, and virtual environments
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Required**:
- **Test Framework**: pytest
- **Assertions**: Built-in assert + pytest assertions
- **Mocking**: pytest-mock (wraps unittest.mock)
- **Coverage**: pytest-cov
- **Async Testing**: pytest-asyncio (if needed)
- **Runtime**: Match detected Python version

**Forbidden**:
- unittest (migrate to pytest if found)
- nose/nose2 (deprecated)

## Infrastructure Templates

> **ALWAYS**: Replace `{PYTHON_VERSION}` with detected version before creating files

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM python:{PYTHON_VERSION}-slim AS build
WORKDIR /app
COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r requirements-dev.txt
COPY . .

FROM build AS test
WORKDIR /app
RUN mkdir -p /test-results /coverage
```

**File**: `docker/docker-compose.tests.yml`
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: pytest --cov=src --cov-report=xml:/coverage/coverage.xml --cov-report=html:/coverage/html --junit-xml=/test-results/junit.xml
    volumes:
      - ../test-results:/test-results
      - ../coverage:/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions**:
```yaml
- name: Run Tests
  run: |
    pip install -r requirements-dev.txt
    pytest --cov=src --cov-report=xml --cov-report=term
  env:
    PYTHON_VERSION: {PYTHON_VERSION}
```

**GitLab CI**:
```yaml
test:
  image: python:{PYTHON_VERSION}-slim
  script:
    - pip install -r requirements-dev.txt
    - pytest --cov=src --cov-report=xml --cov-report=term --junit-xml=report.xml
  artifacts:
    reports:
      junit: report.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and test requirements

1. Detect Python version from `pyproject.toml`, `setup.py`, or `.python-version`
2. Identify framework (Django/FastAPI/Flask/None)
3. Analyze existing test setup

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure pytest

1. Create `requirements-dev.txt` with pytest, coverage, mocking
2. Create `pytest.ini` or `pyproject.toml` test config
3. Install dependencies

**Deliverable**: Test framework ready

### Phase 4: Test Structure

**Objective**: Establish test directory organization

1. Create test structure: `tests/unit/`, `integration/`, `fixtures/`
2. Create `conftest.py` with shared fixtures
3. Set up test helpers/factories

**Deliverable**: Test structure in place

### Phase 5: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior
2. Write tests (unit/integration/e2e)
3. Ensure tests pass
4. Log bugs found (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

### Unit Test Pattern
```python
import pytest
from src.services.user_service import UserService

class TestUserService:
    """Unit tests for UserService"""
    
    def test_create_user_success(self):
        # Given
        service = UserService()
        
        # When
        user = service.create_user("john@example.com", "John Doe")
        
        # Then
        assert user.email == "john@example.com"
        assert user.name == "John Doe"
    
    def test_create_user_invalid_email(self):
        # Given
        service = UserService()
        
        # When/Then
        with pytest.raises(ValueError, match="Invalid email"):
            service.create_user("invalid", "John Doe")
```

### Mocking Pattern (pytest-mock)
```python
import pytest
from src.services.user_service import UserService

class TestUserService:
    
    def test_find_user_by_id(self, mocker):
        # Given
        mock_repository = mocker.Mock()
        mock_repository.find_by_id.return_value = {"id": 1, "name": "John"}
        service = UserService(repository=mock_repository)
        
        # When
        user = service.find_by_id(1)
        
        # Then
        assert user["name"] == "John"
        mock_repository.find_by_id.assert_called_once_with(1)
```

### FastAPI Integration Test Pattern
```python
import pytest
from fastapi.testclient import TestClient
from src.main import app

@pytest.fixture
def client():
    return TestClient(app)

class TestUserAPI:
    
    def test_get_user_by_id(self, client):
        # When
        response = client.get("/api/users/1")
        
        # Then
        assert response.status_code == 200
        assert "id" in response.json()
        assert response.json()["id"] == 1
    
    def test_create_user(self, client):
        # Given
        payload = {"email": "test@example.com", "name": "Test User"}
        
        # When
        response = client.post("/api/users", json=payload)
        
        # Then
        assert response.status_code == 201
        assert response.json()["email"] == "test@example.com"
```

### Django Test Pattern
```python
import pytest
from django.test import Client
from myapp.models import User

@pytest.mark.django_db
class TestUserViews:
    
    def test_user_list_view(self):
        # Given
        client = Client()
        User.objects.create(email="test@example.com", name="Test")
        
        # When
        response = client.get("/users/")
        
        # Then
        assert response.status_code == 200
        assert "test@example.com" in str(response.content)
```

### Async Test Pattern
```python
import pytest
from src.services.async_service import AsyncService

@pytest.mark.asyncio
class TestAsyncService:
    
    async def test_fetch_data(self):
        # Given
        service = AsyncService()
        
        # When
        result = await service.fetch_data("key")
        
        # Then
        assert result is not None
        assert result["status"] == "success"
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Python version + framework + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a Python project

### Complete Implementation Prompt

```
CONTEXT:
You are implementing comprehensive Python testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Python version from pyproject.toml, setup.py, or .python-version
- ALWAYS match detected version in Docker images, pipelines, and virtual environments
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK TO CHOOSE:
Test Framework (choose one):
- pytest ⭐ (recommended) - Most popular, rich plugin ecosystem
- unittest - Python standard library
- nose2 - Extension of unittest

Assertions:
- pytest assertions ⭐ (recommended) - Rich assertion introspection
- unittest.TestCase assertions - Standard library

Mocking (choose one):
- pytest-mock ⭐ (recommended) - pytest wrapper for unittest.mock
- unittest.mock - Standard library
- responses - HTTP mocking

---

PHASE 1 - ANALYSIS:
Objective: Understand project structure and choose test framework

1. Detect Python version from pyproject.toml, setup.py, or .python-version
2. Document in process-docs/PROJECT_MEMORY.md
3. Identify existing test framework or choose pytest (recommended)
4. Analyze current test infrastructure (if any)
5. Report findings

Deliverable: Testing strategy documented, framework chosen

---

PHASE 2 - INFRASTRUCTURE (Optional - skip if using cloud CI/CD):
Objective: Set up test infrastructure

1. Create Dockerfile.tests with detected Python version
2. Create docker-compose.tests.yml
3. Add/update CI/CD pipeline test step
4. Configure pytest.ini or pyproject.toml
5. Configure coverage.py for coverage reporting

Deliverable: Tests can run in CI/CD environment

---

PHASE 3 - TEST PROJECTS:
Objective: Create test project structure

1. Create tests/ directory with __init__.py
2. Create conftest.py for shared fixtures
3. Implement shared test utilities
4. Configure pytest plugins (pytest-cov, pytest-mock, etc.)

Deliverable: Test project structure in place

---

PHASE 4 - TEST IMPLEMENTATION (Iterative):
Objective: Write tests for all components

For each component:
1. Identify component to test
2. Write unit tests using pytest fixtures
3. Write integration tests if applicable
4. Run pytest - must pass
5. If bugs found: Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit
8. Repeat for next component

Deliverable: Comprehensive test coverage

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: Component test checklist
- PROJECT_MEMORY.md: Detected Python version, chosen frameworks, lessons learned
- LOGIC_ANOMALIES.md: Bugs found (audit only)

---

START: Execute Phase 1. Analyze project, detect Python version, propose test framework choices.
```

