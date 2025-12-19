# Spring Boot Framework

> **Scope**: Apply these rules when working with Spring Boot applications.

## 1. Controllers
- **Thin Controllers**: Validate input, delegate to services, return response.
- **REST Controllers**: Use `@RestController` for REST APIs.
- **Response DTOs**: NEVER return entities directly. Use DTOs.
- **HTTP Methods**: Use appropriate annotations (`@GetMapping`, `@PostMapping`, etc.).

```java
// ✅ Good - Thin controller with DTO
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        final UserDto user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable final Long id) {
        return userService.getUser(id);
    }
}

// ❌ Bad - Business logic in controller
@PostMapping
public User createUser(@RequestBody User user) {
    user.setCreatedAt(LocalDateTime.now());
    userRepository.save(user);
    emailService.sendWelcome(user.getEmail());
    return user;  // Returning entity
}
```

## 2. Services
- **Business Logic**: All business rules live in services.
- **Transaction Management**: Use `@Transactional` for multi-step operations.
- **Constructor Injection**: Use constructor injection with `final` fields.

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    @Transactional
    public UserDto createUser(final CreateUserRequest request) {
        final User user = User.builder()
            .email(request.email())
            .name(request.name())
            .build();
        
        final User savedUser = userRepository.save(user);
        emailService.sendWelcomeEmail(savedUser.getEmail());
        
        return UserMapper.toDto(savedUser);
    }
    
    public UserDto getUser(final Long userId) {
        return userRepository.findById(userId)
            .map(UserMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(userId));
    }
}
```

## 3. Repositories
- **Spring Data JPA**: Use Spring Data JPA repositories.
- **Query Methods**: Leverage method name derivation.
- **Custom Queries**: Use `@Query` for complex queries.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // Method name derivation
    Optional<User> findByEmail(String email);
    List<User> findByActiveTrue();
    
    // Custom query
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
    
    // Native query
    @Query(value = "SELECT * FROM users WHERE status = ?1", nativeQuery = true)
    List<User> findByStatus(String status);
}
```

## 4. DTOs & Validation
- **Records**: Use Java records for immutable DTOs.
- **Validation**: Use Jakarta Bean Validation annotations.
- **Mapping**: Create explicit mapper classes or use MapStruct.

```java
// Request DTO
public record CreateUserRequest(
    @NotBlank @Email String email,
    @NotBlank @Size(min = 2, max = 100) String name,
    @NotBlank @Size(min = 8) String password
) {}

// Response DTO
public record UserDto(
    Long id,
    String email,
    String name,
    boolean active,
    LocalDateTime createdAt
) {}

// Mapper
public final class UserMapper {
    private UserMapper() {}
    
    public static UserDto toDto(final User user) {
        return new UserDto(
            user.getId(),
            user.getEmail(),
            user.getName(),
            user.isActive(),
            user.getCreatedAt()
        );
    }
}
```

## 5. Exception Handling
- **Global Exception Handler**: Use `@RestControllerAdvice`.
- **Custom Exceptions**: Create domain-specific exceptions.
- **Error Responses**: Return consistent error format.

```java
// Custom exception
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(final Long userId) {
        super("User not found: " + userId);
    }
}

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(final UserNotFoundException ex) {
        final ErrorResponse error = new ErrorResponse(
            HttpStatus.NOT_FOUND.value(),
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(final MethodArgumentNotValidException ex) {
        final List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(FieldError::getDefaultMessage)
            .toList();
        
        final ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation failed",
            errors,
            LocalDateTime.now()
        );
        return ResponseEntity.badRequest().body(error);
    }
}
```

## 6. Configuration
- **Application Properties**: Use `application.yml` or `application.properties`.
- **Profiles**: Separate configs for dev/staging/prod.
- **Configuration Classes**: Use `@ConfigurationProperties` for type-safe config.

```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Validated
public class AppProperties {
    @NotBlank
    private String name;
    
    @Min(1) @Max(100)
    private int maxConnections;
    
    // Getters and setters
}
```

```yaml
# application.yml
app:
  name: MyApp
  max-connections: 10

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
```

## 7. Security (Spring Security)
- **Method Security**: Use `@PreAuthorize` for method-level security.
- **JWT**: Use JWT for stateless authentication.
- **Password Encoding**: Use BCrypt for password hashing.

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(final HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            );
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

// In service
@Service
public class UserService {
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(final Long userId) {
        userRepository.deleteById(userId);
    }
}
```

## 8. Testing
- **Unit Tests**: Use JUnit 5 and Mockito.
- **Integration Tests**: Use `@SpringBootTest` for integration tests.
- **Test Slices**: Use `@WebMvcTest`, `@DataJpaTest` for focused tests.

```java
// Unit test
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void getUser_WhenUserExists_ReturnsUser() {
        // Given
        final User user = new User(1L, "test@example.com", "Test User");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // When
        final UserDto result = userService.getUser(1L);
        
        // Then
        assertThat(result.email()).isEqualTo("test@example.com");
        verify(userRepository).findById(1L);
    }
}

// Integration test
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
                        "name": "Test User",
                        "password": "Password123"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

## 9. Actuator & Monitoring
- **Endpoints**: Enable health, metrics, and info endpoints.
- **Custom Health Indicators**: Create for external dependencies.

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    private final UserRepository userRepository;
    
    @Override
    public Health health() {
        try {
            userRepository.count();
            return Health.up().build();
        } catch (Exception e) {
            return Health.down().withException(e).build();
        }
    }
}
```

## 10. Anti-Patterns (MUST avoid)
- **Service Layer Skipping**: Don't call repositories from controllers.
  - ❌ Bad: `@GetMapping("/{id}") User get(@PathVariable Long id) { return userRepo.findById(id).get(); }`
  - ✅ Good: `@GetMapping("/{id}") UserDto get(@PathVariable Long id) { return userService.getUser(id); }`
- **N+1 Queries**: Use `@EntityGraph` or JOIN FETCH.
  - ❌ Bad: `users.forEach(u -> u.getPosts().size());` (N+1 query)
  - ✅ Good: `@EntityGraph(attributePaths = {"posts"}) List<User> findAll();`
- **Transactions Everywhere**: Use `@Transactional(readOnly = true)` for read operations.
- **Field Injection**: Use constructor injection, not field injection.

