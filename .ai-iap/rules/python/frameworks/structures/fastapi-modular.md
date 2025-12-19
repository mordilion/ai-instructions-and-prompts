# FastAPI Modular Structure

> **Scope**: This structure extends the FastAPI framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app instance
│   ├── config.py               # Settings
│   ├── database.py             # DB connection
│   ├── users/                  # User domain module
│   │   ├── __init__.py
│   │   ├── router.py           # API routes
│   │   ├── schemas.py          # Pydantic models
│   │   ├── models.py           # SQLAlchemy models
│   │   ├── services.py         # Business logic
│   │   ├── dependencies.py     # FastAPI dependencies
│   │   └── exceptions.py       # Custom exceptions
│   ├── posts/                  # Posts domain module
│   │   ├── router.py
│   │   ├── schemas.py
│   │   ├── models.py
│   │   ├── services.py
│   │   └── dependencies.py
│   ├── orders/
│   │   └── ...
│   ├── core/                   # Shared utilities
│   │   ├── __init__.py
│   │   ├── security.py         # Auth utilities
│   │   ├── exceptions.py       # Base exceptions
│   │   └── dependencies.py     # Shared dependencies
│   └── tests/
│       ├── users/
│       ├── posts/
│       └── conftest.py
├── alembic/                    # Database migrations
│   ├── versions/
│   └── env.py
├── .env
├── requirements.txt
└── pyproject.toml
```

## Module Structure (users/)
```
users/
├── __init__.py
├── router.py                   # FastAPI routes
├── schemas.py                  # Pydantic request/response models
├── models.py                   # SQLAlchemy ORM models
├── services.py                 # Business logic
├── dependencies.py             # Module-specific dependencies
└── exceptions.py               # Module-specific exceptions
```

## Example: Router
```python
# app/users/router.py
from fastapi import APIRouter, Depends, HTTPException
from .schemas import UserCreate, UserResponse, UserList
from .services import UserService
from .dependencies import get_user_service

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends(get_user_service)
) -> UserResponse:
    return await service.create_user(user_data)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    service: UserService = Depends(get_user_service)
) -> UserResponse:
    user = await service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

## Example: Schemas
```python
# app/users/schemas.py
from pydantic import BaseModel, EmailStr, Field, ConfigDict

class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(..., min_length=1, max_length=100)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    id: int
    is_active: bool
    
    model_config = ConfigDict(from_attributes=True)

class UserList(BaseModel):
    users: list[UserResponse]
    total: int
```

## Example: Service
```python
# app/users/services.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from .models import User
from .schemas import UserCreate
from .exceptions import UserNotFoundException

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_user(self, user_data: UserCreate) -> User:
        async with self.db.begin():
            user = User(**user_data.model_dump(exclude={'password'}))
            user.set_password(user_data.password)
            self.db.add(user)
            await self.db.flush()
            await self.db.refresh(user)
            return user
    
    async def get_user(self, user_id: int) -> User | None:
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
```

## Example: Dependencies
```python
# app/users/dependencies.py
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from .services import UserService

def get_user_service(db: AsyncSession = Depends(get_db)) -> UserService:
    return UserService(db)
```

## Example: Main App
```python
# app/main.py
from fastapi import FastAPI
from .users.router import router as users_router
from .posts.router import router as posts_router
from .config import settings

app = FastAPI(title=settings.app_name, version="1.0.0")

app.include_router(users_router)
app.include_router(posts_router)

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

## Rules
- **One Module = One Domain**: Each module represents a domain (users, posts, orders).
- **Self-Contained**: Each module has its own routes, schemas, models, services.
- **Shared Code**: Common utilities in `core/`.
- **Explicit Dependencies**: Use FastAPI's dependency injection.
- **Async All The Way**: All I/O operations must be async.

## When to Use
- Small to medium FastAPI projects
- Clear domain boundaries
- Standard REST API structure
- Teams familiar with FastAPI patterns

