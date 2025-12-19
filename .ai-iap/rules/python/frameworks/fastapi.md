# FastAPI Framework

> **Scope**: Apply these rules when working with FastAPI applications.

## 1. Route Handlers
- **Async by Default**: Use `async def` for all endpoints.
- **Dependency Injection**: Use `Depends()` for shared logic.
- **Path Operations**: Use decorators (`@app.get`, `@app.post`).
- **Thin Handlers**: Validate, delegate to services, return response.

```python
# ✅ Good - Async with dependency injection
from fastapi import APIRouter, Depends, HTTPException
from .schemas import UserCreate, UserResponse
from .services import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    user_service: UserService = Depends()
) -> UserResponse:
    return await user_service.create_user(user_data)

# ❌ Bad - Business logic in route
@router.post("/")
async def create_user(user_data: UserCreate):
    user = User(**user_data.dict())
    db.add(user)
    await db.commit()
    send_email(user.email)
    return user
```

## 2. Pydantic Models (Schemas)
- **Request/Response Models**: Separate models for input/output.
- **Validation**: Use Pydantic validators for complex validation.
- **Config**: Use `ConfigDict` for ORM mode and other settings.
- **Field Descriptions**: Add descriptions for API docs.

```python
from pydantic import BaseModel, EmailStr, Field, field_validator

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str = Field(..., min_length=1, max_length=100)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        return v

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    
    model_config = ConfigDict(from_attributes=True)
```

## 3. Dependency Injection
- **Reusable Dependencies**: Extract common logic to dependencies.
- **Database Sessions**: Inject DB sessions via dependencies.
- **Authentication**: Use dependencies for auth checks.
- **Services**: Inject service instances.

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from .database import get_db

# Database dependency
async def get_db() -> AsyncSession:
    async with async_session() as session:
        yield session

# Service dependency
def get_user_service(db: AsyncSession = Depends(get_db)) -> UserService:
    return UserService(db)

# Auth dependency
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    user = await verify_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user
```

## 4. Service Layer
- **Async Services**: Use `async def` for service methods.
- **Business Logic**: All business logic in services.
- **Transactions**: Use async context managers for transactions.

```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_user(self, user_data: UserCreate) -> User:
        async with self.db.begin():
            user = User(**user_data.model_dump())
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

## 5. Exception Handling
- **Custom Exceptions**: Create domain-specific exceptions.
- **Exception Handlers**: Register global exception handlers.
- **HTTPException**: Use for API errors with status codes.

```python
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

class UserNotFoundException(Exception):
    def __init__(self, user_id: int):
        self.user_id = user_id

@app.exception_handler(UserNotFoundException)
async def user_not_found_handler(request: Request, exc: UserNotFoundException):
    return JSONResponse(
        status_code=404,
        content={"detail": f"User {exc.user_id} not found"}
    )

# In service
async def get_user(self, user_id: int) -> User:
    user = await self._find_user(user_id)
    if not user:
        raise UserNotFoundException(user_id)
    return user
```

## 6. Background Tasks
- **Background Jobs**: Use `BackgroundTasks` for async operations.
- **Celery**: For complex/scheduled tasks, use Celery.
- **Don't Block**: Never block the event loop.

```python
from fastapi import BackgroundTasks

async def send_welcome_email(email: str):
    # Send email asynchronously
    await email_service.send(email, "Welcome!")

@router.post("/users/")
async def create_user(
    user_data: UserCreate,
    background_tasks: BackgroundTasks,
    user_service: UserService = Depends()
):
    user = await user_service.create_user(user_data)
    background_tasks.add_task(send_welcome_email, user.email)
    return user
```

## 7. Database (SQLAlchemy Async)
- **Async Engine**: Use `create_async_engine`.
- **Async Sessions**: Use `AsyncSession`.
- **Relationships**: Define relationships with `relationship()`.
- **Migrations**: Use Alembic for database migrations.

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost/db",
    echo=True
)

async_session = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db() -> AsyncSession:
    async with async_session() as session:
        yield session
```

## 8. Routers
- **APIRouter**: Group related endpoints.
- **Prefixes**: Use prefixes for route organization.
- **Tags**: Add tags for OpenAPI grouping.
- **Include Routers**: Include routers in main app.

```python
# app/users/router.py
from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/")
async def list_users(): ...

@router.post("/")
async def create_user(): ...

# app/main.py
from fastapi import FastAPI
from .users.router import router as users_router

app = FastAPI()
app.include_router(users_router)
```

## 9. Configuration
- **Settings**: Use Pydantic `BaseSettings` for config.
- **Environment Variables**: Load from `.env` file.
- **Validation**: Pydantic validates settings on startup.

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    
    model_config = ConfigDict(env_file=".env")

settings = Settings()
```

## 10. Testing
- **TestClient**: Use FastAPI's `TestClient` for integration tests.
- **Async Tests**: Use `pytest-asyncio` for async tests.
- **Fixtures**: Use pytest fixtures for DB setup.
- **Override Dependencies**: Override dependencies in tests.

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_user():
    response = client.post("/users/", json={
        "email": "test@example.com",
        "password": "Secure123",
        "full_name": "Test User"
    })
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"
```

## 11. Anti-Patterns (MUST avoid)
- **Blocking Code**: NEVER use blocking I/O in async functions.
  - ❌ Bad: `time.sleep(1)` in async function
  - ✅ Good: `await asyncio.sleep(1)`
- **Sync DB Calls**: Use async database drivers (asyncpg, aiomysql).
- **Missing Type Hints**: Always use type hints for FastAPI to work properly.
- **Direct Model Returns**: Return Pydantic schemas, not ORM models directly.

