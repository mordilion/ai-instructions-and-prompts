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

```kotlin
// 1. Domain Model (NO Spring!)
data class User(val id: Long?, val email: String, val name: String)

// 2. Repository Interface
interface UserRepository {
    suspend fun save(user: User): User
}

// 3. Use Case
class CreateUserUseCase(private val repository: UserRepository) {
    suspend fun execute(email: String, name: String) = repository.save(User(null, email, name))
}

// 4. Repository Implementation
@Repository
class UserRepositoryImpl(private val jpa: UserJpaRepository) : UserRepository {
    override suspend fun save(user: User) = mapper.toDomain(jpa.save(mapper.toEntity(user)))
}

// 5. Controller
@RestController
class UserController(private val useCase: CreateUserUseCase) {
    @PostMapping("/api/users")
    suspend fun create(@RequestBody req: CreateUserRequest) = UserDto.from(useCase.execute(req.email, req.name))
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
