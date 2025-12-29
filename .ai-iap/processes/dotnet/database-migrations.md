# Database Migrations Process - .NET/C#

> **Purpose**: Implement versioned database schema migrations with Entity Framework Core

> **Tool**: Entity Framework Core Migrations ⭐

---

## Phase 1: Setup EF Core Migrations

**Install**:
```bash
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet tool install --global dotnet-ef
```

**Create Initial Migration**:
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

> **Git**: `git commit -m "feat: add initial EF Core migration"`

---

## Phase 2: Migration Workflow

**Create Migration**:
```bash
dotnet ef migrations add AddBlogTable
```

**Apply Migration**:
```bash
dotnet ef database update
```

**Rollback**:
```bash
dotnet ef database update PreviousMigrationName
```

**Generate SQL Script** (for production):
```bash
dotnet ef migrations script --output migration.sql --idempotent
```

> **ALWAYS**: Use idempotent scripts in production
> **NEVER**: Modify existing migrations

> **Git**: `git commit -m "feat: add blog table migration"`

---

## Phase 3: CI/CD Integration

**Pipeline**:
```yaml
- name: Run EF Core migrations
  run: dotnet ef database update
  env:
    ConnectionStrings__DefaultConnection: ${{ secrets.DB_CONNECTION }}
```

> **Git**: `git commit -m "ci: integrate EF migrations"`

---

## Best Practices

> **ALWAYS**:
> - Use `--idempotent` for production SQL scripts
> - Test migrations on staging
> - Backup before major changes
> - Version control Migrations/ folder

**Seeding**:
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<User>().HasData(
        new User { Id = 1, Name = "Admin" }
    );
}
```

---

## AI Self-Check

- [ ] EF Core tools installed
- [ ] Initial migration created
- [ ] Migrations version controlled
- [ ] Idempotent scripts for production
- [ ] CI/CD integration complete
- [ ] Tested in staging

---

**Process Complete** ✅

