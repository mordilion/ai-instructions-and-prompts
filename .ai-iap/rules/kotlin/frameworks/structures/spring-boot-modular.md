# Spring Boot Modular Structure

## Overview
Feature-first modular structure organizes code by business capabilities, promoting high cohesion and low coupling.

## Directory Structure

```
src/main/kotlin/com/app/
├── common/                       # Shared utilities
│   ├── config/
│   │   ├── SecurityConfig.kt
│   │   └── DatabaseConfig.kt
│   ├── exception/
│   │   └── GlobalExceptionHandler.kt
│   └── util/
│       └── Extensions.kt
├── user/                        # User module
│   ├── User.kt                 # Domain model
│   ├── UserRepository.kt       # Repository interface
│   ├── UserRepositoryImpl.kt   # Repository implementation
│   ├── UserEntity.kt           # JPA entity
│   ├── UserService.kt          # Business logic
│   ├── UserController.kt       # REST API
│   ├── UserDto.kt              # DTOs
│   └── UserMapper.kt           # Mappers
├── order/                       # Order module
│   ├── Order.kt
│   ├── OrderRepository.kt
│   ├── OrderService.kt
│   ├── OrderController.kt
│   └── OrderDto.kt
├── product/                     # Product module
│   ├── Product.kt
│   ├── ProductRepository.kt
│   ├── ProductService.kt
│   ├── ProductController.kt
│   └── ProductDto.kt
└── Application.kt

src/test/kotlin/com/app/
├── user/
│   ├── UserServiceTest.kt
│   ├── UserControllerTest.kt
│   └── UserRepositoryTest.kt
└── order/
    └── OrderServiceTest.kt
```

## Implementation

### Domain Model
```kotlin
// user/User.kt
data class User(
    val id: Long = 0,
    val name: String,
    val email: String,
    val createdAt: Instant = Instant.now()
)
```

### Entity
```kotlin
// user/UserEntity.kt
@Entity
@Table(name = "users")
data class UserEntity(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val name: String,
    
    @Column(nullable = false, unique = true)
    val email: String,
    
    @Column(name = "created_at")
    val createdAt: Instant = Instant.now()
)
```

### Repository
```kotlin
// user/UserRepository.kt
interface UserRepository {
    suspend fun findAll(): List<User>
    suspend fun findById(id: Long): User?
    suspend fun save(user: User): User
    suspend fun delete(id: Long)
}

// user/UserRepositoryImpl.kt
@Repository
class UserRepositoryImpl(
    private val jpaRepository: JpaUserRepository,
    private val mapper: UserMapper
) : UserRepository {
    
    override suspend fun findAll(): List<User> = withContext(Dispatchers.IO) {
        jpaRepository.findAll().map { mapper.toDomain(it) }
    }
    
    override suspend fun findById(id: Long): User? = withContext(Dispatchers.IO) {
        jpaRepository.findById(id)
            .map { mapper.toDomain(it) }
            .orElse(null)
    }
    
    override suspend fun save(user: User): User = withContext(Dispatchers.IO) {
        val entity = mapper.toEntity(user)
        val saved = jpaRepository.save(entity)
        mapper.toDomain(saved)
    }
    
    override suspend fun delete(id: Long) = withContext(Dispatchers.IO) {
        jpaRepository.deleteById(id)
    }
}

interface JpaUserRepository : JpaRepository<UserEntity, Long> {
    fun findByEmail(email: String): UserEntity?
}
```

### Service
```kotlin
// user/UserService.kt
@Service
class UserService(
    private val repository: UserRepository
) {
    
    suspend fun findAll(): List<UserDto> =
        repository.findAll().map { it.toDto() }
    
    suspend fun findById(id: Long): UserDto =
        repository.findById(id)?.toDto()
            ?: throw UserNotFoundException(id)
    
    suspend fun create(request: CreateUserRequest): UserDto {
        val user = User(
            name = request.name,
            email = request.email
        )
        return repository.save(user).toDto()
    }
    
    suspend fun update(id: Long, request: UpdateUserRequest): UserDto {
        val existing = repository.findById(id)
            ?: throw UserNotFoundException(id)
        
        val updated = existing.copy(
            name = request.name ?: existing.name,
            email = request.email ?: existing.email
        )
        
        return repository.save(updated).toDto()
    }
    
    suspend fun delete(id: Long) {
        if (repository.findById(id) == null) {
            throw UserNotFoundException(id)
        }
        repository.delete(id)
    }
    
    private fun User.toDto() = UserDto(
        id = id,
        name = name,
        email = email,
        createdAt = createdAt
    )
}
```

### Controller
```kotlin
// user/UserController.kt
@RestController
@RequestMapping("/api/users")
class UserController(
    private val service: UserService
) {
    
    @GetMapping
    suspend fun getAll(): List<UserDto> = service.findAll()
    
    @GetMapping("/{id}")
    suspend fun getById(@PathVariable id: Long): UserDto =
        service.findById(id)
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    suspend fun create(@Valid @RequestBody request: CreateUserRequest): UserDto =
        service.create(request)
    
    @PutMapping("/{id}")
    suspend fun update(
        @PathVariable id: Long,
        @Valid @RequestBody request: UpdateUserRequest
    ): UserDto = service.update(id, request)
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    suspend fun delete(@PathVariable id: Long) {
        service.delete(id)
    }
}
```

### DTOs
```kotlin
// user/UserDto.kt
data class UserDto(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: Instant
)

data class CreateUserRequest(
    @field:NotBlank val name: String,
    @field:Email val email: String
)

data class UpdateUserRequest(
    @field:Size(min = 2, max = 100) val name: String? = null,
    @field:Email val email: String? = null
)
```

### Mapper
```kotlin
// user/UserMapper.kt
@Component
class UserMapper {
    
    fun toDomain(entity: UserEntity): User = User(
        id = entity.id,
        name = entity.name,
        email = entity.email,
        createdAt = entity.createdAt
    )
    
    fun toEntity(user: User): UserEntity = UserEntity(
        id = user.id,
        name = user.name,
        email = user.email,
        createdAt = user.createdAt
    )
}
```

## Benefits
- Simple and intuitive structure
- Easy to navigate and understand
- Fast development for small-to-medium projects
- All related code in one place

## When to Use
- Small to medium applications
- Rapid prototyping
- Teams new to Kotlin/Spring Boot
- Projects with clear feature boundaries

