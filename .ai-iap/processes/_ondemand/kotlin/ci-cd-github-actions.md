# CI/CD Implementation Process - Kotlin (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Kotlin applications

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, or Jenkins, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working Kotlin application
> - Git repository with remote (GitHub)
> - Gradle or Maven configured
> - Tests exist (JUnit 5, Kotest, MockK)
> - Kotlin & JVM version defined in build.gradle.kts

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - JVM version from project (read from build.gradle.kts or toolchain config)
> - Kotlin version from build.gradle.kts
> - Setup with actions/setup-java@v3
> - Gradle caching (~/.gradle, ~/.konan for Kotlin/Native)
> - Build: `gradle build` or `mvn clean install`
> - Run tests with JUnit 5 or Kotest
> - Collect coverage with JaCoCo or Kover

> **Version Strategy**:
> - **Best**: Use Gradle toolchain to specify JDK version
> - **Good**: Read from build.gradle.kts `jvmToolchain(17)`
> - **Matrix**: Test against multiple JVM versions if library

> **NEVER**:
> - Skip tests with `-x test`
> - Use outdated Kotlin/JVM versions
> - Ignore compiler warnings
> - Run with Gradle daemon in CI (use `--no-daemon`)

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Cache: Gradle/Maven dependencies
- Kotlin compilation cache

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Use JaCoCo or Kover (Kotlin-specific coverage)
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Coverage Commands**:
```bash
gradle test jacocoTestReport
# Or with Kover: gradle koverXmlReport
```

**Verify**: Pipeline runs, builds succeed, tests execute, coverage report generated, Gradle cache working

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: ktlint, detekt, Dependabot, OWASP Dependency-Check/Snyk, CodeQL (java), fail on violations
> **NEVER**: Suppress warnings globally

**Gradle Plugins**: `org.jlleitschuh.gradle.ktlint`, `io.gitlab.arturbosch.detekt`

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "gradle"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: ktlint/detekt pass, Dependabot creates PRs, CodeQL completes

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant environments/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: dev, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment
> - Use Spring profiles or environment-specific configs

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy on merge to develop), Dev (auto-deploy on feature branches)

### 3.2 Build & Package Artifacts

> **ALWAYS**:
> - Build JAR: `gradle shadowJar` or `gradle bootJar` (Spring Boot)
> - Version artifacts (Gradle: version in build.gradle.kts)
> - Upload artifacts with retention policy
> - Create fat JAR or native image (Kotlin/Native, GraalVM)

> **NEVER**: Include test dependencies, package without optimization, ship debug artifacts

**Package Commands**:
```bash
gradle shadowJar --no-daemon  # Fat JAR
# Or: gradle bootJar for Spring Boot
# Or: gradle nativeCompile for GraalVM native
```

### 3.3 Deployment & Verification

**Platforms**: AWS (Lambda/ECS), Azure, Google Cloud, Docker, Kubernetes  
**Migrations**: Flyway/Liquibase, run before deployment (`gradle flywayMigrate`), test in staging  
**Smoke Tests**: Health check, DB/Redis connectivity, external services  
**NEVER**: Auto-run migrations on app start in production

**Verify**: Deployment succeeds, migrations applied, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**Performance**: kotlinx-benchmark, Gatling/k6, fail if degrades >10%  
**Integration**: Separate workflow, Testcontainers, `@SpringBootTest`, run nightly  
**Release**: gradle-git-versioning/nebula-release, CHANGELOG, GitHub Releases, Maven Central (libraries)  
**NEVER**: Use production DBs, run integration on every PR

### 4.2 Notifications

> **ALWAYS**: Slack/Teams webhook, GitHub Status Checks, Email for security alerts

**Verify**: Benchmarks run, integration tests pass, releases created automatically, Maven Central publish works (if applicable), notifications received

---

## Framework-Specific Notes

| Framework | Notes |
|-----------|-------|
| **Spring Boot (Kotlin)** | Build: `gradle bootJar`; Health: `/actuator/health`; Use Kotlin DSL for configs |
| **Ktor** | Build: `gradle shadowJar`; Health: custom route; Lightweight, async-first |
| **Android** | Build APK: `gradle assembleRelease`; Sign with keystore; Upload to Play Store |
| **Kotlin Multiplatform** | Build for JVM, JS, Native targets; Test on all platforms; Use expect/actual |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Gradle build fails with "daemon not found"** | Always use `--no-daemon` in CI |
| **Kotlin compilation slow in CI** | Enable Gradle build cache, use parallel execution |
| **Tests pass locally but fail in CI** | Check JVM version match, timezone, locale |
| **Coverage not collected** | Ensure JaCoCo/Kover plugin configured, run test + report tasks |
| **Want to use GitLab CI / Azure DevOps** | GitLab: Use `gradle:jdk17` image; Azure: Use `Gradle@2` task - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] JVM & Kotlin versions pinned
- [ ] Builds succeed without warnings
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality enforced (ktlint, detekt)
- [ ] Security scanning enabled (Dependabot, CodeQL)
- [ ] JAR packaged with correct versioning
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
