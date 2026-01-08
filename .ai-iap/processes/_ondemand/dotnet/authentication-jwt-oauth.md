# Authentication Setup Process - .NET/C#

> **Purpose**: Implement secure authentication and authorization in .NET applications

> **Core Stack**: ASP.NET Core Identity, JWT Bearer, OAuth 2.0

---

## Phase 1: ASP.NET Core Identity Setup

> **ALWAYS use**: ASP.NET Core Identity ⭐ (built-in, battle-tested)
> **NEVER**: Roll your own password hashing, use Identity

**Setup**:
```bash
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
```

**Configure**:
```csharp
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = true;
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();
```

> **Git**: `git commit -m "feat: add ASP.NET Core Identity"`

---

## Phase 2: JWT Authentication

> **ALWAYS**:
> - Use Microsoft.AspNetCore.Authentication.JwtBearer
> - Store secret in User Secrets (dev) or Azure Key Vault (prod)
> - Token expiration: 1h access, 7d refresh

**Setup**:
```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

**Configure JWT**:
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

app.UseAuthentication();
app.UseAuthorization();
```

**Token Generation**:
```csharp
var tokenHandler = new JwtSecurityTokenHandler();
var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!);
var tokenDescriptor = new SecurityTokenDescriptor
{
    Subject = new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, userId) }),
    Expires = DateTime.UtcNow.AddHours(1),
    Issuer = _configuration["Jwt:Issuer"],
    Audience = _configuration["Jwt:Audience"],
    SigningCredentials = new SigningCredentials(
        new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
};
return tokenHandler.CreateToken(tokenDescriptor);
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 / Social Login

> **ALWAYS use**: Microsoft.AspNetCore.Authentication.Google/Facebook/Microsoft

**Setup**:
```bash
dotnet add package Microsoft.AspNetCore.Authentication.Google
```

**Configure**:
```csharp
builder.Services.AddAuthentication()
    .AddGoogle(options =>
    {
        options.ClientId = builder.Configuration["Authentication:Google:ClientId"]!;
        options.ClientSecret = builder.Configuration["Authentication:Google:ClientSecret"]!;
    });
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

> **ALWAYS use**: Policy-based authorization

**Configure Policies**:
```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdminRole", policy => policy.RequireRole("Admin"));
    options.AddPolicy("RequirePermission", policy => 
        policy.RequireClaim("Permission", "write:users"));
});
```

**Usage**:
```csharp
[Authorize(Policy = "RequireAdminRole")]
public class AdminController : ControllerBase { }
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (ASP.NET Core 7.0+: built-in)
> - HTTPS enforcement
> - CORS configuration
> - Security headers (NWebsec or built-in)

**Rate Limiting** (ASP.NET Core 7.0+):
```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("login", opt =>
    {
        opt.Window = TimeSpan.FromMinutes(15);
        opt.PermitLimit = 5;
    });
});

app.MapPost("/auth/login", Login).RequireRateLimiting("login");
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### ASP.NET Core Web API
- Use [Authorize] attribute
- JWT in Authorization header
- Policy-based authorization

### Blazor
- Server: ASP.NET Core Identity
- WASM: JWT with custom AuthenticationStateProvider

---

## AI Self-Check

- [ ] ASP.NET Core Identity configured
- [ ] Password hashing automatic (Identity)
- [ ] JWT authentication working
- [ ] Refresh tokens implemented
- [ ] OAuth providers configured (if needed)
- [ ] Authorization policies defined
- [ ] Rate limiting enabled
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] Audit logging implemented

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When implementing authentication system with JWT and OAuth

### Complete Implementation Prompt

```
CONTEXT:
You are implementing authentication system with JWT and OAuth for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use strong JWT secret (min 256 bits, from environment variable)
- ALWAYS set appropriate token expiration (15-60 minutes for access, days for refresh)
- ALWAYS validate tokens on protected endpoints
- ALWAYS hash passwords with bcrypt/Argon2
- NEVER store passwords in plain text
- NEVER commit secrets to version control
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - JWT AUTHENTICATION:
1. Install JWT library
2. Configure JWT secret (from environment variable)
3. Implement token generation (login endpoint)
4. Implement token validation middleware
5. Set up token expiration and refresh mechanism

Deliverable: JWT authentication working

PHASE 2 - USER MANAGEMENT:
1. Create User model/entity
2. Implement password hashing
3. Create registration endpoint
4. Create login endpoint
5. Implement password reset flow

Deliverable: User management complete

PHASE 3 - OAUTH INTEGRATION (Optional):
1. Choose OAuth providers (Google, GitHub, etc.)
2. Register application with providers
3. Implement OAuth callback handling
4. Link OAuth accounts with local users

Deliverable: OAuth authentication working

PHASE 4 - ROLE-BASED ACCESS CONTROL:
1. Define user roles
2. Implement role checking middleware
3. Protect endpoints by role
4. Add role management endpoints

Deliverable: RBAC implemented

SECURITY BEST PRACTICES:
- Use HTTPS only in production
- Implement rate limiting
- Add account lockout after failed attempts
- Log authentication events
- Use secure cookie flags (httpOnly, secure, sameSite)

START: Execute Phase 1. Install JWT library and configure token generation.
```
