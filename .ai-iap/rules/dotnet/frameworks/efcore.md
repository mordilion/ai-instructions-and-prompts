# Entity Framework Core

> **Scope**: Apply these rules when working with Entity Framework Core for data access.

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

## 7. Testing
- **In-Memory Provider**: For unit tests (limited).
- **SQLite In-Memory**: Better for integration tests.
- **Real Database**: For true integration tests.

