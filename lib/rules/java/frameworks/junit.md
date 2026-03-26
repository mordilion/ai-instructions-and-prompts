# JUnit Testing Framework

> **Scope**: Testing with JUnit 5 (Jupiter)  
> **Applies to**: Java test files using JUnit
> **Extends**: java/architecture.md, java/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Given-When-Then structure
> **ALWAYS**: Use descriptive test names (methodName_Condition_ExpectedResult)
> **ALWAYS**: Use AssertJ for fluent assertions
> **ALWAYS**: Mock dependencies with Mockito
> **ALWAYS**: One assertion per test (or use assertAll)
> 
> **NEVER**: Test multiple behaviors in one test
> **NEVER**: Use generic test names
> **NEVER**: Skip cleanup (@AfterEach)
> **NEVER**: Ignore test coverage for critical paths
> **NEVER**: Use Thread.sleep()

## Core Patterns

### Test Structure

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
        User user = User.builder().id(userId).email("test@example.com").build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        
        // When
        UserDto result = userService.getUser(userId);
        
        // Then
        assertThat(result.email()).isEqualTo("test@example.com");
        verify(userRepository).findById(userId);
    }
    
    @Test
    void getUser_WhenUserNotFound_ThrowsException() {
        // Given
        Long userId = 1L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // When/Then
        assertThatThrownBy(() -> userService.getUser(userId))
            .isInstanceOf(UserNotFoundException.class)
            .hasMessage("User not found: 1");
    }
}
```

### AssertJ Assertions

```java
assertThat(user.getName()).isEqualTo("John");
assertThat(users).hasSize(3);
assertThat(users).extracting("name").contains Name("John", "Jane");
assertThat(user).isNotNull().hasFieldOrPropertyWithValue("email", "test@example.com");

assertAll(
    () -> assertThat(user.getName()).isEqualTo("John"),
    () -> assertThat(user.getEmail()).isEqualTo("john@example.com")
);
```

### Parameterized Tests

```java
@ParameterizedTest
@ValueSource(strings = {"", " ", "  "})
void validate_WhenNameIsBlank_ThrowsException(String name) {
    assertThatThrownBy(() -> userService.create(name, "test@example.com"))
        .isInstanceOf(ValidationException.class);
}

@ParameterizedTest
@CsvSource({"John,john@example.com", "Jane,jane@example.com"})
void create_WithValidInput_CreatesUser(String name, String email) {
    UserDto result = userService.create(name, email);
    assertThat(result.name()).isEqualTo(name);
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Generic Name** | `test1()` | `getUser_WhenUserExists_ReturnsUser()` |
| **Multiple Behaviors** | Test create and update | Separate tests |
| **Missing Verify** | No verification | `verify(repository)...` |
| **Thread.sleep** | For async | Awaitility |

## AI Self-Check

- [ ] Given-When-Then structure?
- [ ] Descriptive test names?
- [ ] AssertJ assertions?
- [ ] Mocking with Mockito?
- [ ] One assertion per test?
- [ ] Cleanup with @AfterEach?
- [ ] Critical paths covered?
- [ ] No Thread.sleep?

## Key Features

| Feature | Purpose |
|---------|---------|
| @Test | Test method |
| @Mock | Mock dependencies |
| @InjectMocks | Inject mocks |
| AssertJ | Fluent assertions |
| @ParameterizedTest | Data-driven tests |

## Best Practices

**MUST**: Given-When-Then, descriptive names, AssertJ, Mockito, verify
**SHOULD**: Parameterized tests, @BeforeEach/@AfterEach, test coverage
**AVOID**: Generic names, multiple behaviors, Thread.sleep, no verification
