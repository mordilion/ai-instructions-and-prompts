# .NET Architecture

> **Scope**: .NET architectural patterns and principles  
> **Applies to**: *.cs, *.csproj files  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use async/await for I/O operations
> **ALWAYS**: Use dependency injection (constructor)
> **ALWAYS**: Use interfaces for abstractions
> **ALWAYS**: Use nullable reference types (C# 8+)
> **ALWAYS**: Use ConfigureAwait(false) in libraries
> 
> **NEVER**: Use async void (except event handlers)
> **NEVER**: Block on async code (.Result, .Wait())
> **NEVER**: Use Singleton for DbContext
> **NEVER**: Return null (use nullable types properly)
> **NEVER**: Use static mutable state

## Core Patterns

### Async/Await
```csharp
public async Task<User> GetUserAsync(int id)
{
    var user = await _repository.GetByIdAsync(id);
    return user ?? throw new UserNotFoundException(id);
}
```

### Dependency Injection
```csharp
public interface IUserRepository
{
    Task<User?> GetByIdAsync(int id);
    Task SaveAsync(User user);
}

public class UserService
{
    private readonly IUserRepository _repository;
    
    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }
}
```

### Record Types
```csharp
public record User(int Id, string Name, string Email);

public record CreateUserRequest(string Name, string Email);
```

## Error Handling

```csharp
public class UserNotFoundException : Exception
{
    public UserNotFoundException(int id) 
        : base($"User {id} not found") { }
}
```

## Best Practices

### Nullable Reference Types
```csharp
#nullable enable

public User? FindUser(int id) => _users.Find(id);
```

### Pattern Matching
```csharp
var result = user switch
{
    { Role: "Admin" } => "Administrator",
    { Role: "User" } => "Regular User",
    _ => "Guest"
};
```

### LINQ
```csharp
var admins = users
    .Where(u => u.Role == "Admin")
    .Select(u => u.Name)
    .ToList();
```

## AI Self-Check

- [ ] async/await for I/O operations?
- [ ] Dependency injection via constructor?
- [ ] Interfaces for abstractions?
- [ ] Nullable reference types enabled (C# 8+)?
- [ ] ConfigureAwait(false) in libraries?
- [ ] Records for immutable data (C# 9+)?
- [ ] Pattern matching (C# 8+)?
- [ ] No async void (except event handlers)?
- [ ] No blocking on async (.Result, .Wait())?
- [ ] No Singleton for DbContext?
- [ ] No static mutable state?
- [ ] IDisposable/IAsyncDisposable for resources?
