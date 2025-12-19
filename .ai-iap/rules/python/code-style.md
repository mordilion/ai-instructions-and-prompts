# Python Code Style

> **Scope**: Apply these rules ONLY when working with `.py` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: Python 3.10+ features required (3.11+ recommended).
- **Style Guide**: Follow PEP 8, enforced with Ruff or Black.
- **Type Hints**: Use type hints for all function signatures and class attributes.
- **Immutability**: Prefer immutable data structures. Use `dataclasses(frozen=True)` or Pydantic.

## 2. Structure
- **Files**: One class per file for complex classes. Related functions can be grouped.
- **Imports**: Group and order: Standard library → Third-party → Local. Blank line between groups.
- **Exports**: Use `__all__` to define public API in `__init__.py`.
- **Class Member Order**:
  1. Class variables
  2. `__init__` / `__new__`
  3. Public methods
  4. Private methods (`_method`)
  5. Special methods (`__str__`, `__repr__`)

## 3. Naming
- **Files/Packages**: `snake_case` (e.g., `user_service.py`, `order_repository/`).
- **Classes/Types**: `PascalCase` (e.g., `UserService`, `OrderDto`).
- **Functions/Variables/Methods**: `snake_case` (e.g., `get_user`, `user_id`).
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`, `API_KEY`).
- **Private**: Prefix `_` for internal use (e.g., `_process_data`).
- **Booleans**: Prefix `is_`, `has_`, `should_`, `can_` (e.g., `is_active`, `has_permission`).

## 4. Type Hints
```python
# Always use type hints
def get_user(user_id: int) -> User | None:
    ...

# Use modern union syntax (Python 3.10+)
def process(data: str | int) -> dict[str, Any]:
    ...

# Use Protocol for interfaces
from typing import Protocol

class UserRepositoryProtocol(Protocol):
    def get(self, user_id: int) -> User | None: ...
```

## 5. Language Features
- **Data Classes**: Use `@dataclass` for data containers. Add `frozen=True` for immutability.
- **Comprehensions**: Use list/dict comprehensions for simple transformations.
  - ✅ Good: `active_users = [u for u in users if u.is_active]`
  - ❌ Bad: `for u in users: if u.is_active: active_users.append(u)`
- **Context Managers**: Use `with` for resources (files, connections).
- **F-Strings**: Use f-strings for formatting. NEVER use `%` or `.format()`.

## 6. Best Practices
- **Async**: Use `async/await` for I/O-bound operations (FastAPI, async ORMs).
- **Error Handling**: Use specific exceptions. Create custom exceptions.
  - ✅ Good: `raise UserNotFoundException(f"User {user_id} not found")`
  - ❌ Bad: `raise Exception("User not found")`
- **Logging**: Use `logging` module. NEVER use `print()` in production code.
- **None Checks**: Explicit `is None` / `is not None`.
  - ✅ Good: `if user is not None:`
  - ❌ Bad: `if user:`
- **Docstrings**: Use for public functions/classes (Google or NumPy style).

## 7. Code Organization
```python
"""Module docstring explaining purpose."""
from __future__ import annotations  # For forward references

# Standard library
import logging
from typing import Any, Protocol

# Third-party
from pydantic import BaseModel
from sqlalchemy.orm import Session

# Local
from app.core.exceptions import UserNotFoundException
from app.users.models import User

logger = logging.getLogger(__name__)

class UserService:
    """Service for user operations."""
    
    def __init__(self, db: Session) -> None:
        self.db = db
    
    def get_user(self, user_id: int) -> User:
        """Retrieve user by ID."""
        user = self.db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise UserNotFoundException(f"User {user_id} not found")
        return user
```

## 8. Anti-Patterns (MUST avoid)
- **Bare `except`**: NEVER use `except:` without exception type.
  - ❌ Bad: `try: ... except: pass`
  - ✅ Good: `try: ... except ValueError as e: logger.error(f"Invalid value: {e}")`
- **Mutable Defaults**: NEVER use mutable defaults in function signatures.
  - ❌ Bad: `def process(items=[]):`
  - ✅ Good: `def process(items: list[str] | None = None):`
- **Star Imports**: NEVER use `from module import *`.
- **Global State**: Avoid global variables. Use dependency injection.

