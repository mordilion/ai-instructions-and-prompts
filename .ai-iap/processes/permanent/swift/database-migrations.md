# Database Migrations Process - Swift (Vapor)

> **Purpose**: Implement versioned database schema migrations with Fluent

> **Tool**: Fluent Migrations ⭐ (Vapor ORM)

---

## Phase 1: Setup Fluent Migrations

**Install** (Package.swift):
```swift
.package(url: "https://github.com/vapor/fluent.git", from: "4.0.0")
.package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0")
```

**Configure**:
```swift
import Fluent
import FluentPostgresDriver

app.databases.use(.postgres(
    hostname: Environment.get("DB_HOST") ?? "localhost",
    database: Environment.get("DB_NAME") ?? "vapor"
), as: .psql)
```

---

## Phase 2: Create Migration

**Migration File**:
```swift
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
```

**Register Migration**:
```swift
app.migrations.add(CreateUser())
```

---

## Phase 3: Run Migrations

**Command**:
```bash
# Run migrations
swift run App migrate

# Revert last migration
swift run App migrate --revert
```

> **ALWAYS**: Test rollback migrations
> **NEVER**: Modify existing migrations

> **Git**: `git commit -m "feat: add user migration"`

---

## Phase 4: CI/CD Integration

**Pipeline**:
```yaml
- name: Run Fluent migrations
  run: swift run App migrate --yes
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

---

## Best Practices

> **ALWAYS**:
> - Version control migration files
> - Test on staging
> - Implement revert() method

---

## AI Self-Check

- [ ] Fluent configured
- [ ] Migrations created with revert
- [ ] Migrations run successfully
- [ ] CI/CD integration complete

---

**Process Complete** ✅

