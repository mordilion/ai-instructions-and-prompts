# Dart/Flutter Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for Dart/Flutter projects

## Critical Requirements

> **ALWAYS**: Detect Dart/Flutter version from `pubspec.yaml`
> **ALWAYS**: Match detected version in Docker images, pipelines, and test configuration
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Required**:
- **Test Framework**: Built-in `test` package
- **Widget Testing**: Flutter `flutter_test`
- **Integration Testing**: `integration_test` package
- **Mocking**: `mockito` or `mocktail`
- **BLoC Testing**: `bloc_test` (if using BLoC)
- **Runtime**: Match detected Dart/Flutter version

**Test Types**:
1. **Unit Tests**: Pure Dart logic
2. **Widget Tests**: UI component testing
3. **Integration Tests**: Full app testing

## Infrastructure (Optional)

> **Docker**: Use `cirrusci/flutter:{VERSION}` image  
> **CI/CD**: Run `flutter test --coverage`, collect `coverage/lcov.info`  
> **Merge** test steps into existing pipelines (don't overwrite)

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and choose test approach

1. Detect Dart/Flutter version from `pubspec.yaml`
2. Identify state management (BLoC/Riverpod/GetX/Provider)
3. Analyze existing test setup

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting

**Deliverable**: Tests can run in CI/CD

### Phase 3: Framework Setup

**Objective**: Install and configure test dependencies

1. Add to `pubspec.yaml`: `flutter_test`, `test`, `mockito`/`mocktail`, `bloc_test` (if using BLoC)
2. Run `flutter pub get`
3. Create test configuration

**Deliverable**: Test framework ready

### Phase 4: Test Structure

**Objective**: Establish test directory organization

1. Create test directories: `test/unit/`, `test/widget/`, `test/helpers/`, `integration_test/`
2. Create shared test utilities and mock data helpers

**Deliverable**: Test structure in place

### Phase 5: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior
2. Write tests (unit/widget/integration)
3. Ensure tests pass
4. Log bugs found (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

| Pattern | Package | Key Pattern |
|---------|---------|-------------|
| **Unit** | `test` | `group()` + `test()` + `expect()` |
| **Mock** | `mockito` | `@GenerateMocks([Class])` + `when().thenAnswer()` + `verify()` |
| **Widget** | `flutter_test` | `testWidgets()` + `tester.pumpWidget()` + `find.text()` |
| **BLoC** | `bloc_test` | `blocTest<Bloc, State>()` + `build:` + `act:` + `expect:` |
| **Riverpod** | `flutter_riverpod` | `ProviderContainer()` + `container.read()` + `overrides:` |
| **Integration** | `integration_test` | `IntegrationTestWidgetsFlutterBinding` + `tester.pumpAndSettle()` |
| **Golden** | `flutter_test` | `expectLater()` + `matchesGoldenFile()` |

> **Pattern**: Use Given-When-Then structure, `setUp()` for initialization, `group()` for organization

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Dart/Flutter version + state management + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a Dart/Flutter project

### Complete Implementation Prompt

```
CONTEXT:
You are implementing comprehensive Dart/Flutter testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Dart/Flutter version from pubspec.yaml
- ALWAYS match detected version in Docker images and CI/CD pipelines
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK:
Test Framework:
- flutter_test ⭐ (Flutter projects) - Official Flutter testing
- test package (Dart packages) - Official Dart testing

Mocking (choose one):
- mockito ⭐ (recommended) - Code generation based
- mocktail - No code generation needed

---

PHASE 1 - ANALYSIS:
Objective: Understand project structure

1. Detect Dart/Flutter version from pubspec.yaml
2. Identify project type (Flutter app or Dart package)
3. Document in process-docs/PROJECT_MEMORY.md
4. Analyze current test infrastructure (if any)
5. Report findings

Deliverable: Testing strategy documented

---

PHASE 2 - INFRASTRUCTURE (Optional):
Objective: Set up test infrastructure

1. Create Dockerfile.tests with Flutter/Dart version
2. Configure CI/CD pipeline (use cirrusci/flutter Docker image)
3. Set up flutter test or dart test commands

Deliverable: Tests can run in CI/CD environment

---

PHASE 3 - TEST PROJECTS:
Objective: Create test project structure

1. Create test/ directory
2. Implement shared test utilities
3. Set up mockito code generation (if using)
4. Create test fixtures

Deliverable: Test project structure in place

---

PHASE 4 - TEST IMPLEMENTATION (Iterative):
Objective: Write tests for all components

For each component:
1. Identify component to test
2. Write unit tests
3. Write widget tests if applicable (Flutter)
4. Run flutter test or dart test - must pass
5. If bugs found: Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit
8. Repeat for next component

Deliverable: Comprehensive test coverage

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: Component test checklist
- PROJECT_MEMORY.md: Detected versions, project type, lessons learned
- LOGIC_ANOMALIES.md: Bugs found (audit only)

---

START: Execute Phase 1. Analyze project, detect Dart/Flutter version.
```

