# Java Architecture

## Overview
Clean Java architecture with immutability, dependency injection, and SOLID principles.

## Core Principles

### Immutability
```java
public record User(Long id, String name, String email) {}

// Or with final fields
public final class User {
    private final Long id;
    private final String name;
    
    public User(Long id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

### Dependency Injection
```java
public interface UserRepository {
    Optional<User> findById(Long id);
    User save(User user);
}

public class UserService {
    private final UserRepository repository;
    
    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}
```

### Optional for Nullability
```java
public Optional<User> findUser(Long id) {
    return repository.findById(id);
}

User user = findUser(id)
    .orElseThrow(() -> new UserNotFoundException(id));
```

## Error Handling

```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User " + id + " not found");
    }
}
```

## Best Practices

### Stream API
```java
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .collect(Collectors.toList());
```

### Try-with-Resources
```java
try (var reader = new BufferedReader(new FileReader(file))) {
    return reader.readLine();
}
```

### Sealed Classes (Java 17+)
```java
public sealed interface Result<T> permits Success, Failure {}
record Success<T>(T data) implements Result<T> {}
record Failure<T>(String error) implements Result<T> {}
```
