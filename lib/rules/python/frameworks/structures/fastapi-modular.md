# FastAPI Modular Structure

> **Scope**: Feature-first modular structure for FastAPI  
> **Use When**: Medium-large apps, domain-driven design

## CRITICAL REQUIREMENTS

> **ALWAYS**: Organize by feature/domain module
> **ALWAYS**: Each module is self-contained
> **ALWAYS**: Minimize cross-module dependencies
> **ALWAYS**: Use routers for module APIs
> 
> **NEVER**: Share implementation details between modules
> **NEVER**: Create circular dependencies

## Structure

```
app/
├── main.py                 # FastAPI app
├── config.py               # Settings
├── database.py             # DB setup
├── users/                  # User module (self-contained)
│   ├── router.py           # API routes
│   ├── schemas.py          # Pydantic models
│   ├── models.py           # SQLAlchemy models
│   ├── services.py         # Business logic
│   ├── dependencies.py     # DI
│   └── exceptions.py       # Custom exceptions
├── posts/                  # Posts module
│   ├── router.py
│   ├── schemas.py
│   └── services.py
└── core/                   # Shared utilities only
    ├── security.py
    ├── exceptions.py
    └── dependencies.py
```

## Core Patterns

### Module Organization

```python
# users/router.py
from fastapi import APIRouter, Depends
from .schemas import UserCreate, UserResponse
from .services import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.post("", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends()
) -> UserResponse:
    return await service.create_user(user_data)

# main.py
from users.router import router as users_router
from posts.router import router as posts_router

app.include_router(users_router)
app.include_router(posts_router)
```

### Cross-Module Communication

```python
# users/public_api.py - Interface for other modules
class UserPublicApi:
    async def get_user(self, user_id: int) -> Optional[UserResponse]:
        pass

# posts/services.py - Uses user module via interface
class PostService:
    def __init__(self, user_api: UserPublicApi = Depends()):
        self.user_api = user_api
    
    async def create_post(self, user_id: int, title: str):
        user = await self.user_api.get_user(user_id)
        if not user:
            raise UserNotFoundError()
        return await self.repository.create(user_id, title)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Circular Deps** | user → post → user | Use interfaces |
| **Shared Implementation** | Direct service access | Public API |
| **Module Coupling** | Access internal classes | Public API only |
| **Core Bloat** | Everything in core/ | Only shared code |

## AI Self-Check

- [ ] Organized by feature?
- [ ] Each module self-contained?
- [ ] Public API for cross-module?
- [ ] No circular dependencies?
- [ ] Core/ has only shared utilities?
- [ ] Tests mirror module structure?
- [ ] Routers for module APIs?
- [ ] Clear module boundaries?

## Benefits

- ✅ High cohesion, low coupling
- ✅ Easy to understand scope
- ✅ Parallel development
- ✅ Easy to extract microservices

## When to Use

- ✅ Medium-large apps
- ✅ Clear business domains
- ✅ Multiple teams
- ❌ Simple CRUD apps
