# Security Scanning Setup (Java)

> **Goal**: Establish automated security vulnerability scanning in existing Java projects using SAST/DAST tools

## Phase 1: Choose Security Scanning Tools

> **ALWAYS**: Use at least one SAST (Static) tool
> **ALWAYS**: Run security scans in CI/CD pipeline
> **NEVER**: Skip dependency vulnerability scanning
> **NEVER**: Ignore high/critical vulnerabilities

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **OWASP Dependency-Check** ⭐ | Dependency | Free, comprehensive | Maven/Gradle plugin |
| **Snyk** ⭐ | SAST + Dependencies | Free for open-source | CLI or plugin |
| **SpotBugs + Find Security Bugs** | SAST | Code patterns | Maven/Gradle plugin |
| **SonarQube/SonarCloud** | SAST | Comprehensive | Cloud or self-hosted |
| **Checkmarx** | SAST | Enterprise | Commercial |
| **Semgrep** | SAST | Custom rules | `pip install semgrep` |

---

## Phase 2: Dependency Scanning Setup

### OWASP Dependency-Check (Maven)

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>org.owasp</groupId>
      <artifactId>dependency-check-maven</artifactId>
      <version>9.0.0</version>
      <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

### OWASP Dependency-Check (Gradle)

```groovy
// build.gradle
plugins {
    id 'org.owasp.dependencycheck' version '9.0.0'
}

dependencyCheck {
    failBuildOnCVSS = 7
    suppressionFile = 'dependency-check-suppressions.xml'
    analyzers {
        assemblyEnabled = false
    }
}
```

### Snyk Setup

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Test Maven project
snyk test --file=pom.xml

# Test Gradle project
snyk test --file=build.gradle

# Monitor (CI/CD)
snyk monitor
```

---

## Phase 3: SAST Configuration

### SpotBugs + Find Security Bugs (Maven)

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>com.github.spotbugs</groupId>
      <artifactId>spotbugs-maven-plugin</artifactId>
      <version>4.8.3.0</version>
      <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <plugins>
          <plugin>
            <groupId>com.h3xstream.findsecbugs</groupId>
            <artifactId>findsecbugs-plugin</artifactId>
            <version>1.12.0</version>
          </plugin>
        </plugins>
      </configuration>
      <executions>
        <execution>
          <goals>
            <goal>check</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

### SpotBugs + Find Security Bugs (Gradle)

```groovy
// build.gradle
plugins {
    id 'com.github.spotbugs' version '6.0.0'
}

spotbugs {
    effort = 'max'
    reportLevel = 'low'
}

dependencies {
    spotbugsPlugins 'com.h3xstream.findsecbugs:findsecbugs-plugin:1.12.0'
}
```

**Suppressions** (`spotbugs-exclude.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
  <!-- Suppress false positive -->
  <Match>
    <Class name="com.example.SafeClass"/>
    <Bug pattern="SQL_INJECTION_SPRING_JDBC"/>
  </Match>
</FindBugsFilter>
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
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ steps.read-version.outputs.version }}
          cache: 'maven'
      
      - name: Read Java version from pom.xml
        id: read-version
        run: echo "version=$(mvn help:evaluate -Dexpression=maven.compiler.target -q -DforceStdout)" >> $GITHUB_OUTPUT
      
      - name: Run OWASP Dependency-Check
        run: mvn dependency-check:check
        continue-on-error: true
      
      - name: Run SpotBugs
        run: mvn spotbugs:check
      
      - name: Run Snyk
        uses: snyk/actions/maven@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
      
      - name: Upload Dependency-Check report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: dependency-check-report
          path: target/dependency-check-report.html
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Dependency-Check slow** | Cache NVD database, use `--noupdate` locally |
| **SpotBugs false positives** | Add to `spotbugs-exclude.xml` with justification |
| **Snyk authentication fails** | Use `snyk auth` or set `SNYK_TOKEN` |
| **CI fails on vulnerabilities** | Use `continue-on-error: true` initially, then enforce |

---

## Best Practices

> **ALWAYS**: Scan dependencies before every release
> **ALWAYS**: Fix high/critical vulnerabilities within 7 days
> **ALWAYS**: Use latest stable Java LTS version
> **ALWAYS**: Update dependencies monthly
> **NEVER**: Commit secrets (use environment variables, vault)
> **NEVER**: Disable security checks without documentation
> **NEVER**: Use outdated dependencies in production

---

## AI Self-Check

- [ ] OWASP Dependency-Check or Snyk configured?
- [ ] SpotBugs with Find Security Bugs installed?
- [ ] Security scanning in CI/CD pipeline?
- [ ] High/critical vulnerabilities addressed?
- [ ] Suppressions documented with justification?
- [ ] Weekly/monthly security scans scheduled?
- [ ] Secrets excluded from repository?
- [ ] Team trained on vulnerability triage?
- [ ] Java version up-to-date (LTS)?
- [ ] Dependencies updated regularly?

---

## Security Checklist

**Dependencies:**
- [ ] OWASP Dependency-Check passing (CVSS < 7)
- [ ] Snyk test passing
- [ ] All dependencies up-to-date (within 6 months)

**Code:**
- [ ] SpotBugs security rules enabled
- [ ] No hardcoded secrets
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (PreparedStatement, JPA)
- [ ] XSS prevention (OWASP Java Encoder)

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
| SpotBugs + FSB | Free | Code patterns | ✅ | Static analysis |
| SonarQube | Free/Paid | Comprehensive | ✅ | Enterprise |
| Semgrep | Free/Paid | Custom rules | ✅ | Advanced |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up security vulnerability scanning

### Complete Implementation Prompt

```
CONTEXT:
You are configuring security vulnerability scanning for this project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for known vulnerabilities
- ALWAYS integrate with CI/CD pipeline
- ALWAYS configure to fail on high/critical vulnerabilities
- ALWAYS keep scanning tools updated

IMPLEMENTATION STEPS:

1. CHOOSE SCANNING TOOLS:
   Select tools for the language (see Tech Stack section):
   - Dependency scanning (npm audit, safety, etc.)
   - SAST (CodeQL, Snyk, SonarQube)
   - Container scanning (Trivy, Grype)

2. CONFIGURE DEPENDENCY SCANNING:
   Enable dependency vulnerability scanning
   Set severity thresholds
   Configure auto-fix for known vulnerabilities

3. CONFIGURE SAST:
   Set up static application security testing
   Configure scan rules
   Integrate with CI/CD

4. CONFIGURE CONTAINER SCANNING:
   Scan Docker images for vulnerabilities
   Fail builds on critical issues

5. SET UP MONITORING:
   Configure security alerts
   Set up regular scanning schedule
   Create remediation workflow

DELIVERABLE:
- Dependency scanning active
- SAST integrated
- Container scanning configured
- Security alerts enabled

START: Choose scanning tools and configure dependency scanning.
```
