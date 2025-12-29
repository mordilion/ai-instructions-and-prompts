# Spring Boot Framework

> **Scope**: Apply these rules when working with Spring Boot applications
> **Applies to**: Java files in Spring Boot projects
> **Extends**: java/architecture.md, java/code-style.md
> **Precedence**: Framework rules OVERRIDE Java rules for Spring Boot-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use constructor injection with @RequiredArgsConstructor (field injection FORBIDDEN)
> **ALWAYS**: Use @Transactional(readOnly=true) on service classes by default
> **ALWAYS**: Return DTOs from controllers (NEVER expose entities)
> **ALWAYS**: Use final fields for dependencies (immutability required)
> **ALWAYS**: Use @Valid for request body validation
> 
> **NEVER**: Use @Autowired on fields (breaks testability and immutability)
> **NEVER**: Return entity objects from controllers (causes lazy loading issues, security risks)
> **NEVER**: Put business logic in controllers (belongs in services)
> **NEVER**: Miss @Transactional on write operations (causes data inconsistency)
> **NEVER**: Expose JPA exceptions to API layer (wrap in domain exceptions)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Constructor Injection | Always (required) | `@RequiredArgsConstructor`, `final` fields |
| ResponseEntity | Creating/deleting resources, custom status codes | `ResponseEntity.status()`, `HttpStatus.CREATED`, `204 NO_CONTENT` |
| DTO Direct Return | Simple GET operations | Direct return type, Spring auto-200 |
| @Transactional(readOnly=true) | Service class level (default) | Class-level annotation |
| @Transactional | Write operations (override) | Method-level override |

## Core Patterns

### Dependency Injection (REQUIRED)
```java
@Service
@RequiredArgsConstructor  // Generates constructor for final fields
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository repository;  // final = immutable, required
}
```

### Controller (Thin Layer)
```java
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<UserDto> create(@Valid @RequestBody CreateUserRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(req));
    }
    
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable Long id) {
        return userService.getUser(id);  // DTO, not entity
    }
}
```

### Service (Business Logic Layer)
```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository repository;
    
    @Transactional  // Override for write
    public UserDto createUser(CreateUserRequest request) {
        User user = repository.save(mapper.toEntity(request));
        return mapper.toDto(user);  // Always return DTO
    }
}
```

### Repository
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
}
```

### DTOs & Validation
```java
public record CreateUserRequest(
    @NotBlank @Size(min = 2, max = 100) String name,
    @NotBlank @Email String email
) {}

public record UserDto(Long id, String name, String email) {}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Field Injection** | `@Autowired private UserService service;` | `@RequiredArgsConstructor` + `final` field | Untestable, mutable, industry anti-pattern |
| **Exposing Entities** | `public User getUser()` returning entity | `public UserDto getUser()` returning DTO | Lazy loading errors, security risks, serialization issues |
| **Missing @Transactional** | Write method without annotation | `@Transactional` on write methods | Data inconsistency, no rollback, partial commits |
| **Business Logic in Controller** | Controller does DB access, validation | Controller calls service only | Untestable, violates SoC, unmaintainable |
| **Wrong DTO Mapping** | Mapping in controller layer | Mapping in service layer | Breaks layering, logic leak |

### Anti-Pattern: Field Injection (FORBIDDEN)
```java
// ❌ WRONG - Cannot test, breaks immutability
@Service
public class UserService {
    @Autowired private UserRepository repository;  // DO NOT GENERATE
}

// ✅ CORRECT - Constructor injection
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository repository;  // Immutable, testable
}
```

### Anti-Pattern: Exposing Entities (FORBIDDEN)
```java
// ❌ WRONG - Entity in API layer
@GetMapping("/{id}")
public User getUser(@PathVariable Long id) {
    return repository.findById(id).orElseThrow();  // Causes bugs
}

// ✅ CORRECT - DTO in API layer
@GetMapping("/{id}")
public UserDto getUser(@PathVariable Long id) {
    return userService.getUser(id);  // Returns DTO
}
```

## AI Self-Check (Verify BEFORE generating Spring Boot code)

- [ ] Constructor injection with @RequiredArgsConstructor? (NOT @Autowired on fields)
- [ ] All dependency fields are final? (Immutability required)
- [ ] @Transactional(readOnly=true) on service class? (Default for all methods)
- [ ] @Transactional on write methods? (Override readOnly for updates)
- [ ] Returns DTO from controller? (NOT entity)
- [ ] @Valid on request bodies? (Automatic validation)
- [ ] Business logic in service? (NOT in controller)
- [ ] Exceptions wrapped? (NO JPA exceptions in API layer)
- [ ] Records used for DTOs? (Java 17+ recommended)
- [ ] ResponseEntity for non-200 status codes?

## Testing

| Test Type | Annotation | Purpose |
|-----------|------------|---------|
| Controller | `@WebMvcTest(UserController.class)` | Test REST layer with MockMvc |
| Service | `@ExtendWith(MockitoExtension.class)` | Unit test with mocks |
| Integration | `@SpringBootTest(webEnvironment = RANDOM_PORT)` | Full app context |

## Exception Handling

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handle(UserNotFoundException ex) {
        return new ErrorResponse(404, ex.getMessage());
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
    @NotBlank private String name;
    private String version;
}
```

## Key Libraries

- **Lombok**: `@RequiredArgsConstructor`, `@Getter`, `@Setter`, `@Builder`
- **Validation**: `@Valid`, `@NotBlank`, `@Email`, `@Size`
- **JPA**: `JpaRepository`, `@Query`, `@Transactional`
- **Testing**: `@WebMvcTest`, `@SpringBootTest`, `MockMvc`, `@MockBean`
