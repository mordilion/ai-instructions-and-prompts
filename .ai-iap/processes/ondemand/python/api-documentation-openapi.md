# Python API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for Python API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a Python REST API (FastAPI/Flask).

CRITICAL REQUIREMENTS:
- ALWAYS use FastAPI (automatic docs) or flask-smorest
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use type hints and Pydantic models

========================================
PHASE 1 - BASIC SETUP
========================================

For FastAPI (automatic documentation):

```bash
pip install fastapi[all]
```

Create API:
```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="My API",
    description="API documentation",
    version="1.0.0"
)

# Docs automatically available at:
# /docs (Swagger UI)
# /redoc (ReDoc)
# /openapi.json (OpenAPI spec)
```

For Flask:
```bash
pip install flask-smorest
```

Deliverable: Interactive docs at /docs

========================================
PHASE 2 - DOCUMENT ENDPOINTS
========================================

Use FastAPI with type hints:

```python
from typing import List
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field, EmailStr

class CreateUserDto(BaseModel):
    name: str = Field(..., min_length=3, max_length=100, example="John Doe")
    email: EmailStr = Field(..., example="john@example.com")

class User(BaseModel):
    id: int
    name: str
    email: str

@app.get("/users", 
    response_model=List[User],
    summary="Get all users",
    description="Returns a list of all users",
    tags=["Users"]
)
async def get_users():
    return users

@app.post("/users",
    response_model=User,
    status_code=status.HTTP_201_CREATED,
    summary="Create user",
    description="Creates a new user",
    responses={
        201: {"description": "User created"},
        400: {"description": "Invalid input"}
    },
    tags=["Users"]
)
async def create_user(user: CreateUserDto):
    # Implementation
    return created_user
```

Deliverable: Documented endpoints with types

========================================
PHASE 3 - ENHANCED DOCUMENTATION
========================================

Add detailed descriptions:

```python
from fastapi import Path, Query

@app.get("/users/{user_id}",
    response_model=User,
    summary="Get user by ID",
    responses={
        200: {"description": "User found"},
        404: {"description": "User not found"}
    }
)
async def get_user(
    user_id: int = Path(..., description="The ID of the user", gt=0, example=1)
):
    """
    Get a user by ID:
    
    - **user_id**: Unique identifier for the user
    
    Returns the user object if found.
    """
    if user := find_user(user_id):
        return user
    raise HTTPException(status_code=404, detail="User not found")

@app.get("/search",
    response_model=List[User],
    summary="Search users"
)
async def search_users(
    q: str = Query(..., min_length=3, description="Search query", example="John"),
    limit: int = Query(10, ge=1, le=100, description="Max results")
):
    """Search users by name or email"""
    return search(q, limit)
```

Deliverable: Enhanced docs with examples

========================================
PHASE 4 - AUTHENTICATION
========================================

Add JWT authentication:

```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

@app.get("/protected",
    dependencies=[Depends(security)],
    summary="Protected endpoint"
)
async def protected_route():
    return {"message": "authenticated"}
```

Configure security globally:
```python
app = FastAPI(
    title="My API",
    version="1.0.0",
    swagger_ui_init_oauth={
        "usePkceWithAuthorizationCodeGrant": True,
    }
)

# Add to specific endpoints
@app.get("/users", dependencies=[Depends(security)])
```

Deliverable: Authentication in docs

========================================
BEST PRACTICES
========================================

- Use FastAPI for automatic docs
- Use Pydantic for models
- Add type hints everywhere
- Include descriptions and examples
- Document error responses
- Use tags to organize endpoints
- Add authentication schemes
- Export OpenAPI spec for clients
- Keep models in sync

========================================
EXECUTION
========================================

START: Set up FastAPI (Phase 1)
CONTINUE: Document with type hints (Phase 2)
CONTINUE: Enhance descriptions (Phase 3)
CONTINUE: Add authentication (Phase 4)
REMEMBER: Type hints, Pydantic models, automatic
```

---

## Quick Reference

**What you get**: Automatic OpenAPI docs from FastAPI type hints  
**Time**: 1-2 hours  
**Output**: OpenAPI spec, Swagger UI, ReDoc
