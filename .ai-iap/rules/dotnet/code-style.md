# .NET Code Style

## General Rules

- **.NET 8+**, **C# 12+**
- **Nullable reference types** enabled
- **EditorConfig** for style
- **Async/await** for I/O

## Naming Conventions

```csharp
// PascalCase for public members
public class UserService {}
public string UserName { get; set; }
public void GetUser() {}

// camelCase for private fields with underscore
private readonly IUserRepository _repository;
private string _userName;

// PascalCase for constants
public const int MaxAttempts = 3;
```

## Type Declarations

```csharp
// Use var when type is obvious
var users = new List<User>();
var count = 10;

// Explicit when not obvious
IUserRepository repository = new UserRepository();
```

## Methods

```csharp
// Async suffix for async methods
public async Task<User> GetUserAsync(int id)
{
    return await _repository.GetByIdAsync(id);
}

// Expression-bodied members
public int Double(int x) => x * 2;
public string Name => _name;
```

## Null Safety

```csharp
#nullable enable

// Nullable reference
public User? FindUser(int id) => users.Find(id);

// Null-coalescing
var name = user?.Name ?? "Anonymous";

// Null-conditional
var email = user?.Profile?.Email;
```

## Best Practices

```csharp
// Use records for DTOs
public record UserDto(int Id, string Name);

// Init-only properties
public string Name { get; init; }

// Pattern matching
if (obj is User { Role: "Admin" } admin)
{
    // Use admin
}

// String interpolation
var message = $"User {name} created";
```
