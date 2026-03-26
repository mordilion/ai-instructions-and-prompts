# Python Testing Implementation - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up testing infrastructure in a Python project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive testing infrastructure for a Python project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Python version from pyproject.toml, setup.py, or .python-version
- ALWAYS match detected version in Docker/CI/CD
- NEVER fix production code bugs (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow

========================================
TECH STACK
========================================

Test Framework: pytest ⭐ (recommended) / unittest / nose2
Assertions: pytest assertions ⭐ (recommended) / unittest.TestCase
Mocking: pytest-mock ⭐ (recommended) / unittest.mock / responses

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Python version used
   - Framework (Django/Flask/FastAPI/etc)
   - Test framework chosen
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs found but not fixed
   - Code smells discovered
   - Areas needing refactoring

3. Read TESTING-SETUP.md if it exists:
   - Current test configuration
   - Modules already tested
   - Mock strategies in use
   - Fixtures available

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid re-testing already covered modules
- Build upon existing test infrastructure

If no docs exist: Start fresh and create them.

========================================
PHASE 1 - ANALYSIS
========================================

1. Detect Python version from pyproject.toml, setup.py, or .python-version
2. Document in process-docs/PROJECT_MEMORY.md
3. Choose pytest (recommended)
4. Report findings

Deliverable: Testing strategy documented

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

Create Dockerfile.tests:
```dockerfile
FROM python:{VERSION}-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
RUN pytest
```

Add to CI/CD:
```yaml
- name: Test
  run: |
    pip install pytest pytest-cov
    pytest --cov
```

Deliverable: Tests run in CI/CD

========================================
PHASE 3 - TEST PROJECT SETUP
========================================

1. Create tests/ directory with __init__.py

2. Create conftest.py for shared fixtures

3. Install dependencies:
```bash
pip install pytest pytest-cov pytest-mock
```

4. Configure pytest.ini or pyproject.toml:
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
```

Deliverable: Test infrastructure ready

========================================
PHASE 4 - WRITE TESTS (Iterative)
========================================

For each component:

1. Write unit tests (pytest):
```python
def test_should_handle_success_case():
    # Given
    service = MyService()
    
    # When
    result = service.process("input")
    
    # Then
    assert result == "expected"
```

2. Use fixtures:
```python
@pytest.fixture
def service():
    return MyService()

def test_with_fixture(service):
    result = service.process("input")
    assert result == "expected"
```

3. Mock dependencies:
```python
def test_calls_repository(mocker):
    mock_repo = mocker.Mock()
    service = Service(mock_repo)
    
    service.process(1)
    
    mock_repo.find.assert_called_once_with(1)
```

4. Parametrize tests:
```python
@pytest.mark.parametrize("input,expected", [
    ("a", "A"),
    ("b", "B"),
])
def test_uppercase(input, expected):
    assert to_upper(input) == expected
```

5. Run tests: pytest (must pass)
6. If bugs found: Log to LOGIC_ANOMALIES.md
7. Update STATUS-DETAILS.md
8. Propose commit
9. Repeat

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# Testing Implementation Memory

## Detected Versions
- Python: {version from pyproject.toml or setup.py}
- Framework: {Django/Flask/FastAPI/none}

## Framework Choices
- Test Framework: pytest v{version}
- Mocking: pytest-mock v{version}
- Why: {reasons}

## Key Decisions
- Test location: tests/
- Mocking strategy: pytest-mock
- Coverage target: 80%+

## Lessons Learned
- {Challenges}
- {Solutions}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Bugs Discovered (Not Fixed)
1. **File**: user_service.py:45
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged only, not fixed

## Code Smells
- {Areas needing refactoring}

## Missing Tests
- {Modules needing coverage}
\```

**TESTING-SETUP.md** (Process-specific):
```markdown
# Testing Setup Guide

## Quick Start
\```bash
pytest                    # Run all tests
pytest -v                 # Verbose
pytest --cov              # With coverage
pytest -k test_user       # Single test
\```

## Configuration
- Framework: pytest v{version}
- Config: pytest.ini or pyproject.toml
- Coverage: pytest-cov
- Target: 80%+

## Test Structure
- Unit: tests/unit/
- Integration: tests/integration/
- Fixtures: tests/conftest.py

## Mocking Strategy
- HTTP: responses or httpx mock
- Database: pytest fixtures with SQLite
- External services: pytest-mock

## Modules Tested
- [ ] Module A
- [ ] Service B
- [x] API C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80%
- Reports: htmlcov/index.html

## Troubleshooting
- **Import errors**: Check PYTHONPATH or pytest.ini
- **Mock not working**: Verify patch path
- **Coverage too low**: Run pytest --cov --cov-report=html

## Maintenance
- Update dependencies: pip install --upgrade pytest pytest-cov
- Run tests: pytest
- Generate coverage: pytest --cov --cov-report=html
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Execute Phase 1 - detect Python version, choose frameworks
CONTINUE: Execute phases 2-4 iteratively
FINISH: Update all documentation files
REMEMBER: Use pytest fixtures, don't fix bugs, iterate, document for catch-up
```

---

## Quick Reference

**What you get**: Complete test infrastructure with pytest, fixtures, mocking  
**Time**: 4-8 hours depending on project size  
**Output**: Comprehensive test coverage with pytest
