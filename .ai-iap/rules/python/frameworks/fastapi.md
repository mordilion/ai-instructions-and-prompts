# FastAPI Framework

> **Scope**: Apply these rules when working with FastAPI applications
> **Applies to**: Python files in FastAPI projects
> **Extends**: python/architecture.md, python/code-style.md
> **Precedence**: Framework rules OVERRIDE Python rules for FastAPI-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use async/await for all I/O operations (database, external APIs)
> **ALWAYS**: Use Pydantic models for request/response validation
> **ALWAYS**: Use dependency injection with Depends() for services
> **ALWAYS**: Use type hints everywhere (FastAPI requires them)
> **ALWAYS**: Return response_model in route decorators
> 
> **NEVER**: Return ORM models directly (use Pydantic schemas)
> **NEVER**: Use sync functions for I/O (blocks event loop)
> **NEVER**: Skip type hints (FastAPI can't generate docs without them)
> **NEVER**: Put business logic in route handlers (belongs in services)
> **NEVER**: Handle exceptions in routes (use exception handlers)

## Overview
FastAPI: modern, high-performance Python web framework built on Starlette and Pydantic.
Automatic OpenAPI (Swagger) documentation, data validation, and async support out of the box.
Best for building high-performance APIs with automatic validation and documentation.

## Basic API

```python
from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr
from typing import List

app = FastAPI()

class CreateUserRequest(BaseModel):
    name: str
    email: EmailStr

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    
    class Config:
        from_attributes = True

@app.get("/users", response_model=List[UserResponse])
async def get_users():
    users = await user_service.get_all()
    return users

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    user = await user_service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(request: CreateUserRequest):
    return await user_service.create(request)

@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int):
    await user_service.delete(user_id)
```

## Dependency Injection

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session

@app.get("/users")
async def get_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User))
    return result.scalars().all()

# Dependency class
class UserService:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db
    
    async def get_all(self) -> List[User]:
        result = await self.db.execute(select(User))
        return result.scalars().all()

@app.get("/users")
async def get_users(service: UserService = Depends()):
    return await service.get_all()
```

## Models & Database (SQLAlchemy)

```python
from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
```

## Request Validation

```python
from pydantic import BaseModel, Field, validator

class CreateUserRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)
    
    @validator("name")
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError("Name cannot be blank")
        return v.strip()

# Query parameters
@app.get("/users")
async def search_users(
    query: str | None = None,
    skip: int = 0,
    limit: int = 100
):
    return await user_service.search(query, skip, limit)
```

## Exception Handling

```python
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

class UserNotFoundException(Exception):
    def __init__(self, user_id: int):
        self.user_id = user_id

@app.exception_handler(UserNotFoundException)
async def user_not_found_handler(request: Request, exc: UserNotFoundException):
    return JSONResponse(
        status_code=404,
        content={"message": f"User {exc.user_id} not found"}
    )
```

## Authentication

```python
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    user = await user_service.get_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user

@app.get("/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

## Background Tasks

```python
from fastapi import BackgroundTasks

def send_email(email: str, message: str):
    # Send email
    pass

@app.post("/users")
async def create_user(request: CreateUserRequest, background_tasks: BackgroundTasks):
    user = await user_service.create(request)
    background_tasks.add_task(send_email, request.email, "Welcome!")
    return user
```

## Middleware

```python
from fastapi.middleware.cors import CORSMiddleware
import time

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response
```

## Testing

```python
from fastapi.testclient import TestClient

client = TestClient(app)

def test_get_users():
    response = client.get("/users")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_user():
    response = client.post("/users", json={
        "name": "John",
        "email": "john@test.com"
    })
    assert response.status_code == 201
    assert response.json()["name"] == "John"
```

## Best Practices

**MUST**:
- Use Pydantic models for ALL request/response schemas
- Use `async/await` for I/O operations (database, HTTP calls, file I/O)
- Specify `response_model` on endpoints for automatic validation/docs
- Use dependency injection via `Depends()` for services, auth, database
- Use type hints everywhere - FastAPI relies on them for validation

**SHOULD**:
- Use `HTTPException` for errors (NOT raw exceptions)
- Use `BackgroundTasks` for operations that don't block response
- Use `APIRouter` to organize endpoints into modules
- Use environment variables for configuration
- Use middleware for cross-cutting concerns (CORS, auth, logging)

**AVOID**:
- Synchronous I/O in async endpoints (blocks event loop)
- Missing `response_model` (loses validation + auto docs)
- Returning dict instead of Pydantic model (loses validation)
- Business logic in endpoints (move to services)
- Not using dependency injection (makes testing hard)

## Pattern Selection

### Async vs Sync
**Use `async def` when**:
- Making database calls (with async driver)
- Making HTTP requests (httpx, aiohttp)
- Reading/writing files with async libraries
- Most modern APIs (default choice)

**Use regular `def` when**:
- CPU-bound operations (calculations, data processing)
- Using synchronous libraries (no async alternative)
- Blocking operations (FastAPI runs in thread pool)

```python
# ✅ GOOD: Async for I/O
@app.get("/users")
async def get_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User))  # Async database call
    return result.scalars().all()

# ❌ BAD: Sync call in async function (blocks event loop)
@app.get("/users")
async def get_users():
    time.sleep(5)  # Blocks entire event loop!
    return []

# ✅ GOOD: Sync for CPU-bound work
@app.post("/process")
def process_data(data: ProcessRequest):
    result = heavy_computation(data)  # CPU-bound, runs in thread pool
    return result
```

## Common Patterns

### Dependency Injection
```python
# Database dependency
async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session  # Cleanup after request

# Service dependency
class UserService:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db
    
    async def get_user(self, user_id: int) -> User:
        result = await self.db.execute(select(User).where(User.id == user_id))
        return result.scalar_one()

# Use in endpoint
@app.get("/users/{user_id}")
async def get_user(
    user_id: int,
    service: UserService = Depends()  # Injected automatically
):
    return await service.get_user(user_id)
```

### Error Handling
```python
# Custom exceptions
class UserNotFoundError(Exception):
    pass

# Global exception handler
@app.exception_handler(UserNotFoundError)
async def user_not_found_handler(request: Request, exc: UserNotFoundError):
    return JSONResponse(
        status_code=404,
        content={"message": str(exc)}
    )

# In endpoint
@app.get("/users/{user_id}")
async def get_user(user_id: int, service: UserService = Depends()):
    user = await service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")  # Standard way
    return user
```
