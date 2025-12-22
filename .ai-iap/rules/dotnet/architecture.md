# .NET Architecture

## Overview
Modern .NET with clean architecture, dependency injection, and async patterns.

## Core Principles

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
