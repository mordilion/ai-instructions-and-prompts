# CI/CD Implementation Process - .NET/C#

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for .NET applications

---

## Prerequisites

> **BEFORE starting**:
> - Working .NET application (6.0+ recommended)
> - Git repository with remote (GitHub)
> - Solution (.sln) and project files (.csproj)
> - Tests exist (xUnit/NUnit/MSTest)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `dotnet.yml` or `build.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - .NET version matrix (6.0, 7.0, 8.0)
> - Restore dependencies (`dotnet restore`)
> - Build solution (`dotnet build --no-restore`)
> - Run tests (`dotnet test --no-build --verbosity normal`)
> - Collect coverage (coverlet, ReportGenerator)

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

### 1.3 Coverage Reporting

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

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic .NET build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - All projects build successfully
> - Tests execute with results displayed
> - Coverage report generated
> - NuGet cache working

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - StyleCop Analyzers (StyleCop.Analyzers NuGet)
> - Roslynator or SonarAnalyzer.CSharp
> - Treat warnings as errors in CI (`<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`)
> - EditorConfig enforcement

> **NEVER**:
> - Suppress warnings globally
> - Skip analyzer configuration
> - Allow SA violations in new code

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - NuGet package vulnerability scanning
> - Target framework updates
> - Fail on known vulnerabilities

> **Dependabot Config**:
> - Package ecosystem: nuget
> - Directory: "/" (or specific project path)
> - Schedule: weekly
> - Open PR limit: 5

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: csharp
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud integration
> - Security Code Scan analyzer
> - Meziantou.Analyzer for additional rules

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - Analyzers run during build
> - Warnings treated as errors
> - Dependabot creates update PRs
> - CodeQL scan completes
> - Security vulnerabilities reported

---

## Phase 3: Deployment Pipeline

### Branch Strategy
```
main → ci/deployment
```

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: Development, Staging, Production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (connection strings, API keys)
> - Use User Secrets for local dev

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Development: auto-deploy on feature branches

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

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

**Azure App Service**:
- Use azure/webapps-deploy@v2
- Configure publish profile or service principal
- Use deployment slots (staging → production swap)

**Azure Container Apps / AKS**:
- Build Docker image
- Push to Azure Container Registry (ACR)
- Deploy with az containerapp update or kubectl

**AWS (Elastic Beanstalk / ECS / Lambda)**:
- Use aws-actions/configure-aws-credentials
- Package with `dotnet lambda package` (Lambda)
- Deploy to ECS with task definition update

**Docker Registry**:
- Build multi-stage Dockerfile
- Push to Docker Hub, GHCR, ACR, ECR
- Tag with git SHA + semantic version

**IIS / Windows Server**:
- Use Web Deploy (MSDeploy)
- PowerShell remoting for deployment
- Or sftp/scp artifacts + restart IIS

### 3.4 Database Migrations

> **ALWAYS**:
> - Run EF Core migrations before app deployment
> - Use `dotnet ef database update` or SQL scripts
> - Test migrations in staging first
> - Create rollback scripts

> **NEVER**:
> - Run migrations automatically on app start in production
> - Skip migration testing
> - Deploy app before migrations complete

**Migration Commands**:
```bash
dotnet ef migrations script --idempotent --output migration.sql
# Execute SQL script in deployment job
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint test (`/health` or `/healthz`)
> - Database connectivity check
> - Cache/Redis connectivity
> - External API integration check

> **NEVER**:
> - Run full integration tests in deployment job
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
> - Artifacts published correctly
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
> - BenchmarkDotNet for micro-benchmarks
> - Load testing with k6, JMeter, or NBomber
> - Track response times and memory usage
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use TestContainers for database/Redis
> - WebApplicationFactory for in-memory testing
> - Run on schedule (nightly) + release tags

> **NEVER**:
> - Use real production databases
> - Skip cleanup after tests
> - Run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use GitVersion or Nerdbank.GitVersioning
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish NuGet packages (if library)

> **Version Strategies**:
> - Mainline mode: continuous delivery
> - GitFlow mode: release branches
> - Tag-based: manual version bumps

### 4.4 NuGet Package Publishing

> **If creating libraries**:
> - Pack with `dotnet pack -c Release`
> - Include symbols package (.snupkg)
> - Publish to NuGet.org or private feed (Azure Artifacts, GitHub Packages)
> - Validate package contents before publish

> **ALWAYS**:
> - Set PackageVersion, Authors, Description, License
> - Include README.md in package
> - Sign packages with certificate (optional but recommended)

### 4.5 Notifications

> **ALWAYS**:
> - Teams/Slack webhook on deploy success/failure
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
> - NuGet packages published (if applicable)
> - Notifications received

---

## Framework-Specific Notes

### ASP.NET Core Web API
- Publish: `dotnet publish -c Release`
- Health checks: `app.MapHealthChecks("/health")`
- Swagger/OpenAPI generation
- Use Kestrel for production with reverse proxy (nginx/IIS)

### ASP.NET Core MVC / Razor Pages
- Publish with runtime assets (`-r linux-x64` or framework-dependent)
- Static files bundling (CSS/JS minification)
- Use CDN for static assets in production

### Blazor (Server / WebAssembly)
- Blazor Server: standard publish
- Blazor WASM: `dotnet publish -c Release` (outputs to wwwroot)
- Pre-compression (Brotli) for WASM files
- Deploy WASM to static hosting (Azure Static Web Apps, Cloudflare Pages)

### .NET MAUI
- Build: `dotnet build -f net8.0-android` or `-ios` or `-windows`
- Sign Android APK/AAB with keystore
- Sign iOS with provisioning profile
- Publish to App Store / Google Play

### Worker Services / Background Jobs
- Publish as self-contained or with runtime
- Use systemd (Linux) or Windows Service
- Health check port for monitoring
- Graceful shutdown handling

---

## Common Issues & Solutions

### Issue: NuGet restore fails in CI
- **Solution**: Commit packages.lock.json, use authenticated feeds with secrets

### Issue: Tests pass locally but fail in CI
- **Solution**: Check timezone, culture info, connection strings in appsettings.json

### Issue: Coverage not collected
- **Solution**: Install coverlet.collector, use `--collect:"XPlat Code Coverage"`

### Issue: Deployment fails with permission error
- **Solution**: Verify service principal roles (Azure), IAM policies (AWS)

### Issue: Migrations fail with timeout
- **Solution**: Increase command timeout, split large migrations, check firewall rules

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] .NET SDK version pinned (global.json)
- [ ] Solution builds without warnings (TreatWarningsAsErrors)
- [ ] All tests pass with coverage ≥80%
- [ ] Code analyzers enabled (StyleCop, Roslynator)
- [ ] Security scanning enabled (CodeQL, Dependabot)
- [ ] NuGet packages up to date
- [ ] Artifacts published with correct versioning
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

