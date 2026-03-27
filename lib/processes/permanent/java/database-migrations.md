# Database Migrations Process - Java

> **Purpose**: Implement versioned database schema migrations with Flyway or Liquibase

> **Tools**: Flyway ⭐ (simple SQL), Liquibase (XML/YAML/JSON)

---

## Phase 1: Setup Flyway

**Dependencies** (Maven):
```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

**Configuration** (application.properties):
```properties
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
```

**Create Migration**:
```sql
-- src/main/resources/db/migration/V1__Initial_schema.sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    username VARCHAR(255) NOT NULL
);
```

> **Naming**: `V{version}__{description}.sql` (e.g., `V1__Initial_schema.sql`)

> **Git**: `git commit -m "feat: add initial Flyway migration"`

---

## Phase 2: Migration Workflow

**Auto-run** (Spring Boot):
- Migrations run automatically on startup

**Manual run**:
```bash
mvn flyway:migrate
```

**Rollback** (Flyway Teams only):
```bash
mvn flyway:undo
```

> **ALWAYS**: Create new migrations, never modify existing ones
> **NEVER**: Skip versioning (use V1, V2, V3, etc.)

> **Git**: `git commit -m "feat: add products table migration"`

---

## Phase 3: Liquibase Alternative

**Dependencies**:
```xml
<dependency>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-core</artifactId>
</dependency>
```

**Changelog** (db/changelog/db.changelog-master.yaml):
```yaml
databaseChangeLog:
  - changeSet:
      id: 1
      author: developer
      changes:
        - createTable:
            tableName: users
            columns:
              - column:
                  name: id
                  type: BIGINT
                  constraints:
                    primaryKey: true
```

---

## Phase 4: CI/CD Integration

**Pipeline**:
```yaml
- name: Run Flyway migrations
  run: mvn flyway:migrate
  env:
    SPRING_DATASOURCE_URL: ${{ secrets.DB_URL }}
```

---

## Best Practices

> **ALWAYS**:
> - Use versioned migrations (V1, V2, V3)
> - Test on staging first
> - Backup before major changes
> - Version control migrations

**Seeding** (optional):
```sql
-- V2__Seed_data.sql
INSERT INTO users (id, username) VALUES (1, 'admin');
```

---

## AI Self-Check

- [ ] Flyway/Liquibase configured
- [ ] Initial migration created
- [ ] Migrations version controlled
- [ ] Auto-run on startup enabled
- [ ] CI/CD integration complete
- [ ] Tested in staging

---

**Process Complete** ✅

