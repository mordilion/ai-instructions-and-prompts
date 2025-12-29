# Pydantic

> **Scope**: Apply these rules when using Pydantic for data validation
> **Applies to**: Python files using Pydantic models
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use Pydantic v2 syntax (Field, ConfigDict)
> **ALWAYS**: Use type hints for all model fields
> **ALWAYS**: Use Field() for constraints and metadata
> **ALWAYS**: Use validators for complex validation logic
> **ALWAYS**: Use model_validate for external data
> 
> **NEVER**: Use deprecated v1 Config class (use ConfigDict)
> **NEVER**: Skip type hints (defeats purpose)
> **NEVER**: Use mutable defaults without default_factory
> **NEVER**: Ignore validation errors
> **NEVER**: Use dict() (deprecated, use model_dump())

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| BaseModel | Data models | Core Pydantic class |
| Field() | Constraints, defaults | Validation rules |
| field_validator | Custom validation | @field_validator decorator |
| model_validator | Cross-field validation | @model_validator decorator |
| ConfigDict | Model config | from_attributes, strict, etc |

## Core Patterns

### Basic Model (Pydantic v2)
```python
from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
from datetime import datetime

class User(BaseModel):
    id: int
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)
    tags: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.now)
    
    model_config = ConfigDict(
        from_attributes=True,  # For ORM models
        str_strip_whitespace=True,
        validate_assignment=True
    )
```

### Field Validation
```python
from pydantic import field_validator, model_validator

class User(BaseModel):
    email: EmailStr
    password: str
    confirm_password: str
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain a digit')
        return v
    
    @model_validator(mode='after')
    def check_passwords_match(self):
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self
```

### Nested Models
```python
class Address(BaseModel):
    street: str
    city: str
    country: str
    zip_code: str = Field(..., pattern=r'^\d{5}$')

class User(BaseModel):
    name: str
    email: EmailStr
    address: Address  # Nested model
    addresses: List[Address] = Field(default_factory=list)
```

### Serialization (Pydantic v2)
```python
user = User(id=1, name="John", email="john@example.com", age=30)

# ✅ CORRECT - Pydantic v2
user_dict = user.model_dump()
user_json = user.model_dump_json()

# ❌ WRONG - Deprecated v1
user_dict = user.dict()  # Deprecated!
user_json = user.json()  # Deprecated!
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **v1 Config** | `class Config:` | `model_config = ConfigDict()` | v1 deprecated |
| **dict()** | `user.dict()` | `user.model_dump()` | v1 deprecated |
| **Mutable Defaults** | `tags: List = []` | `tags: List = Field(default_factory=list)` | Shared state bug |
| **No Type Hints** | `name: str = "default"` only | Always include type | No validation |
| **Ignore Validation** | `.construct()` for user data | `model_validate()` | Security risk |

### Anti-Pattern: v1 Syntax (DEPRECATED)
```python
# ❌ WRONG - Pydantic v1 (deprecated)
class User(BaseModel):
    name: str
    
    class Config:  # Old v1 syntax
        from_orm = True
    
    def dict(self):  # Deprecated method
        return super().dict()

# ✅ CORRECT - Pydantic v2
class User(BaseModel):
    name: str
    
    model_config = ConfigDict(
        from_attributes=True  # New v2 syntax
    )
```

### Anti-Pattern: Mutable Defaults (SHARED STATE BUG)
```python
# ❌ WRONG - Mutable default
class User(BaseModel):
    tags: List[str] = []  # Shared across all instances!

user1 = User()
user1.tags.append("admin")
user2 = User()
print(user2.tags)  # ["admin"] - BUG!

# ✅ CORRECT - default_factory
class User(BaseModel):
    tags: List[str] = Field(default_factory=list)
```

## AI Self-Check (Verify BEFORE generating Pydantic code)

- [ ] Using Pydantic v2 syntax? (ConfigDict, model_dump)
- [ ] Type hints on all fields?
- [ ] Field() for constraints?
- [ ] field_validator for custom validation?
- [ ] model_validator for cross-field checks?
- [ ] default_factory for mutable defaults?
- [ ] model_validate for external data?
- [ ] No deprecated v1 methods?
- [ ] ConfigDict for model configuration?
- [ ] Proper error handling for validation?

## Validation Modes

```python
# Strict mode - no type coercion
class StrictUser(BaseModel):
    age: int
    
    model_config = ConfigDict(strict=True)

StrictUser(age="25")  # ValidationError - no coercion

# Lax mode - allows coercion (default)
class LaxUser(BaseModel):
    age: int

LaxUser(age="25")  # OK - coerces to 25
```

## Common Validators

```python
from pydantic import Field, HttpUrl, FilePath, DirectoryPath

class Config(BaseModel):
    url: HttpUrl  # Validates URL format
    port: int = Field(..., ge=1, le=65535)
    ratio: float = Field(..., gt=0.0, lt=1.0)
    file_path: FilePath  # Validates file exists
    dir_path: DirectoryPath  # Validates directory exists
    pattern: str = Field(..., pattern=r'^\d{3}-\d{2}-\d{4}$')
```

## Key Features

| Feature | Purpose | Example |
|---------|---------|---------|
| Type validation | Auto-validate types | `age: int` |
| Field constraints | Min/max, regex | `Field(ge=0, le=100)` |
| Nested models | Complex structures | Model within model |
| Custom validators | Complex rules | `@field_validator` |
| Serialization | Dict/JSON output | `model_dump()`, `model_dump_json()` |

## Key Methods (v2)

- `model_validate()`: Validate dict/object
- `model_dump()`: Serialize to dict
- `model_dump_json()`: Serialize to JSON
- `model_validate_json()`: Validate JSON string
- `model_copy()`: Create copy with updates

## Migration from v1 to v2

| v1 (Deprecated) | v2 (Current) |
|----------------|--------------|
| `class Config:` | `model_config = ConfigDict()` |
| `.dict()` | `.model_dump()` |
| `.json()` | `.model_dump_json()` |
| `.parse_obj()` | `.model_validate()` |
| `from_orm=True` | `from_attributes=True` |
