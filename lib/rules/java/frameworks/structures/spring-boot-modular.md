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
src/main/java/com/app/
├── common/              # Shared utilities only
│   ├── exception/
│   ├── security/
│   └── config/
├── users/                # User module (self-contained)
│   ├── User.java
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserRepository.java
│   └── dto/
├── orders/               # Order module
│   ├── Order.java
│   ├── OrderService.java
│   └── OrderController.java
└── products/             # Product module
```

## Core Patterns

```java
// Module Organization (users/)
@Entity
public class User {
    @Id @GeneratedValue private Long id;
    private String name, email;
}

@Service
public class UserService {
    public User create(String name, String email) {
        return repository.save(new User(name, email));
    }
}

@RestController
public class UserController {
    @PostMapping("/api/users")
    public UserDto create(@Valid @RequestBody CreateUserDto dto) {
        return service.create(dto.name(), dto.email()).toDto();
    }
}

// Cross-Module Communication (Public API)
public interface UserPublicApi {
    Optional<UserDto> getUserById(Long id);
}

@Service
public class UserPublicApiImpl implements UserPublicApi {
    public Optional<UserDto> getUserById(Long id) {
        return service.findById(id).map(User::toDto);
    }
}

// orders/OrderService.java (uses UserPublicApi)
@Service
public class OrderService {
    private final UserPublicApi userApi;
    public Order createOrder(Long userId) {
        return userApi.getUserById(userId).map(u -> new Order(userId)).orElseThrow();
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
