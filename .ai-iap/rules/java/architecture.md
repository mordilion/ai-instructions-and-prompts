# Java Architecture

> **Scope**: Java architectural patterns and principles
> **Applies to**: *.java files
> **Extends**: general/architecture.md
> **Precedence**: Structure > Framework > Language > General

## Rule Precedence Matrix

When rules conflict across multiple files, use this priority order:

| Your Context | Winning Rule File | Overrides |
|-------------|-------------------|-----------|
| Spring Boot service | spring-boot.md | Java + General rules |
| Spring Boot with Clean Architecture | spring-boot-clean.md | Spring Boot + Java rules |
| Android Activity | android.md → android-mvvm.md | Java + General rules |
| Generic Java class | **This file** | General rules only |
| Hibernate entity | hibernate.md + spring-boot.md | Java + General rules |

**Rule**: MOST SPECIFIC FILE ALWAYS WINS.

### Example Conflict Resolution

```
Context: Spring Boot service dependency injection
Question: Use @Autowired or constructor injection?

Precedence check:
1. Structure rules (spring-boot-clean.md)? → No specific guidance
2. Framework rules (spring-boot.md)? → "ALWAYS @RequiredArgsConstructor" ← USE THIS
3. Language rules (this file)? → "Constructor injection" ← SUPPORTS, but less specific
4. General rules? → "Dependency injection" ← IGNORE

Answer: @RequiredArgsConstructor (Framework rule is most specific)
```

```
Context: Generic Java utility class
Question: How to handle optional values?

Precedence check:
1. Structure rules? → Not applicable
2. Framework rules? → Not applicable
3. Language rules (this file)? → "Use Optional<T>" ← USE THIS
4. General rules? → "Return null or throw" ← IGNORE

Answer: Use Optional<T> (Language rule wins)
```

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
