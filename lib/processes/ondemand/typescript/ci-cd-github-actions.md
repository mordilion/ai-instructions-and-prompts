# TypeScript CI/CD with GitHub Actions - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up CI/CD pipeline for TypeScript/Node.js project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
TYPESCRIPT CI/CD - GITHUB ACTIONS
========================================

CONTEXT:
You are implementing CI/CD pipeline with GitHub Actions for a TypeScript/Node.js project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Node version from .nvmrc or package.json
- ALWAYS use caching for npm/yarn/pnpm
- NEVER hardcode secrets in workflows
- Use team's Git workflow

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Node.js version used
   - Package manager (npm/yarn/pnpm)
   - Deployment target
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Build/deployment issues found
   - Configuration problems
   - Areas needing attention

3. Read CI-CD-SETUP.md if it exists:
   - Current pipeline configuration
   - Workflows already set up
   - Secrets configured
   - Deployment process

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing setup
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
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version-file: '.nvmrc'  # Or detect from package.json
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build
      run: npm run build
    
    - name: Test
      run: npm test -- --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: coverage/lcov.info
```

For pnpm:
```yaml
    - uses: pnpm/action-setup@v2
      with:
        version: 8
    - uses: actions/setup-node@v3
      with:
        node-version-file: '.nvmrc'
        cache: 'pnpm'
```

Deliverable: Basic CI pipeline running

========================================
PHASE 2 - CODE QUALITY
========================================

Add to workflow:

```yaml
    - name: Lint
      run: npm run lint
    
    - name: Type check
      run: npm run type-check
    
    - name: Format check
      run: npm run format:check
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
    - uses: actions/setup-node@v3
      with:
        node-version-file: '.nvmrc'
        cache: 'npm'
    - run: npm ci
    - run: npm run build
    - name: Deploy to Vercel
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        vercel-args: '--prod'
```

Deliverable: Automated deployment

========================================
BEST PRACTICES
========================================

- Cache npm/yarn/pnpm dependencies
- Use matrix for multi-version testing
- Run ESLint and Prettier
- Type check with TypeScript
- Use semantic versioning
- Set up branch protection

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# CI/CD Implementation Memory

## Detected Versions
- Node.js: {version from .nvmrc or package.json}
- Package Manager: {npm/yarn/pnpm} v{version}

## Pipeline Choices
- CI Tool: GitHub Actions
- Runners: ubuntu-latest
- Deployment: {target environment}
- Why: {reasons}

## Key Decisions
- Workflows: .github/workflows/ci.yml
- Caching strategy: {choice}
- Branch protection: {rules}

## Lessons Learned
- {Challenges}
- {Solutions}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Build/Deploy Issues
1. **File**: {workflow file}
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged for resolution

## Configuration Problems
- {Areas needing attention}

## Missing Steps
- {Pipeline gaps identified}
\```

**CI-CD-SETUP.md** (Process-specific):
```markdown
# CI/CD Setup Guide

## Quick Start
\```bash
# Local workflow testing
act                       # Use act to test workflows locally
npm run build             # Test build locally
npm test                  # Test before pushing
\```

## Pipeline Configuration
- Workflows: .github/workflows/
- Main workflow: ci.yml
- Node.js version: {version}
- Package manager: {npm/yarn/pnpm}

## Workflows
- **ci.yml**: Build, lint, test on push/PR
- **deploy.yml**: Deploy to {environment} (if exists)

## Secrets Required
- None (for basic CI)
- Add deployment secrets if needed:
  - DEPLOY_KEY
  - API_TOKEN

## Branch Protection
- main: Require PR, status checks
- develop: Require status checks

## Troubleshooting
- **Workflow fails**: Check Node version matches
- **Cache not working**: Clear cache and re-run
- **Tests timeout**: Increase timeout in workflow

## Maintenance
- Update Node version: Edit .nvmrc and workflow
- Update dependencies: dependabot or renovate
- Monitor workflow runs: Actions tab
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Create basic CI pipeline (Phase 1)
CONTINUE: Add quality checks (Phase 2)
OPTIONAL: Add deployment (Phase 3)
FINISH: Update all documentation files
REMEMBER: Detect version, use caching, document for catch-up
```

---

## Quick Reference

**What you get**: Complete CI/CD pipeline with npm/pnpm and TypeScript tooling  
**Time**: 1-2 hours  
**Output**: .github/workflows/ci.yml
