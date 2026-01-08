# Dart/Flutter Linting & Formatting - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up linting and code formatting  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER LINTING & FORMATTING
========================================

CONTEXT:
You are setting up linting and code formatting for a Dart/Flutter project.

CRITICAL REQUIREMENTS:
- ALWAYS use dart analyze and dart format
- NEVER ignore lints without justification
- Use flutter_lints or lint package
- Enforce in CI pipeline

========================================
PHASE 1 - BASIC LINTING
========================================

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_lints: ^3.0.0  # For Flutter projects
  # OR
  lints: ^3.0.0  # For Dart-only projects
```

Create/update analysis_options.yaml:
```yaml
include: package:flutter_lints/flutter.yaml  # or package:lints/recommended.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_print
    - prefer_single_quotes
    - require_trailing_commas

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
  errors:
    invalid_annotation_target: ignore
```

Deliverable: Linting configured

========================================
PHASE 2 - FORMATTING
========================================

Format code:
```bash
# Format all files
dart format .

# Check without modifying
dart format --set-exit-if-changed .
```

Configure line length in analysis_options.yaml:
```yaml
formatter:
  page_width: 80
```

Deliverable: Auto-formatting enabled

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:
```yaml
- name: Analyze
  run: flutter analyze --fatal-infos

- name: Format check
  run: dart format --set-exit-if-changed .
```

Deliverable: Automated checks in CI

========================================
PHASE 4 - IDE INTEGRATION
========================================

VS Code settings.json:
```json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.rulers": [80]
  }
}
```

Deliverable: IDE auto-formatting

========================================
BEST PRACTICES
========================================

- Use flutter_lints/lints package
- Run dart analyze before commits
- Format code automatically
- Exclude generated files
- Fail CI on warnings
- Use trailing commas for better diffs

========================================
EXECUTION
========================================

START: Add lints package (Phase 1)
CONTINUE: Configure formatting (Phase 2)
CONTINUE: Add CI checks (Phase 3)
OPTIONAL: Configure IDE (Phase 4)
REMEMBER: Exclude generated files, enforce in CI
```

---

## Quick Reference

**What you get**: Complete linting and formatting setup  
**Time**: 30 minutes  
**Output**: analysis_options.yaml, CI integration
