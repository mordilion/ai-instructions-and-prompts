# SQLAlchemy ORM

> **Scope**: Apply these rules when using SQLAlchemy (with Django, FastAPI, Flask, or standalone).

## 1. Models (Declarative)
- **Declarative Base**: Use declarative base for model definitions.
- **Table Names**: Explicit `__tablename__` in lowercase with underscores.
- **Type Hints**: Use type hints for columns.
- **Relationships**: Define relationships with `relationship()`.

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

## 2. Relationships
- **Back Populates**: Use `back_populates` for bidirectional relationships.
- **Lazy Loading**: Choose appropriate lazy loading strategy (`select`, `joined`, `subquery`).
- **Cascade**: Define cascade behavior for related objects.

```python
class Post(Base):
    __tablename__ = 'posts'
    
    id: int = Column(Integer, primary_key=True)
    title: str = Column(String(200), nullable=False)
    content: str = Column(String, nullable=False)
    author_id: int = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    author = relationship('User', back_populates='posts')
    comments = relationship('Comment', back_populates='post', lazy='dynamic')
```

## 3. Queries
- **Query API**: Use `select()` for queries (SQLAlchemy 2.0 style).
- **Filters**: Use `where()` for filtering.
- **Joins**: Explicit joins with `join()`.
- **Eager Loading**: Use `selectinload()` or `joinedload()` to avoid N+1.

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

# Basic query
stmt = select(User).where(User.is_active == True)
users = session.execute(stmt).scalars().all()

# With relationship loading
stmt = select(User).options(selectinload(User.posts)).where(User.id == user_id)
user = session.execute(stmt).scalar_one_or_none()

# Join query
stmt = select(Post).join(User).where(User.email == 'test@example.com')
posts = session.execute(stmt).scalars().all()
```

## 4. Sessions
- **Session Management**: Use context managers for sessions.
- **Transactions**: Commit or rollback explicitly.
- **Async Sessions**: Use `AsyncSession` for async applications.

```python
# Sync session
from sqlalchemy.orm import Session

def create_user(db: Session, email: str, full_name: str) -> User:
    user = User(email=email, full_name=full_name)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

# Async session
from sqlalchemy.ext.asyncio import AsyncSession

async def create_user_async(db: AsyncSession, email: str, full_name: str) -> User:
    async with db.begin():
        user = User(email=email, full_name=full_name)
        db.add(user)
        await db.flush()
        await db.refresh(user)
        return user
```

## 5. Migrations (Alembic)
- **Version Control**: Use Alembic for database migrations.
- **Auto-Generate**: Use autogenerate for initial migrations.
- **Review**: Always review generated migrations.
- **Naming**: Use descriptive names for migration files.

```bash
# Initialize Alembic
alembic init alembic

# Create migration
alembic revision --autogenerate -m "Add users table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## 6. Indexes
- **Performance**: Add indexes on frequently queried columns.
- **Composite Indexes**: For multi-column queries.
- **Unique Indexes**: For unique constraints.

```python
class User(Base):
    __tablename__ = 'users'
    
    id: int = Column(Integer, primary_key=True)
    email: str = Column(String(120), unique=True, nullable=False, index=True)
    last_name: str = Column(String(50), index=True)
    first_name: str = Column(String(50))
    
    __table_args__ = (
        Index('idx_full_name', 'last_name', 'first_name'),
    )
```

## 7. Async SQLAlchemy
- **Async Engine**: Use `create_async_engine` for async apps.
- **Async Session**: Use `AsyncSession` for database operations.
- **Await**: All database operations must be awaited.

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

## 8. Repository Pattern
- **Data Access Layer**: Encapsulate database operations in repositories.
- **Reusable Queries**: Define common queries in repository methods.
- **Testability**: Easier to mock for testing.

```python
from sqlalchemy.orm import Session
from sqlalchemy import select

class UserRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, user_id: int) -> User | None:
        return self.db.get(User, user_id)
    
    def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        return self.db.execute(stmt).scalar_one_or_none()
    
    def create(self, user: User) -> User:
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_active_users(self) -> list[User]:
        stmt = select(User).where(User.is_active == True)
        return list(self.db.execute(stmt).scalars().all())
```

## 9. Best Practices
- **Eager Loading**: Use `selectinload()` or `joinedload()` to prevent N+1 queries.
- **Bulk Operations**: Use `bulk_insert_mappings()` for large inserts.
- **Connection Pooling**: Configure pool size for production.
- **Query Optimization**: Use `explain()` to analyze query performance.

```python
# Eager loading to prevent N+1
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.posts))
users = session.execute(stmt).scalars().all()

# Bulk insert
users_data = [
    {'email': 'user1@example.com', 'full_name': 'User 1'},
    {'email': 'user2@example.com', 'full_name': 'User 2'},
]
session.bulk_insert_mappings(User, users_data)
session.commit()
```

## 10. Anti-Patterns (MUST avoid)
- **N+1 Queries**: Use eager loading to avoid multiple queries.
  - ❌ Bad: `for user in users: print(user.posts)`
  - ✅ Good: `users = session.execute(select(User).options(selectinload(User.posts))).scalars()`
- **Detached Instances**: Access relationships before session closes.
- **Missing Indexes**: Add indexes on frequently queried columns.
- **Large Transactions**: Keep transactions small and focused.

