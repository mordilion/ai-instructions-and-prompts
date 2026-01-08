# Linting & Formatting Setup (Swift)

> **Goal**: Establish automated code linting and formatting in existing Swift projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **SwiftLint** ⭐ | Linter | Code style + quality | CocoaPods/SPM/Homebrew |
| **swift-format** ⭐ | Formatter | Code style | SPM/Homebrew |
| **SwiftFormat** | Formatter | Alternative | CocoaPods/SPM |

---

## Phase 2: Linter Configuration

### SwiftLint Setup

```bash
# Install via Homebrew
brew install swiftlint

# Or via CocoaPods
pod 'SwiftLint'

# Or via SPM
.package(url: "https://github.com/realm/SwiftLint", from: "0.54.0")
```

**Configuration** (`.swiftlint.yml`):
```yaml
disabled_rules:
  - line_length
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional
  - weak_delegate
  - closure_spacing
  - contains_over_filter_count
  - multiline_parameters

excluded:
  - Pods
  - Tests
  - Carthage
  - DerivedData

line_length:
  warning: 120
  error: 150

type_body_length:
  warning: 300
  error: 400

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 60
  error: 80

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 40
    error: 50
  excluded:
    - id
    - URL
    - url

custom_rules:
  no_print:
    name: "No Print Statements"
    regex: "print\\("
    message: "Use proper logging instead of print()"
    severity: warning
```

**Commands**:
```bash
# Lint
swiftlint

# Auto-fix
swiftlint --fix

# CI/CD
swiftlint lint --reporter json > swiftlint-report.json
```

---

## Phase 3: Formatter Configuration

### swift-format Setup

```bash
# Install via Homebrew
brew install swift-format

# Format
swift-format format -i -r Sources/

# Check formatting
swift-format lint -r Sources/
```

**Configuration** (`.swift-format.json`):
```json
{
  "version": 1,
  "lineLength": 120,
  "indentation": {
    "spaces": 2
  },
  "maximumBlankLines": 1,
  "respectsExistingLineBreaks": false,
  "lineBreakBeforeControlFlowKeywords": true,
  "lineBreakBeforeEachArgument": true
}
```

### SwiftFormat Setup (Alternative)

```bash
# Install via Homebrew
brew install swiftformat

# Format
swiftformat .

# Check formatting
swiftformat --lint .
```

**Configuration** (`.swiftformat`):
```
--indent 2
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
--self insert
--importgrouping testable-bottom
--stripunusedargs closure-only
--disable redundantSelf
--exclude Pods,Carthage
```

---

## Phase 4: IDE Integration & Pre-commit Hooks

### Xcode Setup

**Build Phase for SwiftLint**:
1. In Xcode, select your target
2. Go to `Build Phases`
3. Add "New Run Script Phase"
4. Add script:
```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

### Pre-commit Hooks (pre-commit framework)

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: swiftlint
        name: SwiftLint
        entry: swiftlint lint --strict
        language: system
        types: [swift]
      
      - id: swift-format
        name: swift-format
        entry: swift-format format -i -r
        language: system
        types: [swift]
        pass_filenames: false
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
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version-file: '.xcode-version'
      
      - name: Install SwiftLint
        run: brew install swiftlint
      
      - name: Install swift-format
        run: brew install swift-format
      
      - name: Run SwiftLint
        run: swiftlint lint --reporter github-actions-logging
      
      - name: Check swift-format
        run: swift-format lint -r Sources/
      
      - name: Upload SwiftLint report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: swiftlint-report
          path: swiftlint-report.json
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **SwiftLint not found in Xcode** | Add to `PATH` in build script: `export PATH="$PATH:/opt/homebrew/bin"` |
| **SwiftLint false positives** | Add to `.swiftlint.yml` disabled_rules or use `// swiftlint:disable` |
| **swift-format conflicts** | Choose one formatter (swift-format or SwiftFormat) |
| **CI fails on formatting** | Run `swift-format format -i -r .` locally before commit |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run linter in CI/CD and Xcode builds
> **ALWAYS**: Fix all linter warnings before merge
> **ALWAYS**: Use consistent style across team
> **NEVER**: Disable linter rules without team discussion
> **NEVER**: Commit code with warnings
> **NEVER**: Use `print()` in production (use logging)

---

## AI Self-Check

- [ ] SwiftLint configured and passing?
- [ ] swift-format or SwiftFormat installed?
- [ ] `.swiftlint.yml` file present?
- [ ] Xcode build phase for SwiftLint added?
- [ ] Pre-commit hooks installed?
- [ ] CI/CD runs linter and formatter checks?
- [ ] All warnings fixed?
- [ ] Team trained on Swift style guide?
- [ ] Force unwrapping avoided?
- [ ] Logging used instead of `print()`?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| SwiftLint | Linter | Fast | ⭐⭐⭐ | Code quality |
| swift-format | Formatter | Fast | ⭐⭐ | Apple's official |
| SwiftFormat | Formatter | Fast | ⭐⭐ | Alternative |


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
