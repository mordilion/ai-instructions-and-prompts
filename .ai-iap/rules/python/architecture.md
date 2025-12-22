# Python Architecture

## Overview
Clean Python with type hints, dataclasses, and async patterns.

## Core Principles

### Type Hints
```python
from typing import Optional

def get_user(user_id: int) -> Optional[User]:
    return repository.find_by_id(user_id)

async def fetch_users() -> list[User]:
    return await repository.get_all()
```

### Dataclasses
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    id: int
    name: str
    email: str
```

### Dependency Injection
```python
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    async def find_by_id(self, user_id: int) -> Optional[User]:
        pass

class UserService:
    def __init__(self, repository: UserRepository):
        self.repository = repository
```

## Error Handling

```python
class UserNotFoundError(Exception):
    def __init__(self, user_id: int):
        super().__init__(f"User {user_id} not found")
```

## Best Practices

### Context Managers
```python
with open('file.txt') as f:
    content = f.read()
```

### Comprehensions
```python
names = [user.name for user in users if user.is_active]
```

### Async/Await
```python
async def process_users():
    users = await fetch_users()
    tasks = [process_user(user) for user in users]
    await asyncio.gather(*tasks)
```
