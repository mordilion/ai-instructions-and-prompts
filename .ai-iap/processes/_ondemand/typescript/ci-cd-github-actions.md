# CI/CD Implementation Process - TypeScript/Node.js (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for TypeScript/Node.js projects

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, or Jenkins, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working application with package.json
> - Git repository with remote (GitHub)
> - npm/yarn/pnpm configured
> - Tests exist (unit/integration)
> - Node.js version defined in package.json or .nvmrc

---

## Phase 1: Basic CI Pipeline

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - Node.js version from project (read from `.nvmrc`, `package.json` engines, or matrix with LTS versions)
> - Dependency caching (npm/yarn/pnpm)
> - `npm ci` for reproducible installs
> - Run linter (ESLint/Biome)
> - Run tests with coverage
> - Build/compile step

> **Version Strategy**:
> - **Best**: Read from `.nvmrc` or `package.json` engines field
> - **Good**: Use matrix with currently supported LTS versions
> - **Avoid**: Hardcoding single version without justification

> **NEVER**:
> - Use `npm install` in CI (use `npm ci` for lockfile integrity)
> - Skip cache invalidation strategy
> - Hardcode secrets in workflow files
> - Run tests without timeout limits

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Artifacts: coverage reports, build output
- Cache: node_modules by lock file hash

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Upload coverage to Codecov/Coveralls (if configured)
> - Set minimum coverage threshold (80%+)
> - Fail build if coverage drops below threshold
> - Generate HTML reports as artifacts

**Verify**: Pipeline runs, all jobs pass, coverage generated, cache working

---

## Phase 2: Code Quality & Security

### 2.1 Dependency Security Scanning

> **ALWAYS include**:
> - `npm audit` or `yarn audit` step
> - Dependabot configuration (`.github/dependabot.yml`)
> - Fail on high/critical vulnerabilities

**Dependabot Config** (`.github/dependabot.yml`):
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```

### 2.2 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure languages: javascript, typescript
> - Run on schedule (weekly) + push to main
> - Review security alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud/SonarQube
> - ESLint security plugin (eslint-plugin-security)
> - TypeScript strict mode enforcement

**Verify**: Dependabot creates PRs, CodeQL scan completes, security alerts visible

---

## Phase 3: Deployment Pipeline

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: dev, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (API keys, tokens)
> - Use environment variables for config

**Protection Rules**:
- Production: require approval, restrict to main branch
- Staging: auto-deploy on merge to develop/staging
- Dev: auto-deploy on any push

### 3.2 Build Artifacts

> **ALWAYS**:
> - Build production bundle (`npm run build`)
> - Upload artifacts with retention policy (30-90 days)
> - Version artifacts (git SHA, tag, semantic version)
> - Generate source maps (upload separately, not public)

> **NEVER**:
> - Include `.env` files in artifacts
> - Ship development dependencies
> - Deploy without minification/optimization

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

| Platform | Tool | Notes |
|----------|------|-------|
| **Vercel/Netlify** | Official GitHub Actions | Deploy previews for PRs, production on main |
| **AWS** | aws-actions/configure-aws-credentials | S3+CloudFront, ECS, or Lambda |
| **Azure** | azure/webapps-deploy | App Service or Static Web Apps |
| **Docker** | docker/build-push-action | Push to Docker Hub, GHCR, ECR |

### 3.4 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint test (200 OK)
> - Critical API endpoint validation
> - Database connectivity check
> - External service integration check

> **NEVER**:
> - Run full E2E suite in deployment job (separate workflow)
> - Block rollback on smoke test failures (alert + rollback)

**Verify**: Manual trigger works, environment secrets accessible, deployment succeeds, smoke tests pass, rollback tested

---

## Phase 4: Advanced Features

### 4.1 Performance Testing

> **ALWAYS**:
> - Lighthouse CI for frontend apps
> - Bundle size tracking (next-bundle-analyzer, webpack-bundle-analyzer)
> - Fail if bundle size increases >10% without justification
> - API response time benchmarks

### 4.2 E2E Testing

> **Playwright/Cypress**:
> - Separate workflow (`e2e.yml`)
> - Run on schedule (nightly) + release tags
> - Record videos/screenshots on failure
> - Upload artifacts for debugging

> **NEVER**:
> - Run E2E on every PR (too slow, use separate schedule/trigger)
> - Skip parallelization (use matrix strategy)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Conventional commits (feat, fix, BREAKING CHANGE)
> - Automated changelog generation
> - GitHub Releases with notes
> - npm publish (if library)

**Tools**: semantic-release, release-please, or changesets

### 4.4 Notifications

> **ALWAYS**:
> - Slack/Discord webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for security alerts

> **NEVER**:
> - Spam notifications for every commit
> - Expose webhook URLs in public repos

**Verify**: Performance budgets enforced, E2E tests run on schedule, releases created on version bump, notifications received

---

## Framework-Specific Notes

| Framework | Build Command | Deployment | Notes |
|-----------|---------------|------------|-------|
| **React/Next.js** | `next build` + `next export` | Vercel CLI | Use `@next/bundle-analyzer` |
| **NestJS** | `npm run build` | Docker-friendly | Single executable, use PM2 |
| **Express/Fastify** | `tsc` or build script | Node process | Health check at `/health` |
| **Angular** | `ng build --configuration production` | Firebase, Azure | Use `webpack-bundle-analyzer` |
| **Vue.js** | `npm run build` (Vite/Webpack) | Netlify, Firebase | Preview with `npm run preview` |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **`npm ci` fails with lockfile mismatch** | Commit updated `package-lock.json`, use exact versions |
| **Tests fail only in CI** | Check timezone, env vars, ensure `CI=true` flag set |
| **Cache not working** | Verify cache key includes lock file hash, check runner OS |
| **Deployment secrets not found** | Verify environment name matches workflow, check secret names |
| **Build works locally but fails in CI** | Use `.nvmrc` or `package.json` engines to specify Node version |
| **Want to use GitLab CI / Azure DevOps** | Adapt workflow syntax: GitLab (`.gitlab-ci.yml`), Azure (`azure-pipelines.yml`), CircleCI (`.circleci/config.yml`) - core concepts remain same |

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Linting enforced, tests pass with ≥80% coverage
- [ ] Security scanning enabled (npm audit, CodeQL, Dependabot)
- [ ] Build artifacts generated and versioned
- [ ] Deployment to at least one environment works
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment health
- [ ] Performance budgets tracked
- [ ] Rollback procedure documented
- [ ] Documentation updated (README.md with badges)

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
