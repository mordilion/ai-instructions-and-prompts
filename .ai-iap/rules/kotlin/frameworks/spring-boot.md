# Spring Boot with Kotlin

> **Scope**: Spring Boot apps using Kotlin
> **Applies to**: Kotlin files in Spring Boot projects  
> **Extends**: kotlin/architecture.md, kotlin/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use constructor injection (NOT field injection)
> **ALWAYS**: Use data classes for DTOs
> **ALWAYS**: Use coroutines for async operations
> **ALWAYS**: Use sealed classes for exceptions
> **ALWAYS**: Validate with `@Valid`
> 
> **NEVER**: Use field injection (`@Autowired` on fields)
> **NEVER**: Use `lateinit` for dependencies
> **NEVER**: Ignore null safety
> **NEVER**: Use Java-style getters/setters

## Core Patterns

### REST Controller

```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(private val userService: UserService) {
    
    @GetMapping
    fun getUsers(): List<UserDto> = userService.findAll()
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createUser(@Valid @RequestBody request: CreateUserRequest) =
        userService.create(request)
}
```

### Service with Coroutines

```kotlin
@Service
class UserService(
    private val repository: UserRepository
) {
    suspend fun findAll(): List<UserDto> = withContext(Dispatchers.IO) {
        repository.findAll().map { it.toDto() }
    }
    
    @Transactional
    suspend fun create(request: CreateUserRequest): UserDto {
        val user = User(name = request.name, email = request.email)
        return repository.save(user).toDto()
    }
}
```

### Exception Handling

```kotlin
sealed class AppException(message: String) : RuntimeException(message) {
    class UserNotFound(id: Long) : AppException("User $id not found")
    class InvalidInput(msg: String) : AppException(msg)
}

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(AppException.UserNotFound::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleNotFound(ex: AppException.UserNotFound) =
        ErrorResponse(404, ex.message ?: "")
}
```

### Entity (JPA)

```kotlin
@Entity
@Table(name = "users")
data class User(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(nullable = false, length = 100)
    val name: String,
    
    @Column(unique = true, nullable = false)
    val email: String,
    
    @CreationTimestamp
    val createdAt: Instant? = null
)
```

### DTO & Mapper

```kotlin
data class UserDto(val id: Long, val name: String, val email: String)

fun User.toDto() = UserDto(id = id!!, name = name, email = email)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Field Injection** | `@Autowired lateinit var` | Constructor injection |
| **No Coroutines** | Blocking calls | `suspend` + `withContext` |
| **Java Style** | Getters/setters | Properties |
| **Mutable DTOs** | `var` in DTOs | `val` (immutable) |

### Anti-Pattern: Field Injection

```kotlin
// ❌ WRONG
@Service
class UserService {
    @Autowired
    lateinit var repository: UserRepository  // Field injection!
}

// ✅ CORRECT
@Service
class UserService(
    private val repository: UserRepository  // Constructor injection
)
```

## AI Self-Check

- [ ] Constructor injection?
- [ ] Data classes for DTOs?
- [ ] Coroutines for async?
- [ ] Sealed classes for exceptions?
- [ ] @Valid for validation?
- [ ] No field injection?
- [ ] No lateinit for dependencies?
- [ ] Properties not getters/setters?
- [ ] Immutable DTOs (`val`)?
- [ ] @Transactional for writes?

## Key Annotations

| Annotation | Purpose |
|------------|---------|
| `@RestController` | REST endpoints |
| `@Service` | Business logic |
| `@Repository` | Data access |
| `@Entity` | JPA entity |
| `@Valid` | Input validation |
| `@Transactional` | Transaction boundary |

## Best Practices

**MUST**: Constructor injection, data classes, coroutines, sealed exceptions
**SHOULD**: @Valid, @Transactional, immutable DTOs
**AVOID**: Field injection, lateinit for DI, blocking calls, mutable DTOs
