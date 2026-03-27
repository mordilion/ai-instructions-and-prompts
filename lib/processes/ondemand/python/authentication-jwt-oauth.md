# Python Authentication (JWT/OAuth) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Implementing authentication for Python API (FastAPI/Flask)  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PYTHON AUTHENTICATION - JWT/OAUTH
========================================

CONTEXT:
You are implementing JWT and OAuth authentication for a Python application.

CRITICAL REQUIREMENTS:
- ALWAYS use passlib for password hashing
- ALWAYS validate JWT tokens on protected routes
- NEVER store passwords in plain text
- NEVER expose JWT secrets

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - JWT AUTHENTICATION (FASTAPI)
========================================

Install dependencies:

```bash
pip install fastapi[all] python-jose[cryptography] passlib[bcrypt] python-multipart
```

Create auth utility:
```python
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext

SECRET_KEY = "your-secret-key-here"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            return None
        return email
    except JWTError:
        return None
```

Create auth dependency:
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    email = verify_token(token)
    
    if email is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
    
    user = await get_user_by_email(email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user
```

Deliverable: JWT utility configured

========================================
PHASE 2 - AUTH ENDPOINTS
========================================

Create auth router:

```python
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr

router = APIRouter(prefix="/auth", tags=["auth"])

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(request: RegisterRequest):
    # Check if user exists
    existing_user = await get_user_by_email(request.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User already exists"
        )
    
    # Hash password
    hashed_password = hash_password(request.password)
    
    # Create user
    user = await create_user(request.email, hashed_password)
    
    # Generate token
    access_token = create_access_token(data={"sub": user.email})
    
    return TokenResponse(access_token=access_token)

@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    # Find user
    user = await get_user_by_email(request.email)
    if not user or not verify_password(request.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    
    # Generate token
    access_token = create_access_token(data={"sub": user.email})
    
    return TokenResponse(access_token=access_token)

@router.get("/me")
async def get_me(current_user = Depends(get_current_user)):
    return {"id": current_user.id, "email": current_user.email}
```

Deliverable: Auth endpoints working

========================================
PHASE 3 - FLASK IMPLEMENTATION
========================================

For Flask with Flask-JWT-Extended:

```bash
pip install Flask-JWT-Extended
```

Configure:
```python
from flask import Flask, jsonify, request
from flask_jwt_extended import (
    JWTManager, create_access_token,
    jwt_required, get_jwt_identity
)

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your-secret-key'
jwt = JWTManager(app)

@app.route('/auth/login', methods=['POST'])
def login():
    email = request.json.get('email')
    password = request.json.get('password')
    
    user = find_user_by_email(email)
    if not user or not verify_password(password, user.password):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    access_token = create_access_token(identity=email)
    return jsonify({'access_token': access_token})

@app.route('/auth/me', methods=['GET'])
@jwt_required()
def get_me():
    current_user_email = get_jwt_identity()
    user = find_user_by_email(current_user_email)
    return jsonify({'id': user.id, 'email': user.email})
```

Deliverable: Flask auth working

========================================
PHASE 4 - OAUTH 2.0 (OPTIONAL)
========================================

For FastAPI with Google OAuth:

```bash
pip install authlib httpx
```

Configure:
```python
from authlib.integrations.starlette_client import OAuth

oauth = OAuth()
oauth.register(
    name='google',
    client_id=os.getenv('GOOGLE_CLIENT_ID'),
    client_secret=os.getenv('GOOGLE_CLIENT_SECRET'),
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

@app.get('/auth/google')
async def google_login(request: Request):
    redirect_uri = request.url_for('google_callback')
    return await oauth.google.authorize_redirect(request, redirect_uri)

@app.get('/auth/google/callback')
async def google_callback(request: Request):
    token = await oauth.google.authorize_access_token(request)
    user_info = token.get('userinfo')
    
    # Find or create user
    user = await get_or_create_user(user_info['email'])
    
    # Generate JWT
    access_token = create_access_token(data={"sub": user.email})
    
    return {'access_token': access_token}
```

Deliverable: OAuth configured

========================================
BEST PRACTICES
========================================

- Use passlib with bcrypt for password hashing
- Store JWT secrets in environment variables
- Use python-jose for JWT operations
- Set reasonable token expiry
- Implement refresh tokens
- Add rate limiting
- Use HTTPS only
- Validate input with Pydantic
- Use FastAPI for automatic docs

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Configure JWT (Phase 1)
CONTINUE: Create auth endpoints (Phase 2)
ALTERNATIVE: Use Flask (Phase 3)
OPTIONAL: Add OAuth (Phase 4)
FINISH: Update all documentation files
REMEMBER: passlib, python-jose, secure secrets, document for catch-up
```

---

## Quick Reference

**What you get**: Complete JWT/OAuth authentication for Python  
**Time**: 3-4 hours  
**Output**: Auth service, protected routes, OAuth
