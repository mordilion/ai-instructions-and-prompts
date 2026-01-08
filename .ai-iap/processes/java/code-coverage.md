# Code Coverage Setup (Java)

> **Goal**: Establish automated code coverage tracking in existing Java projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **JaCoCo** ⭐ | Coverage tool | Industry standard | Maven/Gradle plugin |
| **Cobertura** | Coverage tool | Alternative | Maven/Gradle plugin |
| **IntelliJ Coverage** | IDE integration | JetBrains IDEs | Built-in |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Tool Configuration

**Maven**: Add `jacoco-maven-plugin` with executions: `prepare-agent`, `report`, `check` (LINE 0.80, BRANCH 0.75)  
**Gradle**: Apply `jacoco` plugin, configure `jacocoTestReport` (xml/html), `jacocoTestCoverageVerification` (minimum 0.80)

**Commands**: `mvn test jacoco:report` or `./gradlew test jacocoTestReport`

---

## Phase 3: Exclusions & Thresholds

**Exclude**: `**/generated/**`, `**/dto/**`, `**/config/**` (configure in plugin)  
**Thresholds**: LINE 80%, BRANCH 75%, METHOD 70% (adjust per project)

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Run `mvn test jacoco:report` or `./gradlew test jacocoTestReport`, upload to Codecov/Coveralls  
**Report Paths**: Maven: `target/site/jacoco/jacoco.xml`, Gradle: `build/reports/jacoco/test/jacocoTestReport.xml`

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Maven - Open report
open target/site/jacoco/index.html

# Gradle - Open report
open build/reports/jacoco/test/html/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (services, domain)
2. Data validation (validators, mappers)
3. Error handling
4. API controllers
5. Repositories

### Exclude Code with Annotations

```java
// Lombok generated code
@lombok.Generated
public class User { }

// Custom annotation
@CoverageExclude
public void legacyMethod() { }
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage reports empty** | Check `excludes` configuration |
| **Slow test runs** | Use parallel test execution |
| **Missing coverage for Lombok** | Add `@lombok.Generated` exclusion |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Exclude generated code (Lombok, DTOs)
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Write tests just to increase coverage
> **NEVER**: Skip edge cases and error paths

---

## AI Self-Check

- [ ] JaCoCo configured for coverage?
- [ ] Coverage thresholds set (80% line, 75% branch)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Generated code excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] Lombok generated code excluded?
- [ ] Critical business logic covered?
- [ ] Uncovered code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Method Coverage** | % of methods called | 80-85% |
| **Instruction Coverage** | % of bytecode instructions executed | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| JaCoCo | Fast | Easy | ✅ | Industry standard |
| Cobertura | Medium | Medium | ✅ | Alternative |
| IntelliJ | Fast | Built-in | ⚠️ | IDE only |
| Codecov | N/A | Easy | ✅ | Reporting |

