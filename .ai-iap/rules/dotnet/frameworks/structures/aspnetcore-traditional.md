# ASP.NET Core Traditional Structure

> Standard layered architecture with Controllers, Services, and Data folders. Best for traditional MVC/API applications.

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
