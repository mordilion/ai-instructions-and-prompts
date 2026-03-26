# Java Code Style

> **Scope**: Java formatting and maintainability  
> **Applies to**: *.java files  
> **Extends**: General code style, java/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Google Java Style or Sun conventions
> **ALWAYS**: Prefer immutability (final fields, records)
> **ALWAYS**: Use Optional<T> for nullable returns
> **ALWAYS**: Use var when type is obvious
> **ALWAYS**: Use try-with-resources for AutoCloseable
> 
> **NEVER**: Return null (use Optional<T>)
> **NEVER**: Use raw types (use generics)
> **NEVER**: Catch generic Exception
> **NEVER**: Use field injection
> **NEVER**: Mutate collections after creation

## Naming Conventions

```java
// PascalCase for classes
public class UserService {}

// camelCase for variables, methods
private String userName;
public void getUser() {}

// UPPER_SNAKE_CASE for constants
public static final int MAX_ATTEMPTS = 3;
```

## Type Declarations

```java
// Use var when type is obvious (modern Java)
var users = List.of(user1, user2);
var count = 10;

// Explicit when not obvious
UserRepository repository = new DatabaseUserRepository();
```

## Methods

```java
// Use Optional for nullable returns
public Optional<User> findUser(Long id) {
    return repository.findById(id);
}

// Explicit null checks
public User getUser(Long id) {
    Objects.requireNonNull(id, "ID cannot be null");
    return repository.findById(id)
        .orElseThrow(() -> new UserNotFoundException(id));
}
```

## Best Practices

```java
// Use records (modern Java)
public record UserDto(Long id, String name) {}

// Use switch expressions (modern Java)
var result = switch (status) {
    case PENDING -> handlePending();
    case APPROVED -> handleApproved();
    default -> handleDefault();
};

// Text blocks (modern Java)
String json = """
    {
      "name": "John",
      "email": "john@test.com"
    }
    """;

// Pattern matching (modern Java)
if (obj instanceof User user) {
    System.out.println(user.getName());
}
```

## AI Self-Check

- [ ] Following Google Java Style or Sun conventions?
- [ ] Preferring immutability (final fields)?
- [ ] Using Optional<T> for nullable returns?
- [ ] Using var when type is obvious?
- [ ] try-with-resources for AutoCloseable?
- [ ] Lombok for boilerplate reduction?
- [ ] Records for immutable data (Java 14+)?
- [ ] No null returns?
- [ ] No raw types (using generics)?
- [ ] No generic Exception catches?
- [ ] No field injection?
- [ ] Collections immutable after creation?
