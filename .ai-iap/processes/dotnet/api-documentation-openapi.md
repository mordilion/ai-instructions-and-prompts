# API Documentation Process - .NET/C# (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation with Swashbuckle

> **Tool**: Swashbuckle.AspNetCore ⭐ (built-in with ASP.NET Core)

---

## Phase 1: Setup Swashbuckle

**Install** (if not already):
```bash
dotnet add package Swashbuckle.AspNetCore
```

**Configure** (Program.cs):
```csharp
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Version = "v1",
        Title = "My API",
        Description = "API for my application"
    });
    
    // JWT Auth
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });
});

app.UseSwagger();
app.UseSwaggerUI();
```

**Annotate Controllers**:
```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class UsersController : ControllerBase
{
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(User), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public ActionResult<User> GetUser(int id) { }
}
```

> **Access**: https://localhost:5001/swagger

---

## Phase 2: XML Comments

**Enable XML Documentation**:
```xml
<PropertyGroup>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

**Include in Swagger**:
```csharp
options.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, "MyApi.xml"));
```

**Document with XML**:
```csharp
/// <summary>
/// Gets a user by ID
/// </summary>
/// <param name="id">User ID</param>
/// <returns>User object</returns>
[HttpGet("{id}")]
public ActionResult<User> GetUser(int id) { }
```

---

## AI Self-Check

- [ ] Swashbuckle configured
- [ ] All endpoints documented
- [ ] XML comments enabled
- [ ] JWT auth documented
- [ ] Swagger UI accessible

---

**Process Complete** ✅

