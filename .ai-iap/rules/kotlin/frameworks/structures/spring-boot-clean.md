# Spring Boot Clean Architecture

> **Scope**: Spring Boot with Clean Architecture (DDD-inspired)
> **Use When**: Complex domain, clear boundaries, framework independence

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, data, presentation layers
> **ALWAYS**: Domain has no framework dependencies
> **ALWAYS**: Use interfaces for repositories
> **ALWAYS**: Dependency rule: inner layers don't know outer
> 
> **NEVER**: Import Spring in domain
> **NEVER**: Put business logic in controllers
> **NEVER**: Skip repository interfaces

## Structure

```
src/main/kotlin/com/app/
├── feature/user/
│   ├── domain/              # Pure business logic
│   │   ├── model/          # Entities
│   │   ├── repository/     # Interfaces
│   │   └── usecase/        # Business rules
│   ├── data/               # Data layer
│   │   ├── repository/     # Implementations
│   │   ├── entity/         # JPA entities
│   │   └── mapper/
│   ├── presentation/        # API layer
│   │   ├── controller/
│   │   └── dto/
│   └── config/
└── core/                    # Shared
```

## Core Patterns

### Domain Model (Pure)

```kotlin
// domain/model/User.kt - NO Spring dependencies
data class User(
    val id: Long?,
    val email: String,
    val name: String
) {
    fun changeEmail(newEmail: String): User {
        require("@" in newEmail) { "Invalid email" }
        return copy(email = newEmail)
    }
}
```

### Repository Interface

```kotlin
// domain/repository/UserRepository.kt
interface UserRepository {
    suspend fun findById(id: Long): User?
    suspend fun save(user: User): User
    suspend fun findAll(): List<User>
}
```

### Use Case

```kotlin
// domain/usecase/CreateUserUseCase.kt
class CreateUserUseCase(private val repository: UserRepository) {
    suspend fun execute(email: String, name: String): User {
        val user = User(id = null, email = email, name = name)
        return repository.save(user)
    }
}
```

### Repository Implementation

```kotlin
// data/repository/UserRepositoryImpl.kt
@Repository
class UserRepositoryImpl(
    private val jpaRepository: UserJpaRepository,
    private val mapper: UserEntityMapper
) : UserRepository {
    
    override suspend fun findById(id: Long): User? = withContext(Dispatchers.IO) {
        jpaRepository.findById(id).map { mapper.toDomain(it) }.orElse(null)
    }
    
    override suspend fun save(user: User): User = withContext(Dispatchers.IO) {
        val entity = mapper.toEntity(user)
        val saved = jpaRepository.save(entity)
        mapper.toDomain(saved)
    }
}
```

### Controller

```kotlin
// presentation/controller/UserController.kt
@RestController
@RequestMapping("/api/users")
class UserController(private val createUserUseCase: CreateUserUseCase) {
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    suspend fun create(@Valid @RequestBody request: CreateUserRequest): UserDto {
        val user = createUserUseCase.execute(request.email, request.name)
        return UserDto.from(user)
    }
}
```

### Configuration

```kotlin
// config/UserConfig.kt
@Configuration
class UserConfig {
    @Bean
    fun createUserUseCase(repository: UserRepository) = 
        CreateUserUseCase(repository)
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Spring** | `@Entity` in domain | Pure Kotlin classes |
| **No Interfaces** | Direct JPA access | Repository interface |
| **Logic in Controller** | Business rules in API | Use cases |
| **Wrong Direction** | Domain imports API | API imports domain |

## AI Self-Check

- [ ] Domain layer pure (no Spring)?
- [ ] Repository interfaces in domain?
- [ ] Use cases for business logic?
- [ ] Dependency rule followed?
- [ ] DTOs for API boundary?
- [ ] No business logic in controllers?
- [ ] Data layer implements interfaces?
- [ ] Testable without database?
- [ ] Mapper between entity and domain?
- [ ] Configuration beans for use cases?

## Benefits

- ✅ Framework-independent business logic
- ✅ Testable (mock repositories)
- ✅ Clear boundaries
- ✅ Easy infrastructure changes

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability needs
- ❌ Simple CRUD (over-engineering)
