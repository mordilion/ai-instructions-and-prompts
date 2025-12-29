# CI/CD Implementation Process - TypeScript/Node.js

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for TypeScript/Node.js projects

---

## Prerequisites

> **BEFORE starting**:
> - Working application with package.json
> - Git repository with remote (GitHub)
> - npm/yarn/pnpm configured
> - Tests exist (unit/integration)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `ci.yml` or `build.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - Node.js version matrix (18.x, 20.x, latest LTS)
> - Dependency caching (npm/yarn/pnpm)
> - `npm ci` for reproducible installs
> - Run linter (ESLint/Biome)
> - Run tests with coverage
> - Build/compile step

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

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Upload coverage to Codecov/Coveralls (if configured)
> - Set minimum coverage threshold (e.g., 80%)
> - Fail build if coverage drops below threshold
> - Generate HTML reports as artifacts

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - All jobs pass (lint, test, build)
> - Coverage report generated
> - Cache working (check run times)

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security (or continue on ci/basic-pipeline)
```

### 2.1 Dependency Security Scanning

> **ALWAYS include**:
> - `npm audit` or `yarn audit` step
> - Dependabot configuration (`.github/dependabot.yml`)
> - Fail on high/critical vulnerabilities
> - Auto-update patch versions

> **Dependabot Config**:
> - Package ecosystem: npm
> - Update schedule: weekly
> - Review reviewers/assignees
> - Semantic versioning rules

### 2.2 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure languages: javascript, typescript
> - Run on schedule (weekly) + push to main
> - Review security alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud/SonarQube integration
> - ESLint security plugin (eslint-plugin-security)
> - TypeScript strict mode enforcement

### 2.3 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml
> git commit -m "ci: add dependency scanning and CodeQL analysis"
> git push origin ci/quality-security
> ```

> **Verify**:
> - Dependabot creates PRs for outdated deps
> - CodeQL scan completes successfully
> - Security alerts visible in repo

---

## Phase 3: Deployment Pipeline

### Branch Strategy
```
main → ci/deployment
```

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: dev, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (API keys, tokens)
> - Use environment variables for config

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop/staging
> - Dev: auto-deploy on any push

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

**Vercel/Netlify**:
- Use official GitHub Actions (vercel/actions, netlify/actions)
- Deploy previews for PRs
- Production deploy on main branch merge

**AWS (S3 + CloudFront / ECS / Lambda)**:
- Use aws-actions/configure-aws-credentials
- Deploy static assets to S3
- Invalidate CloudFront cache
- Or deploy Docker image to ECR + ECS

**Azure (App Service / Static Web Apps)**:
- Use azure/webapps-deploy
- Configure publish profile secrets
- Deployment slots for staging

**Docker Registry**:
- Build multi-stage Dockerfile
- Push to Docker Hub, GHCR, ECR
- Tag with git SHA + semver

### 3.4 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint test (200 OK)
> - Critical API endpoint validation
> - Database connectivity check
> - External service integration check

> **NEVER**:
> - Run full E2E suite in deployment job (separate workflow)
> - Block rollback on smoke test failures (alert + rollback)

### 3.5 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/deploy*.yml
> git commit -m "ci: add deployment pipeline with smoke tests"
> git push origin ci/deployment
> ```

> **Verify**:
> - Manual trigger works (workflow_dispatch)
> - Environment secrets accessible
> - Deployment succeeds to dev/staging
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

> **Tools**:
> - semantic-release
> - release-please
> - changesets

### 4.4 Notifications

> **ALWAYS**:
> - Slack/Discord webhook on deploy success/failure
> - GitHub Status Checks for PR reviews
> - Email notifications for security alerts

> **NEVER**:
> - Spam notifications for every commit
> - Expose webhook URLs in public repos

### 4.5 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add performance tests, E2E, and release automation"
> git push origin ci/advanced
> ```

> **Verify**:
> - Performance budgets enforced
> - E2E tests run on schedule
> - Release created on version bump
> - Notifications received

---

## Framework-Specific Notes

### React/Next.js
- Use `next build` and `next export` (if static)
- Vercel CLI for deployment (`vercel --prod`)
- Analyze bundle with `@next/bundle-analyzer`

### NestJS
- Build: `npm run build`
- Start: `node dist/main.js`
- Docker-friendly (single executable)
- Use PM2 for production process management

### Express/Fastify
- Build TypeScript: `tsc` or `tsc -p tsconfig.build.json`
- Use `node -r dotenv/config dist/index.js` for production
- Health check route: `/health` or `/api/health`

### Angular
- Build: `ng build --configuration production`
- Analyze: `ng build --stats-json` + webpack-bundle-analyzer
- Deploy to Firebase Hosting, Azure Static Web Apps

### Vue.js
- Build: `npm run build` (Vite/Webpack)
- Preview: `npm run preview`
- Deploy to Netlify, Firebase Hosting

---

## Common Issues & Solutions

### Issue: `npm ci` fails with lockfile mismatch
- **Solution**: Commit updated `package-lock.json`, use exact versions

### Issue: Tests fail only in CI
- **Solution**: Check timezone, env vars, ensure `CI=true` flag set

### Issue: Cache not working
- **Solution**: Verify cache key includes lock file hash, check runner OS

### Issue: Deployment secrets not found
- **Solution**: Verify environment name matches workflow, check secret names

### Issue: Build works locally but fails in CI
- **Solution**: Use `.nvmrc` to pin Node version, check global dependencies

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Linting enforced (ESLint/Biome)
- [ ] Tests run with coverage reporting
- [ ] Coverage threshold met (≥80%)
- [ ] Security scanning enabled (npm audit, CodeQL)
- [ ] Dependabot configured for updates
- [ ] Build artifacts generated and versioned
- [ ] Deployment to at least one environment works
- [ ] Environment secrets properly configured
- [ ] Smoke tests validate deployment health
- [ ] Rollback procedure documented
- [ ] Performance budgets tracked
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

