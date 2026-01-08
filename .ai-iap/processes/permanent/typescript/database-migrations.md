# Database Migrations Process - TypeScript/Node.js

> **Purpose**: Implement versioned database schema migrations for safe, trackable database changes

> **Tools**: TypeORM, Prisma, Knex.js, node-pg-migrate, Sequelize

---

## Phase 1: Setup Migration Tool

### Choose Tool

> **ALWAYS use a migration tool** (NEVER manual SQL scripts without versioning)

**Recommended by ORM**:
- **Prisma** ⭐ - Type-safe, auto-migration generation
- **TypeORM** - Decorators, TypeScript-first
- **Knex.js** - SQL query builder, framework-agnostic
- **node-pg-migrate** - PostgreSQL-specific, no ORM required

### Install (Prisma Example)

```bash
npm install prisma @prisma/client
npx prisma init
```

> **Git**: `git commit -m "feat: initialize Prisma for migrations"`

---

## Phase 2: Create Initial Migration

> **ALWAYS**:
> - Create migration for existing schema (baseline)
> - Include timestamps in migration names
> - Use descriptive names (`create_users_table`, not `migration_1`)

**Prisma**:
```bash
# Define schema in prisma/schema.prisma
npx prisma migrate dev --name init
```

**TypeORM**:
```bash
npx typeorm migration:generate -n InitialSchema
npx typeorm migration:run
```

**Knex.js**:
```bash
npx knex migrate:make initial_schema
npx knex migrate:latest
```

> **Git**: `git commit -m "feat: add initial database migration"`

---

## Phase 3: Migration Workflow

> **ALWAYS**:
> - One migration per logical change
> - Test migrations in development first
> - Provide rollback (down) migrations
> - Run migrations before deployment

**Create Migration**:
```bash
# Prisma
npx prisma migrate dev --name add_posts_table

# TypeORM
npx typeorm migration:create -n AddPostsTable

# Knex
npx knex migrate:make add_posts_table
```

**Run Migrations**:
```bash
# Prisma
npx prisma migrate deploy

# TypeORM
npx typeorm migration:run

# Knex
npx knex migrate:latest
```

**Rollback**:
```bash
# TypeORM
npx typeorm migration:revert

# Knex
npx knex migrate:rollback
```

> **NEVER**:
> - Modify existing migrations (create new ones)
> - Run migrations manually in production
> - Skip testing rollbacks

> **Git**: `git commit -m "feat: add posts table migration"`

---

## Phase 4: CI/CD Integration

> **ALWAYS run migrations before app deployment**

**CI/CD Pipeline**:
```yaml
# .github/workflows/deploy.yml
- name: Run database migrations
  run: |
    npx prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**Docker**:
```dockerfile
# Separate migration step
RUN npx prisma generate
CMD ["npx", "prisma", "migrate", "deploy", "&&", "node", "dist/index.js"]
```

> **Git**: `git commit -m "ci: integrate migrations into deployment"`

---

## Phase 5: Best Practices

> **ALWAYS**:
> - Version control migrations (`git add migrations/`)
> - Test on staging before production
> - Backup database before major migrations
> - Use transactions (most tools do automatically)

> **NEVER**:
> - Delete old migrations from version control
> - Run migrations on production directly (use CI/CD)
> - Skip migration testing

**Seeding** (optional):
```bash
# Prisma
npx prisma db seed

# Create seed script in package.json
"prisma": {
  "seed": "ts-node prisma/seed.ts"
}
```

> **Git**: `git commit -m "feat: add database seed script"`

---

## Tool-Specific Notes

### Prisma
- Auto-generates migrations from schema changes
- Type-safe client auto-generated
- `prisma migrate dev` (dev), `prisma migrate deploy` (prod)

### TypeORM
- Entity decorators define schema
- `migration:generate` for auto-generation
- Supports multiple databases

### Knex.js
- Manual migration files (up/down functions)
- Framework-agnostic
- Great for complex SQL

---

## AI Self-Check

- [ ] Migration tool installed and configured
- [ ] Initial migration created (baseline)
- [ ] Migrations version controlled
- [ ] Rollback migrations provided
- [ ] Migrations integrated into CI/CD
- [ ] Tested in staging environment
- [ ] Backup strategy documented
- [ ] Seed scripts created (if needed)

---

**Process Complete** ✅

