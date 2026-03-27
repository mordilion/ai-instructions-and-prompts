# ASP.NET Core Traditional Structure

> **Scope**: Traditional layered architecture for ASP.NET Core  
> **Applies to**: ASP.NET Core projects with layered structure  
> **Extends**: dotnet/frameworks/aspnetcore.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Controllers → Services → Repositories → Data
> **ALWAYS**: Use interfaces for Services and Repositories
> **ALWAYS**: DTOs for API contracts (not entities)
> **ALWAYS**: Dependency injection for all layers
> **ALWAYS**: Keep controllers thin (delegate to services)
> 
> **NEVER**: Controllers call Repositories directly
> **NEVER**: Return entities from controllers
> **NEVER**: Put business logic in controllers
> **NEVER**: Static classes for services
> **NEVER**: Circular dependencies between layers

## Directory Structure

```
src/
├── Controllers/UserController.cs
├── Services/UserService.cs
├── Repositories/UserRepository.cs
├── Models/User.cs
└── DTOs/
    ├── UserDto.cs
    └── CreateUserRequest.cs
```

## Implementation

```csharp
// Models/User.cs
public class User {
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

// Repositories/UserRepository.cs
public interface IUserRepository {
    Task<User?> GetByIdAsync(int id);
}

// Services/UserService.cs
public class UserService {
    private readonly IUserRepository _repository;
    
    public UserService(IUserRepository repository) {
        _repository = repository;
    }
    
    public async Task<UserDto> GetUserAsync(int id) {
        var user = await _repository.GetByIdAsync(id);
        return user != null ? MapToDto(user) : throw new UserNotFoundException(id);
    }
}

// Controllers/UserController.cs
[ApiController]
[Route("api/users")]
public class UserController : ControllerBase {
    private readonly UserService _service;
    
    public UserController(UserService service) {
        _service = service;
    }
    
    [HttpGet("{id}")]
    public async Task<UserDto> GetUser(int id) {
        return await _service.GetUserAsync(id);
    }
}
```

## When to Use
- Traditional enterprise apps
- CRUD-focused applications

## AI Self-Check

- [ ] Controllers → Services → Repositories → Data flow?
- [ ] Interfaces for Services and Repositories?
- [ ] DTOs for API contracts (not entities)?
- [ ] Dependency injection for all layers?
- [ ] Controllers thin (delegating to services)?
- [ ] No controllers calling Repositories directly?
- [ ] No entities returned from controllers?
- [ ] No business logic in controllers?
- [ ] No static classes for services?
- [ ] No circular dependencies?
