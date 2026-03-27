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

```csharp
// DbContext
public class AppDbContext : DbContext
{
    public DbSet<User> Users => Set<User>();
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(e => {
            e.HasKey(x => x.Id);
            e.HasIndex(x => x.Email).IsUnique();
            e.HasMany(x => x.Posts).WithOne(x => x.User);
        });
    }
}

// Eager Loading (Avoid N+1)
var users = await _context.Users
    .Include(u => u.Posts).ThenInclude(p => p.Comments)
    .ToListAsync();

// AsNoTracking (Read-Only)
var users = await _context.Users.AsNoTracking().ToListAsync();

// Repository Pattern
public class UserRepository : IUserRepository
{
    public async Task<User?> GetByIdAsync(int id) =>
        await _context.Users.Include(u => u.Posts).FirstOrDefaultAsync(u => u.Id == id);
    
    public async Task AddAsync(User user) {
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();
    }
}

// Raw SQL (Parameterized)
var users = await _context.Users.FromSqlRaw("SELECT * FROM Users WHERE Email = {0}", email).ToListAsync();
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
