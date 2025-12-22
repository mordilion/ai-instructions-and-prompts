# Entity Framework Core

> **Scope**: Apply these rules when working with Entity Framework Core for data access.

## Overview

Entity Framework Core is a modern object-relational mapper (ORM) for .NET. It supports LINQ queries, change tracking, updates, and schema migrations.

**Key Capabilities**:
- **Code-First**: Define schema with C# classes
- **LINQ Queries**: Type-safe database queries
- **Change Tracking**: Automatic update detection
- **Migrations**: Version-controlled schema changes
- **Multiple Databases**: SQL Server, PostgreSQL, SQLite, etc.

## Pattern Selection

### Query Strategy
**Use AsNoTracking when**:
- Read-only queries
- Projecting to DTOs
- Performance matters

**Use Tracking when**:
- Updating entities
- Need change detection

### Loading Strategy
**Use Eager Loading (Include) when**:
- Always need related data
- Want to avoid N+1

**Use Explicit Loading when**:
- Conditionally need related data
- Large object graphs

**AVOID Lazy Loading**: Can cause N+1 queries

## 1. DbContext Design
- **One Context per Bounded Context**: Don't create a "god" DbContext.
- **No Business Logic**: DbContext is for data access only.
- **Configuration**: Use `IEntityTypeConfiguration<T>` for entity configs.

```csharp
// ✅ Good
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Email).IsRequired().HasMaxLength(256);
    }
}

// ❌ Bad
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // 500 lines of configuration in one file
}
```

## 2. Repository Pattern
- **Abstract EF**: Repositories return domain entities, not EF entities.
- **No IQueryable Leaks**: Don't expose `IQueryable` outside repository.
- **Specification Pattern**: For complex queries.

```csharp
// ✅ Good
public async Task<User?> GetByIdAsync(int id)
    => await _context.Users.FirstOrDefaultAsync(u => u.Id == id);

// ❌ Bad
public IQueryable<User> GetUsers() => _context.Users;  // Leaking IQueryable
```

## 3. Queries
- **AsNoTracking**: Use for read-only queries.
- **Projection**: Select only needed columns with `Select()`.
- **Pagination**: Always paginate large result sets.
- **Include Carefully**: Avoid N+1, but don't over-include.

```csharp
// ✅ Good
var users = await _context.Users
    .AsNoTracking()
    .Where(u => u.IsActive)
    .Select(u => new UserDto(u.Id, u.Name))
    .ToListAsync();

// ❌ Bad
var users = await _context.Users.Include(u => u.Orders).ToListAsync();
// Then filtering in memory
```

## 4. Commands (Writes)
- **Unit of Work**: SaveChanges once per operation.
- **Transactions**: Use `BeginTransactionAsync()` for multi-aggregate operations.
- **Optimistic Concurrency**: Use `RowVersion` for conflict detection.

## 5. Migrations
- **Meaningful Names**: `AddUserEmailIndex`, not `Migration_20240101`.
- **Review Generated SQL**: Check what EF generates.
- **No Data in Migrations**: Use seed data or separate scripts.

## 6. Performance
- **Compiled Queries**: For frequently executed queries.
- **Batching**: EF Core 7+ batches by default.
- **Connection Pooling**: Use appropriate pool size.
- **Avoid**: Lazy loading in web apps, loading entire tables.

## Best Practices

**MUST**:
- Use IEntityTypeConfiguration for entity configs (NO OnModelCreating)
- Use AsNoTracking for read-only queries
- Use projection (Select) to DTOs (NO loading full entities)
- Use async methods (ToListAsync, FirstOrDefaultAsync)
- Use transactions for multi-aggregate operations

**SHOULD**:
- Use repository pattern to abstract EF
- Use compiled queries for frequent queries
- Use pagination for large result sets
- Include related data carefully (avoid N+1)
- Use migrations for schema changes

**AVOID**:
- Lazy loading in web apps (causes N+1)
- Exposing IQueryable outside repositories
- Loading entire tables (use Where/Take)
- Singleton lifetime for DbContext
- Data in migrations (use seed data)

## Common Patterns

### Repository with Specification
```csharp
// ✅ GOOD: Repository abstracts EF
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    public async Task<List<User>> GetActiveUsersAsync(int page, int pageSize)
    {
        return await _context.Users
            .AsNoTracking()
            .Where(u => u.IsActive)
            .OrderBy(u => u.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<User> AddAsync(User user)
    {
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}

// ❌ BAD: Exposing IQueryable
public IQueryable<User> GetUsers()
{
    return _context.Users;  // Leaks EF implementation
}
```

### Projection to DTOs
```csharp
// ✅ GOOD: Project to DTO (efficient)
var users = await _context.Users
    .AsNoTracking()
    .Where(u => u.IsActive)
    .Select(u => new UserDto
    {
        Id = u.Id,
        Name = u.Name,
        Email = u.Email,
        OrderCount = u.Orders.Count  // Computed in SQL
    })
    .ToListAsync();

// ❌ BAD: Loading full entities
var users = await _context.Users
    .Include(u => u.Orders)
    .ToListAsync();  // Loads everything into memory

var dtos = users.Select(u => new UserDto
{
    Id = u.Id,
    Name = u.Name,
    OrderCount = u.Orders.Count  // Computed in C#
}).ToList();
```

### Eager Loading (Avoiding N+1)
```csharp
// ✅ GOOD: Eager load with Include
var users = await _context.Users
    .Include(u => u.Orders)
        .ThenInclude(o => o.Items)
    .Where(u => u.IsActive)
    .ToListAsync();

// Access orders without additional queries
foreach (var user in users)
{
    Console.WriteLine($"{user.Name}: {user.Orders.Count} orders");
}

// ❌ BAD: N+1 queries
var users = await _context.Users.ToListAsync();

foreach (var user in users)
{
    // Separate query for EACH user!
    var orders = await _context.Orders
        .Where(o => o.UserId == user.Id)
        .ToListAsync();
}
```

### Transactions
```csharp
// ✅ GOOD: Transaction for multi-step operations
public async Task TransferOrderAsync(int orderId, int newUserId)
{
    using var transaction = await _context.Database.BeginTransactionAsync();
    
    try
    {
        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) throw new NotFoundException();

        order.UserId = newUserId;
        order.TransferredAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Audit log
        _context.AuditLogs.Add(new AuditLog
        {
            Action = "OrderTransferred",
            EntityId = orderId,
            Timestamp = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();
    }
    catch
    {
        await transaction.RollbackAsync();
        throw;
    }
}

// ❌ BAD: No transaction (partial state possible)
public async Task TransferOrderAsync(int orderId, int newUserId)
{
    var order = await _context.Orders.FindAsync(orderId);
    order.UserId = newUserId;
    await _context.SaveChangesAsync();  // If next fails, inconsistent

    _context.AuditLogs.Add(new AuditLog { ... });
    await _context.SaveChangesAsync();  // Might fail
}
```

### Entity Configuration
```csharp
// ✅ GOOD: Separate configuration class
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(u => u.Id);
        
        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(256);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.HasMany(u => u.Orders)
            .WithOne(o => o.User)
            .HasForeignKey(o => o.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(u => u.RowVersion)
            .IsRowVersion();  // Optimistic concurrency
    }
}

// In DbContext
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
}

// ❌ BAD: Everything in OnModelCreating
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // 500 lines of configuration
    modelBuilder.Entity<User>().HasKey(u => u.Id);
    modelBuilder.Entity<User>().Property(u => u.Email).IsRequired();
    // ...
}
```

## Common Anti-Patterns

**❌ Lazy loading in web apps**:
```csharp
// BAD
public class User
{
    public virtual ICollection<Order> Orders { get; set; }  // Virtual = lazy loading
}

// Causes N+1 queries when accessing Orders
foreach (var user in users)
{
    Console.WriteLine(user.Orders.Count);  // Separate query!
}
```

**✅ Use eager loading**:
```csharp
// GOOD
var users = await _context.Users.Include(u => u.Orders).ToListAsync();
```

**❌ Loading entire tables**:
```csharp
// BAD
var allUsers = await _context.Users.ToListAsync();  // 1 million users!
```

**✅ Use pagination**:
```csharp
// GOOD
var users = await _context.Users
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

## 7. Testing
- **In-Memory Provider**: For unit tests (limited, not full SQL)
- **SQLite In-Memory**: Better for integration tests (closer to real DB)
- **Real Database**: For true integration tests (use test containers)

