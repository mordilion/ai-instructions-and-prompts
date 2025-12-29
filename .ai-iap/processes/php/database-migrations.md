# Database Migrations Process - PHP

> **Purpose**: Implement versioned database schema migrations with Laravel or Doctrine

> **Tools**: Laravel Migrations ⭐, Doctrine Migrations, Phinx

---

## Phase 1: Laravel Migrations

**Create Migration**:
```bash
php artisan make:migration create_users_table
```

**Migration File**:
```php
public function up() {
    Schema::create('users', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->string('email')->unique();
        $table->timestamps();
    });
}

public function down() {
    Schema::dropIfExists('users');
}
```

**Run Migrations**:
```bash
php artisan migrate
```

**Rollback**:
```bash
php artisan migrate:rollback
php artisan migrate:rollback --step=1
```

> **Git**: `git commit -m "feat: add users table migration"`

---

## Phase 2: Doctrine Migrations (Symfony)

**Install**:
```bash
composer require doctrine/doctrine-migrations-bundle
```

**Create Migration**:
```bash
php bin/console make:migration
```

**Run Migrations**:
```bash
php bin/console doctrine:migrations:migrate
```

**Rollback**:
```bash
php bin/console doctrine:migrations:migrate prev
```

---

## Phase 3: CI/CD Integration

**Pipeline** (Laravel):
```yaml
- name: Run Laravel migrations
  run: php artisan migrate --force
  env:
    DB_CONNECTION: ${{ secrets.DB_CONNECTION }}
```

> **ALWAYS**: Use `--force` in production (no prompts)

---

## Best Practices

> **ALWAYS**:
> - Version control database/migrations/
> - Test on staging
> - Use Schema::dropIfExists() in down()

**Seeding** (Laravel):
```bash
php artisan make:seeder UserSeeder
php artisan db:seed
```

---

## AI Self-Check

- [ ] Migration tool configured
- [ ] Migrations created
- [ ] Rollback methods implemented
- [ ] CI/CD integration complete
- [ ] Tested in staging

---

**Process Complete** ✅

