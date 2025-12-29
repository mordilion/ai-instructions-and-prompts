# ASP.NET Core Framework

> **Scope**: Apply these rules when working with ASP.NET Core web APIs and MVC applications
> **Applies to**: *.cs files in ASP.NET Core projects
> **Extends**: dotnet/architecture.md, dotnet/code-style.md
> **Precedence**: Framework rules OVERRIDE C# rules for ASP.NET Core-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use constructor injection (NOT property injection)
> **ALWAYS**: Return ActionResult<T> for type-safe API responses
> **ALWAYS**: Use DTOs for API contracts (NEVER expose entities)
> **ALWAYS**: Use async/await for I/O operations
> **ALWAYS**: Register services in layer-specific extension methods
> 
> **NEVER**: Use Singleton lifetime for DbContext (causes threading issues)
> **NEVER**: Return entities from controllers (causes lazy loading errors)
> **NEVER**: Put business logic in controllers (belongs in services)
> **NEVER**: Use try-catch in controllers (use middleware for exceptions)
> **NEVER**: Access database directly from controllers

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Controllers | Complex routing, filters, traditional MVC | `[ApiController]`, `ControllerBase`, `[HttpGet]` |
| Minimal APIs | Simple endpoints, microservices | `MapGet()`, `MapPost()`, `MapGroup()` |
| ActionResult<T> | Type-safe responses (required) | Return type for all actions |
| Scoped Lifetime | DbContext, per-request services | `AddDbContext<T>()`, `AddScoped<T>()` |
| Singleton Lifetime | Stateless services, configuration | `AddSingleton<T>()` |

## Core Patterns

### Thin Controller (REQUIRED)
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService) => _userService = userService;

    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> CreateUser(CreateUserRequest request)
    {
        var user = await _userService.CreateAsync(request);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }
}
```

### Dependency Injection Registration
```csharp
// Application/DependencyInjection.cs
public static IServiceCollection AddApplication(this IServiceCollection services)
{
    services.AddScoped<IUserService, UserService>();
    services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
    return services;
}

// Infrastructure/DependencyInjection.cs
public static IServiceCollection AddInfrastructure(
    this IServiceCollection services, IConfiguration config)
{
    services.AddDbContext<AppDbContext>(options =>
        options.UseSqlServer(config.GetConnectionString("Default")));
    services.AddScoped<IUserRepository, UserRepository>();
    return services;
}
```

### Middleware Pipeline (Order Critical)
```csharp
app.UseExceptionHandler("/error");  // 1. Exception handling FIRST
app.UseCors();                      // 2. CORS before auth
app.UseAuthentication();            // 3. Authentication before authorization
app.UseAuthorization();             // 4. Authorization after authentication
app.MapControllers();               // 5. Endpoints LAST
```

### Global Exception Handling
```csharp
app.UseExceptionHandler(errorApp => {
    errorApp.Run(async context => {
        var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        
        var problemDetails = exception switch {
            NotFoundException => new ProblemDetails { Status = 404, Detail = exception.Message },
            ValidationException => new ValidationProblemDetails { Status = 400 },
            _ => new ProblemDetails { Status = 500, Title = "Internal Server Error" }
        };
        
        await context.Response.WriteAsJsonAsync(problemDetails);
    });
});
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Singleton DbContext** | `AddSingleton<DbContext>()` | `AddDbContext<T>()` (scoped) | Not thread-safe, production crashes |
| **Exposing Entities** | `public User GetUser()` returning entity | `public UserDto GetUser()` returning DTO | Lazy loading errors, security risk |
| **Business Logic in Controller** | Controller does validation, DB access | Controller calls service only | Untestable, unmaintainable |
| **Wrong Middleware Order** | `UseAuthorization()` before `UseAuthentication()` | Auth before Authz | Security bypass |
| **Try-Catch in Controllers** | `try-catch` in every action | Global exception middleware | Code duplication, inconsistent errors |

### Anti-Pattern: Singleton DbContext (FORBIDDEN)
```csharp
// ❌ WRONG - Not thread-safe
services.AddSingleton<AppDbContext>();  // Causes concurrency bugs

// ✅ CORRECT - Scoped lifetime
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));
```

### Anti-Pattern: Exposing Entities (FORBIDDEN)
```csharp
// ❌ WRONG - Entity in API
[HttpGet]
public async Task<List<User>> GetUsers() {
    return await _context.Users.ToListAsync();  // Security risk
}

// ✅ CORRECT - DTO in API
[HttpGet]
public async Task<ActionResult<List<UserDto>>> GetUsers() {
    return await _context.Users
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();
}
```

### Anti-Pattern: Business Logic in Controller (FORBIDDEN)
```csharp
// ❌ WRONG - Fat controller
[HttpPost]
public async Task<IActionResult> CreateUser(CreateUserRequest req) {
    if (string.IsNullOrEmpty(req.Email)) return BadRequest();  // Validation here
    var user = new User { Email = req.Email };  // Business logic here
    _context.Users.Add(user);  // DB access here
    await _context.SaveChangesAsync();
    return Ok(user);
}

// ✅ CORRECT - Thin controller
[HttpPost]
public async Task<ActionResult<UserDto>> CreateUser(CreateUserRequest req) {
    var user = await _userService.CreateAsync(req);  // Service handles all logic
    return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
}
```

## AI Self-Check (Verify BEFORE generating ASP.NET Core code)

- [ ] Constructor injection? (NOT property injection)
- [ ] ActionResult<T> return type? (Type-safe responses)
- [ ] Returns DTO? (NOT entity)
- [ ] Async/await for I/O? (All DB/API calls)
- [ ] DbContext is scoped? (NEVER Singleton)
- [ ] Business logic in service? (NOT in controller)
- [ ] Middleware in correct order? (Exception→CORS→Auth→Authz→Endpoints)
- [ ] No try-catch in controller? (Use global middleware)
- [ ] Layer-specific DI registration? (AddApplication/AddInfrastructure)
- [ ] DTOs use records? (C# 9+)

## API Conventions

| Convention | Format | Example |
|------------|--------|---------|
| Route Naming | Plural nouns | `/api/users` (NOT `/api/user`) |
| HTTP Verbs | RESTful | GET (read), POST (create), PUT (replace), PATCH (update), DELETE (remove) |
| Status Codes | Standard | 200 OK, 201 Created, 204 NoContent, 400 BadRequest, 404 NotFound |

## Validation

```csharp
// FluentValidation (complex rules)
public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest> {
    public CreateUserRequestValidator() {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Name).MinimumLength(2).MaximumLength(100);
    }
}

// Data Annotations (simple rules)
public record CreateUserRequest(
    [Required][StringLength(100)] string Name,
    [Required][EmailAddress] string Email
);
```

## Configuration

```csharp
// Options Pattern
services.Configure<JwtSettings>(configuration.GetSection("Jwt"));

// Usage
public class AuthService {
    private readonly JwtSettings _settings;
    
    public AuthService(IOptions<JwtSettings> settings) {
        _settings = settings.Value;
    }
}
```

## Key Libraries

- **DI**: Built-in, `IServiceCollection`, `AddScoped/Singleton/Transient`
- **Validation**: FluentValidation, Data Annotations
- **EF Core**: `AddDbContext<T>()`, `DbContext`, `DbSet<T>`
- **MediatR**: CQRS pattern, request/response pipeline
- **AutoMapper**: DTO mapping
