# Dart/Flutter Code Coverage - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up code coverage for Dart/Flutter project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
DART/FLUTTER CODE COVERAGE
========================================

CONTEXT:
You are implementing code coverage measurement for a Dart/Flutter project.

CRITICAL REQUIREMENTS:
- ALWAYS use lcov format (standard for Dart/Flutter)
- NEVER commit coverage reports to Git
- Target 80%+ coverage for critical paths
- Exclude generated files from coverage

========================================
PHASE 1 - LOCAL COVERAGE
========================================

Run tests with coverage:

```bash
# For Flutter projects
flutter test --coverage

# For Dart-only projects
dart test --coverage=coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Update .gitignore:
```
coverage/
*.coverage
```

Deliverable: Local coverage report

========================================
PHASE 2 - CONFIGURE EXCLUSIONS
========================================

Create test/coverage_helper_test.dart:
```dart
// coverage:ignore-file
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coverage helper', () {
    // Import all files to include in coverage
  });
}
```

Update analysis_options.yaml:
```yaml
analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - 'lib/generated/**'
```

Deliverable: Proper file exclusions

========================================
PHASE 3 - CI INTEGRATION
========================================

Add to .github/workflows/ci.yml:

```yaml
    - name: Test with coverage
      run: flutter test --coverage
    
    - name: Remove generated files
      run: |
        lcov --remove coverage/lcov.info \
          '**/*.g.dart' \
          '**/*.freezed.dart' \
          'lib/generated/**' \
          -o coverage/filtered.lcov
    
    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage/filtered.lcov
        fail_ci_if_error: true
```

Deliverable: CI coverage reporting

========================================
PHASE 4 - COVERAGE ENFORCEMENT
========================================

Add to pubspec.yaml:
```yaml
dev_dependencies:
  test_cov_console: ^0.2.2
```

Add to test script:
```bash
flutter test --coverage
lcov --list coverage/lcov.info | grep "Total:"
# Fail if below threshold
```

Or use Codecov's PR comments for enforcement.

Deliverable: Automated coverage enforcement

========================================
BEST PRACTICES
========================================

- Exclude generated code (*.g.dart, *.freezed.dart)
- Use lcov for filtering
- Focus on business logic coverage
- Test edge cases and error paths
- Use Codecov for visualization
- Set minimum thresholds (80%+)

========================================
EXECUTION
========================================

START: Run local coverage (Phase 1)
CONTINUE: Configure exclusions (Phase 2)
CONTINUE: Add CI integration (Phase 3)
OPTIONAL: Add enforcement (Phase 4)
REMEMBER: Exclude generated files, use lcov
```

---

## Quick Reference

**What you get**: Complete code coverage setup with lcov  
**Time**: 1 hour  
**Output**: Coverage reports in CI and locally
