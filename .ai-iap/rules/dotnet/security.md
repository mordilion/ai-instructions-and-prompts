# .NET/C# Security

> **Scope**: .NET and C#-specific security practices
> **Extends**: General security rules
> **Applies to**: *.cs files

## 0. Embedded SQL (when SQL appears inside C#)
- **ALWAYS**: Use parameterized queries / prepared statements (or a safe ORM). This applies to any SQL you embed in C# code.
- **NEVER**: Concatenate or interpolate untrusted input into SQL (including `FormattableString` → raw SQL).
- **If** you must select dynamic table/column names: use strict allowlists (do not pass user input through).

## 1. Authentication

### ASP.NET Core Identity
- **ALWAYS**: Use Identity for user management. Configure password requirements (12+ chars).
- **ALWAYS**: `BCryptPasswordEncoder` or Identity's default (PBKDF2). NEVER MD5/SHA1.
- **2FA**: Enable via Identity (`services.AddIdentity<User, Role>().AddDefaultTokenProviders()`).

### JWT
- **ALWAYS**: `JwtBearerAuthentication` with expiration (`ValidateLifetime = true`).
- **Secret**: Strong key (32+ bytes) from `IConfiguration`. NEVER hardcode.
- **Validation**: Validate issuer, audience, lifetime.

## 2. Authorization

### Policies
- **ALWAYS**: `[Authorize]` attribute on controllers/actions.
- **ALWAYS**: Policy-based authorization (`services.AddAuthorization(o => o.AddPolicy(...))`).
- **NEVER**: Check roles in business logic. Use policies.

### Claims
- **ALWAYS**: Role/claim-based checks (`User.IsInRole()`, `User.HasClaim()`).
- **Resource-Based**: `IAuthorizationService.AuthorizeAsync()` for entity ownership checks.

## 3. Data Protection

### Input Validation
- **ALWAYS**: Data annotations (`[Required]`, `[EmailAddress]`, `[StringLength(100)]`, `[Range(18,120)]`).
- **ALWAYS**: `[ValidateAntiForgeryToken]` on POST/PUT/DELETE actions.
- **Custom**: FluentValidation for complex validation.

### SQL Injection Prevention
- **ALWAYS**: Entity Framework parameterized queries. NEVER string concatenation.
- **Raw SQL**: `FromSqlRaw("SELECT * FROM Users WHERE Email = {0}", email)`.
- **NEVER**: `FromSqlRaw($"SELECT * FROM Users WHERE Email = '{email}'")`

### XSS Prevention
- **ALWAYS**: Razor auto-escapes (`@Model.UserInput`).
- **NEVER**: `@Html.Raw()` without sanitization (use HtmlSanitizer).

## 4. Infrastructure

### HTTPS
- **ALWAYS**: `app.UseHttpsRedirection()` in Program.cs.
- **ALWAYS**: `app.UseHsts()` in production.
- **Config**: `services.AddHsts(o => o.MaxAge = TimeSpan.FromDays(365))`.

### Security Headers
- **ALWAYS**: Configure in middleware or reverse proxy.
- **Headers**: `X-Frame-Options`, `X-Content-Type-Options`, `Content-Security-Policy`.

### CORS
- **ALWAYS**: Specific origins in `AddCors()`. NEVER `AllowAnyOrigin()` with `AllowCredentials()`.

### Rate Limiting
- **ALWAYS**: `AspNetCoreRateLimit` NuGet or middleware.
- **Config**: Strict on auth endpoints (5 requests/15 min).

### Secrets Management
- **ALWAYS**: User Secrets (dev), Azure Key Vault (prod), environment variables.
- **NEVER**: `appsettings.json` for secrets in source control.

## 5. Error Handling

- **ALWAYS**: Global exception handler (`app.UseExceptionHandler("/Error")`).
- **ALWAYS**: Generic error messages to clients. Log details server-side.
- **NEVER**: `app.UseDeveloperExceptionPage()` in production.

## 6. Dependency Security

- **ALWAYS**: NuGet package scanning (Snyk, Dependabot).
- **ALWAYS**: Target latest LTS .NET version.

## AI Self-Check

Before generating C# code:
- [ ] ASP.NET Core Identity or BCrypt for passwords?
- [ ] `[Authorize]` on protected endpoints?
- [ ] Data annotations + `[ValidateAntiForgeryToken]`?
- [ ] EF parameterized queries (no string concatenation)?
- [ ] HTTPS + HSTS configured?
- [ ] Secrets in User Secrets/Key Vault?
- [ ] CORS specific origins?
- [ ] Rate limiting configured?
- [ ] Global exception handler (no stack traces)?
- [ ] Security headers configured?
