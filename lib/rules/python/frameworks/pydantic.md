# Pydantic

> **Scope**: Pydantic v2 for data validation  
> **Applies to**: Python files using Pydantic models
> **Extends**: python/architecture.md, python/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Pydantic v2 syntax
> **ALWAYS**: Use type hints for all fields
> **ALWAYS**: Use Field() for constraints
> **ALWAYS**: Use validators for complex validation
> **ALWAYS**: Use model_validate for external data
> 
> **NEVER**: Use deprecated v1 Config class
> **NEVER**: Skip type hints
> **NEVER**: Use mutable defaults without default_factory
> **NEVER**: Ignore validation errors
> **NEVER**: Use dict() (deprecated)

## Core Patterns

### Basic Model (v2)

```python
from pydantic import BaseModel, Field, EmailStr
from typing import List
from datetime import datetime

class User(BaseModel):
    id: int
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)
    tags: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.now)
    
    model_config = ConfigDict(
        from_attributes=True,
        str_strip_whitespace=True,
        validate_assignment=True
    )
```

### Field Validator

```python
from pydantic import field_validator

class User(BaseModel):
    email: str
    password: str
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase')
        return v
```

### Model Validator

```python
from pydantic import model_validator

class DateRange(BaseModel):
    start: datetime
    end: datetime
    
    @model_validator(mode='after')
    def check_dates(self) -> 'DateRange':
        if self.start >= self.end:
            raise ValueError('start must be before end')
        return self
```

### Nested Models

```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class User(BaseModel):
    name: str
    email: EmailStr
    address: Address
```

### Usage

```python
// Validate dict
user = User.model_validate({'name': 'John', 'email': 'john@example.com', 'age': 30})

// Export to dict
data = user.model_dump()

// Export to JSON
json_str = user.model_dump_json()

// Parse JSON
user = User.model_validate_json('{"name": "John", ...}')

// From ORM
user = User.model_validate(db_user)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **v1 Config** | `class Config:` | `model_config = ConfigDict()` |
| **No Type Hints** | `name` | `name: str` |
| **Mutable Default** | `tags: list = []` | `tags: list = Field(default_factory=list)` |
| **dict()** | `.dict()` | `.model_dump()` |

## AI Self-Check

- [ ] Using v2 syntax?
- [ ] Type hints on all fields?
- [ ] Field() for constraints?
- [ ] Validators for complex logic?
- [ ] model_validate for external data?
- [ ] ConfigDict not Config?
- [ ] default_factory for mutable?
- [ ] model_dump() not dict()?

## Key Features

| Feature | Purpose |
|---------|---------|
| BaseModel | Core class |
| Field() | Constraints |
| field_validator | Field validation |
| model_validator | Cross-field validation |
| ConfigDict | Configuration |

## Best Practices

**MUST**: v2 syntax, type hints, Field(), validators, model_validate
**SHOULD**: ConfigDict, default_factory, EmailStr, nested models
**AVOID**: v1 Config, mutable defaults, dict(), missing type hints
