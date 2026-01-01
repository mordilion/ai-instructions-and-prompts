# Security Scanning Setup (Kotlin)

> **Goal**: Establish automated security vulnerability scanning in existing Kotlin projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **OWASP Dependency-Check** ⭐ | Dependency | Free, comprehensive | Gradle plugin |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | CLI or plugin |
| **Detekt** ⭐ | SAST | Code quality + security | Gradle plugin |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### OWASP Dependency-Check (Gradle)

```kotlin
// build.gradle.kts
plugins {
    id("org.owasp.dependencycheck") version "9.0.0"
}

dependencyCheck {
    failBuildOnCVSS = 7.0f
    suppressionFile = "dependency-check-suppressions.xml"
    analyzers.apply {
        assemblyEnabled = false
    }
}
```

**Suppressions** (`dependency-check-suppressions.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
  <suppress>
    <notes>False positive - not exploitable in our context</notes>
    <cve>CVE-2023-12345</cve>
  </suppress>
</suppressions>
```

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test Gradle project
snyk test --file=build.gradle.kts

# Monitor (CI/CD)
snyk monitor
```

---

## Phase 3: SAST Configuration

### Detekt with Security Rules

```kotlin
// build.gradle.kts
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.0"
}

detekt {
    buildUponDefaultConfig = true
    allRules = false
    config.setFrom("$projectDir/detekt.yml")
}

dependencies {
    detektPlugins("io.gitlab.arturbosch.detekt:detekt-formatting:1.23.0")
}
```

**Configuration** (`detekt.yml`):
```yaml
potential-bugs:
  active: true
  UnsafeCast:
    active: true
  UnsafeCallOnNullableType:
    active: true

security:
  active: true
  HardcodedPassword:
    active: true
    ignoreVariableNames: ['mockPassword', 'testPassword']
```

### Semgrep

```bash
# Install
pip install semgrep

# Run with Kotlin security rules
semgrep --config=p/kotlin src/

# CI mode
semgrep ci
```

---

## Phase 4: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 0 * * 1' # Weekly

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version-file: '.java-version'
          cache: 'gradle'
      
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
      
      - name: Run OWASP Dependency-Check
        run: ./gradlew dependencyCheckAnalyze
        continue-on-error: true
      
      - name: Run Detekt
        run: ./gradlew detekt
      
      - name: Run Snyk
        uses: snyk/actions/gradle@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Upload Dependency-Check report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: dependency-check-report
          path: build/reports/dependency-check-report.html
      
      - name: Upload Detekt report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: detekt-report
          path: build/reports/detekt/
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Dependency-Check slow** | Cache NVD database, use `--noupdate` locally |
| **Detekt false positives** | Add to `detekt.yml` ignore list with justification |
| **Snyk authentication fails** | Use `snyk auth` or set `SNYK_TOKEN` |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable Kotlin version
> **ALWAYS**: Update dependencies monthly
> **NEVER**: Commit secrets (use environment variables, vault)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] OWASP Dependency-Check or Snyk configured?
- [ ] Detekt with security rules installed?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] Suppressions documented with justification?
- [ ] Weekly/monthly security scans scheduled?
- [ ] Secrets excluded from repository?
- [ ] Team trained on vulnerability triage?
- [ ] Kotlin version up-to-date?
- [ ] Dependencies updated regularly?

---

## Security Checklist

**Dependencies:**
- [ ] OWASP Dependency-Check passing (CVSS < 7)
- [ ] Snyk test passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] Detekt security rules enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries, Exposed ORM)
- [ ] Null safety enforced

**CI/CD:**
- [ ] Security scans on every PR
- [ ] Weekly scheduled scans
- [ ] Fail build on high/critical issues

---

## Tools Comparison

| Tool | Cost | Coverage | CI/CD | Best For |
|------|------|----------|-------|----------|
| OWASP Dependency-Check | Free | Dependencies | ✅ | Basic scanning |
| Snyk | Free/Paid | Deps + Code | ✅ | Comprehensive |
| Detekt | Free | Code patterns | ✅ | Static analysis |
| SonarQube | Free/Paid | Comprehensive | ✅ | Enterprise |
| Semgrep | Free/Paid | Custom rules | ✅ | Advanced |

