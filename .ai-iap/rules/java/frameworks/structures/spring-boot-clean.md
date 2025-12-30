# Spring Boot Clean Architecture

> **Scope**: Spring Boot with Clean Architecture  
> **Use When**: Complex domain, framework independence

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, infrastructure, presentation
> **ALWAYS**: Domain has no Spring dependencies
> **ALWAYS**: Use repository interfaces
> **ALWAYS**: Dependency rule: inner → outer
> 
> **NEVER**: Import Spring in domain
> **NEVER**: Skip repository interfaces
> **NEVER**: Put business logic in controllers

## Structure

```
src/main/java/com/app/
├── domain/             # Pure business logic
│   ├── model/         # User, Order
│   ├── repository/    # Interfaces
│   ├── service/       # Domain services
│   └── exception/
├── application/        # Use cases
│   ├── usecase/       # CreateUserUseCase
│   ├── dto/
│   └── mapper/
├── infrastructure/     # External interfaces
│   ├── persistence/
│   │   ├── entity/    # JPA entities
│   │   └── repository/
│   ├── config/
│   └── external/
└── presentation/       # API layer
    ├── controller/
    ├── dto/
    └── exception/
```

## Core Patterns

### Domain Model (Pure)

```java
// domain/model/User.java
public class User {
    private final Long id;
    private final String email;
    private final String name;
    
    public User(Long id, String email, String name) {
        if (!email.contains("@")) throw new IllegalArgumentException("Invalid email");
        this.id = id;
        this.email = email;
        this.name = name;
    }
    
    // Getters only, no setters (immutable)
}
```

### Repository Interface

```java
// domain/repository/UserRepository.java
public interface UserRepository {
    Optional<User> findById(Long id);
    User save(User user);
    List<User> findAll();
}
```

### Use Case

```java
// application/usecase/CreateUserUseCase.java
@Service
public class CreateUserUseCase {
    private final UserRepository repository;
    
    public CreateUserUseCase(UserRepository repository) {
        this.repository = repository;
    }
    
    public User execute(String email, String name) {
        User user = new User(null, email, name);
        return repository.save(user);
    }
}
```

### Repository Implementation

```java
// infrastructure/persistence/repository/JpaUserRepository.java
@Repository
public class JpaUserRepositoryAdapter implements UserRepository {
    private final JpaUserRepository jpaRepo;
    private final UserMapper mapper;
    
    @Override
    public Optional<User> findById(Long id) {
        return jpaRepo.findById(id).map(mapper::toDomain);
    }
    
    @Override
    public User save(User user) {
        UserEntity entity = mapper.toEntity(user);
        UserEntity saved = jpaRepo.save(entity);
        return mapper.toDomain(saved);
    }
}
```

### Controller

```java
// presentation/controller/UserController.java
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final CreateUserUseCase createUserUseCase;
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest request) {
        User user = createUserUseCase.execute(request.getEmail(), request.getName());
        return UserResponse.from(user);
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Spring** | `@Entity` in domain | Pure Java |
| **No Interfaces** | Direct JPA | Repository interface |
| **Logic in Controller** | Business rules | Use cases |
| **Wrong Direction** | Domain imports API | API imports domain |

## AI Self-Check

- [ ] Domain layer pure Java?
- [ ] Repository interfaces in domain?
- [ ] Use cases for business logic?
- [ ] Dependency rule followed?
- [ ] No Spring in domain?
- [ ] DTOs for API boundary?
- [ ] Infrastructure implements interfaces?
- [ ] Mappers between entity and domain?

## Benefits

- ✅ Framework-independent business logic
- ✅ Testable (mock repositories)
- ✅ Clear boundaries
- ✅ Easy infrastructure changes

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability needs
- ❌ Simple CRUD
