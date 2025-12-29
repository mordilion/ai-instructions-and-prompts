# SQLAlchemy ORM

> **Scope**: Python SQL toolkit and ORM
> **Applies to**: Python files using SQLAlchemy
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use DeclarativeBase for model definitions
> **ALWAYS**: Use `select()` for queries (SQLAlchemy 2.0 style)
> **ALWAYS**: Use eager loading to avoid N+1 queries
> **ALWAYS**: Define relationships with `relationship()` and `back_populates`
> **ALWAYS**: Use async session for async applications
> 
> **NEVER**: Use old Query API (deprecated in 2.0)
> **NEVER**: Skip eager loading for related objects
> **NEVER**: Forget to close sessions
> **NEVER**: Use string column names (use model attributes)
> **NEVER**: Skip migration management

## Core Patterns

### Models (Declarative)

```python
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship, DeclarativeBase
from datetime import datetime

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'
    
    id: int = Column(Integer, primary_key=True)
    email: str = Column(String(120), unique=True, nullable=False, index=True)
    full_name: str = Column(String(100), nullable=False)
    is_active: bool = Column(Boolean, default=True)
    created_at: datetime = Column(DateTime, default=datetime.utcnow)
    
    posts = relationship('Post', back_populates='author', cascade='all, delete-orphan')
```

### Relationships

```python
class Post(Base):
    __tablename__ = 'posts'
    
    id: int = Column(Integer, primary_key=True)
    title: str = Column(String(200), nullable=False)
    content: str = Column(String, nullable=False)
    author_id: int = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    author = relationship('User', back_populates='posts')
    comments = relationship('Comment', back_populates='post', lazy='selectin')
```

### Queries (SQLAlchemy 2.0 Style)

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

# Basic query
stmt = select(User).where(User.is_active == True)
users = session.execute(stmt).scalars().all()

# With eager loading (avoid N+1)
stmt = select(User).options(selectinload(User.posts)).where(User.id == user_id)
user = session.execute(stmt).scalar_one()

# Joins
stmt = select(User).join(Post).where(Post.title.like('%Python%'))
users = session.execute(stmt).scalars().all()
```

### Session Management

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

engine = create_engine("postgresql://user:pass@localhost/db")
SessionLocal = sessionmaker(bind=engine)

# Context manager
def get_users():
    with SessionLocal() as session:
        stmt = select(User)
        return session.execute(stmt).scalars().all()
```

### Async Support

```python
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker

async_engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")
AsyncSessionLocal = async_sessionmaker(async_engine)

async def get_users():
    async with AsyncSessionLocal() as session:
        stmt = select(User)
        result = await session.execute(stmt)
        return result.scalars().all()
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Old Query API** | `session.query(User)` | `select(User)` | Deprecated in 2.0 |
| **N+1 Queries** | Loop with lazy load | `selectinload()` | Performance |
| **String Columns** | `filter_by(name="John")` | `where(User.name == "John")` | Type safety |
| **No Session Close** | Open session | Context manager | Resource leak |

### Anti-Pattern: N+1 Queries (PERFORMANCE DISASTER)

```python
# ❌ WRONG: N+1 queries
users = session.execute(select(User)).scalars().all()
for user in users:
    print(user.posts)  # Separate query for EACH user!

# ✅ CORRECT: Eager loading
stmt = select(User).options(selectinload(User.posts))
users = session.execute(stmt).scalars().all()
for user in users:
    print(user.posts)  # Already loaded
```

## AI Self-Check (Verify BEFORE generating SQLAlchemy code)

- [ ] Using DeclarativeBase?
- [ ] select() for queries (not old Query API)?
- [ ] Eager loading with selectinload/joinedload?
- [ ] Relationships with back_populates?
- [ ] Session management (context manager)?
- [ ] Type hints on columns?
- [ ] Explicit __tablename__?
- [ ] Cascade options defined?
- [ ] Indexes on frequently queried columns?
- [ ] Migration strategy (Alembic)?

## Key Features

| Feature | Purpose | Keywords |
|---------|---------|----------|
| **DeclarativeBase** | Model definition | Modern, type-safe |
| **select()** | Queries | SQLAlchemy 2.0 style |
| **Eager Loading** | Avoid N+1 | `selectinload`, `joinedload` |
| **Relationships** | Associations | `relationship()`, `back_populates` |
| **Async** | Async I/O | `async_sessionmaker` |
| **Alembic** | Migrations | Version control for schema |

## Best Practices

**MUST**:
- DeclarativeBase
- select() queries
- Eager loading
- Session context managers
- back_populates

**SHOULD**:
- Async for async apps
- Alembic for migrations
- Type hints
- Indexes
- Cascade options

**AVOID**:
- Old Query API
- N+1 queries
- String column names
- Unclosed sessions
- Lazy loading in loops
