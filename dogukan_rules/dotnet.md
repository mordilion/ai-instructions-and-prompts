---
globs: ["**/*.cs", "**/*.csproj", "**/Program.cs", "**/Startup.cs", "**/*DbContext*.cs", "**/*Repository*.cs", "**/Migrations/**", "**/EntityConfigurations/**"]
alwaysApply: false
---

# .NET Backend Rules

**Supported Versions:** .NET 6 (LTS), .NET 8 (LTS), .NET 10

<!-- Last updated: 2025-01-19 -->

<checklist>
## Before Writing Code
- [ ] Check project's target framework (.NET 6/8/10)
- [ ] Read existing code in affected area
- [ ] Check for existing services/patterns to reuse
- [ ] Match project naming conventions
- [ ] Plan interfaces before implementations
- [ ] Consider SOLID principles applicability
</checklist>

<version-features>
## Version-Specific Features

### .NET 6 (Baseline)
- Minimal APIs, Global usings, File-scoped namespaces, Nullable reference types

### .NET 8 (Preferred for new projects)
- Primary constructors for classes
- Collection expressions `[1, 2, 3]`
- Keyed DI services `[FromKeyedServices("name")]`
- Frozen collections, Time abstraction (`TimeProvider`)

### .NET 10 (Latest)
- Extension types (preview), Field keyword in properties
- Enhanced pattern matching, Improved AOT support

**Check .csproj:** `<TargetFramework>net8.0</TargetFramework>`
</version-features>

<solid>
## SOLID Principles

### Single Responsibility Principle (SRP)
Each class has ONE reason to change. Separate validation, persistence, business logic.

```csharp
// GOOD: Separated concerns
public interface IPharmacyRepository { }
public interface IPharmacyValidator { }
public class PharmacyService
{
    private readonly IPharmacyRepository _repository;
    private readonly IPharmacyValidator _validator;
    // Orchestrates, delegates to specialized services
}

// BAD: Multiple responsibilities
public class PharmacyService
{
    public async Task Create(PharmacyDto dto)
    {
        // Validation mixed in
        if (string.IsNullOrEmpty(dto.Name)) throw new Exception();
        // Database logic mixed in
        using var context = new DbContext();
        // Logging mixed in
        _logger.Log("Created");
    }
}
```

### Open/Closed Principle (OCP)
Open for extension, closed for modification. Use interfaces/abstractions to add new behavior without changing existing code.

```csharp
// GOOD: Extensible via new implementations
public interface INotificationStrategy
{
    Task SendAsync(string recipient, string message, CancellationToken ct);
}
public class EmailNotification : INotificationStrategy { }
public class SmsNotification : INotificationStrategy { }
// Adding push notification? Create new class, no changes to existing code
public class PushNotification : INotificationStrategy { }
```

### Liskov Substitution Principle (LSP)
Derived classes must be substitutable for base classes without breaking behavior. Subtypes must honor the contracts of their base types.

```csharp
// GOOD: Substitutable implementations
public interface IReadOnlyRepository<T>
{
    Task<T?> GetByIdAsync(int id, CancellationToken ct);
}
public class PharmacyRepository : IReadOnlyRepository<Pharmacy> { }
public class CachedPharmacyRepository : IReadOnlyRepository<Pharmacy> { }
// Both can be used interchangeably

// BAD: Violates LSP - throws where base doesn't
public class ReadOnlyPharmacyRepository : IPharmacyRepository
{
    public Task AddAsync(Pharmacy p, CancellationToken ct)
        => throw new NotSupportedException(); // Breaks expectations!
}
```

### Interface Segregation Principle (ISP)
Clients depend only on interfaces they use. Split large interfaces into smaller, focused ones.

```csharp
// GOOD: Segregated interfaces
public interface IPharmacyReader
{
    Task<Pharmacy?> GetByIdAsync(int id, CancellationToken ct);
    Task<IEnumerable<Pharmacy>> GetAllAsync(CancellationToken ct);
}
public interface IPharmacyWriter
{
    Task<Pharmacy> AddAsync(Pharmacy pharmacy, CancellationToken ct);
    Task UpdateAsync(Pharmacy pharmacy, CancellationToken ct);
}

// BAD: Fat interface forces unnecessary dependency
public interface IPharmacyService
{
    Task<Pharmacy?> GetByIdAsync(int id, CancellationToken ct);
    Task<Pharmacy> AddAsync(Pharmacy pharmacy, CancellationToken ct);
    Task DeleteAsync(int id, CancellationToken ct);
    Task ExportToPdfAsync(int id, CancellationToken ct);
    Task SendNotificationAsync(int id, CancellationToken ct);
    // Client that only reads must still depend on all methods
}
```

### Dependency Inversion Principle (DIP)
Depend on abstractions, not concrete implementations. High-level modules should not depend on low-level modules.

```csharp
// GOOD: Depends on abstraction
public class PharmacyService
{
    private readonly IPharmacyRepository _repository;
    public PharmacyService(IPharmacyRepository repository) => _repository = repository;
}

// BAD: Depends on concrete implementation
public class PharmacyService
{
    private readonly PharmacyRepository _repository = new();
    // Cannot mock for testing, tightly coupled
}
```
</solid>

<dry-yagni>
## DRY & YAGNI

### DRY (Don't Repeat Yourself)
Extract common logic into shared methods/classes. Every piece of knowledge should have a single, unambiguous representation.

```csharp
// GOOD: Extracted pagination - reusable across all repositories
public static class QueryableExtensions
{
    public static async Task<PagedResult<T>> ToPagedResultAsync<T>(
        this IQueryable<T> query, int page, int pageSize, CancellationToken ct)
    {
        var total = await query.CountAsync(ct);
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
        return new PagedResult<T>(items, total, page, pageSize);
    }
}

// GOOD: Shared validation logic
public static class ValidationExtensions
{
    public static bool IsValidEmail(this string email)
        => !string.IsNullOrEmpty(email) && email.Contains('@');
}

// BAD: Same pagination logic copy-pasted in every repository
public class PharmacyRepository
{
    public async Task<PagedResult<Pharmacy>> GetPagedAsync(int page, int size, CancellationToken ct)
    {
        var total = await _context.Pharmacies.CountAsync(ct);
        var items = await _context.Pharmacies.Skip((page - 1) * size).Take(size).ToListAsync(ct);
        return new PagedResult<Pharmacy>(items, total, page, size);
    }
}
public class UserRepository
{
    public async Task<PagedResult<User>> GetPagedAsync(int page, int size, CancellationToken ct)
    {
        // Same logic duplicated!
        var total = await _context.Users.CountAsync(ct);
        var items = await _context.Users.Skip((page - 1) * size).Take(size).ToListAsync(ct);
        return new PagedResult<User>(items, total, page, size);
    }
}
```

### YAGNI (You Aren't Gonna Need It)
Only implement what's needed now. No speculative features or "future-proofing". Delete unused code instead of commenting it out.

```csharp
// GOOD: Simple, focused on current requirements
public class PharmacyService
{
    private readonly IPharmacyRepository _repository;

    public async Task<Pharmacy?> GetByIdAsync(int id, CancellationToken ct)
        => await _repository.GetByIdAsync(id, ct);
}

// BAD: Over-engineered for hypothetical needs
public class PharmacyService
{
    private readonly IPharmacyRepository _repository;
    private readonly IDistributedCache _cache;        // Not needed yet
    private readonly IAuditService _audit;            // Not in requirements
    private readonly IEventBus _eventBus;             // "Might need later"

    public Task<IEnumerable<Pharmacy>> SearchAsync(
        PharmacySearchCriteria criteria,              // Complex filtering not requested
        SearchOptions options,                        // Pagination, sorting, etc. not needed
        CacheOptions cacheOptions,                    // No caching requirement
        CancellationToken ct) { }
}

// BAD: Commented code "just in case"
public async Task<Pharmacy?> GetByIdAsync(int id, CancellationToken ct)
{
    // var cached = await _cache.GetAsync(id);
    // if (cached != null) return cached;
    return await _repository.GetByIdAsync(id, ct);
}
```
</dry-yagni>

<async>
## Async/Await Patterns

### Required Practices
- `async/await` for ALL I/O operations
- Pass `CancellationToken ct` through entire call chain
- Never use `.Result` or `.Wait()` (sync-over-async)
- Never use `async void` (except event handlers)

```csharp
// GOOD: Async all the way
public async Task<Result<PharmacyDto>> CreateAsync(
    CreatePharmacyRequest request,
    CancellationToken ct)
{
    var pharmacy = await _repository.AddAsync(entity, ct);
    return Result<PharmacyDto>.Success(MapToDto(pharmacy));
}

// BAD: Sync-over-async blocks thread pool
public Pharmacy? GetPharmacy(int id)
{
    return _repository.GetByIdAsync(id, CancellationToken.None).Result; // BLOCKS!
}

// BAD: async void loses exceptions
public async void HandleClick() { } // Don't do this
```
</async>

<di>
## Dependency Injection

### Lifetimes
| Lifetime | Use Case | Examples |
|----------|----------|----------|
| **Scoped** | One per request | Repositories, DbContext, Services |
| **Transient** | New instance each time | Stateless utilities, Mappers |
| **Singleton** | One for app lifetime | Configuration, HTTP clients |

```csharp
// Service registration (.NET 6+)
builder.Services.AddScoped<IPharmacyRepository, PharmacyRepository>();
builder.Services.AddScoped<IPharmacyService, PharmacyService>();
builder.Services.AddTransient<IPharmacyMapper, PharmacyMapper>();

// DbContext - ALWAYS Scoped
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, serverVersion));
```

### Keyed Services (.NET 8+)
```csharp
builder.Services.AddKeyedScoped<INotificationService, EmailNotification>("email");
builder.Services.AddKeyedScoped<INotificationService, SmsNotification>("sms");

public class NotificationOrchestrator(
    [FromKeyedServices("email")] INotificationService emailService,
    [FromKeyedServices("sms")] INotificationService smsService) { }
```

### Primary Constructors (.NET 8+)
```csharp
public class PharmacyService(
    IPharmacyRepository repository,
    ILogger<PharmacyService> logger) : IPharmacyService
{
    public async Task<Pharmacy?> GetByIdAsync(int id, CancellationToken ct)
    {
        logger.LogInformation("Getting pharmacy {Id}", id);
        return await repository.GetByIdAsync(id, ct);
    }
}
```

### DI Anti-patterns
```csharp
// BAD: Scoped service in Singleton (captive dependency)
public class SingletonService
{
    private readonly IPharmacyRepository _repository; // Scoped - wrong!
}

// BAD: Transient DbContext - creates too many connections
builder.Services.AddTransient<AppDbContext>();

// BAD: Singleton DbContext - memory leak, thread-unsafe
builder.Services.AddSingleton<AppDbContext>();
```
</di>

<ef-core>
## Entity Framework Core

### Query Optimization
```csharp
// GOOD: Read-only with projection
var pharmacies = await _context.Pharmacies
    .AsNoTracking()
    .Where(p => p.IsActive)
    .Select(p => new PharmacyDto { Id = p.Id, Name = p.Name })
    .ToListAsync(ct);

// BAD: Tracking + SELECT * + client-side filtering
var all = await _context.Pharmacies.ToListAsync(ct);
var filtered = all.Where(p => p.IsActive);
```

### N+1 Prevention
```csharp
// GOOD: Single query with Include
var pharmacy = await _context.Pharmacies
    .Include(p => p.Contacts)
    .AsNoTracking()
    .FirstOrDefaultAsync(p => p.Id == id, ct);

// Use AsSplitQuery for multiple large collections
var pharmacy = await _context.Pharmacies
    .AsSplitQuery()
    .Include(p => p.Contacts)
    .Include(p => p.Inventory).ThenInclude(i => i.Drug)
    .AsNoTracking()
    .FirstOrDefaultAsync(p => p.Id == id, ct);
```

### Pagination
```csharp
public async Task<PagedResult<PharmacyDto>> GetPagedAsync(
    int pageNumber, int pageSize, CancellationToken ct)
{
    var query = _context.Pharmacies.AsNoTracking().Where(p => p.IsActive);
    var total = await query.CountAsync(ct);
    var items = await query
        .OrderBy(p => p.Name)
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .Select(p => new PharmacyDto { Id = p.Id, Name = p.Name })
        .ToListAsync(ct);
    return new PagedResult<PharmacyDto>(items, total, pageNumber, pageSize);
}
```

### Efficient Existence Checks
```csharp
// GOOD: Stops at first match
var exists = await _context.Pharmacies.AnyAsync(p => p.Email == email, ct);

// BAD: Loads entire entity
var pharmacy = await _context.Pharmacies.FirstOrDefaultAsync(p => p.Email == email, ct);
var exists = pharmacy != null;
```

### DbContext Configuration
```csharp
// Default to NoTracking for read-heavy apps
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(connectionString, serverVersion)
        .UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);
});

// For high-performance: use pooling
builder.Services.AddDbContextPool<AppDbContext>(options =>
    options.UseMySql(connectionString, serverVersion), poolSize: 128);
```

### Migrations
```bash
# GOOD naming
dotnet ef migrations add AddPharmacyTable
dotnet ef migrations add AddEmailIndexToPharmacy

# BAD naming
dotnet ef migrations add Update1

# Generate script for review
dotnet ef migrations script --idempotent -o migration.sql
```

### Index Configuration
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Unique index
    modelBuilder.Entity<Pharmacy>().HasIndex(p => p.Email).IsUnique();

    // Composite index for common filter
    modelBuilder.Entity<Pharmacy>().HasIndex(p => new { p.City, p.IsActive });

    // Filtered index
    modelBuilder.Entity<Pharmacy>().HasIndex(p => p.Name).HasFilter("[IsActive] = 1");
}
```
</ef-core>

<patterns>
## Required Patterns

### Interface-First Design
- Define interface first: `I{Name}Service.cs`
- Implementation separate: `{Name}Service.cs`
- Register in DI container

### Input Validation
```csharp
public class CreatePharmacyValidator : AbstractValidator<CreatePharmacyRequest>
{
    public CreatePharmacyValidator()
    {
        RuleFor(x => x.Name).NotEmpty().Length(3, 100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
    }
}
```

### Result Pattern for Domain Errors
```csharp
public record Result<T>(bool IsSuccess, T? Value, string? Error)
{
    public static Result<T> Success(T value) => new(true, value, null);
    public static Result<T> Failure(string error) => new(false, default, error);
}

public async Task<Result<PharmacyDto>> CreateAsync(Request request, CancellationToken ct)
{
    if (await _repo.ExistsWithEmailAsync(request.Email, ct))
        return Result<PharmacyDto>.Failure("Email already exists");
    var pharmacy = await _repo.AddAsync(entity, ct);
    return Result<PharmacyDto>.Success(MapToDto(pharmacy));
}
```

### Exception Handling
```csharp
// GOOD: Specific catch with rethrow for cancellation
catch (DbUpdateException ex) when (ex.InnerException?.Message.Contains("Duplicate") ?? false)
{
    return Result.Failure("Duplicate entry");
}
catch (OperationCanceledException) { throw; } // Always rethrow

// BAD: Swallows all exceptions
catch (Exception ex) { return null; }
```
</patterns>

<security>
## Security
- No SQL injection (parameterized queries only)
- No sensitive data in logs
- Input validation on all endpoints
- No hardcoded credentials
</security>

<anti-patterns>
## Anti-Patterns to Avoid
- Loading all entities then filtering in memory
- Using `.Result` or `.Wait()` on async methods
- Forgetting `AsNoTracking()` for read-only queries
- Queries in loops (N+1)
- SELECT * when only few columns needed
- Missing pagination for potentially large results
- Transient or Singleton DbContext lifetime
- Exceptions for control flow
- Catching all exceptions
</anti-patterns>
