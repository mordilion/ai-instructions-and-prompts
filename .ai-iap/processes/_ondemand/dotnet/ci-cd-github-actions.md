# CI/CD Implementation Process - .NET/C# (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for .NET applications

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, or Jenkins, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working .NET application
> - Git repository with remote (GitHub)
> - Solution (.sln) and project files (.csproj)
> - Tests exist (xUnit/NUnit/MSTest)
> - .NET version defined in .csproj or global.json

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - .NET version from project (read from `global.json` or .csproj `<TargetFramework>`)
> - Restore dependencies (`dotnet restore`)
> - Build solution (`dotnet build --no-restore`)
> - Run tests (`dotnet test --no-build --verbosity normal`)
> - Collect coverage (coverlet, ReportGenerator)

> **Version Strategy**:
> - **Best**: Use `global.json` to pin SDK version: `dotnet new globaljson --sdk-version 8.0.100`
> - **Good**: Read from .csproj `<TargetFramework>` (net8.0, net6.0, etc.)
> - **Avoid**: Hardcoding version without project config

> **NEVER**:
> - Skip `--no-restore` and `--no-build` flags (wasteful rebuilds)
> - Use outdated .NET versions in production
> - Run tests without proper logger output
> - Forget to include test projects in solution

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: build → test → publish
- Setup: actions/setup-dotnet@v3
- Cache: NuGet packages by packages.lock.json

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Use coverlet.collector or coverlet.msbuild
> - Generate reports with ReportGenerator
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)
> - Use `--collect:"XPlat Code Coverage"` flag

**Coverage Commands**:
```bash
dotnet test --collect:"XPlat Code Coverage" --results-directory ./coverage
reportgenerator -reports:./coverage/**/coverage.cobertura.xml -targetdir:./coverage/report -reporttypes:Html
```

**Verify**: Pipeline runs, all projects build, tests execute with results, coverage report generated, NuGet cache working

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: StyleCop Analyzers, Roslynator, TreatWarningsAsErrors, EditorConfig, Dependabot, CodeQL (csharp), NuGet vulnerability scanning
> **NEVER**: Suppress warnings globally

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: Analyzers run, warnings=errors, Dependabot creates PRs, CodeQL completes

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant environments/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: Development, Staging, Production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (connection strings, API keys)
> - Use User Secrets for local dev

**Protection Rules**:
- Production: require approval, restrict to main branch
- Staging: auto-deploy on merge to develop
- Development: auto-deploy on feature branches

### 3.2 Build & Publish Artifacts

> **ALWAYS**:
> - Publish with `dotnet publish -c Release -o ./publish`
> - Include runtime identifier if self-contained (`-r linux-x64`)
> - Version assemblies (AssemblyVersion, FileVersion, InformationalVersion)
> - Upload artifacts with retention policy

> **NEVER**:
> - Include appsettings.Development.json in artifacts
> - Publish without trimming/optimization
> - Ship PDB files to production (upload separately for debugging)

**Publish Commands**:
```bash
dotnet publish -c Release -o ./publish --no-restore
# Self-contained: add --self-contained -r linux-x64
# Framework-dependent: add --no-self-contained
```

### 3.3 Deployment & Verification

**Platforms**: Azure App Service, AKS/Container Apps, AWS (ECS/Lambda), Docker Registry, IIS  
**Migrations**: `dotnet ef migrations script --idempotent`, run before deployment, test in staging  
**Smoke Tests**: Health check, DB/Redis connectivity, external APIs  
**NEVER**: Auto-run migrations on app start in production

**Verify**: Deployment succeeds, migrations applied, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**Performance**: BenchmarkDotNet, k6/JMeter/NBomber, fail if degrades >10%  
**Integration**: Separate workflow, TestContainers, WebApplicationFactory, run nightly  
**NEVER**: Use production DBs, run integration on every PR

### 4.2 Release Automation

> **Semantic Versioning**:
> - Use GitVersion or Nerdbank.GitVersioning
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish NuGet packages (if library)

**Version Strategies**: Mainline mode (continuous delivery), GitFlow mode (release branches), Tag-based (manual version bumps)

### 4.4 NuGet Package Publishing

> **If creating libraries**:
> - Pack with `dotnet pack -c Release`
> - Include symbols package (.snupkg)
> - Publish to NuGet.org or private feed (Azure Artifacts, GitHub Packages)
> - Validate package contents before publish

> **ALWAYS**: Set PackageVersion, Authors, Description, License; Include README.md in package; Sign packages (optional but recommended)

### 4.5 Notifications

> **ALWAYS**:
> - Teams/Slack webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for security alerts

**Verify**: Benchmarks run and tracked, integration tests pass in isolation, releases created automatically, NuGet packages published (if applicable), notifications received

---

## Framework-Specific Notes

| Framework | Notes |
|-----------|-------|
| **ASP.NET Core Web API** | Health checks: `app.MapHealthChecks("/health")`, Swagger/OpenAPI, Use Kestrel with reverse proxy (nginx/IIS) |
| **ASP.NET Core MVC / Razor Pages** | Static files bundling (CSS/JS minification), Use CDN for static assets in production |
| **Blazor (Server / WebAssembly)** | Blazor Server: standard publish; Blazor WASM: outputs to wwwroot, pre-compression (Brotli), deploy to Azure Static Web Apps or Cloudflare Pages |
| **.NET MAUI** | Sign Android APK/AAB with keystore, Sign iOS with provisioning profile, Publish to App Store / Google Play |
| **Worker Services** | Use systemd (Linux) or Windows Service, Health check port for monitoring, Graceful shutdown handling |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **NuGet restore fails in CI** | Commit packages.lock.json, use authenticated feeds with secrets |
| **Tests pass locally but fail in CI** | Check timezone, culture info, connection strings in appsettings.json |
| **Coverage not collected** | Install coverlet.collector, use `--collect:"XPlat Code Coverage"` |
| **Deployment fails with permission error** | Verify service principal roles (Azure), IAM policies (AWS) |
| **Migrations fail with timeout** | Increase command timeout, split large migrations, check firewall rules |
| **Want to use Azure DevOps / GitLab CI** | Azure DevOps: Use `DotNetCoreCLI@2` tasks in azure-pipelines.yml; GitLab CI: Use `mcr.microsoft.com/dotnet/sdk` image - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] .NET SDK version pinned (global.json)
- [ ] Solution builds without warnings (TreatWarningsAsErrors)
- [ ] All tests pass with coverage ≥80%
- [ ] Code analyzers enabled (StyleCop, Roslynator)
- [ ] Security scanning enabled (CodeQL, Dependabot)
- [ ] Artifacts published with correct versioning
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
# Merge all phases and tag release using your team's workflow
git tag -a v1.0.0-ci -m "CI/CD pipeline implemented"
git push --tags
```

---

**Process Complete** ✅

## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When setting up CI/CD pipeline with GitHub Actions

### Complete Implementation Prompt

```
CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS match detected version in GitHub Actions workflow
- ALWAYS use caching for dependencies
- NEVER hardcode secrets in workflow files (use GitHub Secrets)
- Use team's Git workflow (adapt to existing branching strategy)

PLATFORM NOTE:
This guide uses GitHub Actions. For other platforms (GitLab CI, Azure DevOps, CircleCI, Jenkins), adapt the workflow syntax while keeping the same phases and objectives.

---

PHASE 1 - BASIC CI PIPELINE:
Objective: Set up basic build and test workflow

1. Create .github/workflows/ci.yml
2. Detect and configure language version
3. Set up dependency caching
4. Add build and test steps with coverage
5. Configure triggers (push/pull request)

Deliverable: Basic CI pipeline running on every push

---

PHASE 2 - CODE QUALITY & SECURITY:
Objective: Add linting and security scanning

1. Add linting step
2. Add dependency security scanning
3. Add SAST scanning (CodeQL, Snyk, etc.)
4. Configure to fail on critical issues

Deliverable: Automated code quality and security checks

---

PHASE 3 - DEPLOYMENT PIPELINE (Optional):
Objective: Add deployment automation

1. Configure deployment environments
2. Add deployment steps with approval gates
3. Configure secrets
4. Add deployment verification

Deliverable: Automated deployment on successful builds

---

PHASE 4 - ADVANCED FEATURES (Optional):
Objective: Add advanced CI/CD capabilities

1. Matrix testing (multiple versions/platforms)
2. Performance testing
3. Release automation
4. Notifications

Deliverable: Production-grade CI/CD pipeline

---

START: Execute Phase 1. Detect language version, create basic CI workflow.
```
