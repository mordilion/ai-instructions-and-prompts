# FastAPI Layered Structure

> **Scope**: This structure extends the FastAPI framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Settings
│   ├── database.py             # DB setup
│   ├── api/                    # Presentation layer
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── endpoints/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── users.py
│   │   │   │   ├── posts.py
│   │   │   │   └── auth.py
│   │   │   └── dependencies.py
│   │   └── router.py
│   ├── schemas/                # Pydantic models (DTOs)
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── post.py
│   │   └── auth.py
│   ├── models/                 # SQLAlchemy models (Data layer)
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── post.py
│   │   └── base.py
│   ├── services/               # Business logic layer
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   ├── post_service.py
│   │   └── auth_service.py
│   ├── repositories/           # Data access layer
│   │   ├── __init__.py
│   │   ├── user_repository.py
│   │   ├── post_repository.py
│   │   └── base_repository.py
│   ├── core/                   # Core utilities
│   │   ├── __init__.py
│   │   ├── security.py
│   │   ├── exceptions.py
│   │   └── middleware.py
│   └── tests/
│       ├── api/
│       ├── services/
│       └── repositories/
├── alembic/
├── .env
└── requirements.txt
```

## Layer Responsibilities

### API Layer (Presentation)
- HTTP request/response handling
- Input validation (Pydantic)
- Route definitions
- Dependency injection setup

### Schemas Layer (DTOs)
- Request/response models
- Data validation
- Serialization/deserialization

### Services Layer (Business Logic)
- Business rules and workflows
- Orchestration of repositories
- Transaction management

### Repositories Layer (Data Access)
- Database queries
- ORM operations
- Data persistence

### Models Layer (Data)
- SQLAlchemy ORM models
- Database schema definitions

## Example: Endpoint
```python
# app/api/v1/endpoints/users.py
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService
from app.api.v1.dependencies import get_user_service

router = APIRouter()

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends(get_user_service)
):
    return await service.create_user(user_data)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    service: UserService = Depends(get_user_service)
):
    user = await service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

## Example: Service
```python
# app/services/user_service.py
from app.schemas.user import UserCreate
from app.models.user import User
from app.repositories.user_repository import UserRepository

class UserService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo
    
    async def create_user(self, user_data: UserCreate) -> User:
        # Business logic here
        if await self.user_repo.get_by_email(user_data.email):
            raise ValueError("Email already exists")
        
        user = User(**user_data.model_dump(exclude={'password'}))
        user.set_password(user_data.password)
        return await self.user_repo.create(user)
    
    async def get_user(self, user_id: int) -> User | None:
        return await self.user_repo.get_by_id(user_id)
```

## Example: Repository
```python
# app/repositories/user_repository.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user import User

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create(self, user: User) -> User:
        async with self.db.begin():
            self.db.add(user)
            await self.db.flush()
            await self.db.refresh(user)
            return user
    
    async def get_by_id(self, user_id: int) -> User | None:
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_by_email(self, email: str) -> User | None:
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
```

## Example: Router Setup
```python
# app/api/v1/router.py
from fastapi import APIRouter
from .endpoints import users, posts, auth

api_router = APIRouter()

api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(posts.router, prefix="/posts", tags=["posts"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])

# app/main.py
from fastapi import FastAPI
from app.api.v1.router import api_router

app = FastAPI()
app.include_router(api_router, prefix="/api/v1")
```

## Rules
- **Clear Layer Separation**: Each layer has distinct responsibility.
- **Dependency Flow**: API → Services → Repositories → Models.
- **No Layer Skipping**: API calls Services, Services call Repositories.
- **Shared Schemas**: Use Pydantic schemas for data transfer between layers.
- **Repository Pattern**: All database access through repositories.

## When to Use
- Medium to large FastAPI projects
- Need for clear separation of concerns
- Multiple developers working on different layers
- Complex business logic requiring service layer
- Projects requiring high testability

