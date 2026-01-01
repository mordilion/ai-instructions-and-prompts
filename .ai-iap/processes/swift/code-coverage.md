# Code Coverage Setup (Swift)

> **Goal**: Establish automated code coverage tracking in existing Swift projects

## Phase 1: Choose Code Coverage Tools

> **ALWAYS**: Track line, branch, and function coverage
> **ALWAYS**: Set minimum coverage thresholds
> **NEVER**: Aim for 100% coverage (diminishing returns)
> **NEVER**: Skip uncovered critical paths

### Recommended Tools

| Tool | Type | Use Case | Setup |
|------|------|----------|-------|
| **XCTest (built-in)** ⭐ | Test runner + coverage | Native | Xcode configuration |
| **Slather** | Report formatter | Cobertura/HTML reports | `gem install slather` |
| **Codecov** | Reporting | CI/CD integration | Cloud service |

---

## Phase 2: Coverage Tool Configuration

### Xcode Code Coverage Setup

**Enable in Xcode**:
1. Select scheme → Edit Scheme
2. Go to Test tab
3. Check "Gather coverage for: All targets" or select specific targets

**Command line**:
```bash
# Run tests with coverage
xcodebuild test \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Or with Swift Package Manager
swift test --enable-code-coverage
```

### Slather Setup (Report Generation)

```bash
# Install
gem install slather

# Generate HTML report
slather coverage \
  --html \
  --scheme YourScheme \
  --output-directory coverage \
  YourProject.xcodeproj

# Generate Cobertura XML
slather coverage \
  --cobertura-xml \
  --scheme YourScheme \
  --output-directory coverage \
  YourProject.xcodeproj
```

**Configuration** (`.slather.yml`):
```yaml
coverage_service: cobertura_xml
xcodeproj: YourProject.xcodeproj
scheme: YourScheme
output_directory: coverage
ignore:
  - Tests/*
  - Pods/*
  - Generated/*
  - Mocks/*
```

---

## Phase 3: Coverage Thresholds & Reporting

### Package.swift Configuration (SPM)

```swift
// Package.swift
let package = Package(
    name: "YourPackage",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "YourPackage", targets: ["YourPackage"])
    ],
    targets: [
        .target(name: "YourPackage"),
        .testTarget(
            name: "YourPackageTests",
            dependencies: ["YourPackage"]
        )
    ]
)
```

### Exclude Code from Coverage

```swift
// No native way to exclude, use separate target or build configuration

#if DEBUG
// This code won't be counted in release builds
func debugOnlyFunction() { }
#endif
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
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version-file: '.xcode-version'
      
      - name: Install dependencies
        run: |
          gem install slather
          gem install xcpretty
      
      - name: Run tests with coverage
        run: |
          xcodebuild test \
            -scheme YourScheme \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -enableCodeCoverage YES \
            | xcpretty
      
      - name: Generate coverage report
        run: |
          slather coverage \
            --cobertura-xml \
            --scheme YourScheme \
            --output-directory coverage \
            YourProject.xcodeproj
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/cobertura.xml
          fail_ci_if_error: true
      
      - name: Generate HTML report
        run: |
          slather coverage \
            --html \
            --scheme YourScheme \
            --output-directory coverage/html \
            YourProject.xcodeproj
      
      - name: Archive coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/html/
```

**For Swift Package Manager**:
```yaml
- name: Run tests with coverage
  run: swift test --enable-code-coverage

- name: Generate coverage report
  run: |
    xcrun llvm-cov export -format="lcov" \
      .build/debug/YourPackagePackageTests.xctest/Contents/MacOS/YourPackagePackageTests \
      -instr-profile .build/debug/codecov/default.profdata \
      > coverage.lcov
```

---

## Phase 5: Coverage Analysis & Improvement

### Identify Uncovered Code

**Xcode**:
1. Run tests with coverage enabled
2. Go to Report Navigator (⌘9)
3. Select latest test run
4. Click Coverage tab
5. Expand targets to see file-by-file coverage

**Command line**:
```bash
# Generate HTML report
slather coverage --html --scheme YourScheme YourProject.xcodeproj
open coverage/index.html
```

### Prioritize Critical Paths

**Coverage priorities (high to low)**:
1. Business logic (domain models, use cases)
2. Data validation (input/output)
3. Error handling
4. ViewModels (MVVM)
5. UI components (SwiftUI views)

### UI Testing Considerations

```swift
// Unit tests (preferred for coverage)
func testViewModel() {
    let viewModel = MyViewModel()
    viewModel.performAction()
    XCTAssertEqual(viewModel.state, .success)
}

// UI tests (not counted in coverage)
func testUI() {
    let app = XCUIApplication()
    app.launch()
    app.buttons["Login"].tap()
}
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Coverage data missing** | Clean build folder, enable coverage in scheme |
| **Slather fails** | Ensure scheme is shared (`Edit Scheme → Shared`) |
| **SwiftUI views not counted** | Use ViewInspector or extract logic to ViewModels |
| **CI fails to find .xcresult** | Check `-resultBundlePath` in xcodebuild command |

---

## Best Practices

> **ALWAYS**: Set realistic thresholds (70-85% is good)
> **ALWAYS**: Extract business logic from SwiftUI views
> **ALWAYS**: Review coverage reports before merge
> **ALWAYS**: Track coverage trends over time
> **NEVER**: Aim for 100% (diminishing returns)
> **NEVER**: Skip ViewModel/business logic tests
> **NEVER**: Rely only on UI tests for coverage

---

## AI Self-Check

- [ ] Xcode code coverage enabled?
- [ ] Slather configured for report generation?
- [ ] CI/CD runs tests with coverage?
- [ ] Coverage reports uploaded to Codecov/Coveralls?
- [ ] Test targets excluded from coverage?
- [ ] HTML reports generated for local review?
- [ ] Team reviews coverage reports?
- [ ] Business logic extracted from SwiftUI views?
- [ ] ViewModels have high coverage (>85%)?
- [ ] Uncovered critical code identified and tested?

---

## Coverage Metrics Explained

| Metric | Definition | Target |
|--------|------------|--------|
| **Line Coverage** | % of lines executed | 80-85% |
| **Branch Coverage** | % of if/else branches executed | 75-80% |
| **Function Coverage** | % of functions called | 80-85% |

---

## Tools Comparison

| Tool | Speed | Setup | CI/CD | Best For |
|------|-------|-------|-------|----------|
| XCTest | Fast | Built-in | ✅ | Native |
| Slather | N/A | Easy | ✅ | Report formatting |
| Codecov | N/A | Easy | ✅ | Reporting |

