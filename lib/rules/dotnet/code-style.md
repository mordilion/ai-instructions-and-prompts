# .NET Code Style

> **Scope**: .NET/C# formatting and maintainability  
> **Applies to**: *.cs files  
> **Extends**: General code style, dotnet/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Enable nullable reference types
> **ALWAYS**: Use EditorConfig for style
> **ALWAYS**: Use async/await for I/O operations
> **ALWAYS**: Use var when type is obvious
> **ALWAYS**: Use expression-bodied members for single statements
> 
> **NEVER**: Block on async (.Result, .Wait())
> **NEVER**: Use async void (except event handlers)
> **NEVER**: Skip nullable annotations
> **NEVER**: Use underscores for local variables
> **NEVER**: Public fields (use properties)

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

## AI Self-Check

- [ ] Nullable reference types enabled?
- [ ] EditorConfig configured?
- [ ] async/await for I/O operations?
- [ ] var when type is obvious?
- [ ] Expression-bodied members?
- [ ] PascalCase for public members?
- [ ] camelCase with underscore for private fields?
- [ ] No blocking on async (.Result, .Wait())?
- [ ] No async void (except event handlers)?
- [ ] No missing nullable annotations?
- [ ] No public fields (using properties)?
- [ ] Records for immutable data (C# 9+)?
