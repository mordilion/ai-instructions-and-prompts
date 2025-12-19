# Java Code Style

> **Scope**: Apply these rules ONLY when working with `.java` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: Java 17+ features required (21+ recommended).
- **Style Guide**: Follow Google Java Style Guide or Oracle Code Conventions.
- **Immutability**: Prefer immutable objects. Use `final` for variables and fields.
- **Null Safety**: NEVER return `null`. Use `Optional<T>` or throw exceptions.

## 2. Structure
- **One Class per File**: One public class per `.java` file.
- **Imports**: No wildcard imports (`import java.util.*`). Order: Java → Javax → Third-party → Company.
- **Class Member Order**:
  1. Constants (`static final`)
  2. Static fields
  3. Instance fields
  4. Constructors
  5. Public methods
  6. Private methods
  7. Nested classes

## 3. Naming
- **Files**: Match class name (e.g., `UserService.java`).
- **Classes/Interfaces**: `PascalCase` (e.g., `UserService`, `OrderDto`).
- **Methods/Variables**: `camelCase` (e.g., `getUser`, `userId`).
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`, `DEFAULT_TIMEOUT`).
- **Packages**: lowercase, no underscores (e.g., `com.company.users`).
- **Type Parameters**: Single uppercase letter (e.g., `T`, `E`, `K`, `V`).
- **Booleans**: Prefix `is`, `has`, `should`, `can` (e.g., `isActive`, `hasPermission`).

## 4. Language Features
- **Records**: Use for immutable DTOs (Java 14+).
```java
// ✅ Good - Record for DTO
public record UserDto(Long id, String email, String name) {}
```
- **Switch Expressions**: Use modern switch expressions (Java 14+).
```java
// ✅ Good - Switch expression
String result = switch (status) {
    case ACTIVE -> "User is active";
    case INACTIVE -> "User is inactive";
    case PENDING -> "User is pending";
};
```
- **Streams**: Use streams for collection operations.
  - ✅ Good: `users.stream().filter(User::isActive).toList()`
  - ❌ Bad: `for (User u : users) { if (u.isActive()) { ... } }`
- **Optionals**: Use `Optional<T>` to indicate absence of value.
  - ✅ Good: `Optional<User> findById(Long id);`
  - ❌ Bad: `User findById(Long id); // might return null`

## 5. Best Practices
- **Final Variables**: Use `final` for method parameters and local variables.
```java
public void processUser(final User user) {
    final String email = user.getEmail();
    // ...
}
```
- **Exceptions**: Throw specific exceptions. Create custom exceptions.
  - ✅ Good: `throw new UserNotFoundException("User " + userId + " not found");`
  - ❌ Bad: `throw new RuntimeException("User not found");`
- **Logging**: Use SLF4J with placeholders.
  - ✅ Good: `log.error("Failed to process user {}", userId, exception);`
  - ❌ Bad: `log.error("Failed to process user " + userId + ": " + exception.getMessage());`
- **Builder Pattern**: Use for objects with many parameters.
```java
User user = User.builder()
    .email("test@example.com")
    .name("Test User")
    .active(true)
    .build();
```
- **Javadoc**: Document public APIs and complex logic.
```java
/**
 * Retrieves a user by their unique identifier.
 *
 * @param userId the unique identifier of the user
 * @return the user if found
 * @throws UserNotFoundException if the user does not exist
 */
public User getUser(final Long userId) {
    return userRepository.findById(userId)
        .orElseThrow(() -> new UserNotFoundException(userId));
}
```

## 6. Code Organization
```java
package com.company.users;

// Java standard library
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

// Third-party
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

// Company
import com.company.core.exceptions.UserNotFoundException;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    
    public UserDto getUser(final Long userId) {
        log.debug("Fetching user with id: {}", userId);
        
        final User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        return UserMapper.toDto(user);
    }
}
```

## 7. Dependency Injection
- **Constructor Injection**: Use constructor injection with `final` fields.
```java
// ✅ Good - Constructor injection with Lombok
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
}

// ✅ Good - Without Lombok
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    @Autowired
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
}

// ❌ Bad - Field injection
public class UserService {
    @Autowired
    private UserRepository userRepository;  // Not final, hard to test
}
```

## 8. Anti-Patterns (MUST avoid)
- **Mutable Objects**: Prefer immutable objects. Use `final` fields.
  - ❌ Bad: `public class User { private String name; public void setName(String name) {...} }`
  - ✅ Good: `public record UserDto(String name) {}` or use Lombok `@Value`
- **Null Returns**: NEVER return `null`. Use `Optional` or throw exceptions.
  - ❌ Bad: `public User findUser(Long id) { return null; }`
  - ✅ Good: `public Optional<User> findUser(Long id) { return Optional.empty(); }`
- **Checked Exceptions**: Avoid checked exceptions for business logic.
  - ❌ Bad: `public User getUser(Long id) throws UserNotFoundException`
  - ✅ Good: `public User getUser(Long id)` (throw `UserNotFoundException extends RuntimeException`)
- **Magic Numbers**: Use named constants.
  - ❌ Bad: `if (user.getAge() > 18) {...}`
  - ✅ Good: `private static final int MINIMUM_AGE = 18; if (user.getAge() > MINIMUM_AGE) {...}`
- **Utility Classes**: Make utility classes final with private constructor.
```java
// ✅ Good
public final class StringUtils {
    private StringUtils() {
        throw new UnsupportedOperationException("Utility class");
    }
    
    public static String capitalize(final String str) {
        // ...
    }
}
```

