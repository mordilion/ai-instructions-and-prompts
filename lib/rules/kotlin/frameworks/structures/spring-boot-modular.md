# Spring Boot Modular Structure

> **Scope**: Feature-first modular structure for Spring Boot  
> **Use When**: Medium-large apps, domain-driven design

## CRITICAL REQUIREMENTS

> **ALWAYS**: Organize by feature/business capability
> **ALWAYS**: Each module is self-contained
> **ALWAYS**: Minimize cross-module dependencies
> **ALWAYS**: Use interfaces for module communication
> 
> **NEVER**: Share implementation details between modules
> **NEVER**: Create circular dependencies

## Structure

```
src/main/kotlin/com/app/
├── common/              # Shared utilities only
│   ├── config/
│   ├── exception/
│   └── util/
├── user/                # User module (self-contained)
│   ├── User.kt         # Domain
│   ├── UserRepository.kt
│   ├── UserService.kt
│   ├── UserController.kt
│   └── UserDto.kt
├── order/               # Order module
│   ├── Order.kt
│   ├── OrderService.kt
│   └── OrderController.kt
└── product/             # Product module
```

## Core Patterns

### Module Organization

```kotlin
// user/User.kt
data class User(
    val id: Long?,
    val name: String,
    val email: String
)

// user/UserService.kt
@Service
class UserService(private val repository: UserRepository) {
    suspend fun create(name: String, email: String): User {
        val user = User(id = null, name = name, email = email)
        return repository.save(user)
    }
}

// user/UserController.kt
@RestController
@RequestMapping("/api/users")
class UserController(private val service: UserService) {
    @PostMapping
    suspend fun create(@Valid @RequestBody dto: CreateUserDto) =
        service.create(dto.name, dto.email).toDto()
}
```

### Cross-Module Communication

```kotlin
// user/UserPublicApi.kt - Interface for other modules
interface UserPublicApi {
    suspend fun getUserById(id: Long): UserDto?
}

@Service
class UserPublicApiImpl(private val service: UserService) : UserPublicApi {
    override suspend fun getUserById(id: Long) = 
        service.findById(id)?.toDto()
}

// order/OrderService.kt - Uses user module via interface
@Service
class OrderService(private val userApi: UserPublicApi) {
    suspend fun createOrder(userId: Long, items: List<Item>): Order {
        val user = userApi.getUserById(userId) ?: throw UserNotFoundException()
        return Order(userId = userId, items = items)
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Circular Dependencies** | user → order → user | Use interfaces |
| **Shared Implementation** | Expose service directly | Public API interface |
| **Module Coupling** | Access internal classes | Public API only |
| **Common Bloat** | Everything in common/ | Only truly shared code |

## AI Self-Check

- [ ] Organized by feature?
- [ ] Each module self-contained?
- [ ] Public API interfaces for cross-module?
- [ ] No circular dependencies?
- [ ] Common/ has only shared utilities?
- [ ] Tests mirror module structure?
- [ ] No implementation sharing?
- [ ] Clear module boundaries?

## Benefits

- ✅ High cohesion, low coupling
- ✅ Easy to understand scope
- ✅ Parallel team development
- ✅ Easier to extract to microservices

## When to Use

- ✅ Medium-large applications
- ✅ Clear business domains
- ✅ Multiple teams
- ❌ Simple CRUD apps
