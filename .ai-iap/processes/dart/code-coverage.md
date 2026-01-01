# Code Coverage Setup (Dart/Flutter)

> **Goal**: Establish automated code coverage tracking in existing Dart/Flutter projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **dart test (built-in)** ⭐ | Test runner + coverage | Native | `dart test --coverage` |
| **lcov** | Report formatter | HTML reports | `sudo apt install lcov` (Linux) |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### dart test with Coverage

```bash
# Run tests with coverage
dart test --coverage=coverage

# Or for Flutter
flutter test --coverage

# Generate LCOV report
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --packages=.dart_tool/package_config.json \
  --report-on=lib
```

### lcov Setup (HTML Reports)

```bash
# Install lcov (macOS)
brew install lcov

# Install lcov (Linux)
sudo apt install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

---

## Phase 3: Coverage Thresholds & Reporting

### Custom Coverage Check Script

**Script** (`scripts/check_coverage.sh`):
```bash
#!/bin/bash

# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Extract coverage percentage
COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')

# Check threshold
THRESHOLD=80

if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "❌ Coverage $COVERAGE% is below threshold $THRESHOLD%"
  exit 1
else
  echo "✅ Coverage $COVERAGE% meets threshold $THRESHOLD%"
  exit 0
fi
```

### Exclude Code from Coverage

**Ignore generated files** (`.lcovrc`):
```
# .lcovrc
geninfo_adjust_src_path = /path/to/project

# Exclude generated files
lcov_excl_line = LCOV_EXCL_LINE
lcov_excl_br_line = LCOV_EXCL_BR_LINE

# Patterns to exclude
lcov_excl_line = ignore: coverage
```

**In code**:
```dart
// Exclude entire block
// coverage:ignore-start
void debugFunction() {
  print('Debug');
}
// coverage:ignore-end

// Exclude single line
void someFunction() {
  print('Not counted'); // coverage:ignore-line
}

// Exclude file
// coverage:ignore-file
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
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version-file: '.fvmrc'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: Install lcov
        run: sudo apt-get install -y lcov
      
      - name: Remove generated files from coverage
        run: |
          lcov --remove coverage/lcov.info \
            '**/*.g.dart' \
            '**/*.freezed.dart' \
            '**/generated/**' \
            -o coverage/lcov_filtered.info
      
      - name: Generate HTML report
        run: genhtml coverage/lcov_filtered.info -o coverage/html
      
      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov_filtered.info | grep "lines" | awk '{print $2}' | sed 's/%//')
          THRESHOLD=80
          if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
            echo "Coverage $COVERAGE% is below threshold $THRESHOLD%"
            exit 1
          fi
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/lcov_filtered.info
          fail_ci_if_error: true
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/html/
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

```bash
# Run tests with coverage
flutter test --coverage

# Remove generated files
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  -o coverage/lcov_filtered.info

# Generate HTML report
genhtml coverage/lcov_filtered.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (domain models, use cases)
2. State management (BLoC, Riverpod providers)
3. Data validation (input/output)
4. Error handling
5. UI widgets (harder to test, lower priority)

### Widget Testing for Coverage

```dart
// Test widget logic
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(find.text('0'), findsOneWidget);
  
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  
  expect(find.text('1'), findsOneWidget);
});

// Extract logic to separate classes for easier testing
class CounterLogic {
  int increment(int value) => value + 1;
}

// Test logic separately
test('Counter logic increments', () {
  final logic = CounterLogic();
  expect(logic.increment(0), 1);
});
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage data missing** | Run `dart pub get` first, check `.dart_tool/` exists |
| **Generated files counted** | Use `lcov --remove` to exclude `*.g.dart`, `*.freezed.dart` |
| **Widget tests not counted** | Ensure `flutter test --coverage` (not `dart test`) |
| **CI fails on threshold** | Review uncovered code, add tests or adjust threshold |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Exclude generated files (`*.g.dart`, `*.freezed.dart`)
> **ALWAYS**: Extract business logic from widgets
> **ALWAYS**: Review coverage reports before merge
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Skip business logic tests
> **NEVER**: Rely only on widget tests for coverage

---

## AI Self-Check

- [ ] `dart test --coverage` or `flutter test --coverage` configured?
- [ ] lcov installed for HTML reports?
- [ ] Coverage thresholds set (80% line)?
- [ ] CI/CD runs coverage and fails on threshold violation?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Generated files excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] Business logic extracted from widgets?
- [ ] Uncovered critical code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Function Coverage** | % of functions called | 80-85% |

**Note**: Dart coverage doesn't report branch coverage separately.

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| dart test | Fast | Built-in | ✅ | Native |
| lcov | N/A | Easy | ✅ | Report formatting |
| Codecov | N/A | Easy | ✅ | Reporting |

