# .NET CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for .NET project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a .NET project.

CRITICAL REQUIREMENTS:
- ALWAYS detect .NET version from .csproj TargetFramework
- ALWAYS use caching for NuGet packages
- NEVER hardcode secrets in workflows
- Use team's Git workflow

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - .NET version used
   - CI/CD setup decisions
   - Deployment target
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Build/deployment issues found
   - Configuration problems

3. Read CI-CD-SETUP.md if it exists:
   - Current pipeline configuration
   - Workflows already set up

Use this information to:
- Continue from where previous work stopped
- Avoid recreating existing workflows
- Build upon existing pipelines

If no docs exist: Start fresh and create them.

========================================
PHASE 1 - BASIC CI PIPELINE
========================================

Create .github/workflows/ci.yml:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'  # Detect from .csproj
    
    - name: Cache NuGet
      uses: actions/cache@v3
      with:
        path: ~/.nuget/packages
        key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
    
    - name: Restore
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore --configuration Release
    
    - name: Test
      run: dotnet test --no-build --verbosity normal --collect:"XPlat Code Coverage"
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: '**/coverage.cobertura.xml'
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Format check
      run: dotnet format --verify-no-changes
    
    - name: Security scan
      run: dotnet list package --vulnerable
```

Deliverable: Automated code quality checks

========================================
PHASE 3 - DEPLOYMENT (Optional)
========================================

Add deployment:

```yaml
  deploy:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'
    - run: dotnet publish -c Release -o ./publish
    - name: Deploy to Azure
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
        package: ./publish
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache NuGet packages
- Use matrix for multi-version testing
- Collect code coverage
- Run security scans
- Use environments for deployment
- Set up branch protection

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md**, **LOGIC-ANOMALIES.md**, **CI-CD-SETUP.md**:
```markdown
# CI/CD Setup Guide

## Quick Start
\```bash
dotnet build            # Test locally
dotnet test             # Run tests
gh workflow run ci.yml  # Trigger workflow
\```

## Configuration
- .NET version: {from .csproj}
- Workflows: .github/workflows/ci.yml
- Cache: NuGet packages

## Secrets (if deploying)
- AZURE_CREDENTIALS
- NUGET_API_KEY

## Maintenance
- Update .NET: Edit .csproj TargetFramework
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
FINISH: Update all documentation files
REMEMBER: Detect version from .csproj, use caching, document for catch-up
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with build, test, and deployment  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml with automated checks
