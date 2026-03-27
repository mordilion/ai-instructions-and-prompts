# Database Migrations Process - Kotlin

> **Purpose**: Implement versioned database schema migrations (same tools as Java)

> **Tools**: Flyway ⭐ (Spring Boot), Liquibase, Exposed Migrations

---

## Phase 1: Flyway (Spring Boot)

**Same as Java** - Flyway works identically with Kotlin

**Dependencies** (Gradle):
```kotlin
implementation("org.flywaydb:flyway-core")
```

**Migration** (src/main/resources/db/migration/V1__Initial.sql):
```sql
CREATE TABLE users (id BIGINT PRIMARY KEY, name VARCHAR(255));
```

> **Git**: `git commit -m "feat: add Flyway migration"`

---

## Phase 2: Exposed Migrations (Ktor)

**Install**:
```kotlin
implementation("org.jetbrains.exposed:exposed-core:$exposed_version")
implementation("org.jetbrains.exposed:exposed-dao:$exposed_version")
implementation("org.jetbrains.exposed:exposed-jdbc:$exposed_version")
```

**Schema Evolution**:
```kotlin
object Users : Table() {
    val id = long("id").autoIncrement()
    val name = varchar("name", 255)
    override val primaryKey = PrimaryKey(id)
}

// Auto-create tables (dev only)
SchemaUtils.create(Users)

// For production: Use Flyway for migrations
```

---

## Best Practices

> **ALWAYS**: Use Flyway for production migrations
> **NEVER**: Use SchemaUtils.create() in production

---

## AI Self-Check

- [ ] Flyway configured
- [ ] Migrations version controlled
- [ ] CI/CD integration complete

---

**Process Complete** ✅

