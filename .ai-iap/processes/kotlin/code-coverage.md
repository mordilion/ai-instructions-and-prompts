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

## Phase 2: Coverage Tool Configuration

### Kover Setup (Recommended for Kotlin)

```kotlin
// build.gradle.kts
plugins {
    id("org.jetbrains.kotlinx.kover") version "0.7.5"
}

koverReport {
    defaults {
        html {
            onCheck = true
        }
        xml {
            onCheck = true
        }
    }
    
    filters {
        excludes {
            classes("*.BuildConfig", "*.Companion")
            packages("*.generated")
            annotatedBy("Generated")
        }
    }
    
    verify {
        rule {
            minBound(80)
        }
        rule {
            minBound(75, coverageUnits = kotlinx.kover.gradle.plugin.dsl.CoverageUnit.BRANCH)
        }
    }
}
```

**Commands**:
```bash
# Run tests with coverage
./gradlew koverHtmlReport

# Verify thresholds
./gradlew koverVerify

# Generate XML report
./gradlew koverXmlReport
```

### JaCoCo Setup (Alternative)

```kotlin
// build.gradle.kts
plugins {
    id("jacoco")
}

jacoco {
    toolVersion = "0.8.11"
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
        csv.required.set(false)
    }
}

tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = "0.80".toBigDecimal()
            }
        }
    }
}

tasks.test {
    finalizedBy(tasks.jacocoTestReport)
}
```

---

## Phase 3: Coverage Thresholds & Reporting

### Kover Thresholds

```kotlin
koverReport {
    verify {
        rule {
            name = "Minimal line coverage"
            minBound(80)
        }
        rule {
            name = "Minimal branch coverage"
            minBound(75, coverageUnits = kotlinx.kover.gradle.plugin.dsl.CoverageUnit.BRANCH)
        }
        rule {
            name = "Critical packages"
            filters {
                includes {
                    packages("com.example.critical")
                }
            }
            minBound(90)
        }
    }
}
```

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

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test & Coverage

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
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
      
      - name: Run tests with coverage
        run: ./gradlew test koverXmlReport koverHtmlReport
      
      - name: Verify coverage thresholds
        run: ./gradlew koverVerify
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./build/reports/kover/report.xml
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: build/reports/kover/html/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Generate HTML report
./gradlew koverHtmlReport

# Open report
open build/reports/kover/html/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (domain, use cases)
2. Data validation (validators, mappers)
3. Error handling
4. ViewModels (Android) / Controllers (Ktor)
5. Repositories

### Android-Specific Exclusions

```kotlin
koverReport {
    filters {
        excludes {
            // Android components (hard to test)
            classes("*Activity", "*Fragment", "*Application")
            
            // Jetpack Compose
            annotatedBy("androidx.compose.runtime.Composable")
            
            // Dependency injection
            packages("*.di", "*.injection")
            
            // Generated code
            classes("*_Factory", "*_MembersInjector")
        }
    }
}
```

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

