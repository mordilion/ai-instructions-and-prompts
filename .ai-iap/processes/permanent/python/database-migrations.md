# Database Migrations Process - Python

> **Purpose**: Implement versioned database schema migrations with Alembic or Django

> **Tools**: Alembic ⭐ (SQLAlchemy), Django Migrations (Django ORM)

---

## Phase 1: Setup Alembic (SQLAlchemy)

**Install**:
```bash
pip install alembic
alembic init alembic
```

**Configure** (alembic.ini):
```ini
sqlalchemy.url = driver://user:pass@localhost/dbname
```

**Create Initial Migration**:
```bash
alembic revision --autogenerate -m "Initial schema"
alembic upgrade head
```

> **Git**: `git commit -m "feat: add initial Alembic migration"`

---

## Phase 2: Migration Workflow

**Create Migration**:
```bash
alembic revision --autogenerate -m "Add posts table"
```

**Apply Migrations**:
```bash
alembic upgrade head
```

**Rollback**:
```bash
alembic downgrade -1  # One version back
alembic downgrade base  # All the way back
```

> **ALWAYS**: Review auto-generated migrations
> **NEVER**: Modify applied migrations

> **Git**: `git commit -m "feat: add posts table migration"`

---

## Phase 3: Django Migrations

**Create Migration**:
```bash
python manage.py makemigrations
```

**Apply Migrations**:
```bash
python manage.py migrate
```

**Rollback**:
```bash
python manage.py migrate app_name migration_name
```

**Generate SQL** (review before applying):
```bash
python manage.py sqlmigrate app_name migration_number
```

---

## Phase 4: CI/CD Integration

**Pipeline** (Alembic):
```yaml
- name: Run Alembic migrations
  run: alembic upgrade head
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**Pipeline** (Django):
```yaml
- name: Run Django migrations
  run: python manage.py migrate
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

---

## Best Practices

> **ALWAYS**:
> - Version control migrations folder
> - Test on staging first
> - Backup before major changes
> - Use transactions (default in Alembic/Django)

**Seeding** (Django):
```python
# myapp/management/commands/seed.py
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    def handle(self, *args, **options):
        User.objects.create(username='admin')
```

Run: `python manage.py seed`

---

## AI Self-Check

- [ ] Alembic/Django migrations configured
- [ ] Initial migration created
- [ ] Migrations version controlled
- [ ] Rollback tested
- [ ] CI/CD integration complete
- [ ] Tested in staging

---

**Process Complete** ✅

