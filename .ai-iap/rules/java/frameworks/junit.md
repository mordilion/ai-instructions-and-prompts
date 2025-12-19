# JUnit Testing Framework

> **Scope**: Apply these rules when writing tests with JUnit 5 (Jupiter).

## 1. Test Structure
- **Given-When-Then**: Structure tests clearly.
- **One Assertion per Test**: Focus on single behavior.
- **Descriptive Names**: Test names should describe what is being tested.

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

## 2. Assertions
- **AssertJ**: Use AssertJ for fluent assertions.
- **Multiple Assertions**: Use `assertAll()` for related assertions.

```java
@Test
void createUser_ValidRequest_ReturnsUser() {
    // Given
    CreateUserRequest request = new CreateUserRequest("test@example.com", "Test User");
    
    // When
    UserDto result = userService.createUser(request);
    
    // Then
    assertAll(
        () -> assertThat(result.id()).isNotNull(),
        () -> assertThat(result.email()).isEqualTo("test@example.com"),
        () -> assertThat(result.name()).isEqualTo("Test User"),
        () -> assertThat(result.active()).isTrue()
    );
}
```

## 3. Parameterized Tests
- **@ParameterizedTest**: Test multiple inputs.
- **@ValueSource**: Simple value inputs.
- **@CsvSource**: Multiple parameters.

```java
@ParameterizedTest
@ValueSource(strings = {"", "  ", "invalid"})
void validateEmail_InvalidEmail_ThrowsException(String email) {
    assertThrows(IllegalArgumentException.class, 
        () -> validator.validateEmail(email));
}

@ParameterizedTest
@CsvSource({
    "test@example.com, true",
    "invalid, false",
    "@example.com, false"
})
void isValidEmail_VariousInputs_ReturnsExpected(String email, boolean expected) {
    assertThat(validator.isValidEmail(email)).isEqualTo(expected);
}
```

## 4. Mocking (Mockito)
- **@Mock**: Mock dependencies.
- **@InjectMocks**: Inject mocks into class under test.
- **Verification**: Verify interactions.

```java
@Test
void createUser_ValidRequest_SavesUser() {
    // Given
    CreateUserRequest request = new CreateUserRequest("test@example.com", "Test");
    User savedUser = User.builder().id(1L).email(request.email()).build();
    when(userRepository.save(any(User.class))).thenReturn(savedUser);
    
    // When
    userService.createUser(request);
    
    // Then
    verify(userRepository).save(argThat(user -> 
        user.getEmail().equals("test@example.com") &&
        user.getName().equals("Test")
    ));
}
```

## 5. Integration Tests (Spring Boot)
- **@SpringBootTest**: Full application context.
- **@WebMvcTest**: Test controllers only.
- **@DataJpaTest**: Test JPA repositories only.

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIntegrationTest {
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void createUser_ValidRequest_ReturnsCreated() throws Exception {
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "email": "test@example.com",
                        "name": "Test User"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"))
            .andExpect(jsonPath("$.name").value("Test User"));
    }
}
```

## 6. Test Lifecycle
- **@BeforeEach**: Setup before each test.
- **@AfterEach**: Cleanup after each test.
- **@BeforeAll**: Setup once before all tests (must be static).

```java
class UserServiceTest {
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(new InMemoryUserRepository());
    }
    
    @AfterEach
    void tearDown() {
        // Cleanup if needed
    }
    
    @Test
    void test() {
        // ...
    }
}
```

## 7. Best Practices
- **Test Naming**: `methodName_condition_expectedResult`
- **Arrange-Act-Assert**: Clear test structure
- **Don't Test Framework Code**: Only test your business logic
- **Fast Tests**: Unit tests should run in milliseconds
- **Independent Tests**: Tests should not depend on execution order

