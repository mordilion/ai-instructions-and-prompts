# Entity Framework Core

> **Scope**: EF Core in .NET applications  
> **Applies to**: C# files using Entity Framework Core
> **Extends**: dotnet/architecture.md, dotnet/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use async methods for database operations
> **ALWAYS**: Use DbContext with scoped lifetime
> **ALWAYS**: Use Include/ThenInclude to avoid N+1
> **ALWAYS**: Use migrations for schema changes
> **ALWAYS**: Use AsNoTracking for read-only queries
> 
> **NEVER**: Use synchronous methods
> **NEVER**: Use DbContext as singleton
> **NEVER**: Lazy load in loops
> **NEVER**: Use string-based column names
> **NEVER**: Track entities unnecessarily

## Core Patterns

### DbContext

```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    
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
                .WithOne(e => e.User)
                .HasForeignKey(e => e.UserId);
        });
    }
}
```

### Eager Loading (Avoid N+1)

```csharp
// ❌ WRONG: N+1 queries
var users = await _context.Users.ToListAsync();
foreach (var user in users)
{
    var posts = user.Posts;  // Lazy load for each user!
}

// ✅ CORRECT: Single query with Include
var users = await _context.Users
    .Include(u => u.Posts)
    .ThenInclude(p => p.Comments)
    .ToListAsync();
```

### AsNoTracking

```csharp
// Read-only query
var users = await _context.Users
    .AsNoTracking()
    .Where(u => u.IsActive)
    .ToListAsync();
```

### Repository Pattern

```csharp
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;
    
    public UserRepository(AppDbContext context) => _context = context;
    
    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users
            .Include(u => u.Posts)
            .FirstOrDefaultAsync(u => u.Id == id);
    }
    
    public async Task<IEnumerable<User>> GetAllAsync()
    {
        return await _context.Users.AsNoTracking().ToListAsync();
    }
    
    public async Task AddAsync(User user)
    {
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();
    }
}
```

### Raw SQL (Parameterized)

```csharp
var users = await _context.Users
    .FromSqlRaw("SELECT * FROM Users WHERE Email = {0}", email)
    .ToListAsync();

// Execute non-query
await _context.Database.ExecuteSqlRawAsync(
    "UPDATE Users SET IsActive = {0} WHERE Id = {1}", 
    true, userId);
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Sync Methods** | `.ToList()` | `.ToListAsync()` |
| **Singleton** | `AddSingleton<DbContext>` | `AddScoped<DbContext>` |
| **N+1** | Lazy load in loop | `.Include()` |
| **Tracking** | Default for reads | `.AsNoTracking()` |

## AI Self-Check

- [ ] Using async methods?
- [ ] Scoped lifetime?
- [ ] Include for related data?
- [ ] Migrations configured?
- [ ] AsNoTracking for reads?
- [ ] No sync methods?
- [ ] No singleton DbContext?
- [ ] Lambda-based queries?
- [ ] Parameterized raw SQL?

## Key Features

| Feature | Purpose |
|---------|---------|
| Include/ThenInclude | Eager loading |
| AsNoTracking | Performance |
| Migrations | Schema versioning |
| FromSqlRaw | Raw SQL |
| DbContext | Unit of work |

## Best Practices

**MUST**: Async, scoped lifetime, Include, migrations, AsNoTracking
**SHOULD**: Repository pattern, lambda queries, parameterized SQL
**AVOID**: Sync methods, singleton DbContext, lazy loading in loops, tracking reads
