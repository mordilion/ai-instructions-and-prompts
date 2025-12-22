# Python Code Style

## General Rules

- **Python 3.10+ (3.11 recommended)**
- **PEP 8** style guide
- **Type hints** everywhere
- **Black** for formatting

## Naming Conventions

```python
# snake_case for functions, variables
def get_user():
    user_name = "John"

# PascalCase for classes
class UserService:
    pass

# UPPER_SNAKE_CASE for constants
MAX_ATTEMPTS = 3
```

## Type Hints

```python
from typing import Optional

def get_user(user_id: int) -> Optional[User]:
    return users.get(user_id)

# Use built-in types (Python 3.9+)
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}
```

## Functions

```python
# Use type hints
def double(x: int) -> int:
    return x * 2

# Async functions
async def fetch_data() -> Data:
    return await client.get_data()
```

## Best Practices

```python
# Use dataclasses
from dataclasses import dataclass

@dataclass
class User:
    id: int
    name: str

# F-strings for formatting
name = "John"
message = f"Hello, {name}!"

# Walrus operator
if (user := find_user(id)) is not None:
    print(user.name)

# Match statement (Python 3.10+)
match status:
    case "pending":
        handle_pending()
    case "approved":
        handle_approved()
```
