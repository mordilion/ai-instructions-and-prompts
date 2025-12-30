# FastAPI Framework

> **Scope**: FastAPI applications  
> **Applies to**: Python files in FastAPI projects
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Pydantic models for validation
> **ALWAYS**: Use async def for I/O operations
> **ALWAYS**: Use DI for shared resources (Depends)
> **ALWAYS**: Use HTTPException for errors
> **ALWAYS**: Type hint all parameters
> 
> **NEVER**: Use sync functions for I/O
> **NEVER**: Use global state
> **NEVER**: Skip Pydantic validation
> **NEVER**: Return dict without Pydantic model
> **NEVER**: Use mutable default arguments

## Core Patterns

### Async Endpoint with Pydantic

```python
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr, Field

app = FastAPI()

class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)

class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr

@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate) -> UserResponse:
    # Auto-validates, 422 on error
    created = await db.create_user(user)
    return UserResponse(**created)
```

### Dependency Injection

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncSession:
    async with SessionLocal() as session:
        yield session

@app.get("/users/{user_id}")
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### APIRouter

```python
# routers/users.py
from fastapi import APIRouter

router = APIRouter(prefix="/users", tags=["users"])

@router.get("")
async def list_users():
    return await db.get_users()

# main.py
from routers import users
app.include_router(users.router)
```

### Error Handling

```python
@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    return JSONResponse(
        status_code=400,
        content={"message": str(exc)}
    )
```

### Background Tasks

```python
from fastapi import BackgroundTasks

def send_email(email: str, message: str):
    # Send email logic

@app.post("/users")
async def create_user(user: UserCreate, background_tasks: BackgroundTasks):
    created = await db.create_user(user)
    background_tasks.add_task(send_email, user.email, "Welcome!")
    return created
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Sync I/O** | `def get_users()` | `async def get_users()` |
| **No Validation** | `dict` return | Pydantic model |
| **Global State** | `users = []` | DI with Depends |
| **No Type Hints** | `def get(id)` | `def get(id: int) -> User` |

## AI Self-Check

- [ ] Pydantic models?
- [ ] async def for I/O?
- [ ] Depends() for DI?
- [ ] HTTPException for errors?
- [ ] Type hints?
- [ ] No sync I/O?
- [ ] No global state?
- [ ] response_model set?
- [ ] Status codes correct?

## Key Features

| Feature | Purpose |
|---------|---------|
| Pydantic | Validation |
| async/await | Non-blocking I/O |
| Depends() | DI |
| APIRouter | Route organization |
| BackgroundTasks | Async jobs |

## Best Practices

**MUST**: Pydantic, async def, Depends(), HTTPException, type hints
**SHOULD**: APIRouter, background tasks, exception handlers, middleware
**AVOID**: Sync I/O, global state, dict returns, mutable defaults
