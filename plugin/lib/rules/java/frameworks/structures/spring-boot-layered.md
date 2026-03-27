# Spring Boot Layered Structure

> **Scope**: Layered structure for Spring Boot  
> **Applies to**: Spring Boot projects with layered structure  
> **Extends**: java/frameworks/spring-boot.md

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
src/main/java/com/app/
├── controller/UserController.java
├── service/UserService.java
├── repository/UserRepository.java
├── entity/User.java
├── dto/
│   ├── UserDto.java
│   └── CreateUserRequest.java
├── mapper/UserMapper.java
└── exception/UserNotFoundException.java
```

## Implementation

```java
@Entity
public class User {
    @Id @GeneratedValue
    private Long id;
    private String name;
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {}

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository repository;
    
    public UserDto getUser(Long id) {
        return repository.findById(id)
            .map(UserMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
}

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService service;
    
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable Long id) {
        return service.getUser(id);
    }
}
```

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
