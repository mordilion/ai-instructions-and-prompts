---
globs: ["**/*Tests.cs", "**/*Test*.cs", "**/*.Tests/**"]
alwaysApply: false
---

# .NET Testing Rules (NUnit + Moq)

<checklist>
## Before Writing Tests
- [ ] Identify the class/method under test
- [ ] List all dependencies to mock
- [ ] Define test scenarios (happy path, edge cases, errors)
- [ ] Check existing test patterns in the project
- [ ] Ensure test names describe behavior, not implementation
</checklist>

<naming>
## Naming Conventions

### Test Class Naming
```csharp
// Pattern: {ClassUnderTest}Tests
public class UserServiceTests { }
public class OrderRepositoryTests { }
public class MyLifeAdvertServiceTests { }
```

### Test Method Naming
```csharp
// Pattern: {MethodName}_{Scenario}_{ExpectedBehavior}
// Or: {MethodName}_Should{ExpectedBehavior}_When{Scenario}

// GOOD: Descriptive names
[Test]
public async Task GetById_WithValidId_ReturnsUser() { }

[Test]
public async Task GetById_WithInvalidId_ReturnsNull() { }

[Test]
public async Task Create_WithDuplicateEmail_ThrowsException() { }

[Test]
public async Task ProcessOrder_ShouldSendNotification_WhenOrderCompleted() { }

// BAD: Vague names
[Test]
public void Test1() { }

[Test]
public void GetByIdTest() { }
```

### Test File Organization
```
tests/
├── Services/
│   ├── UserServiceTests/
│   │   ├── GetByIdTests.cs
│   │   ├── CreateTests.cs
│   │   └── DeleteTests.cs
│   └── OrderServiceTests/
│       └── ProcessOrderTests.cs
├── Repositories/
└── Controllers/
```
</naming>

<structure>
## Test Structure (AAA Pattern)

Always use **Arrange-Act-Assert** pattern with clear separation.

```csharp
[Test]
public async Task GetById_WithValidId_ReturnsUser()
{
    // Arrange - Setup test data and mocks
    var userId = 1;
    var expectedUser = new User { Id = userId, Name = "John" };
    _userRepositoryMock
        .Setup(r => r.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
        .ReturnsAsync(expectedUser);

    // Act - Execute the method under test
    var result = await _sut.GetByIdAsync(userId, CancellationToken.None);

    // Assert - Verify the result
    Assert.That(result, Is.Not.Null);
    Assert.That(result.Id, Is.EqualTo(userId));
    Assert.That(result.Name, Is.EqualTo("John"));
}
```

### System Under Test (SUT)
```csharp
// Use _sut for the class being tested
private UserService _sut;
private Mock<IUserRepository> _userRepositoryMock;

[SetUp]
public void Setup()
{
    _userRepositoryMock = new Mock<IUserRepository>();
    _sut = new UserService(_userRepositoryMock.Object);
}
```
</structure>

<nunit>
## NUnit Patterns

### Test Fixture Setup
```csharp
[TestFixture]
public class UserServiceTests
{
    private UserService _sut;
    private Mock<IUserRepository> _repositoryMock;
    private Mock<ILogger<UserService>> _loggerMock;

    [SetUp]
    public void Setup()
    {
        _repositoryMock = new Mock<IUserRepository>();
        _loggerMock = new Mock<ILogger<UserService>>();
        _sut = new UserService(_repositoryMock.Object, _loggerMock.Object);
    }

    [TearDown]
    public void TearDown()
    {
        // Cleanup if needed (rare for unit tests)
    }
}
```

### Common Attributes
```csharp
[TestFixture]           // Marks class as test container
[Test]                  // Marks method as test
[SetUp]                 // Runs before each test
[TearDown]              // Runs after each test
[OneTimeSetUp]          // Runs once before all tests in fixture
[OneTimeTearDown]       // Runs once after all tests in fixture
[Ignore("reason")]      // Skip test with reason
[TestCase(1, "a")]      // Parameterized test
[Category("Integration")] // Test categorization
```

### Parameterized Tests
```csharp
[TestCase(1, "Active")]
[TestCase(2, "Inactive")]
[TestCase(3, "Pending")]
public async Task GetStatus_WithValidId_ReturnsCorrectStatus(int id, string expectedStatus)
{
    // Arrange
    _repositoryMock.Setup(r => r.GetStatusAsync(id, It.IsAny<CancellationToken>()))
        .ReturnsAsync(expectedStatus);

    // Act
    var result = await _sut.GetStatusAsync(id, CancellationToken.None);

    // Assert
    Assert.That(result, Is.EqualTo(expectedStatus));
}
```

### NUnit Assertions
```csharp
// Equality
Assert.That(result, Is.EqualTo(expected));
Assert.That(result, Is.Not.EqualTo(other));

// Null checks
Assert.That(result, Is.Null);
Assert.That(result, Is.Not.Null);

// Boolean
Assert.That(result, Is.True);
Assert.That(result, Is.False);

// Collections
Assert.That(list, Is.Empty);
Assert.That(list, Is.Not.Empty);
Assert.That(list, Has.Count.EqualTo(3));
Assert.That(list, Contains.Item(expectedItem));
Assert.That(list, Has.Exactly(2).Items.With.Property("Status").EqualTo("Active"));

// Strings
Assert.That(result, Does.StartWith("Hello"));
Assert.That(result, Does.Contain("world"));
Assert.That(result, Is.EqualTo("test").IgnoreCase);

// Exceptions
Assert.ThrowsAsync<ArgumentException>(async () => await _sut.Method());
var ex = Assert.ThrowsAsync<ValidationException>(async () => await _sut.Method());
Assert.That(ex.Message, Does.Contain("required"));

// Type checking
Assert.That(result, Is.TypeOf<UserDto>());
Assert.That(result, Is.InstanceOf<IUser>());
```
</nunit>

<moq>
## Moq Patterns

### Basic Setup
```csharp
var mock = new Mock<IUserRepository>();

// Setup method with specific argument
mock.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
    .ReturnsAsync(new User { Id = 1 });

// Setup method with any argument
mock.Setup(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
    .ReturnsAsync(new User());

// Setup method to throw
mock.Setup(r => r.GetByIdAsync(-1, It.IsAny<CancellationToken>()))
    .ThrowsAsync(new ArgumentException("Invalid ID"));

// Setup property
mock.Setup(r => r.ConnectionString).Returns("test-connection");
```

### Argument Matchers
```csharp
It.IsAny<int>()                    // Any int
It.Is<int>(x => x > 0)             // Int greater than 0
It.IsIn(1, 2, 3)                   // One of these values
It.IsNotIn(0, -1)                  // Not one of these
It.IsRegex("[A-Z]+")               // Matches regex
It.IsAny<CancellationToken>()      // Any cancellation token (common)
```

### Verify Calls
```csharp
// Verify method was called
mock.Verify(r => r.SaveAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()), Times.Once);

// Verify with specific arguments
mock.Verify(r => r.SaveAsync(
    It.Is<User>(u => u.Email == "test@test.com"),
    It.IsAny<CancellationToken>()),
    Times.Once);

// Verify call count
mock.Verify(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()), Times.Exactly(2));
mock.Verify(r => r.Delete(It.IsAny<int>()), Times.Never);

// Verify no other calls
mock.VerifyNoOtherCalls();
```

### Callback for Side Effects
```csharp
var capturedUser = default(User);
mock.Setup(r => r.SaveAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()))
    .Callback<User, CancellationToken>((user, ct) => capturedUser = user)
    .ReturnsAsync(true);

// After Act
Assert.That(capturedUser.Name, Is.EqualTo("Expected Name"));
```

### Sequential Returns
```csharp
mock.SetupSequence(r => r.GetNextAsync())
    .ReturnsAsync(item1)
    .ReturnsAsync(item2)
    .ThrowsAsync(new InvalidOperationException("No more items"));
```
</moq>

<async>
## Async Testing

### Async Test Methods
```csharp
// GOOD: Async test
[Test]
public async Task GetById_WithValidId_ReturnsUser()
{
    // Arrange
    _mockRepo.Setup(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()))
        .ReturnsAsync(new User { Id = 1 });

    // Act
    var result = await _sut.GetByIdAsync(1, CancellationToken.None);

    // Assert
    Assert.That(result, Is.Not.Null);
}

// BAD: Blocking on async
[Test]
public void GetById_WithValidId_ReturnsUser()
{
    var result = _sut.GetByIdAsync(1, CancellationToken.None).Result; // BLOCKS!
}
```

### Testing Async Exceptions
```csharp
[Test]
public void Create_WithInvalidData_ThrowsValidationException()
{
    // Arrange
    var invalidUser = new User { Email = "" };

    // Act & Assert
    Assert.ThrowsAsync<ValidationException>(
        async () => await _sut.CreateAsync(invalidUser, CancellationToken.None)
    );
}

// With message verification
[Test]
public async Task Create_WithInvalidData_ThrowsWithMessage()
{
    var invalidUser = new User { Email = "" };

    var ex = Assert.ThrowsAsync<ValidationException>(
        async () => await _sut.CreateAsync(invalidUser, CancellationToken.None)
    );

    Assert.That(ex.Message, Does.Contain("Email is required"));
}
```

### CancellationToken in Tests
```csharp
// Always use CancellationToken.None or create test token
[Test]
public async Task LongOperation_WhenCancelled_ThrowsOperationCancelled()
{
    // Arrange
    using var cts = new CancellationTokenSource();
    cts.Cancel();

    // Act & Assert
    Assert.ThrowsAsync<OperationCanceledException>(
        async () => await _sut.LongOperationAsync(cts.Token)
    );
}
```
</async>

<refit>
## Refit Client Mocking

Refit clients are interfaces - mock them like any other interface.

### Basic Refit Mock
```csharp
[TestFixture]
public class MyLifeAdvertServiceTests
{
    private MyLifeAdvertService _sut;
    private Mock<IW2pClient> _w2pClientMock;
    private Mock<IProductManagementClient> _productClientMock;
    private Mock<ICRMProxyClient> _crmClientMock;

    [SetUp]
    public void Setup()
    {
        _w2pClientMock = new Mock<IW2pClient>();
        _productClientMock = new Mock<IProductManagementClient>();
        _crmClientMock = new Mock<ICRMProxyClient>();

        _sut = new MyLifeAdvertService(
            _w2pClientMock.Object,
            _productClientMock.Object,
            _crmClientMock.Object
        );
    }

    [Test]
    public async Task GenerateAdvert_WithValidData_CallsW2pClient()
    {
        // Arrange
        var request = new AdvertRequest { PharmacyId = 123 };
        var expectedResponse = new W2pResponse { Success = true, Url = "http://test.com" };

        _w2pClientMock
            .Setup(c => c.GenerateMyLifeAdvertisementAsync(It.IsAny<AdvertRequest>()))
            .ReturnsAsync(expectedResponse);

        // Act
        var result = await _sut.GenerateAdvertAsync(request, CancellationToken.None);

        // Assert
        Assert.That(result.Success, Is.True);
        _w2pClientMock.Verify(
            c => c.GenerateMyLifeAdvertisementAsync(It.Is<AdvertRequest>(r => r.PharmacyId == 123)),
            Times.Once
        );
    }
}
```

### Mocking Refit with ApiResponse
```csharp
// When Refit returns ApiResponse<T>
_clientMock
    .Setup(c => c.GetDataAsync(It.IsAny<int>()))
    .ReturnsAsync(new ApiResponse<DataDto>(
        new HttpResponseMessage(HttpStatusCode.OK),
        new DataDto { Id = 1 },
        new RefitSettings()
    ));

// For error responses
_clientMock
    .Setup(c => c.GetDataAsync(-1))
    .ReturnsAsync(new ApiResponse<DataDto>(
        new HttpResponseMessage(HttpStatusCode.NotFound),
        null,
        new RefitSettings()
    ));
```

### Mocking Refit Exceptions
```csharp
// Simulate HTTP error
_clientMock
    .Setup(c => c.GetDataAsync(It.IsAny<int>()))
    .ThrowsAsync(await ApiException.Create(
        new HttpRequestMessage(),
        HttpMethod.Get,
        new HttpResponseMessage(HttpStatusCode.InternalServerError),
        new RefitSettings()
    ));
```
</refit>

<efcore>
## EF Core Mocking

### Mock DbSet with Helper
```csharp
// MockUtils.cs - Helper class
public static class MockUtils
{
    public static Mock<DbSet<T>> MockDbSet<T>(List<T> data) where T : class
    {
        var queryable = data.AsQueryable();
        var mockSet = new Mock<DbSet<T>>();

        mockSet.As<IAsyncEnumerable<T>>()
            .Setup(m => m.GetAsyncEnumerator(It.IsAny<CancellationToken>()))
            .Returns(new TestAsyncEnumerator<T>(queryable.GetEnumerator()));

        mockSet.As<IQueryable<T>>()
            .Setup(m => m.Provider)
            .Returns(new TestAsyncQueryProvider<T>(queryable.Provider));

        mockSet.As<IQueryable<T>>().Setup(m => m.Expression).Returns(queryable.Expression);
        mockSet.As<IQueryable<T>>().Setup(m => m.ElementType).Returns(queryable.ElementType);
        mockSet.As<IQueryable<T>>().Setup(m => m.GetEnumerator()).Returns(queryable.GetEnumerator());

        return mockSet;
    }
}

// Usage in test
[Test]
public async Task GetAllActive_ReturnsOnlyActiveUsers()
{
    // Arrange
    var users = new List<User>
    {
        new User { Id = 1, IsActive = true },
        new User { Id = 2, IsActive = false },
        new User { Id = 3, IsActive = true }
    };

    var mockSet = MockUtils.MockDbSet(users);
    _contextMock.Setup(c => c.Users).Returns(mockSet.Object);

    // Act
    var result = await _sut.GetAllActiveAsync(CancellationToken.None);

    // Assert
    Assert.That(result, Has.Count.EqualTo(2));
}
```

### In-Memory Database Alternative
```csharp
[TestFixture]
public class UserRepositoryTests
{
    private AppDbContext _context;
    private UserRepository _sut;

    [SetUp]
    public void Setup()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new AppDbContext(options);
        _sut = new UserRepository(_context);
    }

    [TearDown]
    public void TearDown()
    {
        _context.Dispose();
    }

    [Test]
    public async Task Add_WithValidUser_PersistsToDatabase()
    {
        // Arrange
        var user = new User { Name = "Test", Email = "test@test.com" };

        // Act
        await _sut.AddAsync(user, CancellationToken.None);
        await _context.SaveChangesAsync();

        // Assert
        var saved = await _context.Users.FirstOrDefaultAsync(u => u.Email == "test@test.com");
        Assert.That(saved, Is.Not.Null);
        Assert.That(saved.Name, Is.EqualTo("Test"));
    }
}
```
</efcore>

<coverage>
## Test Coverage Guidelines

### What to Test
- **Business logic** - Core domain rules
- **Service methods** - Public API
- **Edge cases** - Null inputs, empty collections, boundaries
- **Error paths** - Exceptions, validation failures
- **Integration points** - HTTP clients, database calls (mocked)

### What NOT to Test
- Trivial getters/setters
- Framework code (EF Core, ASP.NET)
- Third-party libraries
- Private methods directly (test via public API)
- Constructor-only classes (DTOs)

### Coverage Commands
```bash
# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run with Coverlet
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

# Generate report
dotnet test /p:CollectCoverage=true /p:CoverletOutput=./coverage/ /p:CoverletOutputFormat=cobertura
```
</coverage>

<anti-patterns>
## Anti-Patterns to Avoid

### Test Anti-Patterns
```csharp
// BAD: Testing multiple things
[Test]
public async Task UserService_WorksCorrectly()
{
    // Tests create, update, delete, and get all in one test
}

// BAD: No assertions
[Test]
public async Task GetById_DoesNotThrow()
{
    await _sut.GetByIdAsync(1, CancellationToken.None);
    // No Assert!
}

// BAD: Testing implementation, not behavior
[Test]
public async Task GetById_CallsRepositoryOnce()
{
    await _sut.GetByIdAsync(1, CancellationToken.None);
    _repoMock.Verify(r => r.GetByIdAsync(1, It.IsAny<CancellationToken>()), Times.Once);
    // Only verifies call, not the result
}

// BAD: Shared mutable state
private static User _testUser = new User(); // Shared across tests!

// BAD: Test depends on other tests
[Test]
public void Step2_UpdateUser() { } // Assumes Step1 ran first
```

### Good Practices
```csharp
// GOOD: One concept per test
[Test]
public async Task GetById_WithValidId_ReturnsUser() { }

[Test]
public async Task GetById_WithInvalidId_ReturnsNull() { }

// GOOD: Independent tests
[SetUp]
public void Setup()
{
    // Fresh mocks for each test
    _repoMock = new Mock<IUserRepository>();
    _sut = new UserService(_repoMock.Object);
}

// GOOD: Descriptive test data
var user = new User
{
    Id = 1,
    Name = "Test User",
    Email = "test@example.com",
    IsActive = true
};
```
</anti-patterns>

<template>
## Test File Template

```csharp
using Moq;
using NUnit.Framework;
using System.Threading;
using System.Threading.Tasks;

namespace MyProject.Tests.Services;

[TestFixture]
public class MyServiceTests
{
    private MyService _sut;
    private Mock<IMyRepository> _repositoryMock;
    private Mock<IExternalClient> _clientMock;
    private Mock<ILogger<MyService>> _loggerMock;

    [SetUp]
    public void Setup()
    {
        _repositoryMock = new Mock<IMyRepository>();
        _clientMock = new Mock<IExternalClient>();
        _loggerMock = new Mock<ILogger<MyService>>();

        _sut = new MyService(
            _repositoryMock.Object,
            _clientMock.Object,
            _loggerMock.Object
        );
    }

    #region GetById Tests

    [Test]
    public async Task GetById_WithValidId_ReturnsEntity()
    {
        // Arrange
        var id = 1;
        var expected = new MyEntity { Id = id, Name = "Test" };
        _repositoryMock
            .Setup(r => r.GetByIdAsync(id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expected);

        // Act
        var result = await _sut.GetByIdAsync(id, CancellationToken.None);

        // Assert
        Assert.That(result, Is.Not.Null);
        Assert.That(result.Id, Is.EqualTo(id));
    }

    [Test]
    public async Task GetById_WithInvalidId_ReturnsNull()
    {
        // Arrange
        _repositoryMock
            .Setup(r => r.GetByIdAsync(It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((MyEntity)null);

        // Act
        var result = await _sut.GetByIdAsync(999, CancellationToken.None);

        // Assert
        Assert.That(result, Is.Null);
    }

    #endregion

    #region Create Tests

    [Test]
    public async Task Create_WithValidData_ReturnsCreatedEntity()
    {
        // Arrange
        var input = new CreateRequest { Name = "New Entity" };
        var expected = new MyEntity { Id = 1, Name = "New Entity" };

        _repositoryMock
            .Setup(r => r.AddAsync(It.IsAny<MyEntity>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expected);

        // Act
        var result = await _sut.CreateAsync(input, CancellationToken.None);

        // Assert
        Assert.That(result, Is.Not.Null);
        Assert.That(result.Name, Is.EqualTo(input.Name));
        _repositoryMock.Verify(
            r => r.AddAsync(It.Is<MyEntity>(e => e.Name == input.Name), It.IsAny<CancellationToken>()),
            Times.Once
        );
    }

    [Test]
    public void Create_WithNullInput_ThrowsArgumentException()
    {
        // Act & Assert
        Assert.ThrowsAsync<ArgumentNullException>(
            async () => await _sut.CreateAsync(null, CancellationToken.None)
        );
    }

    #endregion
}
```
</template>
