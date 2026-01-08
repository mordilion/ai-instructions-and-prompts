# Kotlin Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for Kotlin project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN CODE COVERAGE - KOVER
========================================

CONTEXT:
You are implementing code coverage measurement for a Kotlin project using Kover.

CRITICAL REQUIREMENTS:
- ALWAYS use Kover (official JetBrains tool)
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude generated code and data classes

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Add to build.gradle.kts:
```kotlin
plugins {
    kotlin("jvm") version "1.9.21"
    id("org.jetbrains.kotlinx.kover") version "0.7.5"
}

kover {
    reports {
        filters {
            excludes {
                classes("*.BuildConfig")
            }
        }
    }
}
```

Run tests with coverage:
```bash
./gradlew koverHtmlReport
# Report at: build/reports/kover/html/index.html
open build/reports/kover/html/index.html
```

Update .gitignore:
```
build/reports/kover/
kover.bin
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Add to build.gradle.kts:
```kotlin
kover {
    reports {
        filters {
            excludes {
                classes(
                    "*.BuildConfig",
                    "*.*Application*",
                    "*.dto.*",
                    "*.entity.*",
                    "*.config.*"
                )
                annotatedBy("Generated")
            }
        }
    }
}
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Test with coverage
      run: ./gradlew test koverXmlReport
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: build/reports/kover/report.xml
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Add to build.gradle.kts:
```kotlin
kover {
    verify {
        rule {
            bound {
                minValue = 80
                metric = kotlinx.kover.gradle.plugin.dsl.MetricType.LINE
                aggregation = kotlinx.kover.gradle.plugin.dsl.AggregationType.COVERED_PERCENTAGE
            }
        }
    }
}
```

Run:
```bash
./gradlew koverVerify  # Fails if below 80%
```

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Use Kover for Kotlin projects
- Exclude data classes and configs
- Focus on business logic
- Test coroutines and flows
- Set minimum thresholds (80%+)
- Review coverage in PRs

========================================
EXECUTION
========================================

START: Add Kover plugin (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude generated code, use Kover
```

---

## Quick Reference

**What you get**: Complete code coverage setup with Kover  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
