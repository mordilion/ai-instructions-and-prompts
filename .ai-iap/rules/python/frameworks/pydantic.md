# Pydantic

> **Scope**: Apply these rules when using Pydantic for data validation (with FastAPI, standalone, or other frameworks).

## 1. Models
- **BaseModel**: Inherit from `BaseModel` for all models.
- **Type Hints**: Use type hints for all fields.
- **Field Validation**: Use `Field()` for constraints and metadata.
- **Immutability**: Use `frozen=True` for immutable models.

```python
from pydantic import BaseModel, Field, EmailStr, ConfigDict

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=100)
    full_name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=18, le=120)

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    is_active: bool
    
    model_config = ConfigDict(from_attributes=True)
```

## 2. Field Validation
- **Built-in Validators**: Use Pydantic's built-in field types (`EmailStr`, `HttpUrl`, etc.).
- **Field Constraints**: Use `Field()` for min/max, regex, etc.
- **Custom Validators**: Use `@field_validator` for complex validation.

```python
from pydantic import BaseModel, Field, field_validator
import re

class User(BaseModel):
    username: str = Field(..., min_length=3, max_length=20, pattern=r'^[a-zA-Z0-9_]+$')
    email: EmailStr
    password: str = Field(..., min_length=8)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one digit')
        return v
    
    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str) -> str:
        if v.lower() in ['admin', 'root', 'system']:
            raise ValueError('Username is reserved')
        return v
```

## 3. Model Configuration
- **ConfigDict**: Use `model_config` for model settings.
- **from_attributes**: Enable ORM mode for SQLAlchemy models.
- **Strict Mode**: Enable strict type checking.
- **Alias**: Define field aliases for serialization.

```python
from pydantic import BaseModel, Field, ConfigDict

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str = Field(..., alias='fullName')
    is_active: bool = Field(..., alias='isActive')
    
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,  # Allow both 'full_name' and 'fullName'
        str_strip_whitespace=True,
        validate_assignment=True
    )
```

## 4. Nested Models
- **Composition**: Use nested models for complex structures.
- **Lists**: Use `list[Model]` for collections.
- **Optional**: Use `Model | None` for optional nested models.

```python
from pydantic import BaseModel

class Address(BaseModel):
    street: str
    city: str
    country: str
    postal_code: str

class User(BaseModel):
    id: int
    email: str
    address: Address | None = None
    tags: list[str] = []

# Usage
user = User(
    id=1,
    email='test@example.com',
    address={'street': '123 Main St', 'city': 'NYC', 'country': 'USA', 'postal_code': '10001'},
    tags=['premium', 'verified']
)
```

## 5. Model Methods
- **Serialization**: Use `model_dump()` to convert to dict.
- **JSON**: Use `model_dump_json()` for JSON string.
- **Parsing**: Use `model_validate()` to parse data.
- **Copy**: Use `model_copy()` to create a copy with updates.

```python
user = User(id=1, email='test@example.com', full_name='Test User')

# To dict
user_dict = user.model_dump()

# To JSON
user_json = user.model_dump_json()

# Parse from dict
user = User.model_validate({'id': 1, 'email': 'test@example.com', 'full_name': 'Test'})

# Copy with updates
updated_user = user.model_copy(update={'full_name': 'Updated Name'})
```

## 6. Custom Types
- **Constrained Types**: Use `constr`, `conint`, `confloat` for constraints.
- **Custom Validators**: Create reusable custom types.
- **Annotated**: Use `Annotated` for type metadata.

```python
from pydantic import BaseModel, constr, conint
from typing import Annotated

# Constrained types
Username = Annotated[str, constr(min_length=3, max_length=20, pattern=r'^[a-zA-Z0-9_]+$')]
Age = Annotated[int, conint(ge=0, le=120)]

class User(BaseModel):
    username: Username
    age: Age
```

## 7. Settings Management
- **BaseSettings**: Use `BaseSettings` for configuration.
- **Environment Variables**: Automatically load from `.env`.
- **Validation**: Pydantic validates settings on startup.

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "My App"
    database_url: str
    secret_key: str
    debug: bool = False
    max_connections: int = 10
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False
    )

settings = Settings()
```

## 8. Discriminated Unions
- **Type Discrimination**: Use discriminated unions for polymorphic data.
- **Field Discriminator**: Use `Field(discriminator='type')`.

```python
from pydantic import BaseModel, Field
from typing import Literal

class Cat(BaseModel):
    type: Literal['cat']
    meow: str

class Dog(BaseModel):
    type: Literal['dog']
    bark: str

class Animal(BaseModel):
    animal: Cat | Dog = Field(..., discriminator='type')

# Usage
cat = Animal(animal={'type': 'cat', 'meow': 'meow'})
dog = Animal(animal={'type': 'dog', 'bark': 'woof'})
```

## 9. Computed Fields
- **Computed Properties**: Use `@computed_field` for derived fields.
- **Read-Only**: Computed fields are read-only.

```python
from pydantic import BaseModel, computed_field

class User(BaseModel):
    first_name: str
    last_name: str
    
    @computed_field
    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"

user = User(first_name='John', last_name='Doe')
print(user.full_name)  # "John Doe"
```

## 10. Error Handling
- **ValidationError**: Catch `ValidationError` for validation failures.
- **Error Messages**: Access detailed error messages.
- **Custom Errors**: Raise `ValueError` in validators.

```python
from pydantic import BaseModel, ValidationError

class User(BaseModel):
    email: str
    age: int

try:
    user = User(email='invalid', age='not a number')
except ValidationError as e:
    print(e.errors())
    # [
    #   {'type': 'string_type', 'loc': ('email',), 'msg': 'Input should be a valid string'},
    #   {'type': 'int_parsing', 'loc': ('age',), 'msg': 'Input should be a valid integer'}
    # ]
```

## 11. Best Practices
- **Separate Models**: Use separate models for request/response/database.
- **Reuse**: Create base models for common fields.
- **Validation**: Validate early at API boundaries.
- **Immutability**: Use `frozen=True` for value objects.

```python
# Base model
class UserBase(BaseModel):
    email: EmailStr
    full_name: str

# Request model
class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

# Response model
class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

# Database model (SQLAlchemy)
class UserModel(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    full_name = Column(String)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
```

## 12. Anti-Patterns (MUST avoid)
- **Mixing Concerns**: Don't use same model for request/response/database.
  - ❌ Bad: One `User` model for everything
  - ✅ Good: `UserCreate`, `UserResponse`, `UserModel` (SQLAlchemy)
- **Missing Validation**: Always validate input data.
- **Mutable Defaults**: Use `Field(default_factory=list)` for mutable defaults.
  - ❌ Bad: `tags: list[str] = []`
  - ✅ Good: `tags: list[str] = Field(default_factory=list)`
- **Ignoring Errors**: Always handle `ValidationError`.

