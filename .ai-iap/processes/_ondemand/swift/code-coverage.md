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

## Phase 2: Tool Configuration

**Xcode Setup**:
1. Select scheme → Edit Scheme
2. Go to Test tab
3. Check "Gather coverage for: All targets"

**Command Line**:
```bash
# Xcode projects
xcodebuild test \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Swift Package Manager
swift test --enable-code-coverage
```

**Slather** (Report Generation):
```bash
# Install
gem install slather

# Generate HTML report
slather coverage --html --scheme YourScheme YourProject.xcodeproj

# Generate Cobertura XML (for CI/CD)
slather coverage --cobertura-xml --scheme YourScheme YourProject.xcodeproj
```

**Configuration** (`.slather.yml`):
```yaml
coverage_service: cobertura_xml
xcodeproj: YourProject.xcodeproj
scheme: YourScheme
ignore:
  - Tests/*
  - Pods/*
  - Generated/*
```

---

## Phase 3: Exclusions & Thresholds

**Exclude** (`.slather.yml`): `Tests/*`, `Pods/*`, `Generated/*`, `Mocks/*`  
**Thresholds**: LINE 80% (use custom script or CI tooling to enforce)  
**Code Exclusions**: Use `#if DEBUG` or separate targets (no native exclusion support)

---

## Phase 4: CI/CD Integration

**GitHub Actions**: Run `xcodebuild test -enableCodeCoverage YES` or `swift test --enable-code-coverage`, generate reports with Slather, upload to Codecov  
**Report Paths**: Slather: `coverage/cobertura.xml`, SPM: `.build/debug/codecov/default.profdata` (convert with `xcrun llvm-cov`)

---

## Phase 5: Analysis & Improvement

**Xcode UI**: Report Navigator (⌘9) → Coverage tab  
**Prioritize**: Business logic > Validation > Error handling > ViewModels > SwiftUI views  
**iOS-Specific Exclusions**: UIViewControllers (hard to test), Storyboards, AppDelegate/SceneDelegate

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


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When configuring code coverage tracking and reporting

### Complete Implementation Prompt

```
CONTEXT:
You are configuring code coverage tracking for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect language version from project files
- ALWAYS configure coverage thresholds (recommended: 80% line, 75% branch)
- ALWAYS integrate with CI/CD pipeline
- NEVER lower coverage thresholds without justification

IMPLEMENTATION STEPS:

1. DETECT VERSION:
   Scan project files for language/framework version

2. CHOOSE COVERAGE TOOL:
   Select appropriate tool for the language (see Tech Stack section above)

3. CONFIGURE TOOL:
   Add coverage configuration to project
   Set thresholds (line, branch, function)

4. INTEGRATE WITH CI/CD:
   Add coverage step to pipeline
   Configure to fail build if below thresholds

5. CONFIGURE REPORTING:
   Generate coverage reports (HTML, XML, lcov)
   Optional: Upload to coverage service (Codecov, Coveralls)

DELIVERABLE:
- Coverage tool configured
- Thresholds enforced in CI/CD
- Coverage reports generated

START: Detect language version and configure coverage tool.
```
