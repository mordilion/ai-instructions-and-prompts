# Spring Boot Clean Architecture

> **Scope**: This structure extends the Spring Boot framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
src/main/java/com/company/myapp/
├── domain/                     # Core business logic
│   ├── model/
│   │   ├── User.java
│   │   └── Order.java
│   ├── repository/             # Repository interfaces
│   │   ├── UserRepository.java
│   │   └── OrderRepository.java
│   ├── service/                # Domain services
│   │   └── UserDomainService.java
│   └── exception/
│       └── UserNotFoundException.java
├── application/                # Use cases
│   ├── usecase/
│   │   ├── CreateUserUseCase.java
│   │   ├── GetUserUseCase.java
│   │   └── UpdateUserUseCase.java
│   ├── dto/
│   │   ├── UserDto.java
│   │   └── CreateUserRequest.java
│   └── mapper/
│       └── UserMapper.java
├── infrastructure/             # External interfaces
│   ├── persistence/
│   │   ├── entity/
│   │   │   └── UserEntity.java
│   │   └── repository/
│   │       └── JpaUserRepository.java
│   ├── config/
│   │   ├── DatabaseConfig.java
│   │   └── SecurityConfig.java
│   └── external/
│       └── EmailServiceImpl.java
└── presentation/               # API layer
    ├── controller/
    │   └── UserController.java
    ├── dto/
    │   └── UserResponse.java
    └── exception/
        └── GlobalExceptionHandler.java
```

## Layer Dependencies
```
Presentation → Application → Domain
Infrastructure → Domain (implements interfaces)
```

## Example: Domain Model
```java
// domain/model/User.java
package com.company.myapp.domain.model;

import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class User {
    Long id;
    String email;
    String name;
    boolean active;
    
    public void validate() {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
    }
    
    public User activate() {
        return User.builder()
            .id(this.id)
            .email(this.email)
            .name(this.name)
            .active(true)
            .build();
    }
}
```

## Example: Repository Interface
```java
// domain/repository/UserRepository.java
package com.company.myapp.domain.repository;

import com.company.myapp.domain.model.User;
import java.util.Optional;

public interface UserRepository {
    User save(User user);
    Optional<User> findById(Long id);
    Optional<User> findByEmail(String email);
    void deleteById(Long id);
}
```

## Example: Use Case
```java
// application/usecase/CreateUserUseCase.java
package com.company.myapp.application.usecase;

import com.company.myapp.application.dto.CreateUserRequest;
import com.company.myapp.application.dto.UserDto;
import com.company.myapp.application.mapper.UserMapper;
import com.company.myapp.domain.model.User;
import com.company.myapp.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CreateUserUseCase {
    private final UserRepository userRepository;
    
    @Transactional
    public UserDto execute(final CreateUserRequest request) {
        // Validate
        if (userRepository.findByEmail(request.email()).isPresent()) {
            throw new IllegalArgumentException("Email already exists");
        }
        
        // Create domain model
        final User user = User.builder()
            .email(request.email())
            .name(request.name())
            .active(true)
            .build();
        
        user.validate();
        
        // Save
        final User savedUser = userRepository.save(user);
        
        // Map to DTO
        return UserMapper.toDto(savedUser);
    }
}
```

## Example: Infrastructure Implementation
```java
// infrastructure/persistence/repository/JpaUserRepository.java
package com.company.myapp.infrastructure.persistence.repository;

import com.company.myapp.domain.model.User;
import com.company.myapp.domain.repository.UserRepository;
import com.company.myapp.infrastructure.persistence.entity.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class JpaUserRepository implements UserRepository {
    private final SpringDataUserRepository springDataRepository;
    
    @Override
    public User save(final User user) {
        final UserEntity entity = toEntity(user);
        final UserEntity saved = springDataRepository.save(entity);
        return toDomain(saved);
    }
    
    @Override
    public Optional<User> findById(final Long id) {
        return springDataRepository.findById(id)
            .map(this::toDomain);
    }
    
    private User toDomain(final UserEntity entity) {
        return User.builder()
            .id(entity.getId())
            .email(entity.getEmail())
            .name(entity.getName())
            .active(entity.isActive())
            .build();
    }
    
    private UserEntity toEntity(final User user) {
        return UserEntity.builder()
            .id(user.getId())
            .email(user.getEmail())
            .name(user.getName())
            .active(user.isActive())
            .build();
    }
}

// Spring Data JPA interface (internal to infrastructure)
interface SpringDataUserRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByEmail(String email);
}
```

## Example: Controller
```java
// presentation/controller/UserController.java
package com.company.myapp.presentation.controller;

import com.company.myapp.application.dto.CreateUserRequest;
import com.company.myapp.application.dto.UserDto;
import com.company.myapp.application.usecase.CreateUserUseCase;
import com.company.myapp.application.usecase.GetUserUseCase;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final CreateUserUseCase createUserUseCase;
    private final GetUserUseCase getUserUseCase;
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody final CreateUserRequest request) {
        final UserDto user = createUserUseCase.execute(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
    
    @GetMapping("/{id}")
    public UserDto getUser(@PathVariable final Long id) {
        return getUserUseCase.execute(id);
    }
}
```

## Rules
- **Dependency Rule**: Dependencies point inward toward domain.
- **Domain Independence**: Domain layer has NO Spring/framework dependencies.
- **Use Cases**: All business logic flows through use cases in application layer.
- **Mapping**: Map between entities (infrastructure) and models (domain).
- **Interfaces in Domain**: Define repository interfaces in domain, implement in infrastructure.

## When to Use
- Large, complex Spring Boot applications
- Long-term projects requiring maintainability
- Projects with complex business rules
- Need for framework independence (easier migration)
- Teams experienced with Clean Architecture/Hexagonal Architecture

