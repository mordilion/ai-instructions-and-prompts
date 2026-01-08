# .NET API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for .NET API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
.NET API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a .NET REST API.

CRITICAL REQUIREMENTS:
- ALWAYS use Swashbuckle for .NET
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use XML comments for descriptions

========================================
PHASE 1 - BASIC SETUP
========================================

Install Swashbuckle:

```bash
dotnet add package Swashbuckle.AspNetCore
```

Configure in Program.cs:
```csharp
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Version = "v1",
        Title = "My API",
        Description = "An ASP.NET Core Web API",
        Contact = new OpenApiContact
        {
            Name = "Your Name",
            Url = new Uri("https://example.com")
        }
    });
});

// After app.Build()
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
```

Deliverable: Swagger UI at /swagger

========================================
PHASE 2 - XML COMMENTS
========================================

Enable XML documentation in .csproj:

```xml
<PropertyGroup>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

Update Swagger configuration:
```csharp
options.SwaggerDoc("v1", new OpenApiInfo { ... });

var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
options.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));
```

Add XML comments to controllers:
```csharp
/// <summary>
/// Gets all users
/// </summary>
/// <returns>A list of users</returns>
/// <response code="200">Returns the list of users</response>
[HttpGet]
[ProducesResponseType(typeof(IEnumerable<User>), StatusCodes.Status200OK)]
public async Task<ActionResult<IEnumerable<User>>> GetUsers()
{
    // Implementation
}

/// <summary>
/// Creates a new user
/// </summary>
/// <param name="user">The user to create</param>
/// <returns>The created user</returns>
/// <response code="201">Returns the newly created user</response>
/// <response code="400">If the user is invalid</response>
[HttpPost]
[ProducesResponseType(typeof(User), StatusCodes.Status201Created)]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
public async Task<ActionResult<User>> CreateUser([FromBody] CreateUserDto user)
{
    // Implementation
}
```

Deliverable: Enhanced documentation with descriptions

========================================
PHASE 3 - AUTHENTICATION
========================================

Add JWT bearer authentication:

```csharp
options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
{
    Description = "JWT Authorization header using the Bearer scheme",
    Name = "Authorization",
    In = ParameterLocation.Header,
    Type = SecuritySchemeType.Http,
    Scheme = "bearer"
});

options.AddSecurityRequirement(new OpenApiSecurityRequirement
{
    {
        new OpenApiSecurityScheme
        {
            Reference = new OpenApiReference
            {
                Type = ReferenceType.SecurityScheme,
                Id = "Bearer"
            }
        },
        Array.Empty<string>()
    }
});
```

Deliverable: Authentication in Swagger UI

========================================
PHASE 4 - CI INTEGRATION
========================================

Generate OpenAPI spec file:

Add to .github/workflows/ci.yml:
```yaml
    - name: Generate OpenAPI spec
      run: dotnet swagger tofile --output openapi.json build/MyApi.dll v1
    
    - name: Validate spec
      run: |
        npm install -g @apidevtools/swagger-cli
        swagger-cli validate openapi.json
    
    - name: Upload spec
      uses: actions/upload-artifact@v3
      with:
        name: openapi-spec
        path: openapi.json
```

Deliverable: OpenAPI spec in CI artifacts

========================================
BEST PRACTICES
========================================

- Use XML comments for descriptions
- Document all public endpoints
- Include request/response examples
- Document error responses
- Add authentication schemes
- Use ProducesResponseType attributes
- Generate spec in CI
- Version your API
- Host Swagger UI only in development

========================================
EXECUTION
========================================

START: Install Swashbuckle (Phase 1)
CONTINUE: Add XML comments (Phase 2)
CONTINUE: Add authentication (Phase 3)
CONTINUE: Add CI generation (Phase 4)
REMEMBER: XML comments, validate in CI
```

---

## Quick Reference

**What you get**: Auto-generated OpenAPI documentation from .NET code  
**Time**: 2 hours  
**Output**: OpenAPI spec, Swagger UI, CI integration
