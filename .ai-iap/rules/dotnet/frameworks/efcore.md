# Entity Framework Core

> **Scope**: Apply these rules when using EF Core in .NET applications
> **Applies to**: C# files using Entity Framework Core
> **Extends**: dotnet/architecture.md, dotnet/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use async methods for all database operations
> **ALWAYS**: Use DbContext with scoped lifetime (NOT singleton)
> **ALWAYS**: Use Include/ThenInclude to avoid N+1 queries
> **ALWAYS**: Use migrations for schema changes
> **ALWAYS**: Use AsNoTracking for read-only queries
> 
> **NEVER**: Use synchronous methods (blocks thread pool)
> **NEVER**: Use DbContext as singleton (not thread-safe)
> **NEVER**: Lazy load in loops (N+1 problem)
> **NEVER**: Use string-based column names (use lambdas)
> **NEVER**: Track entities unnecessarily (performance)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Include/ThenInclude | Load related entities | Eager loading, avoid N+1 |
| AsNoTracking | Read-only queries | Performance, no updates needed |
| FromSqlRaw | Raw SQL queries | Complex queries, parameterized |
| ExecuteSqlRaw | Non-query commands | Updates, deletes |
| Migrations | Schema changes | Version control, deployment |

## Core Patterns

### DbContext Configuration
```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }
    
    public DbSet<User> Users => Set<User>();
    public DbSet<Post> Posts => Set<Post>();
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Name).HasMaxLength(100).IsRequired();
            
            entity.HasMany(e => e.Posts)
                .WithOne(e => e.Author)
                .HasForeignKey(e => e.AuthorId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
```

### Repository Pattern
```csharp
public class UserRepository
{
    private readonly AppDbContext _context;
    
    public UserRepository(AppDbContext context)
    {
        _context = context;
    }
    
    public async Task<List<User>> GetAllAsync()
    {
        return await _context.Users
            .AsNoTracking()  // Read-only, better performance
            .Include(u => u.Posts)  // Eager load to avoid N+1
            .ToListAsync();
    }
    
    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users
            .Include(u => u.Posts)
            .FirstOrDefaultAsync(u => u.Id == id);
    }
    
    public async Task<User> CreateAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}
```

### Avoiding N+1 Queries
```csharp
// ✅ CORRECT - Single query with Include
var users = await _context.Users
    .Include(u => u.Posts)
        .ThenInclude(p => p.Comments)  // Nested include
    .ToListAsync();

foreach (var user in users)
{
    Console.WriteLine(user.Posts.Count);  // No additional queries
}

// ❌ WRONG - N+1 queries
var users = await _context.Users.ToListAsync();
foreach (var user in users)
{
    var posts = await _context.Posts
        .Where(p => p.AuthorId == user.Id)
        .ToListAsync();  // Separate query for EACH user!
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Sync Methods** | `.ToList()`, `.First()` | `await .ToListAsync()`, `await .FirstAsync()` | Blocks threads |
| **Singleton DbContext** | `AddSingleton<AppDbContext>()` | `AddDbContext<AppDbContext>()` (scoped) | Not thread-safe |
| **No Include** | Lazy load in loop | `Include()` eager loading | N+1 queries |
| **Always Tracking** | Default tracking for reads | `AsNoTracking()` | Performance |
| **String Names** | `"Email"` in queries | `u => u.Email` | Type-safety |

### Anti-Pattern: Singleton DbContext (NOT THREAD-SAFE)
```csharp
// ❌ WRONG - Singleton DbContext (NOT THREAD-SAFE)
services.AddSingleton<AppDbContext>();  // CRASHES under load!

// ✅ CORRECT - Scoped DbContext
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));  // Scoped by default
```

### Anti-Pattern: N+1 Queries (PERFORMANCE KILLER)
```csharp
// ❌ WRONG - N+1 queries
var users = await _context.Users.ToListAsync();
foreach (var user in users)
{
    // Separate query for EACH user!
    user.Posts = await _context.Posts
        .Where(p => p.AuthorId == user.Id)
        .ToListAsync();
}

// ✅ CORRECT - Single query with Include
var users = await _context.Users
    .Include(u => u.Posts)
    .ToListAsync();
```

## AI Self-Check (Verify BEFORE generating EF Core code)

- [ ] Using async/await for all DB operations?
- [ ] DbContext registered as scoped? (NOT singleton)
- [ ] Include/ThenInclude to avoid N+1?
- [ ] AsNoTracking for read-only queries?
- [ ] Lambdas instead of string column names?
- [ ] Migrations for schema changes?
- [ ] Proper indexes defined?
- [ ] OnDelete behavior configured?
- [ ] No lazy loading in loops?
- [ ] SaveChangesAsync called appropriately?

## Migrations

```bash
# Add migration
dotnet ef migrations add AddUserTable

# Update database
dotnet ef database update

# Remove last migration
dotnet ef migrations remove

# Generate SQL script
dotnet ef migrations script
```

## Query Types

| Method | Purpose | Use Case |
|--------|---------|----------|
| Include | Eager load relations | Avoid N+1 |
| ThenInclude | Nested eager load | Multi-level relations |
| AsNoTracking | Read-only queries | Performance |
| FromSqlRaw | Raw SQL query | Complex queries |
| ExecuteSqlRaw | Non-query command | Bulk updates/deletes |

## Configuration

```csharp
// Program.cs or Startup.cs
services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(connectionString);
    options.EnableSensitiveDataLogging(isDevelopment);  // Dev only
    options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking);  // Global
});
```

## Key Features

- **LINQ Provider**: Type-safe queries
- **Change Tracking**: Automatic update detection
- **Migrations**: Code-first schema management
- **Lazy/Eager Loading**: Flexible data loading
- **Raw SQL**: For complex scenarios

## Key Concepts

- **DbContext**: Unit of work + repository
- **DbSet**: Collection of entities
- **ChangeTracker**: Tracks entity changes
- **SaveChanges**: Persists changes to database
- **Migrations**: Schema version control
