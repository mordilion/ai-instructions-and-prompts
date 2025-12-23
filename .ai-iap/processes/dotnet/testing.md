# .NET Testing Implementation Process

> **ALWAYS**: Follow phases sequentially. One branch per phase. Atomic commits only.

## Critical Requirements

> **ALWAYS**: Detect `.TargetFramework` from `.csproj` files (e.g., `net6.0`, `net8.0`)
> **ALWAYS**: Match detected version in Docker images, pipelines, and test projects
> **ALWAYS**: Create new branch for each phase: `poc/test-establishing/{phase-name}`
> **NEVER**: Combine multiple phases in one commit
> **NEVER**: Fix production code bugs found during testing (log only)

## Tech Stack

**Required**:
- **Test Framework**: NUnit
- **Assertions**: FluentAssertions
- **Mocking**: Moq
- **Runtime**: Match detected .NET version

**Forbidden**:
- xUnit, MSTest (migrate if found)

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

### Phase 1: Analysis
**Branch**: `poc/test-establishing/init-analysis`

1. Initialize `process-docs/` (STATUS-DETAILS.md, PROJECT_MEMORY.md, LOGIC_ANOMALIES.md)
2. Detect .NET version from `.csproj` → Document in PROJECT_MEMORY.md
3. Analyze existing test framework and pipeline
4. Propose commit → Wait for user

### Phase 2: Infrastructure
**Branch**: `poc/test-establishing/docker-infra`

1. Create `docker/Dockerfile.tests` with detected version
2. Create `docker/docker-compose.tests.yml`
3. Merge CI/CD pipeline step (don't overwrite)
4. Propose commit → Wait for user

### Phase 3: Framework Migration (if needed)
**Branch**: `poc/test-establishing/framework-migration`

1. Detect if xUnit/MSTest is used
2. Uninstall old → Install NUnit packages
3. Refactor test syntax to NUnit
4. Propose commit → Wait for user

### Phase 4: Test Projects
**Branch**: `poc/test-establishing/project-skeleton`

1. Create `tests/{ProjectName}.UnitTests` using detected framework
2. Create `tests/{ProjectName}.IntegrationTests` using detected framework
3. Implement base patterns:
   - `CustomWebApplicationFactory<TProgram>`
   - `IntegrationTestBase`
   - `DatabaseSeeder`
   - `TestDataBuilder`
4. Propose commit → Wait for user

### Phase 5: Test Implementation (Loop)
**Branch**: `poc/test-establishing/test-{component}` (new branch per component)

1. Read next untested component from STATUS-DETAILS.md
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