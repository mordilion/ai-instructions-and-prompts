# Kotlin Security Scanning - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up security scanning for Kotlin project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN SECURITY SCANNING
========================================

CONTEXT:
You are implementing security scanning for a Kotlin project.

CRITICAL REQUIREMENTS:
- ALWAYS scan dependencies for vulnerabilities
- ALWAYS integrate security checks in CI
- NEVER ignore critical vulnerabilities
- Use SAST tools (detekt + OWASP Dependency-Check + Snyk)

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - DEPENDENCY SCANNING
========================================

Add OWASP Dependency-Check to build.gradle.kts:

```kotlin
plugins {
    id("org.owasp.dependencycheck") version "9.0.7"
}

dependencyCheck {
    failBuildOnCVSS = 7.0f
}
```

Run:
```bash
./gradlew dependencyCheckAnalyze
```

Add to .github/workflows/security.yml:
```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 1'
  push:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v3
      with:
        java-version: '17'
    
    - name: Dependency Check
      run: ./gradlew dependencyCheckAnalyze
```

Deliverable: Dependency scanning active

========================================
PHASE 2 - SAST SCANNING
========================================

Configure detekt with security rules in build.gradle.kts:

```kotlin
detekt {
    buildUponDefaultConfig = true
    config.setFrom("$projectDir/config/detekt.yml")
}

dependencies {
    detektPlugins("io.gitlab.arturbosch.detekt:detekt-formatting:1.23.4")
}
```

Use Snyk:
```yaml
    - name: Run Snyk
      uses: snyk/actions/gradle@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

Deliverable: SAST scanning configured

========================================
PHASE 3 - SECRETS DETECTION
========================================

Add to GitHub Actions:

```yaml
    - name: Scan for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
```

Deliverable: Secrets scanning active

========================================
PHASE 4 - CODE SECURITY BEST PRACTICES
========================================

Implement security best practices:

```kotlin
// Use parameterized queries (Exposed)
import org.jetbrains.exposed.sql.select

val user = Users.select { Users.email eq email }.singleOrNull()

// Validate input
import javax.validation.constraints.*

data class UserDTO(
    @field:NotBlank
    @field:Size(min = 3, max = 50)
    @field:Pattern(regexp = "^[a-zA-Z0-9]+$")
    val username: String
)

// Hash passwords
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

val encoder = BCryptPasswordEncoder()
val hashedPassword = encoder.encode(password)

// Prevent XSS
import org.owasp.encoder.Encode

val safe = Encode.forHtml(userInput)

// Use HTTPS (Ktor)
import io.ktor.server.application.*
import io.ktor.server.plugins.httpsredirect.*

fun Application.module() {
    install(HttpsRedirect)
}
```

Deliverable: Security best practices implemented

========================================
BEST PRACTICES
========================================

- Use OWASP Dependency-Check
- Configure detekt for security rules
- Use Snyk for vulnerability detection
- Use parameterized queries (Exposed/JPA)
- Validate input with Bean Validation
- Hash passwords with BCrypt
- Sanitize output to prevent XSS
- Enforce HTTPS
- Keep dependencies up to date

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, SECURITY-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Set up OWASP Dependency-Check (Phase 1)
CONTINUE: Configure detekt (Phase 2)
CONTINUE: Add secrets detection (Phase 3)
CONTINUE: Implement security practices (Phase 4)
FINISH: Update all documentation files
REMEMBER: Never ignore critical vulnerabilities, document for catch-up
```

---

## Quick Reference

**What you get**: Automated security scanning with OWASP and detekt  
**Time**: 2 hours  
**Output**: Security CI workflow, SAST integration, best practices
