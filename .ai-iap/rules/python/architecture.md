# Python Architecture

> **Scope**: Apply these rules ONLY when working with `.py` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Modularity**: Small files (<300 lines). Clear, explicit imports.
- **Separation of Concerns**: Business logic separated from framework/infrastructure code.
- **Type Hints**: Use type hints everywhere for clarity and IDE support.

## 2. Project Structure
- **Feature-First**: Organize by feature/domain, NOT by type (services/, models/).
- **Shared Code**: Common utilities in `common/` or `core/` package.
- **Configuration**: Environment-based config in `config/` or `settings/`.
- **Note**: See structure files for specific folder layouts (Django, FastAPI, etc.).

## 3. Naming Conventions
- **Classes**: `PascalCase` (e.g., `UserService`, `OrderRepository`).
- **Functions/Variables**: `snake_case` (e.g., `get_user`, `user_name`).
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).
- **Private**: Prefix with `_` (e.g., `_internal_method`).
- **Interfaces/Protocols**: NO `I` prefix. Use `Protocol` suffix (e.g., `UserRepositoryProtocol`).

## 4. Package Organization
- **`__init__.py`**: Use for exposing public API. Keep minimal.
- **Imports**: Absolute imports preferred. Relative imports only within same package.
  - ✅ Good: `from app.users.services import UserService`
  - ⚠️ Acceptable: `from .services import UserService` (within same package)
  - ❌ Bad: `from ..users.services import UserService` (complex relative)

## 5. Design Patterns
- **Repository Pattern**: Abstract data access behind interfaces.
- **Service Layer**: Business logic in service classes, NOT in views/controllers.
- **Dependency Injection**: Use constructor injection or frameworks (FastAPI Depends, Django Injector).
- **DTOs/Schemas**: Use Pydantic models or dataclasses for data transfer.

## 6. Data Layer
- **ORM**: Use ORM models for persistence, NOT for business logic.
- **DTOs**: NEVER return raw ORM models. Always map to DTOs/schemas.
- **Migrations**: Version-controlled database migrations (Alembic, Django migrations).

## 7. Anti-Patterns (MUST avoid)
- **Circular Imports**: Structure code to avoid circular dependencies.
  - Fix: Use type hints with `from __future__ import annotations` or `TYPE_CHECKING`.
- **God Classes**: Classes >300 lines = split into smaller classes.
- **Business Logic in Views**: Views/routes should delegate to services.
  - ❌ Bad: `def create_user(request): user = User.objects.create(...); send_email(...)`
  - ✅ Good: `def create_user(request): return user_service.create_user(request.data)`
- **Mixing Sync/Async**: Don't mix sync and async code without proper handling.

