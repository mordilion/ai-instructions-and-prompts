# Swift Testing Implementation Process

> **Purpose**: Establish comprehensive testing infrastructure for Swift projects

## Critical Requirements

> **ALWAYS**: Detect Swift version from `Package.swift` or Xcode project settings
> **ALWAYS**: Match detected version in CI/CD and test configuration
> **ALWAYS**: Use your team's workflow for branching and commits (adapt as needed)
> **NEVER**: Fix production code bugs found during testing (log only)

## Workflow Adaptation

> **IMPORTANT**: This guide focuses on OBJECTIVES, not specific workflows.  
> **Your team's conventions take precedence** for Git, commits, Docker, CI/CD.

## Tech Stack

**Required**:
- **Test Framework**: XCTest (built-in)
- **Assertions**: XCTAssert* functions
- **Mocking**: Protocol-based mocking or manual mocks
- **UI Testing**: XCUITest (for iOS/macOS apps)
- **Async Testing**: XCTestExpectation or async/await
- **Runtime**: Match detected Swift version

**Optional**:
- Quick/Nimble (BDD-style syntax)
- OHHTTPStubs (HTTP mocking)
- Cuckoo (mocking framework)

## Infrastructure Templates

> **ALWAYS**: Replace `{SWIFT_VERSION}` and `{XCODE_VERSION}` with detected versions

**File**: `docker/Dockerfile.tests` (for Linux/CI)
```dockerfile
FROM swift:{SWIFT_VERSION}-focal
WORKDIR /app
COPY Package.swift ./
RUN swift package resolve
COPY . .
RUN swift build
```

**CI/CD Integration**:

> **NEVER**: Overwrite existing pipeline. Merge this step only.

**GitHub Actions (Xcode)**:
```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme YourScheme \
      -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
      -enableCodeCoverage YES \
      -resultBundlePath TestResults
```

**GitHub Actions (SPM)**:
```yaml
- name: Run Tests
  run: swift test --enable-code-coverage
```

**GitLab CI**:
```yaml
test:
  image: swift:{SWIFT_VERSION}
  script:
    - swift test --enable-code-coverage
  artifacts:
    paths:
      - .build/debug/codecov/
```

## Implementation Phases

> **For each phase**: Use your team's workflow

### Phase 1: Analysis

**Objective**: Understand project structure and test requirements

1. Detect Swift version from `Package.swift` or Xcode
2. Identify project type (iOS App/macOS App/SPM Package/Vapor)
3. Analyze existing test targets

**Deliverable**: Testing strategy documented

### Phase 2: Infrastructure

**Objective**: Set up test target and coverage

1. Create test target if missing (Xcode or SPM)
2. Configure code coverage in Xcode scheme or SPM
3. Add/update CI/CD pipeline test step

**Deliverable**: Tests can run locally and in CI/CD

### Phase 3: Test Structure

**Objective**: Establish test directory organization

1. Create test structure: `Tests/.../Unit/`, `Integration/`, `Helpers/`
2. Create base test classes: `BaseTestCase.swift`, `MockDataFactory.swift`

**Deliverable**: Test structure in place

### Phase 4: Test Implementation (Iterative)

**Objective**: Write tests for all components

**For each component**:
1. Understand component behavior
2. Write tests (unit/integration/UI)
3. Ensure tests pass
4. Log bugs found (don't fix production code)

**Continue until**: All critical components tested

## Test Patterns

### Basic XCTest Pattern
```swift
import XCTest
@testable import YourModule

final class UserServiceTests: XCTestCase {
    
    var sut: UserService!
    
    override func setUp() {
        super.setUp()
        sut = UserService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCreateUser_WithValidData_ReturnsUser() {
        // Given
        let email = "john@example.com"
        let name = "John Doe"
        
        // When
        let user = sut.createUser(email: email, name: name)
        
        // Then
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.name, name)
    }
    
    func testCreateUser_WithInvalidEmail_ThrowsError() {
        // Given
        let invalidEmail = "invalid"
        
        // When/Then
        XCTAssertThrowsError(try sut.createUser(email: invalidEmail, name: "John")) { error in
            XCTAssertEqual(error as? ValidationError, .invalidEmail)
        }
    }
}
```

### Protocol-Based Mocking Pattern
```swift
// Protocol for dependency
protocol UserRepository {
    func findUser(id: Int) -> User?
}

// Mock implementation
class MockUserRepository: UserRepository {
    var findUserReturnValue: User?
    var findUserCallCount = 0
    var findUserReceivedId: Int?
    
    func findUser(id: Int) -> User? {
        findUserCallCount += 1
        findUserReceivedId = id
        return findUserReturnValue
    }
}

// Test
class UserServiceTests: XCTestCase {
    
    func testFindUser_CallsRepository() {
        // Given
        let mockRepo = MockUserRepository()
        mockRepo.findUserReturnValue = User(id: 1, name: "John")
        let sut = UserService(repository: mockRepo)
        
        // When
        let user = sut.findUser(id: 1)
        
        // Then
        XCTAssertEqual(mockRepo.findUserCallCount, 1)
        XCTAssertEqual(mockRepo.findUserReceivedId, 1)
        XCTAssertEqual(user?.name, "John")
    }
}
```

### Async/Await Testing Pattern (Swift 5.5+)
```swift
import XCTest
@testable import YourModule

final class AsyncServiceTests: XCTestCase {
    
    func testFetchData_ReturnsValidData() async throws {
        // Given
        let sut = AsyncService()
        
        // When
        let result = try await sut.fetchData(key: "test")
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.status, "success")
    }
}
```

### Combine Testing Pattern
```swift
import XCTest
import Combine
@testable import YourModule

final class ViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    func testLoadUsers_UpdatesState() {
        // Given
        let sut = UserViewModel()
        let expectation = expectation(description: "Users loaded")
        
        // When
        sut.$users
            .dropFirst() // Skip initial value
            .sink { users in
                // Then
                XCTAssertEqual(users.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadUsers()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### SwiftUI View Testing Pattern
```swift
import XCTest
import ViewInspector
@testable import YourModule

final class UserViewTests: XCTestCase {
    
    func testUserView_DisplaysUserName() throws {
        // Given
        let user = User(id: 1, name: "John Doe")
        let sut = UserView(user: user)
        
        // When
        let text = try sut.inspect().find(text: "John Doe")
        
        // Then
        XCTAssertNotNil(text)
    }
}
```

### UI Testing Pattern (XCUITest)
```swift
import XCTest

final class LoginUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testLogin_WithValidCredentials_ShowsHomeScreen() {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Login"]
        
        // When
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Then
        XCTAssertTrue(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
    }
}
```

### Vapor (Server-Side) Testing Pattern
```swift
import XCTest
import XCTVapor
@testable import App

final class UserRoutesTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testGetUser_ReturnsUser() async throws {
        try app.test(.GET, "/api/users/1") { response in
            XCTAssertEqual(response.status, .ok)
            let user = try response.content.decode(User.self)
            XCTAssertEqual(user.id, 1)
        }
    }
}
```

## Documentation (`process-docs/`)

- **STATUS-DETAILS.md**: Component test checklist
- **PROJECT_MEMORY.md**: Detected Swift version + project type + lessons learned
- **LOGIC_ANOMALIES.md**: Found bugs (audit only, don't fix)

## Usage

**Initial**:
```
Act as Senior SDET. Start Swift testing implementation.
Phase 1: Create branch `poc/test-establishing/init-analysis`, detect Swift version, analyze project type, initialize docs.
```

**Continue**:
```
Act as Senior SDET. Check STATUS-DETAILS.md for next phase/component. Execute and propose commit.
```

