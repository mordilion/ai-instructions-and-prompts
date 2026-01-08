# Kotlin Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a Kotlin project.

CRITICAL REQUIREMENTS:
- ALWAYS use ktlint + detekt
- NEVER ignore warnings without justification
- Use .editorconfig for consistency
- Enforce in CI pipeline

========================================
PHASE 1 - KTLINT
========================================

Add to build.gradle.kts:
```kotlin
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "12.0.3"
}

ktlint {
    version.set("1.0.1")
    android.set(true)
    ignoreFailures.set(false)
}
```

Run:
```bash
./gradlew ktlintCheck

# Auto-fix
./gradlew ktlintFormat
```

Create .editorconfig:
```ini
[*.{kt,kts}]
indent_size = 4
insert_final_newline = true
max_line_length = 120
```

Deliverable: Ktlint configured

========================================
PHASE 2 - DETEKT
========================================

Add to build.gradle.kts:
```kotlin
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.4"
}

detekt {
    buildUponDefaultConfig = true
    config.setFrom("$projectDir/config/detekt.yml")
}

dependencies {
    detektPlugins("io.gitlab.arturbosch.detekt:detekt-formatting:1.23.4")
}
```

Create config/detekt.yml:
```yaml
build:
  maxIssues: 0

complexity:
  LongMethod:
    threshold: 60
  ComplexMethod:
    threshold: 15

style:
  MagicNumber:
    active: false
```

Run:
```bash
./gradlew detekt
```

Deliverable: Static analysis enabled

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Lint
  run: ./gradlew ktlintCheck

- name: Detekt
  run: ./gradlew detekt
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - IDE INTEGRATION
========================================

Configure IntelliJ IDEA:
1. Preferences → Editor → Code Style → Kotlin
2. Set from: ".editorconfig"
3. Enable "Optimize imports on the fly"

Deliverable: IDE auto-formatting

========================================
BEST PRACTICES
========================================

- Use ktlint for formatting
- Use detekt for static analysis
- Create .editorconfig for consistency
- Fail build on violations
- Auto-fix with ktlintFormat
- Run checks in CI

========================================
EXECUTION
========================================

START: Add ktlint (Phase 1)
CONTINUE: Add detekt (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Configure IDE (Phase 4)
REMEMBER: Fail on violations, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: Ktlint, Detekt, .editorconfig, CI integration
