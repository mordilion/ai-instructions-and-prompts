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

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

### Mistake 1: Wrong DbContext Lifetime ⚠️ CRITICAL
```csharp
// ❌ WRONG - Singleton DbContext (CAUSES THREADING BUGS)
services.AddSingleton<AppDbContext>();  // ← NOT THREAD-SAFE!
// Problem: DbContext is NOT thread-safe, will crash under load

// ❌ WRONG - Manual lifetime management
services.AddTransient<AppDbContext>();  // ← Wrong lifetime

// ✅ CORRECT - Scoped DbContext (REQUIRED)
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));  // ← Scoped by default, one per request
```
**Why wrong**: DbContext not thread-safe, singleton causes concurrency bugs  
**Why critical**: Production crashes under load, data corruption  
**How to fix**: ALWAYS use AddDbContext (scoped by default)

### Mistake 2: Exposing Entities from Controllers ⚠️ CRITICAL
```csharp
// ❌ WRONG - Returning entity (COMMON AI ERROR)
[HttpGet]
public async Task<List<User>> GetUsers() {
    return await _context.Users.ToListAsync();  // ← Exposes entity!
    // Problems: Lazy loading errors, circular refs, security risk
}

// ❌ WRONG - Accepting entity in request
[HttpPost]
public async Task<User> CreateUser(User user) {  // ← Entity as input
    _context.Users.Add(user);
    await _context.SaveChangesAsync();
    return user;
}

// ✅ CORRECT - Use DTOs (REQUIRED)
[HttpGet]
public async Task<ActionResult<List<UserDto>>> GetUsers() {
    return await _context.Users
        .Select(u => new UserDto(u.Id, u.Name, u.Email))  // ← Map to DTO
        .ToListAsync();
}

[HttpPost]
public async Task<ActionResult<UserDto>> CreateUser(CreateUserRequest request) {
    var user = await _userService.CreateAsync(request);  // ← Service handles mapping
    return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
}
```
**Why wrong**: Lazy loading exceptions, exposes DB structure, security risk  
**Why critical**: Most common ASP.NET Core mistake  
**How to fix**: ALWAYS use DTOs for API contracts

### Mistake 3: Business Logic in Controllers
```csharp
// ❌ WRONG - Business logic in controller (COMMON ERROR)
[HttpPost]
public async Task<IActionResult> CreateUser(CreateUserRequest req) {
    // Validation in controller ← WRONG
    if (string.IsNullOrEmpty(req.Email)) 
        return BadRequest("Email required");
    
    // Business logic in controller ← WRONG
    var user = new User {
        Email = req.Email,
        PasswordHash = BCrypt.HashPassword(req.Password),
        CreatedAt = DateTime.UtcNow
    };
    
    // Database access in controller ← WRONG
    _context.Users.Add(user);
    await _context.SaveChangesAsync();
    
    return Ok(user);  // ← And exposing entity!
}

// ✅ CORRECT - Thin controller (REQUIRED)
[HttpPost]
public async Task<ActionResult<UserDto>> CreateUser(CreateUserRequest req) {
    var user = await _userService.CreateAsync(req);  // ← All logic in service
    return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
}

// Service handles all business logic
public class UserService {
    private readonly AppDbContext _context;
    
    public UserService(AppDbContext context) {
        _context = context;
    }
    
    public async Task<UserDto> CreateAsync(CreateUserRequest req) {
        var user = new User {
            Email = req.Email,
            PasswordHash = BCrypt.HashPassword(req.Password),
            CreatedAt = DateTime.UtcNow
        };
        
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        
        return new UserDto(user.Id, user.Name, user.Email);
    }
}
```
**Why wrong**: Violates separation of concerns, untestable, not reusable  
**Why critical**: Controllers become bloated, code unmaintainable  
**How to fix**: Controllers only validate input and call services

### Mistake 4: Wrong Middleware Order
```csharp
// ❌ WRONG - Middleware in wrong order (CAUSES SECURITY ISSUES)
app.UseAuthorization();  // ← Authorization BEFORE authentication!
app.UseAuthentication();  // ← Too late, already authorized!
app.UseExceptionHandler("/error");  // ← Exception handler should be FIRST

// ✅ CORRECT - Proper middleware order (REQUIRED)
app.UseExceptionHandler("/error");  // 1. Exception handling FIRST
app.UseCors();  // 2. CORS before auth
app.UseAuthentication();  // 3. Authentication before authorization
app.UseAuthorization();  // 4. Authorization after authentication
app.MapControllers();  // 5. Endpoints LAST
```
**Why wrong**: Security bypass, exceptions not caught, CORS issues  
**Why critical**: Production security vulnerability  
**How to fix**: Follow strict order - exception→CORS→auth→authz→endpoints

### Mistake 5: Try-Catch in Controllers
```csharp
// ❌ WRONG - Try-catch in controller (REPEATED CODE)
[HttpGet("{id}")]
public async Task<IActionResult> GetUser(int id) {
    try {
        var user = await _userService.GetAsync(id);
        return Ok(user);
    } catch (NotFoundException) {
        return NotFound();  // ← Repeated in EVERY action
    } catch (Exception ex) {
        return StatusCode(500, ex.Message);
    }
}

// ✅ CORRECT - Global exception middleware (REQUIRED)
// In Program.cs
app.UseExceptionHandler(errorApp => {
    errorApp.Run(async context => {
        var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        
        var problemDetails = exception switch {
            NotFoundException => new ProblemDetails {
                Status = 404,
                Title = "Not Found",
                Detail = exception.Message
            },
            _ => new ProblemDetails {
                Status = 500,
                Title = "Internal Server Error"
            }
        };
        
        context.Response.StatusCode = problemDetails.Status ?? 500;
        await context.Response.WriteAsJsonAsync(problemDetails);
    });
});

// Controller - clean, no try-catch needed
[HttpGet("{id}")]
public async Task<ActionResult<UserDto>> GetUser(int id) {
    return await _userService.GetAsync(id);  // ← Exceptions handled by middleware
}
```
**Why wrong**: Code duplication, inconsistent error responses  
**Why critical**: Maintenance nightmare, error handling inconsistent  
**How to fix**: Use global exception middleware, NO try-catch in controllers

## AI Self-Check (Verify BEFORE generating ASP.NET Core code)

Before generating any ASP.NET Core class, verify:
- [ ] Constructor injection? (NOT property injection)
- [ ] ActionResult<T> return type? (Type-safe responses)
- [ ] Returns DTO? (NOT entity - entities forbidden in controllers)
- [ ] Async/await for I/O? (All database/API calls must be async)
- [ ] DbContext is scoped? (NEVER Singleton - not thread-safe)
- [ ] Business logic in service? (NOT in controller)
- [ ] Middleware in correct order? (Exception→CORS→Auth→Authz→Endpoints)
- [ ] No try-catch in controller? (Use global exception middleware)

**If ANY checkbox is unchecked, DO NOT generate code. Fix the issue first.**

## 7. Minimal APIs (Alternative)
- Use for simple CRUD or microservices
- Group endpoints with `MapGroup()`
- Same patterns apply (thin handlers, validation, DTOs)

