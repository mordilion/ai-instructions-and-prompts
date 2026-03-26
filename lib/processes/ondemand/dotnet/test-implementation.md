# .NET Testing Implementation - Copy This Prompt

> **Type**: One-time setup process (iterative, multi-phase)  
> **When to use**: When establishing testing infrastructure in a .NET project  
> **Instructions**: Copy the entire prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET TESTING IMPLEMENTATION
========================================

CONTEXT:
You are implementing comprehensive .NET testing infrastructure for this project.

CRITICAL REQUIREMENTS:
- ALWAYS detect .NET version from .csproj TargetFramework (e.g., net6.0, net8.0)
- ALWAYS match detected version in Docker images, pipelines, and test projects
- NEVER fix production code bugs found during testing (log in LOGIC_ANOMALIES.md only)
- Use team's Git workflow (no prescribed branch names or commit patterns)

========================================
TECH STACK SELECTION
========================================

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:

1. Read PROJECT-MEMORY.md if it exists:
   - .NET version used
   - Test framework chosen (xUnit/NUnit/MSTest)
   - Mocking library selected
   - Key decisions made
   - Lessons learned

2. Read LOGIC-ANOMALIES.md if it exists:
   - Bugs found but not fixed
   - Code smells discovered
   - Areas needing refactoring

3. Read TESTING-SETUP.md if it exists:
   - Current test configuration
   - Components already tested
   - Mock strategies in use
   - Test builders available

Use this information to:
- Continue from where previous work stopped
- Maintain consistency with existing decisions
- Avoid re-testing already covered components
- Build upon existing test infrastructure

If no docs exist: Start fresh and create them.

========================================

TEST FRAMEWORK (choose one):

1. xUnit ⭐ RECOMMENDED
   - Most popular in .NET ecosystem
   - Default in .NET templates (dotnet new xunit)
   - Used by .NET Core team and most open-source projects
   - Modern async/await support
   - Theory tests with InlineData/MemberData
   - Clean, attribute-based syntax
   Install: dotnet add package xUnit --version 2.6.0 or later

2. NUnit
   - Mature, feature-rich (since 2004)
   - Good for teams migrating from Java (similar to JUnit)
   - Extensive assertion library
   - Test case attributes
   Install: dotnet add package NUnit --version 4.0.0 or later

3. MSTest
   - Microsoft's official framework
   - Excellent Visual Studio integration
   - Good for corporate environments
   - DataRow attributes for parameterized tests
   Install: dotnet add package MSTest.TestFramework --version 3.0.0 or later

ASSERTION LIBRARY (choose one):

1. FluentAssertions ⭐ RECOMMENDED
   - Highly readable: result.Should().Be(expected)
   - Extensible for custom assertions
   - Rich exception messages
   - Works with all test frameworks
   Install: dotnet add package FluentAssertions --version 6.12.0 or later

2. Shouldly
   - Similar to FluentAssertions
   - Slightly different syntax: result.ShouldBe(expected)
   Install: dotnet add package Shouldly --version 4.2.0 or later

3. Built-in Assertions
   - xUnit.Assert, NUnit.Assert, or Assert (MSTest)
   - No additional dependencies
   - Less readable but functional

MOCKING LIBRARY (choose one):

1. Moq ⭐ RECOMMENDED
   - Most popular .NET mocking library
   - Simple, intuitive API
   - Mock<T> pattern
   - Setup/Verify methods
   Install: dotnet add package Moq --version 4.20.0 or later
   Example: var mock = new Mock<IService>();
            mock.Setup(x => x.Method()).Returns(value);

2. NSubstitute
   - Clean, concise syntax
   - Less magic strings
   - Substitute.For<T> pattern
   Install: dotnet add package NSubstitute --version 5.1.0 or later
   Example: var sub = Substitute.For<IService>();
            sub.Method().Returns(value);

3. FakeItEasy
   - Discoverable API
   - A.Fake<T> pattern
   - No magic strings
   Install: dotnet add package FakeItEasy --version 8.0.0 or later

========================================
INFRASTRUCTURE SETUP
========================================

DOCKERFILE.TESTS (create in docker/Dockerfile.tests):

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:{VERSION} AS build
WORKDIR /src
COPY . .
RUN dotnet restore && dotnet build -c Release --no-restore

FROM build AS test
RUN dotnet test --no-build --verbosity normal --logger "trx;LogFileName=test_results.trx"

# Optional: Generate coverage
FROM build AS coverage
RUN dotnet test --no-build --collect:"XPlat Code Coverage" --results-directory ./coverage
```

Replace {VERSION} with detected .NET version (e.g., 8.0, 6.0)

DOCKER-COMPOSE.TESTS.YML (create in docker-compose.tests.yml):

```yaml
version: '3.8'
services:
  tests:
    build:
      context: .
      dockerfile: docker/Dockerfile.tests
      target: test
    volumes:
      - ./test-results:/src/test-results
```

GITHUB ACTIONS CI INTEGRATION (add to .github/workflows/*.yml):

```yaml
- name: Test
  run: |
    dotnet test --verbosity normal \
      --logger "trx;LogFileName=test_results.trx" \
      --collect:"XPlat Code Coverage" \
      --results-directory ./coverage
    
- name: Publish Test Results
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: test-results
    path: '**/test_results.trx'
```

========================================
PHASE 1 - ANALYSIS & PLANNING
========================================

Objective: Understand project structure and create testing strategy

Steps:
1. Detect .NET version from .csproj files:
   - Look for <TargetFramework>net6.0</TargetFramework> or similar
   - Document in process-docs/PROJECT_MEMORY.md

2. Identify project type:
   - Web API (ASP.NET Core)
   - Console application
   - Class library
   - Blazor app
   - gRPC service

3. Choose test framework based on team preference:
   - If no preference → xUnit (industry standard)
   - If migrating from Java → NUnit
   - If corporate/Microsoft shop → MSTest

4. Analyze existing test infrastructure:
   - Check for existing test projects
   - Identify testing patterns already in use
   - Review CI/CD configuration

5. Create testing strategy document:
   - Test framework choice and rationale
   - Assertion library choice
   - Mocking library choice
   - Test organization approach
   - Coverage targets (recommended: 80% line, 75% branch)

Deliverable: 
- process-docs/PROJECT_MEMORY.md created with:
  * Detected .NET version
  * Project type
  * Chosen frameworks and rationale
  * Testing strategy

Example PROJECT_MEMORY.md:
```
# .NET Testing Implementation

## Detected Configuration
- .NET Version: net8.0
- Project Type: ASP.NET Core Web API
- Existing Tests: None found

## Framework Choices
- Test Framework: xUnit (team preference, industry standard)
- Assertions: FluentAssertions (readability)
- Mocking: Moq (team familiar with it)

## Strategy
- Unit tests for all services and controllers
- Integration tests for API endpoints
- Target: 80% line coverage, 75% branch coverage
```

========================================
PHASE 2 - INFRASTRUCTURE (Optional)
========================================

Objective: Set up Docker and CI/CD test infrastructure

Skip this phase if:
- Using cloud-based CI/CD only (GitHub Actions, Azure DevOps, etc.)
- Team doesn't use Docker for development

Steps:
1. Create Dockerfile.tests (see template above)
   - Use detected .NET SDK version
   - Multi-stage build (build → test → coverage)

2. Create docker-compose.tests.yml (see template above)
   - Mount test results directory
   - Configure any required services (database, Redis, etc.)

3. Test Docker setup locally:
   ```bash
   docker-compose -f docker-compose.tests.yml up --build
   ```

4. Update CI/CD pipeline:
   - Add test step with coverage collection
   - Publish test results as artifacts
   - Configure coverage reporting
   - Set coverage thresholds (fail if below 80%)

5. Document in PROJECT_MEMORY.md:
   - Docker configuration added
   - CI/CD integration complete

Deliverable:
- docker/Dockerfile.tests created
- docker-compose.tests.yml created
- CI/CD pipeline updated with test step
- Tests run successfully in CI/CD

========================================
PHASE 3 - TEST PROJECTS SETUP
========================================

Objective: Create test project structure and shared utilities

Steps:
1. Create test projects using dotnet CLI:
   
   For unit tests:
   ```bash
   dotnet new xunit -n YourProject.UnitTests
   cd YourProject.UnitTests
   dotnet add reference ../YourProject/YourProject.csproj
   dotnet add package FluentAssertions
   dotnet add package Moq
   ```

   For integration tests:
   ```bash
   dotnet new xunit -n YourProject.IntegrationTests
   cd YourProject.IntegrationTests
   dotnet add reference ../YourProject/YourProject.csproj
   dotnet add package Microsoft.AspNetCore.Mvc.Testing
   dotnet add package FluentAssertions
   ```

2. Add test projects to solution:
   ```bash
   dotnet sln add YourProject.UnitTests/YourProject.UnitTests.csproj
   dotnet sln add YourProject.IntegrationTests/YourProject.IntegrationTests.csproj
   ```

3. Create shared test utilities in UnitTests project:

   TestDataBuilder.cs:
   ```csharp
   public class TestDataBuilder
   {
       private readonly Faker _faker = new();
       
       public User CreateUser(Action<User>? customize = null)
       {
           var user = new User
           {
               Id = Guid.NewGuid(),
               Name = _faker.Name.FullName(),
               Email = _faker.Internet.Email()
           };
           customize?.Invoke(user);
           return user;
       }
   }
   ```

   BaseIntegrationTest.cs (for IntegrationTests):
   ```csharp
   public class BaseIntegrationTest : IClassFixture<WebApplicationFactory<Program>>
   {
       protected HttpClient Client { get; }
       
       public BaseIntegrationTest(WebApplicationFactory<Program> factory)
       {
           Client = factory.CreateClient();
       }
   }
   ```

4. Configure test settings (if needed):
   - Create appsettings.Test.json for integration tests
   - Set up test database connection strings
   - Configure in-memory providers for unit tests

5. Create initial test structure:
   ```
   YourProject.UnitTests/
   ├── Services/
   │   └── UserServiceTests.cs
   ├── Controllers/
   │   └── UsersControllerTests.cs
   ├── Helpers/
   │   └── TestDataBuilder.cs
   └── usings.cs (global usings)
   
   YourProject.IntegrationTests/
   ├── Api/
   │   └── UsersApiTests.cs
   ├── Helpers/
   │   └── BaseIntegrationTest.cs
   └── usings.cs
   ```

Deliverable:
- Test projects created and added to solution
- Shared test utilities implemented
- Test structure organized
- Ready for test implementation

========================================
PHASE 4 - TEST IMPLEMENTATION (Iterative)
========================================

Objective: Write comprehensive tests for all components

IMPORTANT: This phase is ITERATIVE. Implement tests component-by-component.

For EACH component, follow this workflow:

1. IDENTIFY component to test:
   - Check process-docs/STATUS-DETAILS.md for next component
   - Prioritize critical/complex components first
   - Example: UserService, AuthController, PaymentProcessor

2. UNDERSTAND component behavior:
   - Read component code
   - Identify public methods/endpoints
   - Understand dependencies
   - Identify edge cases and error scenarios

3. WRITE UNIT TESTS:
   
   Test structure example (xUnit + FluentAssertions + Moq):
   ```csharp
   public class UserServiceTests
   {
       private readonly Mock<IUserRepository> _mockRepo;
       private readonly UserService _sut; // System Under Test
       private readonly TestDataBuilder _builder;
       
       public UserServiceTests()
       {
           _mockRepo = new Mock<IUserRepository>();
           _sut = new UserService(_mockRepo.Object);
           _builder = new TestDataBuilder();
       }
       
       [Fact]
       public async Task GetUserById_ValidId_ReturnsUser()
       {
           // Arrange
           var user = _builder.CreateUser();
           _mockRepo.Setup(x => x.GetByIdAsync(user.Id))
                    .ReturnsAsync(user);
           
           // Act
           var result = await _sut.GetUserByIdAsync(user.Id);
           
           // Assert
           result.Should().NotBeNull();
           result.Id.Should().Be(user.Id);
           result.Name.Should().Be(user.Name);
       }
       
       [Fact]
       public async Task GetUserById_InvalidId_ThrowsNotFoundException()
       {
           // Arrange
           _mockRepo.Setup(x => x.GetByIdAsync(It.IsAny<Guid>()))
                    .ReturnsAsync((User?)null);
           
           // Act & Assert
           await Assert.ThrowsAsync<NotFoundException>(
               () => _sut.GetUserByIdAsync(Guid.NewGuid())
           );
       }
       
       [Theory]
       [InlineData("")]
       [InlineData(null)]
       [InlineData("   ")]
       public async Task CreateUser_InvalidName_ThrowsValidationException(string invalidName)
       {
           // Arrange
           var user = _builder.CreateUser(u => u.Name = invalidName);
           
           // Act & Assert
           await Assert.ThrowsAsync<ValidationException>(
               () => _sut.CreateUserAsync(user)
           );
       }
   }
   ```

   Key patterns:
   - AAA pattern (Arrange, Act, Assert)
   - One assertion per test (preferred) or related assertions
   - Test method naming: MethodName_Scenario_ExpectedResult
   - Use [Fact] for single test cases
   - Use [Theory] with [InlineData] for parameterized tests

4. WRITE INTEGRATION TESTS (if applicable):
   
   Example for API endpoint:
   ```csharp
   public class UsersApiTests : BaseIntegrationTest
   {
       public UsersApiTests(WebApplicationFactory<Program> factory) 
           : base(factory) { }
       
       [Fact]
       public async Task GetUsers_ReturnsSuccessAndUsers()
       {
           // Act
           var response = await Client.GetAsync("/api/users");
           
           // Assert
           response.StatusCode.Should().Be(HttpStatusCode.OK);
           var users = await response.Content.ReadFromJsonAsync<List<User>>();
           users.Should().NotBeNull();
       }
       
       [Fact]
       public async Task CreateUser_ValidData_ReturnsCreated()
       {
           // Arrange
           var newUser = new { Name = "John Doe", Email = "john@example.com" };
           
           // Act
           var response = await Client.PostAsJsonAsync("/api/users", newUser);
           
           // Assert
           response.StatusCode.Should().Be(HttpStatusCode.Created);
           var location = response.Headers.Location;
           location.Should().NotBeNull();
       }
   }
   ```

5. RUN tests locally:
   ```bash
   dotnet test
   ```
   - ALL tests must pass
   - Fix any failing tests immediately
   - Check coverage: dotnet test /p:CollectCoverage=true

6. IF BUGS FOUND in production code:
   - DO NOT FIX the bug
   - Log to process-docs/LOGIC_ANOMALIES.md:
     ```
     ## UserService.GetUserById
     - Issue: Returns null instead of throwing NotFoundException when user not found
     - Location: UserService.cs, line 45
     - Expected: Should throw NotFoundException
     - Test: UserServiceTests.GetUserById_InvalidId_ThrowsNotFoundException (currently failing, marked [Fact(Skip="Bug in production code")])
     ```
   - Mark test as skipped: [Fact(Skip = "Bug in production code - logged in LOGIC_ANOMALIES.md")]
   - Continue with other tests

7. UPDATE STATUS-DETAILS.md:
   ```
   ## Component Testing Status
   - [x] UserService - Complete (12 tests, 95% coverage)
   - [x] AuthController - Complete (8 tests, 90% coverage)
   - [ ] PaymentProcessor - In Progress
   - [ ] OrderService - Not Started
   ```

8. PROPOSE COMMIT:
   - Use team's commit message format
   - Example: "test: add comprehensive tests for UserService (12 tests, 95% coverage)"
   - Include:
     * Number of tests added
     * Coverage achieved
     * Any skipped tests due to bugs

9. WAIT for user confirmation before committing

10. REPEAT for next component until all are tested

Deliverable (per component):
- Unit tests written and passing
- Integration tests written and passing (if applicable)
- STATUS-DETAILS.md updated
- Bugs logged in LOGIC_ANOMALIES.md (if any)
- Code committed

Final Deliverable (all components):
- Comprehensive test coverage (target: 80% line, 75% branch)
- All components tested
- Test documentation complete

========================================
DOCUMENTATION
========================================

Create/update these files for team catch-up:

1. TESTING-SETUP.md (Process-specific):
```markdown
# Testing Setup Guide

## Quick Start
\```bash
dotnet test              # Run all tests
dotnet test --logger "console;verbosity=detailed"  # Detailed output  
dotnet test /p:CollectCoverage=true  # With coverage
\```

## Configuration
- Framework: xUnit v{version} (or NUnit/MSTest)
- .NET Version: net{version}
- Mocking: Moq v{version}
- Assertions: FluentAssertions v{version}

## Test Structure
- Unit: tests/{Project}.UnitTests/
- Integration: tests/{Project}.IntegrationTests/
- TestBuilders: tests/TestBuilders/

## Mocking Strategy
- HTTP: HttpClient mocking or WireMock
- Database: InMemory provider or TestContainers
- Time: IDateTimeProvider interface

## Components Tested
- [ ] Component A
- [ ] Service B
- [x] Controller C (completed)

## Coverage Status
- Current: {percentage}%
- Target: 80% line, 75% branch
- Reports: coverage/index.html

## Troubleshooting
- **Async tests hang**: Check for missing await
- **Mock not working**: Verify interface/virtual methods
- **Coverage not generated**: Install coverlet.collector

## Maintenance
- Update packages: dotnet list package --outdated
- Run tests: dotnet test
- Generate coverage: dotnet test /p:CollectCoverage=true
\```

2. PROJECT-MEMORY.md (Universal):
```markdown
# Testing Implementation Status

## Components
- [x] UserService (12 tests, 95% coverage)
- [x] AuthController (8 tests, 90% coverage)
- [x] PaymentProcessor (15 tests, 85% coverage)
- [x] OrderService (10 tests, 80% coverage)

## Coverage Summary
- Overall Line Coverage: 87%
- Overall Branch Coverage: 82%
- Target Met: ✅ Yes (80% line, 75% branch)

## Skipped Tests
- UserServiceTests.SomeTest - Bug in production code (see LOGIC_ANOMALIES.md)
```

Replace existing with:
```markdown
```markdown
# .NET Testing Implementation

## Configuration
- .NET Version: net8.0
- Test Framework: xUnit 2.6.0
- Assertions: FluentAssertions 6.12.0
- Mocking: Moq 4.20.0

## Lessons Learned
- TestDataBuilder pattern very useful for reducing test setup
- Integration tests caught 3 bugs unit tests missed
- Moq setup with It.IsAny<> too permissive - prefer specific values
- FluentAssertions error messages much clearer than built-in
```

3. LOGIC-ANOMALIES.md (Universal):
```markdown
# Logic Anomalies Found During Testing

## UserService.GetUserById
- **Issue**: Returns null instead of throwing NotFoundException
- **Location**: UserService.cs, line 45
- **Expected Behavior**: Should throw NotFoundException when user not found
- **Test**: UserServiceTests.GetUserById_InvalidId_ThrowsNotFoundException
- **Status**: Logged, not fixed (audit only)
```

========================================
EXECUTION INSTRUCTIONS
========================================

START HERE:

1. Read existing documentation (CATCH-UP section above)
   - Check PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, TESTING-SETUP.md
   - Understand what's already done
   - Continue from where work stopped

2. Execute Phase 1 - ANALYSIS & PLANNING
   - Detect .NET version from .csproj
   - Choose test frameworks
   - Update PROJECT-MEMORY.md
   - Report findings to user

2. After user confirmation, execute Phase 2 - INFRASTRUCTURE (if needed)
   - Create Docker files
   - Update CI/CD
   - Test setup

3. Execute Phase 3 - TEST PROJECTS SETUP
   - Create test projects
   - Add shared utilities
   - Set up structure

4. Execute Phase 4 - TEST IMPLEMENTATION
   - IMPORTANT: Work component-by-component
   - Create STATUS-DETAILS.md to track progress
   - For each component:
     * Write tests
     * Run tests (must pass)
     * Log any bugs found (don't fix)
     * Update STATUS-DETAILS.md
     * Propose commit
     * Wait for confirmation
   - Repeat until all components tested

5. Final review:
   - Check coverage meets targets
   - Review all documentation
   - Report completion

REMEMBER:
- Work iteratively, one component at a time
- Always wait for user confirmation before committing
- Never fix production bugs found during testing
- Always use team's Git workflow and commit format
- Always detect and use correct .NET version

BEGIN: Start with Phase 1 - detect .NET version and create testing strategy.
```

---

## 📌 Quick Reference

**What this prompt does**:
- Implements comprehensive .NET testing from scratch
- Detects .NET version automatically
- Guides through framework selection
- Creates complete test infrastructure
- Implements tests iteratively with progress tracking

**When to use**:
- Setting up testing for a new .NET project
- Adding tests to an existing project without any
- Establishing testing standards for a team

**What you'll get**:
- Complete test project structure
- Shared test utilities
- Comprehensive test coverage (80%+ target)
- Docker and CI/CD integration (optional)
- Documentation of testing strategy and progress
