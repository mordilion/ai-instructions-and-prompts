# Spring Boot Clean Architecture

## Overview
Clean Architecture with Spring Boot separates business logic from framework concerns, making the application framework-independent at its core.

## Directory Structure

```
src/main/kotlin/com/app/
├── core/                         # Shared components
│   ├── config/                   # Configuration
│   │   ├── SecurityConfig.kt
│   │   └── WebConfig.kt
│   ├── exception/               # Global exception handling
│   │   ├── AppException.kt
│   │   └── GlobalExceptionHandler.kt
│   └── util/                    # Utilities
├── feature/                     # Feature modules
│   ├── user/
│   │   ├── domain/             # Business logic (no Spring deps)
│   │   │   ├── model/
│   │   │   │   └── User.kt
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.kt  # Interface
│   │   │   └── usecase/
│   │   │       ├── GetUserUseCase.kt
│   │   │       ├── CreateUserUseCase.kt
│   │   │       └── UpdateUserUseCase.kt
│   │   ├── data/               # Data implementations
│   │   │   ├── repository/
│   │   │   │   └── UserRepositoryImpl.kt
│   │   │   ├── entity/
│   │   │   │   └── UserEntity.kt
│   │   │   └── mapper/
│   │   │       └── UserEntityMapper.kt
│   │   ├── presentation/       # API layer
│   │   │   ├── controller/
│   │   │   │   └── UserController.kt
│   │   │   └── dto/
│   │   │       ├── UserDto.kt
│   │   │       ├── CreateUserRequest.kt
│   │   │       └── UpdateUserRequest.kt
│   │   └── config/
│   │       └── UserConfig.kt
│   └── order/
│       ├── domain/
│       ├── data/
│       ├── presentation/
│       └── config/
└── Application.kt

src/test/kotlin/com/app/
├── feature/
│   └── user/
│       ├── domain/             # Unit tests (no Spring)
│       ├── data/               # Integration tests
│       └── presentation/       # Controller tests
```

## Implementation

### Domain Layer (Pure Kotlin)

```kotlin
// feature/user/domain/model/User.kt
data class User(
    val id: Long = 0,
    val name: String,
    val email: String,
    val createdAt: Instant = Instant.now()
)

// feature/user/domain/repository/UserRepository.kt
interface UserRepository {
    suspend fun findAll(): List<User>
    suspend fun findById(id: Long): User?
    suspend fun save(user: User): User
    suspend fun delete(id: Long)
}

// feature/user/domain/usecase/GetUserUseCase.kt
class GetUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: Long): User =
        repository.findById(id) ?: throw UserNotFoundException(id)
}

// feature/user/domain/usecase/CreateUserUseCase.kt
class CreateUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(name: String, email: String): User {
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(email.matches(Regex(".+@.+"))) { "Invalid email" }
        
        val user = User(name = name, email = email)
        return repository.save(user)
    }
}
```

### Data Layer

```kotlin
// feature/user/data/entity/UserEntity.kt
@Entity
@Table(name = "users")
data class UserEntity(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val name: String,
    
    @Column(nullable = false, unique = true)
    val email: String,
    
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant = Instant.now()
)

// feature/user/data/repository/JpaUserRepository.kt
interface JpaUserRepository : JpaRepository<UserEntity, Long>

// feature/user/data/mapper/UserEntityMapper.kt
class UserEntityMapper {
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

// feature/user/data/repository/UserRepositoryImpl.kt
@Repository
class UserRepositoryImpl(
    private val jpaRepository: JpaUserRepository,
    private val mapper: UserEntityMapper
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
    
    override suspend fun delete(id: Long): Unit = withContext(Dispatchers.IO) {
        jpaRepository.deleteById(id)
    }
}
```

### Presentation Layer

```kotlin
// feature/user/presentation/dto/UserDto.kt
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
    @field:NotBlank val name: String?,
    @field:Email val email: String?
)

// feature/user/presentation/controller/UserController.kt
@RestController
@RequestMapping("/api/users")
class UserController(
    private val getUserUseCase: GetUserUseCase,
    private val createUserUseCase: CreateUserUseCase,
    private val updateUserUseCase: UpdateUserUseCase,
    private val deleteUserUseCase: DeleteUserUseCase,
    private val getAllUsersUseCase: GetAllUsersUseCase
) {
    
    @GetMapping
    suspend fun getAll(): List<UserDto> =
        getAllUsersUseCase().map { it.toDto() }
    
    @GetMapping("/{id}")
    suspend fun getById(@PathVariable id: Long): UserDto =
        getUserUseCase(id).toDto()
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    suspend fun create(@Valid @RequestBody request: CreateUserRequest): UserDto =
        createUserUseCase(request.name, request.email).toDto()
    
    @PutMapping("/{id}")
    suspend fun update(
        @PathVariable id: Long,
        @Valid @RequestBody request: UpdateUserRequest
    ): UserDto = updateUserUseCase(id, request).toDto()
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    suspend fun delete(@PathVariable id: Long) {
        deleteUserUseCase(id)
    }
    
    private fun User.toDto() = UserDto(
        id = id,
        name = name,
        email = email,
        createdAt = createdAt
    )
}
```

### Configuration

```kotlin
// feature/user/config/UserConfig.kt
@Configuration
class UserConfig {
    
    @Bean
    fun userEntityMapper() = UserEntityMapper()
    
    @Bean
    fun getUserUseCase(repository: UserRepository) =
        GetUserUseCase(repository)
    
    @Bean
    fun createUserUseCase(repository: UserRepository) =
        CreateUserUseCase(repository)
    
    @Bean
    fun updateUserUseCase(repository: UserRepository) =
        UpdateUserUseCase(repository)
    
    @Bean
    fun deleteUserUseCase(repository: UserRepository) =
        DeleteUserUseCase(repository)
    
    @Bean
    fun getAllUsersUseCase(repository: UserRepository) =
        GetAllUsersUseCase(repository)
}
```

## Benefits
- Framework-independent business logic
- Testable without Spring context
- Clear boundaries between layers
- Easy to migrate frameworks

## When to Use
- Large enterprise applications
- When business logic complexity is high
- Projects requiring framework independence

