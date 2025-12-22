# Spring Boot Layered Structure

> Traditional 3-layer architecture (Controller → Service → Repository). Best for CRUD-focused enterprise applications.

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
