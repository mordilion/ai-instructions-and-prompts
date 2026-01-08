# Linting & Formatting Setup (Kotlin)

> **Goal**: Establish automated code linting and formatting in existing Kotlin projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **ktlint** ⭐ | Linter + Formatter | Code style | Gradle plugin |
| **detekt** ⭐ | Linter | Code quality | Gradle plugin |
| **IntelliJ Formatter** | Formatter | Built-in | IDE configuration |

---

## Phase 2: Linter Configuration

### detekt Setup

```kotlin
// build.gradle.kts
plugins {
    id("io.gitlab.arturbosch.detekt") version "1.23.0"
}

detekt {
    buildUponDefaultConfig = true
    allRules = false
    config.setFrom("$projectDir/detekt.yml")
    baseline = file("$projectDir/detekt-baseline.xml")
}

dependencies {
    detektPlugins("io.gitlab.arturbosch.detekt:detekt-formatting:1.23.0")
}

tasks.withType<io.gitlab.arturbosch.detekt.Detekt>().configureEach {
    jvmTarget = "17"
    reports {
        html.required.set(true)
        xml.required.set(false)
        txt.required.set(false)
    }
}
```

**Configuration** (`detekt.yml`):
```yaml
build:
  maxIssues: 0

style:
  MagicNumber:
    active: true
    ignoreNumbers: [-1, 0, 1, 2]
    ignoreHashCodeFunction: true
  MaxLineLength:
    active: true
    maxLineLength: 120

complexity:
  LongMethod:
    active: true
    threshold: 60
  ComplexMethod:
    active: true
    threshold: 15

naming:
  FunctionNaming:
    active: true
    functionPattern: '[a-z][a-zA-Z0-9]*'
  ClassNaming:
    active: true
    classPattern: '[A-Z][a-zA-Z0-9]*'
```

**Commands**:
```bash
# Lint
./gradlew detekt

# Generate baseline (ignore existing issues)
./gradlew detektBaseline
```

---

## Phase 3: Formatter Configuration

### ktlint Setup

```kotlin
// build.gradle.kts
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "12.0.3"
}

ktlint {
    version.set("1.0.1")
    debug.set(false)
    verbose.set(false)
    android.set(false)
    outputToConsole.set(true)
    outputColorName.set("RED")
    ignoreFailures.set(false)
    
    filter {
        exclude("**/generated/**")
        include("**/kotlin/**")
    }
}
```

**Configuration** (`.editorconfig`):
```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
indent_style = space
insert_final_newline = true
max_line_length = 120
trim_trailing_whitespace = true

[*.{kt,kts}]
ij_kotlin_code_style_defaults = KOTLIN_OFFICIAL
ij_kotlin_line_comment_at_first_column = false
ij_kotlin_name_count_to_use_star_import = 5
ij_kotlin_name_count_to_use_star_import_for_members = 3
ij_kotlin_imports_layout = *, java.**, javax.**, kotlin.**, ^
```

**Commands**:
```bash
# Format
./gradlew ktlintFormat

# Check formatting
./gradlew ktlintCheck
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### IntelliJ IDEA Setup

1. Install "detekt" plugin
2. Enable: `Settings → Tools → Actions on Save → Reformat code`
3. Configure: `Settings → Editor → Code Style → Kotlin → Set from... → Kotlin style guide`

### Pre-commit Hooks (pre-commit framework)

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: ktlint-format
        name: ktlint Format
        entry: ./gradlew ktlintFormat
        language: system
        pass_filenames: false
        types: [kotlin]
      
      - id: detekt
        name: detekt
        entry: ./gradlew detekt
        language: system
        pass_filenames: false
        types: [kotlin]
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
          cache: 'gradle'
      
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
      
      - name: Run ktlint Check
        run: ./gradlew ktlintCheck
      
      - name: Run detekt
        run: ./gradlew detekt
      
      - name: Upload detekt report
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
| **ktlint fails on existing code** | Run `./gradlew ktlintFormat` to auto-fix |
| **detekt false positives** | Add to `detekt-baseline.xml` or configure in `detekt.yml` |
| **EditorConfig not applied** | Enable in IDE settings, restart IDE |
| **CI fails on formatting** | Run `./gradlew ktlintFormat` locally before commit |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD
> **ALWAYS**: Fix all linter violations before merge
> **ALWAYS**: Use `.editorconfig` for consistency
> **NEVER**: Disable linter rules without team discussion
> **NEVER**: Commit code with violations
> **NEVER**: Mix tabs and spaces (use spaces)

---

## AI Self-Check

- [ ] ktlint configured and passing?
- [ ] detekt installed and configured?
- [ ] `.editorconfig` file present?
- [ ] Pre-commit hooks installed?
- [ ] IntelliJ IDEA extensions configured?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All violations fixed?
- [ ] Baseline file used for existing code?
- [ ] Team trained on coding standards?
- [ ] Kotlin official style guide followed?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| ktlint | Formatter | Fast | ⭐⭐ | Code style |
| detekt | Linter | Medium | ⭐⭐⭐ | Code quality |
| IntelliJ | Both | Fast | ⭐⭐ | IDE integration |


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up code linting and formatting tools

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code linting and formatting for this project.

CRITICAL REQUIREMENTS:
- ALWAYS configure both linting (quality) and formatting (style)
- ALWAYS integrate with pre-commit hooks
- ALWAYS add to CI/CD pipeline
- ALWAYS use consistent configuration across team

IMPLEMENTATION STEPS:

1. CHOOSE TOOLS:
   Select appropriate linter and formatter for the language (see Tech Stack section)

2. CONFIGURE LINTER:
   Create configuration file (.eslintrc, ruff.toml, etc.)
   Set rules (recommended: start with recommended preset)

3. CONFIGURE FORMATTER:
   Create configuration file (if separate from linter)
   Set style rules (indentation, line length, etc.)

4. INTEGRATE WITH EDITOR:
   Configure IDE/editor plugins
   Enable format-on-save

5. ADD PRE-COMMIT HOOKS:
   Install pre-commit hooks (husky, pre-commit, etc.)
   Configure to run linter and formatter

6. ADD TO CI/CD:
   Add linting step to pipeline
   Fail build on linting errors

DELIVERABLE:
- Linter and formatter configured
- Pre-commit hooks active
- CI/CD integration complete

START: Choose tools and create configuration files.
```
