# ASP.NET Core Framework

> **Scope**: Apply these rules when working with ASP.NET Core web APIs and MVC applications.

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

## 7. Minimal APIs (Alternative)
- Use for simple CRUD or microservices.
- Group endpoints with `MapGroup()`.
- Same patterns apply (thin handlers, validation, DTOs).

