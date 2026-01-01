# Linting & Formatting Setup (Java)

> **Goal**: Establish automated code linting and formatting in existing Java projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **Checkstyle** ⭐ | Linter | Code style | Maven/Gradle plugin |
| **PMD** | Linter | Code quality | Maven/Gradle plugin |
| **Google Java Format** ⭐ | Formatter | Code style | Maven/Gradle plugin |
| **SpotlessApply** | Formatter | Multi-format | Maven/Gradle plugin |

---

## Phase 2: Linter Configuration

### Checkstyle Setup (Maven)

```xml
<!-- pom.xml -->
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-checkstyle-plugin</artifactId>
      <version>3.3.1</version>
      <configuration>
        <configLocation>google_checks.xml</configLocation>
        <consoleOutput>true</consoleOutput>
        <failsOnError>true</failsOnError>
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

### Checkstyle Setup (Gradle)

```groovy
// build.gradle
plugins {
    id 'checkstyle'
}

checkstyle {
    toolVersion = '10.12.5'
    configFile = file("${rootDir}/config/checkstyle/checkstyle.xml")
    maxWarnings = 0
}
```

**Configuration** (`checkstyle.xml`):
```xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
    "https://checkstyle.org/dtds/configuration_1_3.dtd">
<module name="Checker">
  <module name="TreeWalker">
    <module name="NeedBraces"/>
    <module name="LeftCurly"/>
    <module name="RightCurly"/>
    <module name="EmptyStatement"/>
    <module name="EqualsHashCode"/>
    <module name="IllegalImport"/>
    <module name="RedundantImport"/>
    <module name="UnusedImports"/>
  </module>
</module>
```

### PMD Setup (Maven)

```xml
<!-- pom.xml -->
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-pmd-plugin</artifactId>
  <version>3.21.2</version>
  <configuration>
    <rulesets>
      <ruleset>/rulesets/java/quickstart.xml</ruleset>
    </rulesets>
  </configuration>
  <executions>
    <execution>
      <goals>
        <goal>check</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

---

## Phase 3: Formatter Configuration

### Google Java Format (Maven)

```xml
<!-- pom.xml -->
<plugin>
  <groupId>com.spotify.fmt</groupId>
  <artifactId>fmt-maven-plugin</artifactId>
  <version>2.21.1</version>
  <executions>
    <execution>
      <goals>
        <goal>format</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

### Spotless (Gradle)

```groovy
// build.gradle
plugins {
    id 'com.diffplug.spotless' version '6.23.0'
}

spotless {
    java {
        googleJavaFormat('1.18.1')
        removeUnusedImports()
        trimTrailingWhitespace()
        endWithNewline()
    }
}
```

**Commands**:
```bash
# Format code
./gradlew spotlessApply

# Check formatting
./gradlew spotlessCheck
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### IntelliJ IDEA Setup

1. Install "google-java-format" plugin
2. Enable: `Settings → Tools → Actions on Save → Reformat code`
3. Configure: `Settings → Editor → Code Style → Java → Scheme → Google Style`

### Pre-commit Hooks (pre-commit framework)

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: checkstyle
        name: Checkstyle
        entry: ./mvnw checkstyle:check
        language: system
        pass_filenames: false
      
      - id: format
        name: Google Java Format
        entry: ./mvnw fmt:format
        language: system
        pass_filenames: false
        types: [java]
```

---

## Phase 5: CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint & Format Check

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version-file: '.java-version'
          cache: 'maven'
      
      - name: Run Checkstyle
        run: mvn checkstyle:check
      
      - name: Run PMD
        run: mvn pmd:check
      
      - name: Check formatting
        run: mvn fmt:check
```

**For Gradle**:
```yaml
- name: Run Checkstyle
  run: ./gradlew checkstyleMain checkstyleTest

- name: Check formatting
  run: ./gradlew spotlessCheck
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Checkstyle fails on existing code** | Use `maxWarnings` to gradually enforce |
| **Formatter conflicts** | Choose one formatter (Google Java Format or Spotless) |
| **PMD false positives** | Suppress with `@SuppressWarnings("PMD.RuleName")` |
| **CI fails on formatting** | Run `mvn fmt:format` locally before commit |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Fix all linter violations before merge
> **ALWAYS**: Use consistent style across team
> **NEVER**: Disable linter rules without team discussion
> **NEVER**: Commit code with violations
> **NEVER**: Mix tabs and spaces (use spaces)

---

## AI Self-Check

- [ ] Checkstyle configured and passing?
- [ ] Google Java Format or Spotless installed?
- [ ] PMD configured (optional)?
- [ ] Pre-commit hooks installed?
- [ ] IntelliJ IDEA extensions configured?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All violations fixed?
- [ ] `.editorconfig` file present?
- [ ] Team trained on coding standards?
- [ ] Suppressions documented?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| Checkstyle | Linter | Fast | ⭐⭐⭐ | Code style |
| PMD | Linter | Medium | ⭐⭐⭐ | Code quality |
| Google Java Format | Formatter | Fast | ⭐ | Code style |
| Spotless | Formatter | Fast | ⭐⭐ | Multi-format |

