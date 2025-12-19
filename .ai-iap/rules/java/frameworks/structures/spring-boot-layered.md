# Spring Boot Traditional/Layered Structure

> **Scope**: This structure extends the Spring Boot framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
src/main/java/com/company/myapp/
├── controller/                 # REST controllers
│   ├── UserController.java
│   ├── OrderController.java
│   └── ProductController.java
├── service/                    # Business logic
│   ├── UserService.java
│   ├── OrderService.java
│   └── ProductService.java
├── repository/                 # Data access
│   ├── UserRepository.java
│   ├── OrderRepository.java
│   └── ProductRepository.java
├── model/                      # JPA entities
│   ├── User.java
│   ├── Order.java
│   └── Product.java
├── dto/                        # Request/Response DTOs
│   ├── request/
│   │   ├── CreateUserRequest.java
│   │   └── UpdateUserRequest.java
│   └── response/
│       ├── UserDto.java
│       └── OrderDto.java
├── mapper/                     # Entity ↔ DTO mapping
│   ├── UserMapper.java
│   └── OrderMapper.java
├── exception/                  # Custom exceptions
│   ├── UserNotFoundException.java
│   └── GlobalExceptionHandler.java
├── config/                     # Configuration classes
│   ├── DatabaseConfig.java
│   └── SecurityConfig.java
└── Application.java            # Main class
```

## Layer Dependencies
```
Controller → Service → Repository → Model
```

## Example: Model (Entity)
```java
// model/User.java
package com.company.myapp.model;

import jakarta.persistence.*;
import lombok.*;

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
    
    private String name;
    private boolean active;
}
```

## Example: Repository
```java
// repository/UserRepository.java
package com.company.myapp.repository;

import com.company.myapp.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
```

## Example: Service
```java
// service/UserService.java
package com.company.myapp.service;

import com.company.myapp.dto.request.CreateUserRequest;
import com.company.myapp.dto.response.UserDto;
import com.company.myapp.exception.UserNotFoundException;
import com.company.myapp.mapper.UserMapper;
import com.company.myapp.model.User;
import com.company.myapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    
    @Transactional
    public UserDto createUser(final CreateUserRequest request) {
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
// controller/UserController.java
package com.company.myapp.controller;

import com.company.myapp.dto.request.CreateUserRequest;
import com.company.myapp.dto.response.UserDto;
import com.company.myapp.service.UserService;
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

## Rules
- **Clear Layer Separation**: Each layer has distinct responsibility.
- **One Direction Dependency**: Controller → Service → Repository → Model.
- **No Layer Skipping**: Controller must call Service, not Repository directly.
- **Shared DTOs**: Use DTOs for data transfer between layers.

## When to Use
- Small to medium Spring Boot applications
- Teams familiar with traditional layered architecture
- Rapid prototyping and development
- Standard Spring Boot conventions preferred
- Clear technical separation needed

