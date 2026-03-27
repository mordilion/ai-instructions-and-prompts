# FastAPI Layered Structure

> **Scope**: Layered architecture for FastAPI  
> **Use When**: Medium-large apps, clear separation of concerns

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate api, schemas, models, services, repositories
> **ALWAYS**: API layer depends on services only
> **ALWAYS**: Services depend on repositories only
> **ALWAYS**: Use Pydantic schemas for API contracts
> 
> **NEVER**: Access database from API layer
> **NEVER**: Skip repository layer
> **NEVER**: Mix business logic in API/repository

## Structure

```
app/
├── main.py                 # FastAPI app
├── config.py              # Settings
├── database.py            # DB setup
├── api/v1/endpoints/      # Presentation layer
│   ├── users.py
│   └── posts.py
├── schemas/               # Pydantic DTOs
│   ├── user.py
│   └── post.py
├── models/                # SQLAlchemy models
│   ├── user.py
│   └── post.py
├── services/              # Business logic
│   ├── user_service.py
│   └── post_service.py
└── repositories/          # Data access
    ├── user_repository.py
    └── post_repository.py
```

## Core Patterns

### API Endpoint

```python
from fastapi import APIRouter, Depends
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService

router = APIRouter()

@router.post("", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    service: UserService = Depends()
) -> UserResponse:
    return await service.create_user(user_data)
```

### Service Layer

```python
class UserService:
    def __init__(self, repository: UserRepository = Depends()):
        self.repository = repository
    
    async def create_user(self, data: UserCreate) -> UserResponse:
        # Business logic
        if await self.repository.get_by_email(data.email):
            raise UserExistsError()
        user = await self.repository.create(data)
        return UserResponse.from_orm(user)
```

### Repository Layer

```python
class UserRepository:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db
    
    async def create(self, data: UserCreate) -> User:
        user = User(**data.dict())
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user
    
    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct DB Access** | DB query in API | Repository |
| **No Repository** | Service accesses DB | Repository layer |
| **Business Logic** | In API/repository | In service |
| **Circular Deps** | Layer violations | Strict layering |

## AI Self-Check

- [ ] Separate api, services, repositories?
- [ ] API depends on services only?
- [ ] Services depend on repositories?
- [ ] Pydantic schemas?
- [ ] No DB access from API?
- [ ] Business logic in services?
- [ ] Data access in repositories?
- [ ] No circular dependencies?

## Benefits

- ✅ Clear separation of concerns
- ✅ Easy testing (mock layers)
- ✅ Maintainable
- ✅ Scalable

## When to Use

- ✅ Medium-large apps
- ✅ Clear layer boundaries
- ✅ Team structure aligns
- ❌ Simple CRUD apps
