# JUnit Testing Framework

> **Scope**: Testing with JUnit 5 (Jupiter)
> **Applies to**: Java test files using JUnit
> **Extends**: java/architecture.md, java/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use Given-When-Then structure
> **ALWAYS**: Use descriptive test names (methodName_Condition_ExpectedResult)
> **ALWAYS**: Use AssertJ for fluent assertions
> **ALWAYS**: Mock dependencies with Mockito
> **ALWAYS**: One assertion per test (or use assertAll)
> 
> **NEVER**: Test multiple behaviors in one test
> **NEVER**: Use generic test names (test1, test2)
> **NEVER**: Skip cleanup (@AfterEach)
> **NEVER**: Ignore test coverage for critical paths
> **NEVER**: Use Thread.sleep() (use awaitility)

## Core Patterns

### Test Structure (Given-When-Then)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void getUser_WhenUserExists_ReturnsUser() {
        // Given
        Long userId = 1L;
        User user = User.builder()
            .id(userId)
            .email("test@example.com")
            .name("Test User")
            .build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        
        // When
        UserDto result = userService.getUser(userId);
        
        // Then
        assertThat(result.email()).isEqualTo("test@example.com");
        assertThat(result.name()).isEqualTo("Test User");
        verify(userRepository).findById(userId);
    }
    
    @Test
    void getUser_WhenUserNotFound_ThrowsException() {
        // Given
        Long userId = 999L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // When & Then
        assertThrows(UserNotFoundException.class, () -> userService.getUser(userId));
    }
}
```

### Assertions (AssertJ)

```java
@Test
void createUser_ValidRequest_ReturnsUser() {
    // Given
    CreateUserRequest request = new CreateUserRequest("test@example.com", "Test");
    
    // When
    UserDto result = userService.createUser(request);
    
    // Then (AssertJ fluent assertions)
    assertThat(result)
        .isNotNull()
        .extracting(UserDto::email, UserDto::name)
        .containsExactly("test@example.com", "Test");
}

@Test
void getAllUsers_ReturnsMultipleUsers() {
    // Then (collections)
    assertThat(users)
        .hasSize(3)
        .extracting(User::getEmail)
        .containsExactly("user1@test.com", "user2@test.com", "user3@test.com");
}
```

### Parameterized Tests

```java
@ParameterizedTest
@CsvSource({
    "test@example.com, true",
    "invalid-email, false",
    "'', false"
})
void validateEmail_VariousInputs_ReturnsExpected(String email, boolean expected) {
    boolean result = validator.isValidEmail(email);
    assertThat(result).isEqualTo(expected);
}

@ParameterizedTest
@ValueSource(ints = {1, 3, 5, 7, 9})
void isOdd_OddNumbers_ReturnsTrue(int number) {
    assertThat(MathUtils.isOdd(number)).isTrue();
}
```

### Test Lifecycle

```java
@BeforeEach
void setUp() {
    // Initialize test data
    userService = new UserService(userRepository);
}

@AfterEach
void tearDown() {
    // Clean up resources
}

@BeforeAll
static void setUpClass() {
    // One-time setup
}

@AfterAll
static void tearDownClass() {
    // One-time cleanup
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Generic Names** | `test1()`, `testUser()` | `getUser_WhenExists_ReturnsUser()` | Clarity |
| **Multiple Behaviors** | Test 5 things in one | One test per behavior | Isolation |
| **No Mocking** | Use real DB | Mock dependencies | Speed, isolation |
| **Thread.sleep** | `Thread.sleep(1000)` | Awaitility | Flaky tests |

### Anti-Pattern: Generic Test Names (UNMAINTAINABLE)

```java
// ❌ WRONG: Generic names
@Test
void test1() { ... }

@Test
void testUser() { ... }

// ✅ CORRECT: Descriptive names
@Test
void getUser_WhenUserExists_ReturnsUser() { ... }

@Test
void getUser_WhenUserNotFound_ThrowsException() { ... }
```

## AI Self-Check (Verify BEFORE generating JUnit tests)

- [ ] Given-When-Then structure?
- [ ] Descriptive test names?
- [ ] AssertJ assertions?
- [ ] Mockito for mocking?
- [ ] One behavior per test?
- [ ] @BeforeEach/@AfterEach for setup/cleanup?
- [ ] Parameterized tests for multiple inputs?
- [ ] verify() calls for behavior verification?
- [ ] No Thread.sleep()?
- [ ] Test covers critical paths?

## Key Annotations

| Annotation | Purpose |
|------------|---------|
| `@Test` | Mark test method |
| `@ParameterizedTest` | Multiple inputs |
| `@BeforeEach/@AfterEach` | Setup/cleanup |
| `@Mock` | Mockito mock |
| `@InjectMocks` | Inject mocks |
| `@ExtendWith` | JUnit extension |
| `@Disabled` | Skip test |

## Best Practices

**MUST**:
- Given-When-Then
- Descriptive names
- AssertJ assertions
- Mock dependencies
- One behavior per test

**SHOULD**:
- Parameterized tests
- Test lifecycle methods
- verify() for interactions
- Test coverage tools

**AVOID**:
- Generic test names
- Multiple behaviors
- Real dependencies
- Thread.sleep()
- Flaky tests
