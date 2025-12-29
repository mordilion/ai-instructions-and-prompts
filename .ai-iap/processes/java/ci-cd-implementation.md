# CI/CD Implementation Process - Java

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Java applications

---

## Prerequisites

> **BEFORE starting**:
> - Working Java application (Java 11+ recommended)
> - Git repository with remote (GitHub)
> - Build tool configured (Maven or Gradle)
> - Tests exist (JUnit 5, Mockito)

---

## Phase 1: Basic CI Pipeline

### Branch Strategy
```
main → ci/basic-pipeline
```

### 1.1 Create Workflow Directory

> **ALWAYS**:
> - Create `.github/workflows/` directory
> - Name workflow file `maven.yml` or `gradle.yml`

### 1.2 Basic Build & Test Workflow

> **ALWAYS include**:
> - Java version matrix (11, 17, 21)
> - Setup with actions/setup-java@v3
> - Dependency caching (Maven: ~/.m2, Gradle: ~/.gradle)
> - Build command (mvn clean install or gradle build)
> - Run tests with JUnit
> - Collect coverage with JaCoCo

> **NEVER**:
> - Skip tests in CI (`mvn install -DskipTests`)
> - Use outdated Java versions in production
> - Ignore compiler warnings
> - Commit wrapper binaries (mvnw, gradlew) without verification

**Maven Workflow**:
- Restore: automatic with actions/setup-java cache
- Build: `mvn clean install -B`
- Test: included in install phase
- Verify: `mvn verify -B`

**Gradle Workflow**:
- Restore: `gradle dependencies`
- Build: `gradle build`
- Test: `gradle test`
- Validate: `gradle check`

### 1.3 Coverage Reporting

> **ALWAYS**:
> - Use JaCoCo plugin
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**JaCoCo Configuration**:
- Maven: jacoco-maven-plugin
- Gradle: jacoco plugin
- Reports: XML for CI, HTML for review

### 1.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/workflows/
> git commit -m "ci: add basic Java build and test pipeline"
> git push origin ci/basic-pipeline
> ```

> **Verify**:
> - Pipeline runs on push
> - Builds succeed across Java versions
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
> - Checkstyle (google_checks.xml or sun_checks.xml)
> - PMD for static analysis
> - SpotBugs for bug detection
> - Fail build on violations

> **NEVER**:
> - Suppress warnings globally
> - Skip linter configuration
> - Allow critical bugs in new code

**Maven Plugins**:
- maven-checkstyle-plugin
- maven-pmd-plugin
- spotbugs-maven-plugin

**Gradle Plugins**:
- checkstyle
- pmd
- com.github.spotbugs

### 2.2 Dependency Security Scanning

> **ALWAYS include**:
> - Dependabot configuration (`.github/dependabot.yml`)
> - OWASP Dependency-Check
> - Fail on known vulnerabilities (CVSS ≥7)

> **Dependabot Config**:
> - Package ecosystem: maven or gradle
> - Schedule: weekly
> - Open PR limit: 5

**Dependency Check**:
- Maven: `dependency-check-maven`
- Gradle: `org.owasp.dependencycheck`
- Generate reports, fail on high severity

### 2.3 Static Analysis (SAST)

> **ALWAYS**:
> - Add CodeQL analysis (`.github/workflows/codeql.yml`)
> - Configure language: java
> - Run on schedule (weekly) + push to main
> - Review alerts in GitHub Security tab

> **Optional but recommended**:
> - SonarCloud/SonarQube integration
> - Snyk for vulnerability scanning

### 2.4 Commit & Verify

> **Git workflow**:
> ```
> git add .github/dependabot.yml .github/workflows/codeql.yml pom.xml
> git commit -m "ci: add code quality and security scanning"
> git push origin ci/quality-security
> ```

> **Verify**:
> - Checkstyle, PMD, SpotBugs run
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
> - Use Spring Profiles or application.properties per environment

> **Protection Rules**:
> - Production: require approval, restrict to main branch
> - Staging: auto-deploy on merge to develop
> - Dev: auto-deploy on feature branches

### 3.2 Build & Package Artifacts

> **ALWAYS**:
> - Package as JAR/WAR (`mvn package` or `gradle bootJar`)
> - Version artifacts (Maven: version in pom.xml, Gradle: version in build.gradle)
> - Upload artifacts with retention policy
> - Create executable JAR (Spring Boot, fat JAR)

> **NEVER**:
> - Include application-local.properties in artifacts
> - Package without optimization
> - Ship test dependencies

**Maven Package**:
```bash
mvn clean package -DskipTests -B
# Output: target/*.jar or target/*.war
```

**Gradle Package**:
```bash
gradle bootJar --no-daemon
# Output: build/libs/*.jar
```

### 3.3 Deployment Jobs

> **Platform-specific** (choose one or more):

**AWS (Elastic Beanstalk / ECS / Lambda)**:
- Use aws-actions/configure-aws-credentials
- Upload JAR to S3
- Deploy to Elastic Beanstalk or ECS
- Lambda: package with AWS Lambda Java runtime

**Azure (App Service / Container Apps)**:
- Use azure/webapps-deploy@v2
- Upload JAR via FTP or Azure CLI
- Deploy to Azure Spring Apps (optimized for Spring Boot)

**Google Cloud (App Engine / Cloud Run)**:
- Use google-github-actions/setup-gcloud
- Deploy JAR to App Engine standard/flexible
- Cloud Run: containerize JAR and deploy

**Docker Registry**:
- Build Dockerfile (multi-stage: Maven/Gradle build → JRE runtime)
- Push to Docker Hub, GHCR, ECR, GCR
- Tag with git SHA + semver

**Heroku**:
- Use Procfile: `web: java -jar target/*.jar`
- Deploy with Heroku CLI or GitHub integration

### 3.4 Database Migrations

> **ALWAYS**:
> - Use Flyway or Liquibase
> - Run migrations before app deployment
> - Test migrations in staging first
> - Version control all migration scripts

> **NEVER**:
> - Run migrations on app start in production (security risk)
> - Skip migration testing
> - Deploy app before migrations complete

**Flyway/Liquibase Commands**:
```bash
# Flyway
mvn flyway:migrate -Dflyway.url=$DB_URL

# Liquibase
mvn liquibase:update -Dliquibase.url=$DB_URL
```

### 3.5 Smoke Tests Post-Deploy

> **ALWAYS include**:
> - Health check endpoint (`/actuator/health` for Spring Boot)
> - Database connectivity check
> - Cache/Redis connectivity
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
> - JMH (Java Microbenchmark Harness) for micro-benchmarks
> - Load testing with Gatling, JMeter, or k6
> - Track response times and memory usage
> - Fail if performance degrades >10%

### 4.2 Integration Testing

> **ALWAYS**:
> - Separate workflow (`integration-tests.yml`)
> - Use Testcontainers for database/Redis
> - Spring Boot: @SpringBootTest with test profiles
> - Run on schedule (nightly) + release tags

> **NEVER**:
> - Use real production databases
> - Skip cleanup after tests
> - Run on every PR (too slow)

### 4.3 Release Automation

> **Semantic Versioning**:
> - Maven: maven-release-plugin
> - Gradle: semantic-release or nebula-release
> - Generate CHANGELOG from conventional commits
> - Create GitHub Releases with notes
> - Publish to Maven Central (if library)

### 4.4 Maven Central Publishing

> **If creating libraries**:
> - Configure GPG signing
> - Publish to OSSRH (Sonatype)
> - Include sources and javadoc JARs
> - Validate POM metadata

> **ALWAYS**:
> - Set groupId, artifactId, version
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

### Spring Boot
- Package: `mvn spring-boot:build-image` for OCI image
- Health: `/actuator/health`
- Metrics: `/actuator/metrics` (Prometheus, Micrometer)
- Profile: `-Dspring.profiles.active=production`

### Quarkus
- Native build: `mvn package -Pnative` (GraalVM)
- JVM build: `mvn package` (uber-jar)
- Dev mode: not for production
- Extremely fast startup (ideal for serverless)

### Micronaut
- Build: `gradle shadowJar` (fat JAR)
- Native: GraalVM native-image
- Health: `/health`
- Lightweight and cloud-native

### Jakarta EE / Java EE
- Package as WAR for application servers (WildFly, Payara)
- Deploy to server using CLI or web console
- Use MicroProfile for cloud-native features

### Android
- Build APK: `gradle assembleRelease`
- Build AAB: `gradle bundleRelease`
- Sign with keystore
- Upload to Google Play Console

---

## Common Issues & Solutions

### Issue: Maven dependencies not resolving in CI
- **Solution**: Check settings.xml for auth, commit .mvn/wrapper files

### Issue: Gradle build fails with "daemon not found"
- **Solution**: Use `--no-daemon` flag in CI

### Issue: Tests pass locally but fail in CI
- **Solution**: Check timezone, locale, file paths (absolute vs relative)

### Issue: Deployment fails with "port already in use"
- **Solution**: Gracefully stop old process before starting new one

### Issue: Coverage reports not generated
- **Solution**: Ensure JaCoCo plugin configured, run `verify` phase (Maven)

---

## AI Self-Check

Before completing this process, verify:

- [ ] CI pipeline runs on push and PR
- [ ] Java version pinned (in workflow)
- [ ] Builds succeed without warnings
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality tools enabled (Checkstyle, PMD, SpotBugs)
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

