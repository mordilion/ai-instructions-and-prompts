# API Documentation Process - .NET/C# (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation with Swashbuckle

> **Tool**: Swashbuckle.AspNetCore ⭐ (built-in with ASP.NET Core)

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

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

## Phase 3: Security & Versioning

### 3.1 Document Authentication

**JWT Configuration**:
```csharp
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

### 3.2 API Versioning

**Install**:
```bash
dotnet add package Asp.Versioning.Mvc
dotnet add package Asp.Versioning.Mvc.ApiExplorer
```

**Configure**:
```csharp
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
});

options.SwaggerDoc("v1", new OpenApiInfo { Version = "v1", Title = "My API V1" });
options.SwaggerDoc("v2", new OpenApiInfo { Version = "v2", Title = "My API V2" });
```

### 3.3 Rate Limiting (ASP.NET Core 7+)

**Document**:
```csharp
[RateLimiting("fixed")]
[ProducesResponseType(StatusCodes.Status429TooManyRequests)]
public ActionResult<User> GetUser(int id) { }
```

### 3.4 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format

**ASP.NET Core Implementation**:
```csharp
public class ErrorResponse
{
    public ErrorDetail Error { get; set; }
}

public class ErrorDetail
{
    public string Code { get; set; }
    public string Message { get; set; }
    public List<ValidationError> Details { get; set; }
    public DateTime Timestamp { get; set; }
    public string RequestId { get; set; }
}

public class ValidationError
{
    public string Field { get; set; }
    public string Issue { get; set; }
}

// Global exception handler
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var error = context.Features.Get<IExceptionHandlerFeature>();
        var response = new ErrorResponse
        {
            Error = new ErrorDetail
            {
                Code = "INTERNAL_ERROR",
                Message = error.Error.Message,
                Timestamp = DateTime.UtcNow,
                RequestId = context.TraceIdentifier
            }
        };
        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(response);
    });
});
```

---

## Phase 4: CI/CD Integration

> **ALWAYS**:
> - Generate OpenAPI JSON during build
> - Validate with Spectral or similar
> - Version control the spec
> - Export as build artifact

**Generate Spec**:
```bash
dotnet build
dotnet swagger tofile --output openapi.json bin/Debug/net8.0/MyApi.dll v1
```

### 4.2 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate C# Client**:
```bash
dotnet new tool-manifest
dotnet tool install --local Kiota.ApiClient.Generator
dotnet kiota generate -l CSharp -c MyApiClient -n MyApi.Client -d openapi.json -o ./sdks/csharp
```

**Generate TypeScript Client**:
```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-axios \
  -o sdks/typescript-client
```

**Usage Example**:
```csharp
var client = new MyApiClient();
var user = await client.Users.GetByIdAsync("123");
```

---

## Best Practices

> **ALWAYS**:
> - Use XML comments for descriptions
> - Document all status codes with `[ProducesResponseType]`
> - Group endpoints with `[ApiExplorerSettings(GroupName = "...")]`
> - Add examples with `[SwaggerRequestExample]`

> **NEVER**:
> - Expose internal APIs in docs (use `[ApiExplorerSettings(IgnoreApi = true)]`)
> - Include sensitive data in examples
> - Skip documenting error responses

---

## Troubleshooting

### Issue: Swagger UI shows 404
- **Solution**: Ensure `app.UseSwagger()` before `app.UseSwaggerUI()`, check route template

### Issue: XML comments not appearing
- **Solution**: Verify `<GenerateDocumentationFile>true</GenerateDocumentationFile>` in .csproj, check file path in options

### Issue: JWT auth button not showing
- **Solution**: Add both `AddSecurityDefinition` and `AddSecurityRequirement`

---

## AI Self-Check

- [ ] Swashbuckle.AspNetCore installed and configured
- [ ] Swagger UI accessible at `/swagger`
- [ ] XML comments enabled for documentation
- [ ] JWT authentication configured and testable
- [ ] Response types documented with `[ProducesResponseType]`
- [ ] CI/CD generates and validates OpenAPI spec
- [ ] Client SDKs generated for target languages
- [ ] No warnings about missing XML comments
- [ ] Error responses follow consistent format (see general standards)
- [ ] All status codes documented (see general standards)

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up OpenAPI/Swagger API documentation

### Complete Implementation Prompt

```
CONTEXT:
You are setting up auto-generated OpenAPI/Swagger API documentation for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use OpenAPI 3.x specification
- ALWAYS document all endpoints with descriptions
- ALWAYS include request/response schemas
- ALWAYS document authentication requirements
- Use team's Git workflow

IMPLEMENTATION STEPS:

1. INSTALL TOOLS:
   Install OpenAPI/Swagger library for the language (see Tech Stack section)

2. CONFIGURE BASIC SETUP:
   Set up Swagger/OpenAPI generator
   Configure API metadata (title, version, description)
   Set up UI endpoint (e.g., /api-docs, /swagger)

3. DOCUMENT AUTHENTICATION:
   Configure security schemes (JWT, OAuth, API Key)
   Document authentication flows

4. ADD ENDPOINT DOCUMENTATION:
   Document each endpoint:
   - HTTP method and path
   - Parameters (query, path, header)
   - Request body schema
   - Response schemas (success/error)
   - Example requests/responses

5. CONFIGURE AUTO-GENERATION:
   Use framework decorators/annotations
   Enable auto-discovery of endpoints
   Generate schemas from models/DTOs

6. ADD TO CI/CD (Optional):
   Generate OpenAPI spec file in CI
   Validate API spec
   Deploy documentation to hosting

DELIVERABLE:
- Swagger UI accessible
- All endpoints documented
- Request/response schemas complete
- Authentication documented

START: Install OpenAPI tools and configure basic setup with API metadata.
```
