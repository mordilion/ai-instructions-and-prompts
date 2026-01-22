# Spring Boot Layered Structure

> **Scope**: Layered structure for Spring Boot (Kotlin)  
> **Applies to**: Spring Boot Kotlin projects with layered structure  
> **Extends**: kotlin/frameworks/spring-boot.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Controllers in controller/ package
> **ALWAYS**: Services in service/ package
> **ALWAYS**: Repositories extend JpaRepository
> **ALWAYS**: DTOs for API contracts (not entities)
> **ALWAYS**: Controllers thin (delegate to services)
> 
> **NEVER**: Business logic in controllers
> **NEVER**: Controllers call repositories directly
> **NEVER**: Return entities from controllers
> **NEVER**: Fat controllers
> **NEVER**: Skip service layer

## Directory Structure

```
src/main/kotlin/com/app/
├── controller/
│   ├── UserController.kt
│   └── OrderController.kt
├── service/
│   ├── UserService.kt
│   └── OrderService.kt
├── repository/
│   ├── UserRepository.kt
│   └── OrderRepository.kt
├── entity/
│   ├── UserEntity.kt
│   └── OrderEntity.kt
├── dto/
│   ├── request/
│   └── response/
├── mapper/
└── exception/
```

## Implementation

### Entity
```kotlin
@Entity
@Table(name = "users")
data class UserEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) val id: Long = 0,
    @Column(nullable = false) val name: String,
    @Column(nullable = false, unique = true) val email: String
)
```

### Repository
```kotlin
@Repository
interface UserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmail(email: String): UserEntity?
    fun findByNameContainingIgnoreCase(name: String): List<UserEntity>
}
```

### DTO & Mapper
```kotlin
data class UserResponse(val id: Long, val name: String, val email: String)
data class CreateUserRequest(
    @field:NotBlank @field:Size(min = 2, max = 100) val name: String,
    @field:Email val email: String
)

@Component
class UserMapper {
    fun toResponse(entity: UserEntity) = UserResponse(entity.id, entity.name, entity.email)
    fun toEntity(request: CreateUserRequest) = UserEntity(name = request.name, email = request.email)
}
```

### Service
```kotlin
@Service
class UserService(
    private val repository: UserRepository,
    private val mapper: UserMapper
) {
    suspend fun findAll(): List<UserResponse> = withContext(Dispatchers.IO) {
        repository.findAll().map { mapper.toResponse(it) }
    }
    
    suspend fun create(request: CreateUserRequest): UserResponse = withContext(Dispatchers.IO) {
        repository.findByEmail(request.email)?.let {
            throw EmailAlreadyExistsException(request.email)
        }
        val saved = repository.save(mapper.toEntity(request))
        mapper.toResponse(saved)
    }
}
```

### Controller
```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(private val service: UserService) {
    
    @GetMapping
    suspend fun getAll() = ResponseEntity.ok(service.findAll())
    
    @PostMapping
    suspend fun create(@Valid @RequestBody request: CreateUserRequest) =
        ResponseEntity.status(HttpStatus.CREATED).body(service.create(request))
}
```

### Exception
```kotlin
sealed class AppException(message: String) : RuntimeException(message)
class UserNotFoundException(id: Long) : AppException("User not found: $id")
class EmailAlreadyExistsException(email: String) : AppException("Email exists: $email")

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(ex: UserNotFoundException) =
        ErrorResponse(404, ex.message ?: "")
}
```

## Benefits
- Familiar structure
- Clear technical separation
- Easy for CRUD apps

## When to Use
- Traditional enterprise apps
- CRUD-focused applications

## AI Self-Check

- [ ] Controllers in controller/ package?
- [ ] Services in service/ package?
- [ ] Repositories extend JpaRepository?
- [ ] DTOs for API contracts (not entities)?
- [ ] Controllers thin?
- [ ] Services handle business logic?
- [ ] Mappers for entity ↔ DTO conversion?
- [ ] No business logic in controllers?
- [ ] No controllers calling repositories directly?
- [ ] No entities returned from controllers?
