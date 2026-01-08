# Linting & Formatting Setup (Dart/Flutter)

> **Goal**: Establish automated code linting and formatting in existing Dart/Flutter projects

## Phase 1: Choose Linting & Formatting Tools

> **ALWAYS**: Use a linter (code quality) + formatter (code style)
> **ALWAYS**: Run linter/formatter in CI/CD pipeline
> **NEVER**: Mix multiple formatters (choose one)
> **NEVER**: Skip pre-commit hooks

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **dart analyze** ⭐ | Linter | Built-in | `dart analyze` |
| **flutter analyze** | Linter | Flutter-specific | `flutter analyze` |
| **dart format** ⭐ | Formatter | Built-in | `dart format` |

---

## Phase 2: Linter Configuration

### dart analyze / flutter analyze Setup

**Configuration** (`analysis_options.yaml`):
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  
  errors:
    missing_required_param: error
    missing_return: error
    invalid_annotation_target: ignore
    todo: ignore
  
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # Errors
    - always_use_package_imports
    - avoid_empty_else
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - no_adjacent_strings_in_list
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unsafe_html
    
    # Style
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_init_to_null
    - avoid_return_types_on_setters
    - camel_case_types
    - constant_identifier_names
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_single_quotes
    - sort_pub_dependencies
    - use_key_in_widget_constructors
    
    # Pub
    - depend_on_referenced_packages
    - package_names
    - secure_pubspec_urls
```

**Commands**:
```bash
# Lint Dart project
dart analyze

# Lint Flutter project
flutter analyze

# Strict mode
dart analyze --fatal-infos --fatal-warnings
```

---

## Phase 3: Formatter Configuration

### dart format Setup

```bash
# Format
dart format .

# Format with line length
dart format --line-length 100 .

# Check formatting (CI/CD)
dart format --output none --set-exit-if-changed .

# Flutter format
flutter format .
```

**No configuration file needed** - `dart format` uses built-in style guide

---

## Phase 4: IDE Integration & Pre-commit Hooks

### VS Code Setup

**Extensions** (`.vscode/extensions.json`):
```json
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter"
  ]
}
```

**Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "dart-code.dart-code",
    "editor.formatOnSave": true,
    "editor.rulers": [100]
  },
  "dart.lineLength": 100,
  "dart.enableSdkFormatter": true,
  "dart.previewFlutterUiGuides": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

### Pre-commit Hooks (pre-commit framework)

**Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: dart-format
        name: dart format
        entry: dart format --fix
        language: system
        types: [dart]
      
      - id: dart-analyze
        name: dart analyze
        entry: dart analyze --fatal-infos
        language: system
        pass_filenames: false
      
      - id: flutter-test
        name: flutter test
        entry: flutter test
        language: system
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
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version-file: '.fvmrc'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run dart format check
        run: dart format --output none --set-exit-if-changed .
      
      - name: Run dart analyze
        run: dart analyze --fatal-infos --fatal-warnings
      
      - name: Run flutter analyze
        run: flutter analyze
      
      - name: Run tests
        run: flutter test
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **dart analyze slow** | Exclude generated files in `analysis_options.yaml` |
| **dart format conflicts** | Use consistent `--line-length` across team |
| **CI fails on warnings** | Use `--fatal-warnings` flag |
| **Pre-commit hooks slow** | Skip tests in pre-commit, run in CI only |

---

## Best Practices

> **ALWAYS**: Format code before commit (pre-commit hooks)
> **ALWAYS**: Run analyzer in CI/CD
> **ALWAYS**: Fix all analyzer errors before merge
> **ALWAYS**: Use `const` constructors where possible
> **NEVER**: Disable analyzer rules without justification
> **NEVER**: Commit code with analyzer errors
> **NEVER**: Use `ignore` comments excessively

---

## AI Self-Check

- [ ] `dart analyze` or `flutter analyze` configured?
- [ ] `dart format` with consistent line length?
- [ ] `analysis_options.yaml` with strict rules?
- [ ] Pre-commit hooks installed?
- [ ] VS Code extensions configured?
- [ ] CI/CD runs analyzer and formatter checks?
- [ ] All analyzer errors fixed?
- [ ] `const` constructors used where possible?
- [ ] Generated files excluded from analysis?
- [ ] Team trained on Dart style guide?

---

## Tools Comparison

| Tool | Type | Speed | Extensibility | Best For |
|------|------|-------|---------------|----------|
| dart analyze | Linter | Fast | ⭐⭐ | Code quality |
| flutter analyze | Linter | Fast | ⭐⭐ | Flutter apps |
| dart format | Formatter | Very Fast | ⭐ | Code style |


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
