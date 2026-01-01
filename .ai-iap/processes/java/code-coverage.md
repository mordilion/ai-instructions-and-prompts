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

## Phase 2: Coverage Tool Configuration

### JaCoCo Setup (Maven)

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.11</version>
      <executions>
        <execution>
          <id>prepare-agent</id>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
        </execution>
        <execution>
          <id>report</id>
          <phase>test</phase>
          <goals>
            <goal>report</goal>
          </goals>
        </execution>
        <execution>
          <id>check</id>
          <goals>
            <goal>check</goal>
          </goals>
          <configuration>
            <rules>
              <rule>
                <element>BUNDLE</element>
                <limits>
                  <limit>
                    <counter>LINE</counter>
                    <value>COVEREDRATIO</value>
                    <minimum>0.80</minimum>
                  </limit>
                  <limit>
                    <counter>BRANCH</counter>
                    <value>COVEREDRATIO</value>
                    <minimum>0.75</minimum>
                  </limit>
                </limits>
              </rule>
            </rules>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

### JaCoCo Setup (Gradle)

```groovy
// build.gradle
plugins {
    id 'jacoco'
}

jacoco {
    toolVersion = "0.8.11"
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
        csv.required = false
    }
}

jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80
            }
        }
        rule {
            element = 'CLASS'
            limit {
                counter = 'BRANCH'
                value = 'COVEREDRATIO'
                minimum = 0.75
            }
        }
    }
}

test {
    finalizedBy jacocoTestReport
}

check {
    dependsOn jacocoTestCoverageVerification
}
```

**Commands**:
```bash
# Maven
mvn clean test jacoco:report

# Gradle
./gradlew test jacocoTestReport
```

---

## Phase 3: Coverage Thresholds & Reporting

### Exclude Code from Coverage

**Maven** (`jacoco-maven-plugin`):
```xml
<configuration>
  <excludes>
    <exclude>**/generated/**</exclude>
    <exclude>**/dto/**</exclude>
    <exclude>**/config/**</exclude>
  </excludes>
</configuration>
```

**Gradle**:
```groovy
jacocoTestReport {
    afterEvaluate {
        classDirectories.setFrom(files(classDirectories.files.collect {
            fileTree(dir: it, exclude: [
                '**/generated/**',
                '**/dto/**',
                '**/config/**'
            ])
        }))
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
          cache: 'maven'
      
      - name: Run tests with coverage
        run: mvn clean test jacoco:report
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./target/site/jacoco/jacoco.xml
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: target/site/jacoco/
```

**For Gradle**:
```yaml
- name: Run tests with coverage
  run: ./gradlew test jacocoTestReport

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: ./build/reports/jacoco/test/jacocoTestReport.xml
```

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

