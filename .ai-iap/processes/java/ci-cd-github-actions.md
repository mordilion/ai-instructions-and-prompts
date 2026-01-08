# CI/CD Implementation Process - Java (GitHub Actions)

> **Purpose**: Establish comprehensive CI/CD pipeline with GitHub Actions for Java applications

> **Platform**: This guide is for **GitHub Actions**. For GitLab CI, Azure DevOps, CircleCI, or Jenkins, adapt the workflow syntax accordingly.

---

## Prerequisites

> **BEFORE starting**:
> - Working Java application
> - Git repository with remote (GitHub)
> - Build tool configured (Maven or Gradle)
> - Tests exist (JUnit 5, Mockito)
> - Java version defined in pom.xml or build.gradle

---

## Workflow Adaptation

> **IMPORTANT**: Phases below focus on OBJECTIVES. Use your team's workflow.

---

## Phase 1: Basic CI Pipeline

**Objective**: Establish foundational CI pipeline with build, lint, and test automation

### 1.1 Basic Build & Test Workflow

> **ALWAYS include**:
> - Java version from project (read from pom.xml `<java.version>` or build.gradle `sourceCompatibility`)
> - Setup with actions/setup-java@v3
> - Dependency caching (Maven: ~/.m2, Gradle: ~/.gradle)
> - Build command (mvn clean install or gradle build)
> - Run tests with JUnit
> - Collect coverage with JaCoCo

> **Version Strategy**:
> - **Best**: Read from pom.xml `<properties><java.version>` or build.gradle `sourceCompatibility`
> - **Good**: Use toolchain configuration (Maven Toolchains, Gradle Toolchains)
> - **Matrix**: Test against multiple LTS versions (11, 17, 21) if library/framework

> **NEVER**:
> - Skip tests in CI (`mvn install -DskipTests`)
> - Use outdated Java versions in production
> - Ignore compiler warnings
> - Commit wrapper binaries (mvnw, gradlew) without verification

**Maven Workflow**: Restore (automatic with actions/setup-java cache), Build (`mvn clean install -B`), Verify (`mvn verify -B`)

**Gradle Workflow**: Restore (`gradle dependencies`), Build (`gradle build`), Test (`gradle test`), Validate (`gradle check`)

### 1.2 Coverage Reporting

> **ALWAYS**:
> - Use JaCoCo plugin
> - Generate XML/HTML reports
> - Upload to Codecov/Coveralls
> - Set minimum coverage threshold (80%+)

**JaCoCo Configuration**: Maven (jacoco-maven-plugin), Gradle (jacoco plugin), Reports (XML for CI, HTML for review)

**Verify**: Pipeline runs, builds succeed across Java versions, tests execute with results, coverage report generated, cache working

---

## Phase 2: Code Quality & Security

**Objective**: Add code quality and security scanning to CI pipeline

### 2.1 Code Quality & Security

> **ALWAYS**: Checkstyle, PMD, SpotBugs, Dependabot, OWASP Dependency-Check, CodeQL (java), fail on violations
> **NEVER**: Suppress warnings globally

**Plugins**: Maven (checkstyle/pmd/spotbugs), Gradle (checkstyle/pmd/spotbugs)

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "maven" # or "gradle"
    directory: "/"
    schedule: { interval: "weekly" }
```

**Verify**: All tools run, violations fail build, Dependabot creates PRs, CodeQL completes

---

## Phase 3: Deployment Pipeline

**Objective**: Automate app deployment to relevant environments/platforms

### 3.1 Environment Configuration

> **ALWAYS**:
> - Define environments: dev, staging, production
> - Use GitHub Environments with protection rules
> - Store secrets per environment (DB credentials, API keys)
> - Use Spring Profiles or application.properties per environment

**Protection Rules**: Production (require approval, restrict to main), Staging (auto-deploy on merge to develop), Dev (auto-deploy on feature branches)

### 3.2 Build & Package Artifacts

> **ALWAYS**:
> - Package as JAR/WAR (`mvn package` or `gradle bootJar`)
> - Version artifacts (Maven: version in pom.xml, Gradle: version in build.gradle)
> - Upload artifacts with retention policy
> - Create executable JAR (Spring Boot, fat JAR)

> **NEVER**: Include application-local.properties in artifacts, package without optimization, ship test dependencies

**Maven Package**: `mvn clean package -DskipTests -B` → Output: target/*.jar or target/*.war

**Gradle Package**: `gradle bootJar --no-daemon` → Output: build/libs/*.jar

### 3.3 Deployment & Verification

**Platforms**: AWS (Beanstalk/ECS/Lambda), Azure, Google Cloud (App Engine/Run), Docker, Heroku  
**Migrations**: Flyway/Liquibase, run before deployment (`mvn flyway:migrate`), test in staging  
**Smoke Tests**: `/actuator/health`, DB/Redis connectivity, external APIs  
**NEVER**: Auto-run migrations on app start in production

**Verify**: Deployment succeeds, migrations applied, smoke tests pass

---

## Phase 4: Advanced Features

**Objective**: Add advanced CI/CD capabilities (integration tests, release automation)

### 4.1 Advanced Testing & Automation

**Performance**: JMH, Gatling/JMeter/k6, fail if degrades >10%  
**Integration**: Separate workflow, Testcontainers, `@SpringBootTest`, run nightly  
**Release**: maven-release-plugin/semantic-release, CHANGELOG, GitHub Releases, Maven Central (libraries)  
**NEVER**: Use production DBs, run integration on every PR

### 4.2 Notifications

> **ALWAYS**: Slack/Teams webhook on deploy success/failure, GitHub Status Checks for PR reviews, Email notifications for security alerts

**Verify**: Benchmarks run and tracked, integration tests pass in isolation, releases created automatically, Maven Central publish works (if applicable), notifications received

---

## Framework-Specific Notes

| Framework | Notes |
|-----------|-------|
| **Spring Boot** | Package: `mvn spring-boot:build-image` for OCI image; Health: `/actuator/health`; Metrics: `/actuator/metrics` (Prometheus, Micrometer); Profile: `-Dspring.profiles.active=production` |
| **Quarkus** | Native build: `mvn package -Pnative` (GraalVM); JVM build: `mvn package` (uber-jar); Extremely fast startup (ideal for serverless) |
| **Micronaut** | Build: `gradle shadowJar` (fat JAR); Native: GraalVM native-image; Health: `/health`; Lightweight and cloud-native |
| **Jakarta EE / Java EE** | Package as WAR for application servers (WildFly, Payara); Deploy using CLI or web console; Use MicroProfile for cloud-native features |
| **Android** | Build APK: `gradle assembleRelease`; Build AAB: `gradle bundleRelease`; Sign with keystore; Upload to Google Play Console |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Maven dependencies not resolving in CI** | Check settings.xml for auth, commit .mvn/wrapper files |
| **Gradle build fails with "daemon not found"** | Use `--no-daemon` flag in CI |
| **Tests pass locally but fail in CI** | Check timezone, locale, file paths (absolute vs relative) |
| **Deployment fails with "port already in use"** | Gracefully stop old process before starting new one |
| **Coverage reports not generated** | Ensure JaCoCo plugin configured, run `verify` phase (Maven) |
| **Want to use Jenkins / GitLab CI / Azure DevOps** | Jenkins: Use Jenkinsfile with Maven/Gradle plugins; GitLab CI: Use `maven:3.9-eclipse-temurin-21` or `gradle:jdk21` image; Azure DevOps: Use `Maven@3` or `Gradle@2` tasks - core concepts remain same |

---

## AI Self-Check

- [ ] CI pipeline runs on push and PR
- [ ] Java version pinned (in workflow)
- [ ] Builds succeed without warnings
- [ ] All tests pass with coverage ≥80%
- [ ] Code quality tools enabled (Checkstyle, PMD, SpotBugs)
- [ ] Security scanning enabled (CodeQL, Dependabot, OWASP)
- [ ] Artifacts packaged with correct versioning
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
git checkout main
git merge ci/advanced
git tag -a v1.0.0-ci -m "CI/CD pipeline implemented"
git push origin main --tags
```

---

**Process Complete** ✅
