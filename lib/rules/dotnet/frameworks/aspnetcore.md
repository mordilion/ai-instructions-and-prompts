# ASP.NET Core Framework

> **Scope**: ASP.NET Core web APIs and MVC  
> **Applies to**: *.cs, *.csproj, *.razor files in ASP.NET Core projects
> **Extends**: dotnet/architecture.md, dotnet/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use constructor injection
> **ALWAYS**: Return ActionResult<T>
> **ALWAYS**: Use DTOs for API contracts
> **ALWAYS**: Use async/await for I/O
> **ALWAYS**: Register services in extension methods
> 
> **NEVER**: Use Singleton lifetime for DbContext
> **NEVER**: Return entities from controllers
> **NEVER**: Put business logic in controllers
> **NEVER**: Use try-catch in controllers
> **NEVER**: Access database directly from controllers

## Core Patterns

### Thin Controller

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
    public async Task<ActionResult<UserDto>> CreateUser(CreateUserDto dto)
    {
        var user = await _userService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }
}
```

### Minimal API

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/users/{id}", async (int id, IUserService service) =>
{
    var user = await service.GetByIdAsync(id);
    return user is null ? Results.NotFound() : Results.Ok(user);
});

app.MapPost("/users", async (CreateUserDto dto, IUserService service) =>
{
    var user = await service.CreateAsync(dto);
    return Results.Created($"/users/{user.Id}", user);
});

app.Run();
```

### Service Registration

```csharp
// Program.cs
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ICacheService, CacheService>();
```

### Middleware

```csharp
public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    
    public ExceptionMiddleware(RequestDelegate next) => _next = next;
    
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new { error = ex.Message });
        }
    }
}

// Program.cs
app.UseMiddleware<ExceptionMiddleware>();
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Entity Return** | `return entity` | `return dto` |
| **Singleton DbContext** | `AddSingleton<DbContext>` | `AddScoped<DbContext>` |
| **Controller Logic** | Business logic | Service call |
| **try-catch** | In controller | Middleware |

## AI Self-Check

- [ ] Constructor injection?
- [ ] ActionResult<T> return type?
- [ ] DTOs for contracts?
- [ ] async/await for I/O?
- [ ] Services in extensions?
- [ ] Scoped DbContext?
- [ ] Thin controllers?
- [ ] Middleware for exceptions?
- [ ] No direct database access?

## Key Features

| Feature | Purpose |
|---------|---------|
| ActionResult<T> | Type-safe responses |
| Minimal APIs | Simple endpoints |
| Middleware | Request pipeline |
| DI | Service injection |
| Scoped Lifetime | Per-request |

## Best Practices

**MUST**: Constructor DI, ActionResult<T>, DTOs, async/await, scoped DbContext
**SHOULD**: Minimal APIs, middleware, extension methods, filters
**AVOID**: Singleton DbContext, entity returns, controller logic, controller exceptions
