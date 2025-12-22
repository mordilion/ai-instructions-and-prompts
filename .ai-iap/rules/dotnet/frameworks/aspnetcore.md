# ASP.NET Core Framework

> **Scope**: Apply these rules when working with ASP.NET Core web APIs and MVC applications.

## Overview

ASP.NET Core is a cross-platform, high-performance framework for building modern web applications and APIs. It provides built-in dependency injection, middleware pipeline, and comprehensive tooling.

**Key Capabilities**:
- **Cross-Platform**: Windows, Linux, macOS
- **High Performance**: One of the fastest web frameworks
- **Dependency Injection**: Built-in DI container
- **Middleware Pipeline**: Composable request processing
- **Minimal APIs**: Lightweight endpoint definitions (C# 10+)

## Pattern Selection

### API Style
**Use Controllers when**:
- Complex routing logic
- Need filters/attributes
- Traditional MVC pattern

**Use Minimal APIs when**:
- Simple endpoints
- Microservices
- Want less ceremony

### Architecture
**Use Clean Architecture when**:
- Complex business logic
- Multiple bounded contexts
- Long-term maintainability

**Use Traditional Layered when**:
- Simple CRUD
- Small team
- Rapid development

## 1. Controller Design
- **Thin Controllers**: Controllers only validate input and delegate to services or handlers.
- **One Action, One Purpose**: Each action handles exactly one use case.
- **Return Types**: Use `ActionResult<T>` for type safety.

```csharp
// ✅ Good
[HttpGet("{id}")]
public async Task<ActionResult<UserDto>> GetUser(int id)
{
    var result = await _userService.GetByIdAsync(id);
    return result is null ? NotFound() : Ok(result);
}

// ❌ Bad
[HttpGet("{id}")]
public async Task<IActionResult> GetUser(int id)
{
    var user = await _context.Users.FindAsync(id);  // DB in controller
    return Ok(user);  // Exposing entity
}
```

## 2. API Conventions
- **Route Naming**: Use plural nouns (`/api/users`, not `/api/user`).
- **HTTP Verbs**: GET (read), POST (create), PUT (replace), PATCH (update), DELETE (remove).
- **Status Codes**: 200 OK, 201 Created, 204 NoContent, 400 BadRequest, 404 NotFound.

## 3. Middleware Pipeline
- **Order Matters**: Exception handling → CORS → Authentication → Authorization → Endpoints.
- **Custom Middleware**: For cross-cutting concerns (logging, correlation IDs).

```csharp
app.UseExceptionHandler("/error");
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
```

## 4. Dependency Injection
- **Registration**: Use extension methods per layer (`AddApplication()`, `AddInfrastructure()`).
- **Lifetimes**: Scoped for DB contexts, Singleton for stateless services.
- **Options Pattern**: Use `IOptions<T>` for configuration.

```csharp
// ✅ Good
services.Configure<JwtSettings>(configuration.GetSection("Jwt"));
services.AddScoped<IUserRepository, UserRepository>();

// ❌ Bad
services.AddSingleton<DbContext>();  // Wrong lifetime
```

## 5. Validation
- **FluentValidation**: For complex rules in Application layer.
- **Data Annotations**: For simple API model validation.
- **Pipeline Behavior**: Validate before handler executes (if using MediatR).

## 6. Error Handling
- **Global Exception Handler**: Map exceptions to appropriate HTTP responses.
- **Problem Details**: Use RFC 7807 format for error responses.
- **No Try-Catch in Controllers**: Let middleware handle exceptions.

## Best Practices

**MUST**:
- Use `ActionResult<T>` for type-safe responses
- Use DTOs for API contracts (NEVER expose entities)
- Use dependency injection (NO static/new)
- Use async/await for I/O operations
- Use FluentValidation or Data Annotations

**SHOULD**:
- Use thin controllers (delegate to services/handlers)
- Use extension methods for DI registration per layer
- Use middleware for cross-cutting concerns
- Use Options pattern for configuration
- Use Problem Details for errors (RFC 7807)

**AVOID**:
- Database access in controllers
- Business logic in controllers
- Exposing entities in API responses
- Singleton lifetime for DbContext
- Try-catch in controllers (use middleware)

## Common Patterns

### Thin Controller with Service
```csharp
// ✅ GOOD: Thin controller delegates to service
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

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

// ❌ BAD: Fat controller with business logic
[HttpPost]
public async Task<IActionResult> CreateUser(CreateUserRequest request)
{
    // Validation in controller
    if (string.IsNullOrEmpty(request.Email))
        return BadRequest("Email required");

    // Business logic in controller
    var user = new User
    {
        Email = request.Email,
        PasswordHash = BCrypt.HashPassword(request.Password),
        CreatedAt = DateTime.UtcNow
    };

    // Database access in controller
    _context.Users.Add(user);
    await _context.SaveChangesAsync();

    return Ok(user);  // Exposing entity
}
```

### Dependency Injection Registration
```csharp
// ✅ GOOD: Layer-specific extension methods
// Application/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(
        this IServiceCollection services)
    {
        services.AddScoped<IUserService, UserService>();
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
        services.AddMediatR(cfg => 
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly()));
        return services;
    }
}

// Infrastructure/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("Default")));
        
        services.AddScoped<IUserRepository, UserRepository>();
        return services;
    }
}

// Program.cs
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

// ❌ BAD: Everything in Program.cs
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IOrderService, OrderService>();
// 50 more lines...
```

### Middleware Pipeline Order
```csharp
// ✅ GOOD: Correct middleware order
var app = builder.Build();

// Exception handling FIRST
app.UseExceptionHandler("/error");

// CORS before auth
app.UseCors("AllowAll");

// Authentication before authorization
app.UseAuthentication();
app.UseAuthorization();

// Endpoints LAST
app.MapControllers();

// ❌ BAD: Wrong order
app.UseAuthorization();  // Before authentication!
app.UseAuthentication();  // Too late
```

### Global Exception Handling
```csharp
// ✅ GOOD: Global exception handler
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var exceptionHandlerFeature = 
            context.Features.Get<IExceptionHandlerFeature>();
        
        var exception = exceptionHandlerFeature?.Error;

        var problemDetails = exception switch
        {
            NotFoundException => new ProblemDetails
            {
                Status = StatusCodes.Status404NotFound,
                Title = "Not Found",
                Detail = exception.Message
            },
            ValidationException validationEx => new ValidationProblemDetails
            {
                Status = StatusCodes.Status400BadRequest,
                Title = "Validation Error",
                Errors = validationEx.Errors.ToDictionary(
                    e => e.PropertyName, 
                    e => new[] { e.ErrorMessage })
            },
            _ => new ProblemDetails
            {
                Status = StatusCodes.Status500InternalServerError,
                Title = "Internal Server Error"
            }
        };

        context.Response.StatusCode = problemDetails.Status ?? 500;
        await context.Response.WriteAsJsonAsync(problemDetails);
    });
});

// ❌ BAD: Try-catch in every controller
[HttpGet("{id}")]
public async Task<IActionResult> GetUser(int id)
{
    try
    {
        var user = await _userService.GetByIdAsync(id);
        return Ok(user);
    }
    catch (NotFoundException)
    {
        return NotFound();  // Repeated in every action
    }
    catch (Exception ex)
    {
        return StatusCode(500, ex.Message);
    }
}
```

## Common Anti-Patterns

**❌ Wrong DbContext lifetime**:
```csharp
// BAD
services.AddSingleton<DbContext>();  // DbContext is NOT thread-safe
```

**✅ Use Scoped**:
```csharp
// GOOD
services.AddDbContext<AppDbContext>(options => ...);  // Scoped by default
```

**❌ Exposing entities**:
```csharp
// BAD
[HttpGet]
public async Task<List<User>> GetUsers()
{
    return await _context.Users.ToListAsync();  // Exposes all fields
}
```

**✅ Use DTOs**:
```csharp
// GOOD
[HttpGet]
public async Task<ActionResult<List<UserDto>>> GetUsers()
{
    return await _context.Users
        .Select(u => new UserDto(u.Id, u.Name, u.Email))
        .ToListAsync();
}
```

## 7. Minimal APIs (Alternative)
- Use for simple CRUD or microservices
- Group endpoints with `MapGroup()`
- Same patterns apply (thin handlers, validation, DTOs)

