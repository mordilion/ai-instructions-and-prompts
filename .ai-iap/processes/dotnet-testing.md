# Testing Implementation Standard

> **Scope**: This is a step-by-step workflow guide for establishing testing in .NET projects. Follow the phases in order.

**Goal**: Establish a standardized testing environment in .NET projects.

**CRITICAL: VERSION AWARENESS**
- **Dynamic Versioning**: You MUST analyze the project's `.csproj` files to detect the `.TargetFramework` (e.g., `net6.0`, `net8.0`).
- **Consistency**: Docker images, Pipeline images, and new Test Projects MUST match the detected version.

**CRITICAL: GIT WORKFLOW & INCREMENTAL PACKAGES**
- **Branching**: Every logical step MUST happen on a NEW branch: `poc/test-establishing/{topic-kebab-case}`.
- **Commits**: Each step represents one atomic commit. You create the files, the user commits/pushes.
- **Review**: The user reviews the changes locally before pushing to create a PR.

## 1. Prerequisites & Standards

### Standards References
- **Code Style**: Strictly follow the .NET Code Style rules.
- **Architecture**: Strictly follow the .NET Architecture rules.
- **Documentation**: Log everything in `process-docs/`.

### Technology Stack
- **Framework**: **NUnit** (Strictly required).
- **Runtime**: Match the project's **Target Framework** (detect automatically).
- **Assertion**: FluentAssertions.
- **Mocking**: Moq.
- **Forbidden**: xUnit, MSTest (migrate if found).

## 2. Infrastructure Templates (Safe Implementation)

### Docker Setup (`docker/`)

*File: `docker/Dockerfile.tests`*
*NOTE: Replace `{DETECTED_VERSION}` with the actual detected SDK version (e.g. 6.0, 8.0, 9.0).*
```dockerfile
FROM [mcr.microsoft.com/dotnet/sdk](https://mcr.microsoft.com/dotnet/sdk):{DETECTED_VERSION} AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet build -c Release --no-restore

FROM build AS test
WORKDIR /src
RUN mkdir -p /test-results /coverage
# Command is defined in compose
```

*File: `docker/docker-compose.tests.yml`*
```yaml
services:
  tests:
    build:
      context: ..
      dockerfile: docker/Dockerfile.tests
    command: >
      dotnet test --no-build -c Release
      --logger "trx;LogFileName=/test-results/results.trx"
      /p:CollectCoverage=true
      /p:CoverletOutput=/coverage/
      /p:CoverletOutputFormat=cobertura
    volumes:
      - ../test-results:/test-results
      - ../coverage:/coverage
```

### CI/CD (`bitbucket-pipelines.yml`)
**⚠️ SAFE MERGE PROTOCOL**
- **DO NOT** overwrite. Analyze and merge only.
- **Image**: Use the SDK image matching the project version.

*Snippet to insert (replace `{DETECTED_VERSION}`):*
```yaml
    - step: &run-standardized-tests
        name: Run NUnit Tests & Coverage
        image: [mcr.microsoft.com/dotnet/sdk](https://mcr.microsoft.com/dotnet/sdk):{DETECTED_VERSION}
        script:
          - dotnet restore
          - dotnet build --no-restore -c Release
          - dotnet test --no-build -c Release --logger "trx" /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
        artifacts:
          - test-results/**
          - coverage/**
```

## 3. Implementation Process (Step-by-Step)

**RULE**: Before starting ANY phase, create a new branch: `git checkout -b poc/test-establishing/{phase-name}`.

### Phase 1: Analysis & Version Detection
**Branch**: `poc/test-establishing/init-analysis`
1.  Initialize `process-docs/` (Overview, Details, Memory, Logic Anomalies).
2.  **Detect Version**: Check `.csproj` files for `<TargetFramework>`. Note the version (e.g., `net8.0`) in `PROJECT_MEMORY.md`.
3.  Analyze Pipeline & Frameworks.
4.  **Action**: Ask user to commit & push.

### Phase 2: Infrastructure Setup
**Branch**: `poc/test-establishing/docker-infra`
1.  Create `docker/` files. **IMPORTANT**: Replace `{DETECTED_VERSION}` in templates with the version found in Phase 1.
2.  Merge `bitbucket-pipelines.yml` using the correct SDK image.
3.  **Action**: Ask user to commit & push.

### Phase 3: Framework Migration (If needed)
**Branch**: `poc/test-establishing/framework-migration`
1.  Uninstall xUnit/MSTest -> Install NUnit.
2.  Refactor syntax.
3.  **Action**: Ask user to commit & push.

### Phase 4: Project Skeleton & Patterns
**Branch**: `poc/test-establishing/project-skeleton`
1.  Create Projects inside a `tests/` folder (Create folder if missing):
    - Path: `tests/{TargetProjectName}.UnitTests`
    - Path: `tests/{TargetProjectName}.IntegrationTests`
    - **MUST** use the same framework: `dotnet new classlib -f {DETECTED_FRAMEWORK}`.
2.  Implement Patterns: `CustomWebApplicationFactory`, `IntegrationTestBase`, `DatabaseSeeder`, `TestDataBuilder`.
3.  **Action**: Ask user to commit & push.

### Phase 5: Incremental Implementation Loop
Pick the next item from `STATUS-DETAILS.md`.
**Branch**: `poc/test-establishing/test-{service-name}` (New branch per service/controller!)

1.  **Intent Analysis**: Read Code. Understand Intent.
2.  **Implement**: Write Tests using Patterns.
3.  **Run & Verify**: Must pass locally.
4.  **Anomaly Check**: If logic bug found, log to `LOGIC_ANOMALIES.md` (DO NOT FIX CODE).
5.  **Docs**: Update `STATUS-DETAILS.md` & `PROJECT_MEMORY.md`.
6.  **Finalize**:
    - Suggest commit message: `feat(test): add tests for {ServiceName}`.
    - Ask user to: Review -> Commit -> Push -> Create PR.
    - **Wait** for user confirmation before starting next item.

## 4. Documentation Strategy (`process-docs/`)
- `STATUS-DETAILS.md`: Checklist.
- `PROJECT_MEMORY.md`: Lessons Learned & **Defined .NET Version**.
- `LOGIC_ANOMALIES.md`: Found bugs (read-only audit).

## 5. Initial Prompt

```text
Act as Senior SDET. Start the testing process following the Testing Implementation Standard.

Step 1: Create branch `poc/test-establishing/init-analysis`.
Step 2: Detect the .NET Version, initialize documentation and analyze the project.
Step 3: Propose commit.
```

## 6. Continue Prompt

```text
Act as Senior SDET. Check `process-docs/STATUS-DETAILS.md` and the Testing Implementation Standard to determine the next logical step.

1. Create the appropriate branch `poc/test-establishing/...` for this step.
2. Execute the tasks for this phase (e.g., Infrastructure, Skeleton, or the next Service Test).
3. Propose the commit message when done.
```