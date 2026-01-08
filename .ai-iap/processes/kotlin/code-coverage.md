# Code Coverage Setup (Kotlin)

> **Goal**: Establish automated code coverage tracking in existing Kotlin projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **JaCoCo** ⭐ | Coverage tool | Industry standard | Gradle plugin |
| **Kover** ⭐ | Coverage tool | Kotlin-first | Gradle plugin |
| **IntelliJ Coverage** | IDE integration | JetBrains IDEs | Built-in |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Tool Configuration

**Kover** ⭐ (Kotlin) (`build.gradle.kts`):
```kotlin
plugins {
    id("org.jetbrains.kotlinx.kover") version "0.7.5"
}

koverReport {
    defaults {
        xml { onCheck = true }
        html { onCheck = true }
    }
    filters {
        excludes {
            classes("*.BuildConfig", "*.Companion")
            packages("*.generated")
        }
    }
    verify {
        rule { minBound(80) }  // LINE
        rule { minBound(75, coverageUnits = CoverageUnit.BRANCH) }
    }
}
```

**JaCoCo** (Alternative) (`build.gradle.kts`):
```kotlin
plugins { id("jacoco") }
jacoco { toolVersion = "0.8.11" }
tasks.jacocoTestReport {
    reports { xml.required.set(true); html.required.set(true) }
}
tasks.jacocoTestCoverageVerification {
    violationRules { rule { limit { minimum = "0.80".toBigDecimal() } } }
}
```

**Commands**: `./gradlew koverHtmlReport koverVerify` or `./gradlew test jacocoTestReport`

---

## Phase 3: Exclusions & Thresholds

**Exclude**: `*.BuildConfig`, `*.Companion`, `*.generated` packages, `@Generated` annotated  
**Thresholds**: LINE 80%, BRANCH 75%, critical packages 90%

### Exclude Code from Coverage

**Annotation-based**:
```kotlin
@file:Suppress("COVERAGE_EXCLUDE")

@Generated
class GeneratedCode { }
```

**Configuration-based**:
```kotlin
koverReport {
    filters {
        excludes {
            classes("*Test", "*Activity", "*Fragment")
            packages("*.generated", "*.di")
            annotatedBy("Generated", "Composable")
        }
    }
}
```

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Run `./gradlew test koverXmlReport koverVerify`, upload to Codecov  
**Report Paths**: Kover: `build/reports/kover/report.xml`, JaCoCo: `build/reports/jacoco/test/jacocoTestReport.xml`

---

## Phase 5: Analysis & Improvement

**Prioritize**: Business logic > Validation > Error handling > ViewModels/Controllers > Repositories  
**Android Exclusions**: `*Activity`, `*Fragment`, `@Composable`, `*.di`, `*_Factory`

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Kover reports empty** | Check `excludes` configuration |
| **Android tests not counted** | Add `android.testCoverage.jacocoVersion = "0.8.11"` |
| **Compose functions counted** | Exclude `@Composable` annotation |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Exclude Android UI components (hard to test)
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip business logic tests

---

## AI Self-Check

- [ ] Kover or JaCoCo configured for coverage?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Android UI components excluded?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] Generated code excluded?
- [ ] Critical business logic covered?
- [ ] Uncovered code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Method Coverage** | % of methods called | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| Kover | Fast | Easy | ✅ | Kotlin projects |
| JaCoCo | Fast | Easy | ✅ | Java/Kotlin mix |
| IntelliJ | Fast | Built-in | ⚠️ | IDE only |
| Codecov | N/A | Easy | ✅ | Reporting |

