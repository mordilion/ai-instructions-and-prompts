# FastAPI Clean Architecture

> **Scope**: This structure extends the FastAPI framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── src/
│   ├── domain/                 # Enterprise business rules
│   │   ├── __init__.py
│   │   ├── entities/
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   └── post.py
│   │   ├── value_objects/
│   │   │   ├── __init__.py
│   │   │   ├── email.py
│   │   │   └── password.py
│   │   ├── repositories/
│   │   │   ├── __init__.py
│   │   │   ├── user_repository.py  # Interface
│   │   │   └── post_repository.py  # Interface
│   │   └── exceptions/
│   │       ├── __init__.py
│   │       └── domain_exceptions.py
│   ├── application/            # Application business rules
│   │   ├── __init__.py
│   │   ├── use_cases/
│   │   │   ├── __init__.py
│   │   │   ├── users/
│   │   │   │   ├── create_user.py
│   │   │   │   ├── get_user.py
│   │   │   │   └── update_user.py
│   │   │   └── posts/
│   │   ├── dto/
│   │   │   ├── __init__.py
│   │   │   ├── user_dto.py
│   │   │   └── post_dto.py
│   │   └── interfaces/
│   │       ├── __init__.py
│   │       └── email_service.py    # Interface
│   ├── infrastructure/         # External interfaces
│   │   ├── __init__.py
│   │   ├── database/
│   │   │   ├── __init__.py
│   │   │   ├── models.py           # SQLAlchemy models
│   │   │   ├── connection.py
│   │   │   └── repositories/
│   │   │       ├── __init__.py
│   │   │       ├── sqlalchemy_user_repository.py
│   │   │       └── sqlalchemy_post_repository.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── smtp_email_service.py
│   │   └── config/
│   │       ├── __init__.py
│   │       └── settings.py
│   └── presentation/           # API layer
│       ├── __init__.py
│       ├── api/
│       │   ├── __init__.py
│       │   ├── v1/
│       │   │   ├── __init__.py
│       │   │   ├── endpoints/
│       │   │   │   ├── users.py
│       │   │   │   └── posts.py
│       │   │   └── dependencies.py
│       │   └── router.py
│       ├── schemas/
│       │   ├── __init__.py
│       │   ├── user_schema.py
│       │   └── post_schema.py
│       └── main.py              # FastAPI app
├── tests/
│   ├── domain/
│   ├── application/
│   ├── infrastructure/
│   └── presentation/
├── alembic/
└── requirements.txt
```

## Layer Responsibilities

### Domain Layer (Core)
- **Entities**: Business objects with identity and lifecycle.
- **Value Objects**: Immutable objects without identity.
- **Repository Interfaces**: Abstract data access (no implementation).
- **Domain Exceptions**: Business rule violations.
- **NO DEPENDENCIES**: This layer has zero external dependencies.

### Application Layer (Use Cases)
- **Use Cases**: Application-specific business rules.
- **DTOs**: Data transfer objects for use case boundaries.
- **Service Interfaces**: Abstract external services.
- **Orchestration**: Coordinates domain objects and repositories.

### Infrastructure Layer (Details)
- **Database**: SQLAlchemy models and repository implementations.
- **External Services**: Email, SMS, payment gateway implementations.
- **Configuration**: Settings and environment variables.

### Presentation Layer (API)
- **FastAPI Routes**: HTTP request handlers.
- **Pydantic Schemas**: Request/response validation.
- **Dependencies**: FastAPI dependency injection.

## Example: Domain Entity
```python
# src/domain/entities/user.py
from dataclasses import dataclass
from datetime import datetime
from ..value_objects.email import Email

@dataclass
class User:
    id: int | None
    email: Email
    hashed_password: str
    full_name: str
    is_active: bool = True
    created_at: datetime | None = None
    
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
# src/domain/value_objects/email.py
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
    
    def __str__(self) -> str:
        return self.value
```

## Example: Repository Interface
```python
# src/domain/repositories/user_repository.py
from typing import Protocol
from ..entities.user import User

class UserRepositoryProtocol(Protocol):
    async def get_by_id(self, user_id: int) -> User | None: ...
    async def get_by_email(self, email: str) -> User | None: ...
    async def save(self, user: User) -> User: ...
    async def delete(self, user_id: int) -> None: ...
```

## Example: Use Case
```python
# src/application/use_cases/users/create_user.py
from dataclasses import dataclass
from src.domain.entities.user import User
from src.domain.value_objects.email import Email
from src.domain.repositories.user_repository import UserRepositoryProtocol
from src.application.dto.user_dto import UserCreateDto, UserDto

@dataclass
class CreateUserUseCase:
    user_repository: UserRepositoryProtocol
    
    async def execute(self, data: UserCreateDto) -> UserDto:
        # Validate business rules
        email = Email(data.email)
        
        existing_user = await self.user_repository.get_by_email(str(email))
        if existing_user:
            raise ValueError(f"User with email {email} already exists")
        
        # Create domain entity
        user = User(
            id=None,
            email=email,
            hashed_password=data.hashed_password,
            full_name=data.full_name
        )
        
        # Persist
        saved_user = await self.user_repository.save(user)
        
        # Return DTO
        return UserDto.from_entity(saved_user)
```

## Example: Repository Implementation
```python
# src/infrastructure/database/repositories/sqlalchemy_user_repository.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.domain.entities.user import User
from src.domain.value_objects.email import Email
from ..models import UserModel

class SQLAlchemyUserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_by_id(self, user_id: int) -> User | None:
        result = await self.db.execute(
            select(UserModel).where(UserModel.id == user_id)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None
    
    async def save(self, user: User) -> User:
        async with self.db.begin():
            if user.id:
                model = await self.db.get(UserModel, user.id)
            else:
                model = UserModel()
            
            model.email = str(user.email)
            model.hashed_password = user.hashed_password
            model.full_name = user.full_name
            model.is_active = user.is_active
            
            self.db.add(model)
            await self.db.flush()
            await self.db.refresh(model)
            
            return self._to_entity(model)
    
    def _to_entity(self, model: UserModel) -> User:
        return User(
            id=model.id,
            email=Email(model.email),
            hashed_password=model.hashed_password,
            full_name=model.full_name,
            is_active=model.is_active,
            created_at=model.created_at
        )
```

## Example: FastAPI Endpoint
```python
# src/presentation/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from src.application.use_cases.users.create_user import CreateUserUseCase
from src.application.dto.user_dto import UserCreateDto
from src.presentation.schemas.user_schema import UserCreateRequest, UserResponse
from ..dependencies import get_create_user_use_case

router = APIRouter()

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    request: UserCreateRequest,
    use_case: CreateUserUseCase = Depends(get_create_user_use_case)
):
    dto = UserCreateDto(
        email=request.email,
        hashed_password=hash_password(request.password),
        full_name=request.full_name
    )
    
    try:
        user_dto = await use_case.execute(dto)
        return UserResponse.from_dto(user_dto)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

## Rules
- **Dependency Rule**: Dependencies point inward. Domain has no dependencies.
- **Domain Independence**: Domain layer is pure Python, no framework imports.
- **Use Cases**: All business logic flows through use cases.
- **Mapping**: Map between layers (Entity ↔ DTO ↔ Schema ↔ Model).
- **Interfaces**: Define interfaces in inner layers, implement in outer layers.

## When to Use
- Large, complex FastAPI projects
- Long-term projects requiring maintainability
- Projects with complex business rules
- Need for framework independence
- Teams experienced with Clean Architecture

