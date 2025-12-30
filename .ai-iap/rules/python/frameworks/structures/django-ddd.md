# Django Domain-Driven Design Structure

> **Scope**: Django with DDD/Clean Architecture  
> **Use When**: Complex domain, clear bounded contexts

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, infrastructure, presentation
> **ALWAYS**: Domain has no framework dependencies
> **ALWAYS**: Use repository interfaces
> **ALWAYS**: Dependency rule: inner layers independent
> 
> **NEVER**: Import Django in domain
> **NEVER**: Skip repository interfaces
> **NEVER**: Put business logic in views

## Structure

```
src/users/              # Bounded Context
├── domain/             # Pure business logic
│   ├── entities/       # User, Profile
│   ├── value_objects/  # Email, UserRole
│   ├── repositories/   # Interfaces
│   ├── services/       # Domain services
│   └── events/
├── application/        # Use cases
│   ├── commands/       # CreateUser, UpdateProfile
│   ├── queries/        # GetUser, ListUsers
│   └── dto/
├── infrastructure/     # Django-specific
│   ├── models.py       # Django ORM
│   ├── repositories/   # Implementations
│   ├── serializers.py
│   └── admin.py
└── presentation/       # API layer
    ├── views.py
    ├── urls.py
    └── serializers.py
```

## Core Patterns

### Domain Entity (Pure)

```python
# domain/entities/user.py
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    id: Optional[int]
    email: str
    name: str
    
    def change_email(self, new_email: str) -> 'User':
        if '@' not in new_email:
            raise ValueError("Invalid email")
        return User(self.id, new_email, self.name)
```

### Repository Interface

```python
# domain/repositories/user_repository.py
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    def find_by_id(self, user_id: int) -> Optional[User]: pass
    
    @abstractmethod
    def save(self, user: User) -> User: pass
```

### Command (Use Case)

```python
# application/commands/create_user.py
class CreateUserCommand:
    def __init__(self, repository: UserRepository):
        self.repository = repository
    
    def execute(self, email: str, name: str) -> User:
        user = User(id=None, email=email, name=name)
        return self.repository.save(user)
```

### Repository Implementation

```python
# infrastructure/repositories/django_user_repository.py
from domain.repositories.user_repository import UserRepository
from infrastructure.models import UserModel

class DjangoUserRepository(UserRepository):
    def find_by_id(self, user_id: int) -> Optional[User]:
        try:
            model = UserModel.objects.get(id=user_id)
            return self._to_entity(model)
        except UserModel.DoesNotExist:
            return None
    
    def save(self, user: User) -> User:
        model = self._to_model(user)
        model.save()
        return self._to_entity(model)
```

### View

```python
# presentation/views.py
from rest_framework.views import APIView

class UserCreateView(APIView):
    def post(self, request):
        command = CreateUserCommand(get_user_repository())
        user = command.execute(request.data['email'], request.data['name'])
        return Response(UserSerializer(user).data, status=201)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Django** | `from django.db` | Pure Python |
| **No Interfaces** | Direct ORM | Repository interface |
| **Logic in View** | Business rules | Command/Use case |
| **Wrong Direction** | Domain imports infra | Infra imports domain |

## AI Self-Check

- [ ] Domain pure Python?
- [ ] Repository interfaces in domain?
- [ ] Commands for use cases?
- [ ] Dependency rule followed?
- [ ] No Django in domain?
- [ ] DTOs for boundaries?
- [ ] Infrastructure implements interfaces?
- [ ] Mappers between model and entity?

## Benefits

- ✅ Framework-independent business logic
- ✅ Highly testable
- ✅ Clear boundaries
- ✅ Easy infrastructure changes

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability needs
- ❌ Simple CRUD
