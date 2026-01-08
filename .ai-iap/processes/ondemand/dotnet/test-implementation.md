# .NET Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for .NET projects

## Critical Requirements

> **ALWAYS**: Detect `.TargetFramework` from `.csproj` files (e.g., `net6.0`, `net8.0`)
> **ALWAYS**: Match detected version in Docker images, pipelines, and test projects  
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)  
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Test Framework** (choose one):
- **xUnit** ⭐ - Most popular, .NET Core default, used by Microsoft
- **NUnit** - Mature, feature-rich, good for migration from Java
- **MSTest** - Microsoft official, good IDE integration

**Why xUnit is recommended**:
- Default in .NET templates (`dotnet new xunit`)
- Used by .NET Core team and most open-source projects
- Modern async/await support, theory tests, clean syntax

**Assertions** (choose one):
- **FluentAssertions** ⭐ - Readable, extensible
- **Shouldly** - Similar to FluentAssertions
- **Built-in** (xUnit.Assert, NUnit.Assert, MSTest.Assert)

**Mocking** (choose one):
- **Moq** ⭐ - Most popular, simple API
- **NSubstitute** - Clean syntax, less magic strings
- **FakeItEasy** - Discoverable API

**Runtime**: Match detected .NET version

## Infrastructure Templates

> **ALWAYS**: Replace `{VERSION}` with detected .NET version before creating files

**File**: `docker/Dockerfile.tests`
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:{VERSION} AS build
WORKDIR /src
COPY . .
RUN dotnet restore && dotnet build -c Release --no-restore

FROM build AS test
WORKDIR /src
RUN mkdir -p /test-results /coverage
```

**File**: `docker/docker-compose.tests.yml`
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: dotnet test --no-build -c Release --logger "trx;LogFileName=/test-results/results.trx" /p:CollectCoverage=true /p:CoverletOutput=/coverage/ /p:CoverletOutputFormat=cobertura
    volumes:
      - ../test-results:/test-results
      - ../coverage:/coverage
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

```yaml
- step: &run-tests
    name: Run NUnit Tests
    image: mcr.microsoft.com/dotnet/sdk:{VERSION}
    script:
      - dotnet restore
      - dotnet build --no-restore -c Release
      - dotnet test --no-build -c Release --logger "trx" /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
    artifacts:
      - test-results/**
      - coverage/**
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and choose test framework

1. Detect .NET version from `.csproj` files
2. Identify existing test framework (xUnit/NUnit/MSTest) or choose based on team preference
3. Analyze current test infrastructure

**Deliverable**: Testing strategy documented, framework chosen

### Phase 2: Infrastructure (Optional)

**Objective**: Set up test infrastructure (skip if using cloud CI/CD)

1. Create Docker test files (if using Docker)
2. Add/update CI/CD pipeline test step
3. Configure test reporting (Coverlet for coverage)

**Deliverable**: Tests can run in CI/CD

### Phase 3: Test Projects

**Objective**: Create test project structure

1. Create test projects:
   - `tests/{ProjectName}.UnitTests` - Fast, isolated tests
   - `tests/{ProjectName}.IntegrationTests` - Full-stack tests
2. Implement shared test utilities:
   - `CustomWebApplicationFactory<TProgram>` (for integration tests)
   - `IntegrationTestBase` - Base class with common setup
   - `TestDataBuilder` - Test data generation

**Deliverable**: Test project structure in place

### Phase 4: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
2. Understand intent and behavior
3. Write tests using established patterns
4. Run tests locally → Must pass
5. If bugs found → Log to LOGIC_ANOMALIES.md (DON'T fix code)
6. Update STATUS-DETAILS.md
7. Propose commit: `feat(test): add tests for {Component}`
8. Wait for user confirmation → Repeat for next component

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected .NET version + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a .NET project

### Complete Implementation Prompt

```
CONTEXT:
You are implementing comprehensive .NET testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect .NET version from .csproj TargetFramework (e.g., net8.0, net6.0)
- ALWAYS match detected version in Docker images, pipelines, and test projects
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

TECH STACK TO CHOOSE:
Test Framework (choose one):
- xUnit ⭐ (recommended) - .NET default, modern async support
- NUnit - Mature, feature-rich
- MSTest - Microsoft official

Assertions (choose one):
- FluentAssertions ⭐ (recommended) - Readable, extensible
- Shouldly - Similar to FluentAssertions
- Built-in (xUnit.Assert, NUnit.Assert, MSTest.Assert)

Mocking (choose one):
- Moq ⭐ (recommended) - Most popular, simple API
- NSubstitute - Clean syntax
- FakeItEasy - Discoverable API

---

PHASE 1 - ANALYSIS:
Objective: Understand project structure and choose test framework

1. Scan all .csproj files for TargetFramework property
2. Document detected .NET version in process-docs/PROJECT_MEMORY.md
3. Identify existing test framework or choose based on team preference
4. Analyze current test infrastructure (if any)
5. Report findings and proposed framework choices

Deliverable: Testing strategy documented, framework chosen

---

PHASE 2 - INFRASTRUCTURE (Optional - skip if using cloud CI/CD):
Objective: Set up test infrastructure

1. Create docker/Dockerfile.tests with detected .NET SDK version
2. Create docker/docker-compose.tests.yml for test execution
3. Add/update CI/CD pipeline test step (merge with existing, don't overwrite)
4. Configure test reporting (Coverlet for coverage)

Deliverable: Tests can run in CI/CD environment

Infrastructure Templates:
- Dockerfile.tests: FROM mcr.microsoft.com/dotnet/sdk:{VERSION}
- CI/CD: Use mcr.microsoft.com/dotnet/sdk:{VERSION} image
- Commands: dotnet restore → dotnet build → dotnet test with coverage

---

PHASE 3 - TEST PROJECTS:
Objective: Create test project structure

1. Create test projects:
   - tests/{ProjectName}.UnitTests (fast, isolated tests)
   - tests/{ProjectName}.IntegrationTests (full-stack tests)

2. Implement shared test utilities:
   - CustomWebApplicationFactory<TProgram> for integration tests
   - IntegrationTestBase base class with common setup
   - TestDataBuilder for test data generation

3. Add test project references to solution

Deliverable: Test project structure in place with shared utilities

---

PHASE 4 - TEST IMPLEMENTATION (Iterative):
Objective: Write tests for all components

For each component:
1. Identify component to test (from STATUS-DETAILS.md)
2. Understand component intent and behavior
3. Write unit tests (fast, isolated, mocked dependencies)
4. Write integration tests if applicable (full-stack, real dependencies)
5. Run tests locally - must pass
6. If bugs found: Log to LOGIC_ANOMALIES.md (DON'T fix production code)
7. Update STATUS-DETAILS.md with completion status
8. Propose commit using team's commit format
9. Wait for user confirmation
10. Repeat for next component

Deliverable: Comprehensive test coverage for all components

---

DOCUMENTATION (create in process-docs/):
- STATUS-DETAILS.md: Component test checklist (track progress)
- PROJECT_MEMORY.md: Detected .NET version, chosen frameworks, lessons learned
- LOGIC_ANOMALIES.md: Bugs found during testing (audit only, don't fix)

---

START: Execute Phase 1. Analyze project, detect .NET version, propose test framework choices.
```