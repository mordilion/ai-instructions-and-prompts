# Pydantic

## Overview
Pydantic: data validation using Python type annotations with automatic type coercion and validation.
Pydantic v2+ offers significant performance improvements over v1. Use for API request/response models, 
configuration management, and data serialization. Integrates seamlessly with FastAPI.

## Pattern Selection

### Field-Level Validation
**Use `Field()` constraints when**:
- Simple validation (length, range, regex)
- No custom logic needed
- Example: `age: int = Field(ge=0, le=150)`

**Use `@field_validator` when**:
- Business logic required
- Need to transform/normalize values
- Example: Password strength, email normalization

### Model-Level Validation
**Use `@model_validator` when**:
- Validating relationships between fields
- Cross-field dependencies
- Example: Password confirmation, date range validation

## Basic Models

```python
from pydantic import BaseModel, Field, EmailStr, field_validator
from typing import Optional
from datetime import datetime

class User(BaseModel):
    id: int
    name: str = Field(..., min_length=2, max_length=100)  # Field() for simple constraints
    email: EmailStr  # Built-in email validation
    age: int = Field(..., ge=0, le=150)  # ge = greater than or equal
    created_at: datetime = Field(default_factory=datetime.utcnow)  # Use factory for mutable defaults
    
    class Config:
        from_attributes = True  # Enable ORM mode (SQLAlchemy, etc.)

# Create instance - Pydantic validates automatically
user = User(id=1, name="John", email="john@test.com", age=30)
print(user.model_dump())  # Convert to dict (v2 method)
print(user.model_dump_json())  # Convert to JSON string
```

## Validation

```python
class CreateUserRequest(BaseModel):
    name: str
    email: EmailStr
    password: str
    
    # Use @field_validator (Pydantic v2) for business logic
    @field_validator("password")
    @classmethod
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain uppercase letter")
        return v
    
    # Validators can transform values
    @field_validator("name")
    @classmethod
    def validate_name(cls, v):
        return v.strip().title()  # Normalize: remove whitespace, capitalize

# Use Field() for simple validation (preferred for basic constraints)
class Product(BaseModel):
    name: str = Field(..., min_length=1)  # Not empty
    price: float = Field(..., gt=0)  # Greater than 0
    quantity: int = Field(default=0, ge=0)  # Greater than or equal to 0
```

## Nested Models

```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class User(BaseModel):
    name: str
    email: EmailStr
    address: Optional[Address] = None

user = User(
    name="John",
    email="john@test.com",
    address={"street": "123 Main", "city": "NYC", "country": "USA"}
)
```

## Lists & Collections

```python
from typing import List

class UserList(BaseModel):
    users: List[User]
    total: int

class Tag(BaseModel):
    name: str

class Post(BaseModel):
    title: str
    tags: List[Tag]
```

## Aliases & Computed Fields

```python
from pydantic import Field, computed_field

class User(BaseModel):
    id: int
    first_name: str = Field(..., alias="firstName")
    last_name: str = Field(..., alias="lastName")
    
    @computed_field
    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"

user = User(id=1, firstName="John", lastName="Doe")
print(user.full_name)  # "John Doe"
```

## Custom Validators

```python
from pydantic import field_validator, model_validator

class User(BaseModel):
    email: str
    confirm_email: str
    password: str
    confirm_password: str
    
    # Field validator: validates single field
    @field_validator("email")
    @classmethod
    def validate_email(cls, v):
        if "@" not in v:
            raise ValueError("Invalid email")
        return v
    
    # Model validator (mode="after"): validates after all fields parsed
    # Use for cross-field validation
    @model_validator(mode="after")
    def validate_passwords_match(self):
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match")
        if self.email != self.confirm_email:
            raise ValueError("Emails do not match")
        return self  # Must return self
```

## Settings Management

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "My App"
    database_url: str
    secret_key: str
    debug: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

## JSON Schema

```python
from pydantic import BaseModel

class User(BaseModel):
    id: int
    name: str
    email: EmailStr

print(User.model_json_schema())
```

## ORM Integration

```python
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class UserORM(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String)

class UserSchema(BaseModel):
    id: int
    name: str
    email: str
    
    class Config:
        from_attributes = True

# Convert ORM to Pydantic
user_orm = session.query(UserORM).first()
user_pydantic = UserSchema.from_orm(user_orm)
```

## Generic Models

```python
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar("T")

class Response(BaseModel, Generic[T]):
    data: T
    message: str
    success: bool

class User(BaseModel):
    name: str
    email: str

response = Response[User](
    data=User(name="John", email="john@test.com"),
    message="Success",
    success=True
)
```

## Error Handling

```python
from pydantic import ValidationError

try:
    user = User(id=1, name="Jo", email="invalid", age=-5)
except ValidationError as e:
    print(e.errors())
    # [
    #   {'loc': ('name',), 'msg': 'ensure this value has at least 2 characters', 'type': 'value_error.any_str.min_length'},
    #   {'loc': ('email',), 'msg': 'value is not a valid email address', 'type': 'value_error.email'},
    #   {'loc': ('age',), 'msg': 'ensure this value is greater than or equal to 0', 'type': 'value_error.number.not_ge'}
    # ]
```

## Best Practices

**MUST**:
- Use Pydantic v2 syntax (`@field_validator`, `model_dump()`, not v1 `@validator`, `dict()`)
- Use `EmailStr`, `HttpUrl`, `HttpsUrl` for validated string types
- Enable `from_attributes=True` in Config when converting from ORMs
- Use `Field()` with `default_factory` for mutable defaults (lists, dicts, datetime)
- Always use type hints - Pydantic relies on them

**SHOULD**:
- Use `Field()` constraints for simple validation (length, range, regex)
- Use `@field_validator` for business logic and transformations
- Use `@model_validator(mode="after")` for cross-field validation
- Use `ConfigDict` instead of `Config` class (v2+ style)
- Use nested models for complex data structures

**AVOID**:
- Mixing Pydantic v1 and v2 APIs (use v2 consistently)
- Using `@validator` decorator (deprecated in v2, use `@field_validator`)
- Complex logic in `Field()` constraints (use validators instead)
- Mutable defaults without `default_factory` (causes shared state bugs)
- Using `dict()` method (v1 style - use `model_dump()` in v2)

## Common Patterns

### API Request/Response Models
```python
# Request: Accept flexible input
class CreateUserRequest(BaseModel):
    name: str
    email: EmailStr
    age: Optional[int] = None  # Optional fields

# Response: Include computed fields
class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr
    
    @computed_field  # Computed field (not stored)
    @property
    def display_name(self) -> str:
        return f"{self.name} ({self.email})"
```

### ORM Integration
```python
# Enable from_attributes to work with SQLAlchemy
class UserSchema(BaseModel):
    id: int
    name: str
    
    model_config = ConfigDict(from_attributes=True)  # v2 style

# Convert ORM to Pydantic
user_orm = db.query(UserORM).first()
user_pydantic = UserSchema.model_validate(user_orm)  # v2 method
```
