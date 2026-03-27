# Swift Testing Implementation - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up testing infrastructure in a Swift project  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive testing infrastructure for a Swift project.

CRITICAL REQUIREMENTS:
- ALWAYS detect Swift version from Package.swift or Xcode project
- ALWAYS identify project type (iOS app, SPM library, UIKit, SwiftUI)
- NEVER fix production code bugs (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow

========================================
TECH STACK
========================================

Test Framework: XCTest ⭐ (Apple's official) / Quick + Nimble

Project Types:
- iOS App (UIKit) - XCUITest for UI testing
- iOS App (SwiftUI) - SwiftUI testing APIs
- SPM Library - swift test command

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - Swift version used
   - Project type (iOS/macOS/SPM)
   - UI framework (UIKit/SwiftUI)
   - Test framework chosen
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs found but not fixed
   - Code smells discovered
   - Areas needing refactoring

3. Read TESTING-SETUP.md if it exists:
   - Current test configuration
   - Classes/modules already tested
   - Mock strategies in use

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid re-testing already covered components
- Build upon existing test infrastructure

If no docs exist: Start fresh and create them.

========================================
PHASE 1 - ANALYSIS
========================================

1. Detect Swift version from Package.swift or Xcode
2. Identify project type (iOS app, library, platform)
3. Detect UI framework (UIKit, SwiftUI, or both)
4. Document in process-docs/PROJECT_MEMORY.md
5. Report findings

Deliverable: Testing strategy documented

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

For iOS apps:
- Create UI test target in Xcode (XCUITest)
- Configure test schemes

For SPM libraries:
- Configure Package.swift with test targets
- Use swift test

Add to CI/CD:
```yaml
- name: Test
  run: xcodebuild test -scheme MyApp
```

Or for SPM:
```yaml
- name: Test
  run: swift test
```

Deliverable: Tests run in CI/CD

========================================
PHASE 3 - TEST PROJECT SETUP
========================================

1. Create test targets/directories

2. Implement shared test utilities:
   - Mock objects
   - Test doubles
   - Fixtures

3. Set up test schemes

Deliverable: Test infrastructure ready

========================================
PHASE 4 - WRITE TESTS (Iterative)
========================================

For each component:

1. Write unit tests (XCTest):
```swift
import XCTest
@testable import MyApp

class MyServiceTests: XCTestCase {
    func testShouldHandleSuccessCase() {
        // Given
        let service = MyService()
        
        // When
        let result = service.process("input")
        
        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

2. Write UI tests (if applicable):
```swift
class UITests: XCTestCase {
    func testButtonTap() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Submit"].tap()
        XCTAssertTrue(app.staticTexts["Success"].exists)
    }
}
```

3. Run tests - must pass
4. If bugs found: Log to LOGIC_ANOMALIES.md
5. Update STATUS-DETAILS.md
6. Propose commit
7. Repeat

Deliverable: All components tested

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

**PROJECT-MEMORY.md** (Universal):
```markdown
# Testing Implementation Memory

## Detected Versions
- Swift: {version from .swift-version or Xcode project}
- Xcode: {version}
- Project Type: {iOS/macOS/SPM/etc}
- UI Framework: {UIKit/SwiftUI}

## Framework Choices
- Test Framework: XCTest (Apple official)
- Why: Built-in, best Xcode integration

## Key Decisions
- Test location: {ProjectName}Tests/
- Mocking strategy: Protocol-based
- Coverage target: 80%+

## Lessons Learned
- {Challenges}
- {Solutions}
\```

**LOGIC-ANOMALIES.md** (Universal):
```markdown
# Logic Anomalies Found

## Bugs Discovered (Not Fixed)
1. **File**: UserService.swift:45
   **Issue**: Description
   **Impact**: Severity
   **Note**: Logged only, not fixed

## Code Smells
- {Areas needing refactoring}

## Missing Tests
- {Classes needing coverage}
\```

**TESTING-SETUP.md** (Process-specific):
```markdown
# Testing Setup Guide

## Quick Start
\```bash
# Xcode
Cmd+U                     # Run all tests
Cmd+Option+U              # Build for testing
swift test                # SPM projects

# Command line
xcodebuild test -scheme {SchemeName} -destination 'platform=iOS Simulator,name=iPhone 15'
\```

## Configuration
- Framework: XCTest (built-in)
- Xcode Version: {version}
- Swift Version: {version}
- Coverage Target: 80%+

## Test Structure
- Unit: {Project}Tests/{Module}Tests.swift
- UI: {Project}UITests/
- Integration: {Project}Tests/Integration/

## Mocking Strategy
- Protocols: Define testable interfaces
- Dependency Injection: Pass mocks via init
- URLSession: URLProtocol mocking

## Components Tested
- [ ] ViewModel A
- [ ] Service B
- [x] Repository C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80%
- Reports: Xcode > Report Navigator > Coverage

## Troubleshooting
- **Tests not running**: Check scheme has test target enabled
- **Mock not working**: Verify protocol conformance
- **Coverage not showing**: Enable code coverage in scheme

## Maintenance
- Update Swift: Xcode > Settings > Components
- Run tests: Cmd+U or xcodebuild test
- View coverage: Xcode > Report Navigator > select test run
\```

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Execute Phase 1 - detect Swift version and project type
CONTINUE: Execute phases 2-4 iteratively
FINISH: Update all documentation files
REMEMBER: Use XCTest, don't fix bugs, iterate, document for catch-up
```

---

## Quick Reference

**What you get**: Complete test infrastructure with XCTest  
**Time**: 4-8 hours depending on project size  
**Output**: Comprehensive test coverage for Swift project
