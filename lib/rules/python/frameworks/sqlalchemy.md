# SQLAlchemy ORM

> **Scope**: Python SQL toolkit and ORM  
> **Applies to**: Python files using SQLAlchemy
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use DeclarativeBase for models
> **ALWAYS**: Use `select()` for queries (2.0 style)
> **ALWAYS**: Use eager loading to avoid N+1
> **ALWAYS**: Define relationships with back_populates
> **ALWAYS**: Use async session for async apps
> 
> **NEVER**: Use old Query API (deprecated)
> **NEVER**: Skip eager loading
> **NEVER**: Forget to close sessions
> **NEVER**: Use string column names
> **NEVER**: Skip migration management

## Core Patterns

### Model Definition

```python
from sqlalchemy.orm import DeclarativeBase, relationship
from sqlalchemy import Column, Integer, String, ForeignKey

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    email = Column(String(120), unique=True, nullable=False, index=True)
    full_name = Column(String(100), nullable=False)
    
    posts = relationship('Post', back_populates='author', cascade='all, delete-orphan')

class Post(Base):
    __tablename__ = 'posts'
    
    id = Column(Integer, primary_key=True)
    title = Column(String(200), nullable=False)
    author_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    author = relationship('User', back_populates='posts')
```

### CRUD Operations (2.0 Style)

```python
from sqlalchemy import select

# Create
async def create_user(session, email: str, name: str) -> User:
    user = User(email=email, full_name=name)
    session.add(user)
    await session.commit()
    return user

# Read
async def get_user(session, user_id: int) -> Optional[User]:
    result = await session.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()

# Update
async def update_user(session, user_id: int, name: str):
    user = await session.get(User, user_id)
    user.full_name = name
    await session.commit()

// Delete
async def delete_user(session, user_id: int):
    user = await session.get(User, user_id)
    await session.delete(user)
    await session.commit()
```

### Eager Loading (Avoid N+1)

```python
# ❌ WRONG: N+1 queries
users = (await session.execute(select(User))).scalars().all()
for user in users:
    print(user.posts)  # Lazy load per user!

// ✅ CORRECT: Single query with joinedload
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.posts))
users = (await session.execute(stmt)).scalars().all()
```

### Session Management

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Old Query API** | `session.query(User)` | `select(User)` |
| **N+1** | Lazy load in loop | `selectinload()` |
| **String Columns** | `where("email = x")` | `where(User.email == x)` |
| **No Close** | Missing close | `async with session:` |

## AI Self-Check

- [ ] DeclarativeBase?
- [ ] select() for queries?
- [ ] Eager loading?
- [ ] Relationships with back_populates?
- [ ] Async session?
- [ ] No old Query API?
- [ ] No N+1 queries?
- [ ] Session closed?
- [ ] Model attributes not strings?

## Key Features

| Feature | Purpose |
|---------|---------|
| DeclarativeBase | Model definition |
| select() | 2.0 style queries |
| selectinload() | Eager loading |
| relationship() | Relations |
| AsyncSessionLocal | Session management |

## Best Practices

**MUST**: DeclarativeBase, select(), eager loading, relationships, async session
**SHOULD**: Indexes, migrations (Alembic), cascade, connection pooling
**AVOID**: Old Query API, N+1, string columns, unclosed sessions
