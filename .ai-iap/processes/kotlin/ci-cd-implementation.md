# CI/CD Implementation Process - Kotlin

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Kotlin applications

---

## Prerequisites

> **BEFORE starting**:
> - Working Kotlin application (1.8+ recommended)
> - Git repository with remote (GitHub)
> - Gradle configured (Kotlin DSL preferred)
> - Tests exist (JUnit 5, Kotest, MockK)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `kotlin.yml` or `gradle.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - Java/Kotlin version matrix (JDK 11, 17, 21)
> - Setup with actions/setup-java@v3
> - Gradle caching (~/.gradle/caches, ~/.gradle/wrapper)
> - Build command (`gradle build`)
> - Run tests with JUnit/Kotest
> - Collect coverage with JaCoCo or Kover

> **NEVER**:
> - Skip tests (`-x test`)
> - Use outdated Kotlin/JVM versions
> - Ignore compiler warnings
> - Commit Gradle wrapper without verification

**Key Workflow Structure**:
- Trigger: push (main/develop), pull_request
- Jobs: lint → test → build
- Setup: actions/setup-java@v3 with Kotlin
- Cache: Gradle dependencies

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Use Kover (Kotlin-first) or JaCoCo
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**Kover Configuration**:
```kotlin
// build.gradle.kts
plugins {
    id("org.jetbrains.kotlinx.kover") version "0.7.4"
}

kover {
    report {
        defaults {
            xml { onCheck = true }
            html { onCheck = true }
        }
    }
}
```

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic Kotlin build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed across JDK versions
> - Tests execute with results
> - Coverage report generated
> - Cache working (check run times)

---

## Phase 2: Code Quality & Security

### Branch Strategy
```
main → ci/quality-security
```

### 2.1 Code Quality Analysis

> **ALWAYS include**:
> - ktlint for linting (formatting + style)
> - detekt for static analysis
> - Fail build on violations

> **NEVER**:
> - Suppress warnings globally
> - Skip linter configuration
> - Allow critical issues in new code

**ktlint Configuration**:
```kotlin
// build.gradle.kts
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "11.6.1"
}

ktlint {
    version.set("1.0.1")
    android.set(false) // or true for Android
}
```

**detekt Configuration**:
```kotlin
// build.gradle.kts
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.4"
}

detekt {
    buildUponDefaultConfig = true
    config.setFrom("$projectDir/detekt.yml")
}
```

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - OWASP Dependency-Check or Snyk
> - Fail on known vulnerabilities (CVSS ≥7)

> **Dependabot Config**:
> - Package ecosystem: gradle
> - Schedule: weekly
> - Open PR limit: 5

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure languages: kotlin (or java for Kotlin/JVM)
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud/SonarQube integration
> - Snyk for vulnerability scanning

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml build.gradle.kts
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - ktlint and detekt run during CI
> - Violations cause build failures
> - Dependabot creates update PRs
> - CodeQL scan completes
> - Vulnerabilities reported

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
> - Store secrets per environment (DB credentials, API keys)
> - Use Ktor config files or Spring profiles

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Dev: auto-deploy on feature branches

### 3.2 Build & Package Artifacts

> **ALWAYS**:
> - Package as JAR (`gradle shadowJar` for fat JAR)
> - Version artifacts (version in build.gradle.kts)
> - Upload artifacts with retention policy
> - Create executable JAR with main class

> **NEVER**:
> - Include local.properties in artifacts
> - Package without optimization
> - Ship test dependencies

**Gradle Package**:
```bash
gradle shadowJar --no-daemon
# Output: build/libs/*-all.jar
```

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

**AWS (Elastic Beanstalk / ECS / Lambda)**:
- Use aws-actions/configure-aws-credentials
- Upload JAR to S3
- Deploy to Elastic Beanstalk or ECS

**Azure (App Service / Container Apps / Functions)**:
- Use azure/webapps-deploy@v2
- Upload JAR via Azure CLI
- Deploy to Azure Spring Apps

**Google Cloud (App Engine / Cloud Run)**:
- Use google-github-actions/setup-gcloud
- Deploy to App Engine or Cloud Run (containerized)

**Docker Registry**:
- Build Dockerfile (multi-stage: Gradle build → JRE runtime)
- Push to Docker Hub, GHCR, ECR, GCR
- Tag with git SHA + semver

**Android (Google Play)**:
- Build APK: `gradle assembleRelease`
- Build AAB: `gradle bundleRelease`
- Sign with keystore (stored as secret)
- Upload to Google Play Console

### 3.4 Database Migrations

> **ALWAYS**:
> - Use Flyway or Liquibase (or Exposed migrations)
> - Run migrations before app deployment
> - Test migrations in staging first
> - Version control all migration scripts

> **NEVER**:
> - Run migrations on app start in production
> - Skip migration testing
> - Deploy app before migrations complete

**Flyway Commands**:
```bash
gradle flywayMigrate -Dflyway.url=$DB_URL
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint (`/health` or `/actuator/health`)
> - Database connectivity check
> - Cache/Redis connectivity check
> - External API integration check

> **NEVER**:
> - Run full E2E tests in deployment job
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
> - JAR packaged correctly
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
> - kotlinx-benchmark for micro-benchmarks
> - Gatling or k6 for load testing
> - Track response times and memory usage
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use Testcontainers
> - Run on schedule (nightly) + release tags
> - Separate test database

> **NEVER**:
> - Use real production databases
> - Skip cleanup after tests
> - Run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Use semantic-release or Gradle release plugin
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish to Maven Central (if library)

### 4.4 Maven Central Publishing

> **If creating libraries**:
> - Configure GPG signing
> - Publish to OSSRH (Sonatype)
> - Include sources and Dokka documentation
> - Validate POM metadata

> **ALWAYS**:
> - Set group, artifactId, version
> - Include license, developers, SCM
> - Sign artifacts with GPG key

### 4.5 Notifications

> **ALWAYS**:
> - Slack/Teams webhook on deploy success/failure
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
> - Maven Central publish works (if applicable)
> - Notifications received

---

## Framework-Specific Notes

### Ktor
- Build: `gradle shadowJar` (fat JAR with embedded server)
- Engine: Netty, CIO, or Jetty
- Health: custom `/health` endpoint
- Fast startup, lightweight

### Spring Boot (Kotlin)
- Build: `gradle bootJar`
- Kotlin DSL for configuration
- Health: `/actuator/health`
- Coroutines support

### Android
- Build APK: `gradle assembleRelease`
- Build AAB: `gradle bundleRelease` (required for Play Store)
- Sign with release keystore
- ProGuard/R8 for minification

### Exposed (ORM)
- Migrations with Flyway or custom scripts
- Transaction blocks in code
- Type-safe SQL DSL

---

## Common Issues & Solutions

### Issue: Gradle build fails with "daemon not found"
- **Solution**: Use `--no-daemon` flag in CI

### Issue: Kotlin compiler OOM error
- **Solution**: Increase Gradle heap: `org.gradle.jvmargs=-Xmx4g`

### Issue: Tests pass locally but fail in CI
- **Solution**: Check timezone, locale, coroutine dispatchers (use TestDispatchers)

### Issue: Android build fails with signing error
- **Solution**: Verify keystore secret encoding (base64), check alias and passwords

### Issue: Coverage reports not generated
- **Solution**: Ensure Kover/JaCoCo plugin configured, run `koverXmlReport` or `verify`

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Kotlin/JDK version pinned
- [ ] Builds succeed without warnings
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality tools enabled (ktlint, detekt)
- [ ] Security scanning enabled (CodeQL, Dependabot, OWASP)
- [ ] Dependencies up to date
- [ ] Artifacts packaged with correct versioning
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

