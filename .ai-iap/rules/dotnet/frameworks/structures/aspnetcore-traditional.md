# ASP.NET Core Traditional/Layered Structure

> **Scope**: Use this structure for standard .NET web apps with N-tier architecture.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base ASP.NET Core rules.

## Project Structure
```
src/
├── MyApp.Api/                  # Web API project
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   └── UsersController.cs
│   ├── Filters/
│   ├── Middleware/
│   └── Program.cs
├── MyApp.Core/                 # Business logic
│   ├── Services/
│   │   ├── IUserService.cs
│   │   └── UserService.cs
│   ├── Models/
│   │   └── User.cs
│   └── DTOs/
│       ├── CreateUserDto.cs
│       └── UserDto.cs
├── MyApp.Data/                 # Data access
│   ├── AppDbContext.cs
│   ├── Repositories/
│   │   ├── IUserRepository.cs
│   │   └── UserRepository.cs
│   └── Entities/
│       └── UserEntity.cs
└── MyApp.sln
```

## Layer Dependencies
```
Api → Core → Data
```

## Rules
- **Controller → Service → Repository**: Clear dependency chain
- **Interfaces**: Define in Core, implement in Data
- **DTOs**: Separate from entities
- **No Business Logic in Controllers**: Delegate to services

## When to Use
- Small to medium applications
- Standard CRUD operations
- Teams familiar with N-tier
- Quick prototypes

