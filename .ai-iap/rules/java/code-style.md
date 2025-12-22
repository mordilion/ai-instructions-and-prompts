# Java Code Style

## General Rules

- **Java 17+**
- **Google Java Style** or **Sun conventions**
- **Immutability** preferred
- **Lombok** for boilerplate

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
// Use var when type is obvious (Java 10+)
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
// Use records (Java 14+)
public record UserDto(Long id, String name) {}

// Use switch expressions (Java 14+)
var result = switch (status) {
    case PENDING -> handlePending();
    case APPROVED -> handleApproved();
    default -> handleDefault();
};

// Text blocks (Java 15+)
String json = """
    {
      "name": "John",
      "email": "john@test.com"
    }
    """;

// Pattern matching (Java 16+)
if (obj instanceof User user) {
    System.out.println(user.getName());
}
```
