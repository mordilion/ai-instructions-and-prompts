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

## Usage

**Initial**:
```
Act as Senior SDET. Start .NET testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect version, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```