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

## Phase 2: Tool Configuration

**Dart**: `dart test --coverage=coverage` or `flutter test --coverage`, format with `dart run coverage:format_coverage --lcov`  
**HTML Reports**: Install `lcov`, run `genhtml coverage/lcov.info -o coverage/html`

---

## Phase 3: Exclusions & Thresholds

**Exclude**: `// coverage:ignore-file`, `// coverage:ignore-line`, `// coverage:ignore-start/end`  
**Thresholds**: LINE 80% (use custom script to parse `lcov --summary` and fail if below threshold)

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
          files: ./coverage/lcov_filtered.info
```

**Report Path**: `coverage/lcov.info` (filter: `**/*.g.dart`, `**/*.freezed.dart`, `**/generated/**`)

---

## Phase 5: Analysis & Improvement

**Prioritize**: Business logic > Validation > Error handling > Widgets (test with `testWidgets`) > Repositories

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

