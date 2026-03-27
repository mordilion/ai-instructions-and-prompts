# Python Code Style

> **Scope**: Python formatting and maintainability  
> **Applies to**: *.py files  
> **Extends**: General code style, python/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Follow PEP 8 style guide
> **ALWAYS**: Use type hints everywhere
> **ALWAYS**: Use Black for formatting
> **ALWAYS**: Use dataclasses for data structures
> **ALWAYS**: Use list comprehensions (not loops + append)
> 
> **NEVER**: Use mutable default arguments
> **NEVER**: Use * imports (from x import *)
> **NEVER**: Use except: without specific exception
> **NEVER**: Mix tabs and spaces
> **NEVER**: Skip type hints for public functions

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

# Use built-in types (modern Python)
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

# Match statement (modern Python)
match status:
    case "pending":
        handle_pending()
    case "approved":
        handle_approved()
```

## AI Self-Check

- [ ] Following PEP 8?
- [ ] Type hints everywhere?
- [ ] Black for formatting?
- [ ] dataclasses for data structures?
- [ ] List comprehensions (not loops + append)?
- [ ] snake_case for functions/variables?
- [ ] PascalCase for classes?
- [ ] No mutable default arguments?
- [ ] No * imports?
- [ ] Specific exception catches?
- [ ] Type hints for public functions?
- [ ] Context managers for resources?
