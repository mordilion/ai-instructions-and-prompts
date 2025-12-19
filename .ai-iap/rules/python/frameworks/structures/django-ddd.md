# Django Domain-Driven Design Structure

> **Scope**: This structure extends the Django framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── manage.py
├── config/                     # Infrastructure config
│   ├── settings/
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── src/
│   ├── users/                  # Bounded Context
│   │   ├── domain/
│   │   │   ├── __init__.py
│   │   │   ├── entities/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── user.py
│   │   │   │   └── profile.py
│   │   │   ├── value_objects/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── email.py
│   │   │   │   └── user_role.py
│   │   │   ├── repositories/
│   │   │   │   ├── __init__.py
│   │   │   │   └── user_repository.py  # Interface
│   │   │   ├── services/
│   │   │   │   ├── __init__.py
│   │   │   │   └── user_domain_service.py
│   │   │   └── events/
│   │   │       ├── __init__.py
│   │   │       └── user_created.py
│   │   ├── application/
│   │   │   ├── __init__.py
│   │   │   ├── commands/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── create_user.py
│   │   │   │   └── update_profile.py
│   │   │   ├── queries/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── get_user.py
│   │   │   │   └── list_users.py
│   │   │   └── dto/
│   │   │       ├── __init__.py
│   │   │       ├── user_dto.py
│   │   │       └── profile_dto.py
│   │   ├── infrastructure/
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # Django ORM models
│   │   │   ├── repositories/
│   │   │   │   ├── __init__.py
│   │   │   │   └── django_user_repository.py  # Implementation
│   │   │   ├── serializers.py      # DRF serializers
│   │   │   └── admin.py
│   │   ├── presentation/
│   │   │   ├── __init__.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   └── api/
│   │   │       ├── __init__.py
│   │   │       └── user_viewset.py
│   │   ├── tests/
│   │   │   ├── domain/
│   │   │   ├── application/
│   │   │   └── infrastructure/
│   │   └── migrations/
│   ├── orders/                 # Another Bounded Context
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   └── shared/                 # Shared Kernel
│       ├── domain/
│       │   ├── base_entity.py
│       │   └── base_value_object.py
│       ├── application/
│       │   └── base_dto.py
│       └── infrastructure/
│           ├── base_repository.py
│           └── event_bus.py
└── requirements/
```

## Layer Responsibilities

### Domain Layer (Core Business Logic)
- **Entities**: Business objects with identity (User, Order).
- **Value Objects**: Immutable objects without identity (Email, Money).
- **Domain Services**: Business logic that doesn't fit in entities.
- **Repository Interfaces**: Abstract data access (no Django ORM here).
- **Domain Events**: Business events (UserCreated, OrderPlaced).

### Application Layer (Use Cases)
- **Commands**: Write operations (CreateUser, UpdateProfile).
- **Queries**: Read operations (GetUser, ListUsers).
- **DTOs**: Data transfer objects for application boundaries.
- **Application Services**: Orchestrate domain objects and repositories.

### Infrastructure Layer (Technical Details)
- **Django Models**: ORM models (map to domain entities).
- **Repository Implementations**: Concrete data access using Django ORM.
- **Serializers**: DRF serializers for API.
- **External Services**: Email, SMS, payment gateways.

### Presentation Layer (User Interface)
- **Views/ViewSets**: HTTP request handlers.
- **URLs**: Route configuration.
- **API**: REST API endpoints.

## Example: Domain Entity
```python
# src/users/domain/entities/user.py
from dataclasses import dataclass
from ..value_objects.email import Email
from ..value_objects.user_role import UserRole

@dataclass
class User:
    id: int | None
    email: Email
    role: UserRole
    is_active: bool = True
    
    def activate(self) -> None:
        if self.is_active:
            raise ValueError("User is already active")
        self.is_active = True
    
    def deactivate(self) -> None:
        if not self.is_active:
            raise ValueError("User is already inactive")
        self.is_active = False
```

## Example: Value Object
```python
# src/users/domain/value_objects/email.py
from dataclasses import dataclass
import re

@dataclass(frozen=True)
class Email:
    value: str
    
    def __post_init__(self):
        if not self._is_valid(self.value):
            raise ValueError(f"Invalid email: {self.value}")
    
    @staticmethod
    def _is_valid(email: str) -> bool:
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
```

## Example: Repository Interface
```python
# src/users/domain/repositories/user_repository.py
from typing import Protocol
from ..entities.user import User

class UserRepositoryProtocol(Protocol):
    def get_by_id(self, user_id: int) -> User | None: ...
    def get_by_email(self, email: str) -> User | None: ...
    def save(self, user: User) -> User: ...
    def delete(self, user_id: int) -> None: ...
```

## Example: Command Handler
```python
# src/users/application/commands/create_user.py
from dataclasses import dataclass
from django.db import transaction
from ...domain.entities.user import User
from ...domain.value_objects.email import Email
from ...domain.value_objects.user_role import UserRole
from ...domain.repositories.user_repository import UserRepositoryProtocol

@dataclass
class CreateUserCommand:
    email: str
    role: str = "user"

class CreateUserHandler:
    def __init__(self, user_repo: UserRepositoryProtocol):
        self.user_repo = user_repo
    
    @transaction.atomic
    def handle(self, command: CreateUserCommand) -> User:
        email = Email(command.email)
        role = UserRole(command.role)
        
        if self.user_repo.get_by_email(email.value):
            raise ValueError(f"User with email {email.value} already exists")
        
        user = User(id=None, email=email, role=role)
        return self.user_repo.save(user)
```

## Example: Repository Implementation
```python
# src/users/infrastructure/repositories/django_user_repository.py
from ...domain.entities.user import User
from ...domain.value_objects.email import Email
from ...domain.value_objects.user_role import UserRole
from ..models import UserModel

class DjangoUserRepository:
    def get_by_id(self, user_id: int) -> User | None:
        try:
            model = UserModel.objects.get(id=user_id)
            return self._to_entity(model)
        except UserModel.DoesNotExist:
            return None
    
    def save(self, user: User) -> User:
        if user.id:
            model = UserModel.objects.get(id=user.id)
        else:
            model = UserModel()
        
        model.email = user.email.value
        model.role = user.role.value
        model.is_active = user.is_active
        model.save()
        
        return self._to_entity(model)
    
    def _to_entity(self, model: UserModel) -> User:
        return User(
            id=model.id,
            email=Email(model.email),
            role=UserRole(model.role),
            is_active=model.is_active
        )
```

## Rules
- **Domain Independence**: Domain layer has NO Django imports.
- **Dependency Direction**: Outer layers depend on inner, never reverse.
- **Mapping**: Map between Django models and domain entities at infrastructure layer.
- **Pure Business Logic**: All business rules in domain layer.
- **Use Cases**: Application layer orchestrates domain objects.

## When to Use
- Large, complex Django projects
- Long-term projects requiring maintainability
- Teams with DDD experience
- Projects with complex business rules
- Need for domain model independence from framework

