# Python Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect Python version from `pyproject.toml`, `setup.py`, or `.python-version`
> **ALWAYS**: Match detected version in Docker images, pipelines, and virtual environments
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

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

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect Python version from `pyproject.toml`, `setup.py`, or `.python-version` → Document in PROJECT_MEMORY.md
3. Detect framework (Django/FastAPI/Flask/None)
4. Analyze existing test setup
5. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected version
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Setup
**Branch**: `poc/test-establishing/framework-setup`

1. Create `requirements-dev.txt`:
   ```
   pytest>=8.0.0
   pytest-cov>=4.1.0
   pytest-mock>=3.12.0
   pytest-asyncio>=0.23.0  # if async code
   pytest-django>=4.7.0    # if Django
   httpx>=0.26.0           # if FastAPI
   ```
2. Create `pytest.ini`:
   ```ini
   [pytest]
   testpaths = tests
   python_files = test_*.py
   python_classes = Test*
   python_functions = test_*
   addopts = 
       --strict-markers
       --cov=src
       --cov-report=term-missing
       --cov-report=html
   ```
3. Create `pyproject.toml` test config (if not exists):
   ```toml
   [tool.pytest.ini_options]
   testpaths = ["tests"]
   pythonpath = ["src"]
   ```
4. Propose commit → Wait for user

### Phase 4: Test Structure
**Branch**: `poc/test-establishing/project-skeleton`

1. Create test directory structure:
   ```
   tests/
   ├── unit/              # Unit tests
   ├── integration/       # Integration tests
   ├── e2e/              # End-to-end tests
   ├── fixtures/         # Pytest fixtures
   └── conftest.py       # Shared fixtures
   ```
2. Implement base patterns in `tests/conftest.py`:
   ```python
   import pytest
   
   @pytest.fixture
   def sample_data():
       return {"key": "value"}
   ```
3. Create helper modules:
   - `tests/fixtures/factories.py` - Test data factories
   - `tests/fixtures/mocks.py` - Common mocks
4. Propose commit → Wait for user

### Phase 5: Test Implementation (Loop)
**Branch**: `poc/test-establishing/test-{component}` (new branch per component)

1. Read next untested component from STATUS-DETAILS.md
2. Understand intent and behavior
3. Write tests following patterns
4. Run tests locally → Must pass
5. If bugs found → Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit: `feat(test): add tests for {Component}`
8. Wait for user confirmation → Repeat for next component

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

## Usage

**Initial**:
```
Act as Senior SDET. Start Python testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect Python version, analyze project, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```

