# Spring Boot Framework

## Overview
Spring Boot: opinionated framework for building production-grade Spring applications with minimal configuration.
Auto-configuration, embedded servers, and production-ready features (metrics, health checks) out of the box.
Best for enterprise applications, microservices, and when you need the Spring ecosystem.

## Pattern Selection

### Dependency Injection
**Use Constructor Injection (REQUIRED)**:
- Immutable dependencies (`final` fields)
- Easier testing (can inject mocks)
- Required dependencies are explicit

**NEVER use Field Injection** (`@Autowired` on fields):
- Cannot inject mocks in tests
- Dependencies not visible
- Breaks immutability

### Response Patterns
**Use `ResponseEntity` when**:
- Creating resources (return 201)
- Deleting resources (return 204)
- Need custom headers or status codes

**Return DTO directly when**:
- Simple GET operations (200 OK)
- Standard success response

## Controllers

```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor  // Lombok: generates constructor for final fields
public class UserController {
    private final UserService userService;  // final = immutable, required dependency
    
    // POST: Use ResponseEntity for 201 Created status
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(request));
    }
    
    // GET: Return DTO directly for simple 200 OK
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable Long id) {
        return userService.getUser(id);  // Spring returns 200 automatically
    }
    
    @GetMapping
    public List<UserDto> getAll() {
        return userService.findAll();
    }
}
```

## Services

```java
@Service
@RequiredArgsConstructor  // Constructor injection for all final fields
@Transactional(readOnly = true)  // Default: read-only (optimization for reads)
public class UserService {
    private final UserRepository userRepository;  // Required dependencies
    private final EmailService emailService;
    
    @Transactional  // Override: enable write transaction
    public UserDto createUser(CreateUserRequest request) {
        User user = User.builder()  // Builder pattern for complex objects
            .email(request.email())
            .name(request.name())
            .build();
        
        User saved = userRepository.save(user);
        emailService.sendWelcome(saved.getEmail());  // Side effect in same transaction
        
        return UserMapper.toDto(saved);  // NEVER return entity - always DTO
    }
    
    public UserDto getUser(Long id) {
        return userRepository.findById(id)
            .map(UserMapper::toDto)  // Map entity to DTO
            .orElseThrow(() -> new UserNotFoundException(id));  // Throw domain exception
    }
}
```

## Repositories

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByNameContainingIgnoreCase(String name);
    
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
}
```

## Entities

```java
@Entity
@Table(name = "users")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

## DTOs & Validation

```java
public record CreateUserRequest(
    @NotBlank @Size(min = 2, max = 100) String name,
    @NotBlank @Email String email
) {}

public record UserDto(Long id, String name, String email) {}

@Component
public class UserMapper {
    public static UserDto toDto(User user) {
        return new UserDto(user.getId(), user.getName(), user.getEmail());
    }
}
```

## Exception Handling

```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found: " + id);
    }
}

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
        return new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        String errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return new ErrorResponse(HttpStatus.BAD_REQUEST.value(), errors);
    }
}

record ErrorResponse(int status, String message, LocalDateTime timestamp) {
    public ErrorResponse(int status, String message) {
        this(status, message, LocalDateTime.now());
    }
}
```

## Configuration

```java
@Configuration
@ConfigurationProperties(prefix = "app")
@Validated
public class AppProperties {
    @NotBlank
    private String name;
    private String version;
    private ApiProperties api;
    
    public static class ApiProperties {
        private String baseUrl;
        private Duration timeout;
    }
}

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE");
    }
}
```

## Security

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/**").authenticated()
            )
            .httpBasic(Customizer.withDefaults());
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

## Testing

### Controller Tests
```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void getUser_ReturnsUser() throws Exception {
        when(userService.getUser(1L)).thenReturn(
            new UserDto(1L, "John", "john@test.com")
        );
        
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"));
    }
}
```

### Service Tests
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository repository;
    
    @InjectMocks
    private UserService service;
    
    @Test
    void createUser_Success() {
        User user = User.builder().name("John").email("john@test.com").build();
        when(repository.save(any(User.class))).thenReturn(user);
        
        UserDto result = service.createUser(new CreateUserRequest("John", "john@test.com"));
        
        assertEquals("John", result.name());
        verify(repository).save(any(User.class));
    }
}
```

### Integration Tests
```java
@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureTestDatabase
class UserIntegrationTest {
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void createAndRetrieveUser() {
        CreateUserRequest request = new CreateUserRequest("John", "john@test.com");
        
        ResponseEntity<UserDto> response = restTemplate.postForEntity(
            "/api/users", request, UserDto.class
        );
        
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertNotNull(response.getBody());
    }
}
```

## Best Practices

**MUST**:
- Use constructor injection with `@RequiredArgsConstructor` (NEVER `@Autowired` on fields)
- Use `@Transactional(readOnly = true)` on service classes by default
- Return DTOs from controllers, NEVER entities (prevents lazy loading issues)
- Use `@Valid` on ALL request bodies for automatic validation
- Use `final` fields for dependencies (immutability)

**SHOULD**:
- Use `ResponseEntity` when controlling status codes (POST, PUT, DELETE)
- Return DTO directly for simple GET operations (200 OK)
- Use Records (Java 17+) for DTOs and request objects
- Use Builder pattern for entities with 3+ fields
- Use `Optional` for potentially absent values

**AVOID**:
- `@Autowired` field injection (use constructor injection)
- Returning entities from any layer above repository
- Business logic in controllers (move to services)
- Exposing JPA exceptions to controllers (wrap in custom exceptions)
- Missing `@Transactional` on write operations

## Common Patterns

### Transaction Management
```java
@Service
@Transactional(readOnly = true)  // All methods read-only by default
public class UserService {
    
    // Read operation - uses class-level readOnly setting
    public UserDto getUser(Long id) {
        return repository.findById(id).map(UserMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    // Write operation - override with write transaction
    @Transactional  // Enables write operations
    public UserDto createUser(CreateUserRequest request) {
        User user = repository.save(mapper.toEntity(request));
        emailService.sendWelcome(user.getEmail());  // In same transaction
        return mapper.toDto(user);
    }
}
```

### Dependency Injection Anti-Patterns
```java
// ❌ BAD: Field injection
@RestController
public class UserController {
    @Autowired  // Hard to test, mutable, dependencies not visible
    private UserService service;
}

// ❌ BAD: Constructor without Lombok
@RestController
public class UserController {
    private final UserService service;
    
    public UserController(UserService service) {  // Verbose boilerplate
        this.service = service;
    }
}

// ✅ GOOD: Constructor injection with Lombok
@RestController
@RequiredArgsConstructor  // Lombok generates constructor
public class UserController {
    private final UserService service;  // final = required, immutable
}
```

### DTO vs Entity
```java
// ❌ BAD: Returning entity from controller
@GetMapping("/{id}")
public User getUser(@PathVariable Long id) {
    return userRepository.findById(id).orElseThrow();  // WRONG: exposes entity
    // Problems: Lazy loading issues, Jackson serialization problems, security risks
}

// ✅ GOOD: Return DTO
@GetMapping("/{id}")
public UserDto getUser(@PathVariable Long id) {
    return userService.getUser(id);  // Service returns DTO, not entity
}
```
