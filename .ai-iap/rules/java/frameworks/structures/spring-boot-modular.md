# Spring Boot Modular Structure

> **Scope**: This structure extends the Spring Boot framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
src/main/java/com/company/myapp/
├── users/                      # User domain module
│   ├── User.java               # Entity
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserRepository.java
│   ├── dto/
│   │   ├── CreateUserRequest.java
│   │   └── UserDto.java
│   ├── mapper/
│   │   └── UserMapper.java
│   └── exception/
│       └── UserNotFoundException.java
├── orders/                     # Order domain module
│   ├── Order.java
│   ├── OrderController.java
│   ├── OrderService.java
│   ├── OrderRepository.java
│   └── dto/
├── products/                   # Product domain module
│   ├── Product.java
│   ├── ProductController.java
│   ├── ProductService.java
│   └── ProductRepository.java
├── common/                     # Shared utilities
│   ├── exception/
│   │   └── GlobalExceptionHandler.java
│   ├── security/
│   │   └── SecurityConfig.java
│   └── config/
│       └── DatabaseConfig.java
└── Application.java            # Main class
```

## Module Structure (users/)
```
users/
├── User.java                   # JPA Entity
├── UserController.java         # REST controller
├── UserService.java            # Business logic
├── UserRepository.java         # Spring Data JPA repository
├── dto/
│   ├── CreateUserRequest.java # Request DTO
│   └── UserDto.java            # Response DTO
├── mapper/
│   └── UserMapper.java         # Entity ↔ DTO mapping
└── exception/
    └── UserNotFoundException.java
```

## Example: Entity
```java
// users/User.java
package com.company.myapp.users;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    private boolean active;
    
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

## Example: Service
```java
// users/UserService.java
package com.company.myapp.users;

import com.company.myapp.users.dto.CreateUserRequest;
import com.company.myapp.users.dto.UserDto;
import com.company.myapp.users.exception.UserNotFoundException;
import com.company.myapp.users.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    
    @Transactional
    public UserDto createUser(final CreateUserRequest request) {
        log.info("Creating user with email: {}", request.email());
        
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }
        
        final User user = User.builder()
            .email(request.email())
            .name(request.name())
            .active(true)
            .build();
        
        final User saved = userRepository.save(user);
        return UserMapper.toDto(saved);
    }
    
    public UserDto getUser(final Long userId) {
        return userRepository.findById(userId)
            .map(UserMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(userId));
    }
}
```

## Example: Controller
```java
// users/UserController.java
package com.company.myapp.users;

import com.company.myapp.users.dto.CreateUserRequest;
import com.company.myapp.users.dto.UserDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody final CreateUserRequest request) {
        final UserDto user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable final Long id) {
        return userService.getUser(id);
    }
}
```

## Example: Repository
```java
// users/UserRepository.java
package com.company.myapp.users;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

## Rules
- **Self-Contained Modules**: Each module has entities, controllers, services, repositories.
- **Package by Feature**: Group by business domain, not technical layer.
- **Minimal Cross-Module Dependencies**: Modules communicate through DTOs, not entities.
- **Shared Code Only**: Only truly reusable code in `common/`.

## When to Use
- Medium to large Spring Boot applications
- Clear domain boundaries
- Multiple teams working on different modules
- Potential for extracting modules to microservices
- Feature-based development

