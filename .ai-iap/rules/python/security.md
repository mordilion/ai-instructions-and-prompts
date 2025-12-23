# Python Security

> **Scope**: Python-specific security practices (Django, FastAPI, Flask)
> **Extends**: general/security.md
> **Applies to**: *.py files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Django ORM or SQLAlchemy (parameterized queries)
> **ALWAYS**: Use bcrypt or Argon2 for password hashing
> **ALWAYS**: Validate input with Pydantic models (FastAPI) or forms (Django)
> **ALWAYS**: Use HTTPS in production
> **ALWAYS**: Enable CSRF protection (Django)
> 
> **NEVER**: Use string formatting for SQL queries (f-strings, %)
> **NEVER**: Use `eval()` or `exec()` with user input
> **NEVER**: Store passwords in plaintext
> **NEVER**: Disable Django security middleware
> **NEVER**: Trust pickle data from untrusted sources

## 1. Django Security

### Settings Configuration

```python
# ✅ CORRECT - settings.py security
import os
from pathlib import Path

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']  # From environment

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False  # Always False in production

ALLOWED_HOSTS = ['yourapp.com', 'www.yourapp.com']  # Specific hosts only

# Security Middleware (NEVER remove these)
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',  # CSRF protection
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',  # Clickjacking protection
]

# HTTPS settings
SECURE_SSL_REDIRECT = True  # Redirect HTTP to HTTPS
SESSION_COOKIE_SECURE = True  # HTTPS only for session cookie
CSRF_COOKIE_SECURE = True  # HTTPS only for CSRF cookie
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Cookie settings
SESSION_COOKIE_HTTPONLY = True  # No JavaScript access
CSRF_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Strict'  # CSRF protection
CSRF_COOKIE_SAMESITE = 'Strict'

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 12}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Security headers
X_FRAME_OPTIONS = 'DENY'  # or 'SAMEORIGIN'
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True

# ❌ WRONG - Insecure settings
DEBUG = True  # Exposes sensitive information!
SECRET_KEY = 'hardcoded-secret-key'  # Never hardcode!
ALLOWED_HOSTS = ['*']  # Too permissive!
SECURE_SSL_REDIRECT = False  # Allow HTTP in production!
```

### Authentication

```python
# ✅ CORRECT - Django authentication
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password, check_password
from django.views.decorators.csrf import csrf_protect

@csrf_protect
def login_view(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('dashboard')
        else:
            return render(request, 'login.html', {'error': 'Invalid credentials'})
    
    return render(request, 'login.html')

@login_required
def protected_view(request):
    # Only accessible to authenticated users
    return render(request, 'protected.html')

# ❌ WRONG - Manual password checking
def login_view(request):
    user = User.objects.get(username=request.POST['username'])
    if user.password == request.POST['password']:  # Plaintext comparison!
        # ...
```

### SQL Injection Prevention

```python
# ✅ CORRECT - Django ORM (safe)
from django.db.models import Q

def search_users(search_term):
    return User.objects.filter(
        Q(name__icontains=search_term) |
        Q(email__icontains=search_term)
    )

# ✅ CORRECT - Raw SQL with parameters
def get_user_by_email(email):
    return User.objects.raw(
        'SELECT * FROM auth_user WHERE email = %s',
        [email]  # Parameterized
    )

# ❌ WRONG - String formatting
def search_users(search_term):
    return User.objects.raw(
        f"SELECT * FROM auth_user WHERE name LIKE '%{search_term}%'"
    )  # SQL INJECTION!

# ❌ WRONG - String interpolation
def get_user_by_email(email):
    return User.objects.raw(
        "SELECT * FROM auth_user WHERE email = '%s'" % email
    )  # SQL INJECTION!
```

### XSS Prevention

```django
{# ✅ CORRECT - Django templates auto-escape #}
<div>{{ user_input }}</div>
<input type="text" value="{{ user_input }}">

{# ❌ DANGEROUS - Bypass auto-escaping #}
<div>{{ user_input|safe }}</div>

{# ✅ CORRECT - If HTML needed, sanitize first #}
{% load bleach_tags %}
<div>{{ user_input|bleach }}</div>
```

## 2. FastAPI Security

### Input Validation

```python
# ✅ CORRECT - Pydantic validation
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr, constr, validator
from typing import Optional
import re

app = FastAPI()

class CreateUserRequest(BaseModel):
    email: EmailStr
    password: constr(min_length=12, max_length=128)
    name: constr(min_length=2, max_length=100)
    age: int
    
    @validator('password')
    def password_strength(cls, v):
        if not re.match(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])', v):
            raise ValueError('Password must contain uppercase, lowercase, digit, and special character')
        return v
    
    @validator('name')
    def name_alpha(cls, v):
        if not re.match(r'^[a-zA-Z\s]+$', v):
            raise ValueError('Name must contain only letters')
        return v
    
    @validator('age')
    def age_range(cls, v):
        if v < 18 or v > 120:
            raise ValueError('Age must be between 18 and 120')
        return v

@app.post("/users")
async def create_user(request: CreateUserRequest):
    # Validation automatic via Pydantic
    user = await user_service.create(request)
    return user

# ❌ WRONG - No validation
@app.post("/users")
async def create_user(data: dict):
    user = await user_service.create(data)  # No validation!
```

### Authentication

```python
# ✅ CORRECT - FastAPI JWT authentication
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import os

SECRET_KEY = os.getenv("JWT_SECRET")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> User:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = await get_user_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user

@app.get("/protected")
async def protected_route(current_user: User = Depends(get_current_user)):
    return {"message": f"Hello {current_user.name}"}

# ❌ WRONG - No token validation
@app.get("/protected")
async def protected_route():
    return {"data": "sensitive"}  # No authentication!
```

### SQL Injection Prevention (SQLAlchemy)

```python
# ✅ CORRECT - SQLAlchemy ORM
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(
        select(User).where(User.email == email)
    )
    return result.scalar_one_or_none()

# ✅ CORRECT - Parameterized raw SQL
async def search_users(db: AsyncSession, search_term: str):
    result = await db.execute(
        text("SELECT * FROM users WHERE name LIKE :search"),
        {"search": f"%{search_term}%"}
    )
    return result.fetchall()

# ❌ WRONG - String formatting
async def get_user_by_email(db: AsyncSession, email: str):
    result = await db.execute(
        text(f"SELECT * FROM users WHERE email = '{email}'")
    )  # SQL INJECTION!
```

## 3. Flask Security

### Configuration

```python
# ✅ CORRECT - Flask security
from flask import Flask
from flask_wtf.csrf import CSRFProtect
from flask_talisman import Talisman

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ['FLASK_SECRET_KEY']

# Enable CSRF protection
csrf = CSRFProtect(app)

# Security headers
Talisman(app,
    force_https=True,
    strict_transport_security=True,
    strict_transport_security_max_age=31536000,
    content_security_policy={
        'default-src': "'self'",
        'script-src': ["'self'", "'unsafe-inline'"],
    }
)

# Session configuration
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'

# ❌ WRONG - Insecure configuration
app.config['SECRET_KEY'] = 'hardcoded-secret'
app.config['SESSION_COOKIE_SECURE'] = False  # Allow HTTP!
```

## 4. General Python Security

### Avoid Dangerous Functions

```python
# ❌ DANGEROUS - eval() with user input
def calculate(expression):
    return eval(expression)  # Code injection!

# ✅ CORRECT - Use safe alternatives
import ast
import operator

def safe_calculate(expression):
    # Only allow mathematical operations
    allowed_operators = {
        ast.Add: operator.add,
        ast.Sub: operator.sub,
        ast.Mult: operator.mul,
        ast.Div: operator.truediv,
    }
    
    try:
        node = ast.parse(expression, mode='eval')
        return eval_expr(node.body, allowed_operators)
    except:
        raise ValueError("Invalid expression")

# ❌ DANGEROUS - pickle with untrusted data
import pickle

def load_data(data):
    return pickle.loads(data)  # Code execution risk!

# ✅ CORRECT - Use JSON for untrusted data
import json

def load_data(data):
    return json.loads(data)  # Safe
```

### File Operations

```python
# ✅ CORRECT - Safe file upload
from werkzeug.utils import secure_filename
import os

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return {'error': 'No file'}, 400
    
    file = request.files['file']
    
    if not allowed_file(file.filename):
        return {'error': 'Invalid file type'}, 400
    
    # Check file size
    file.seek(0, os.SEEK_END)
    size = file.tell()
    if size > MAX_FILE_SIZE:
        return {'error': 'File too large'}, 400
    file.seek(0)
    
    # Generate safe filename
    filename = secure_filename(file.filename)
    unique_filename = f"{uuid.uuid4()}_{filename}"
    
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], unique_filename))
    
    return {'filename': unique_filename}, 201

# ❌ WRONG - Path traversal vulnerability
@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files['file']
    file.save(file.filename)  # Can overwrite any file!
```

## 5. Environment Variables

```python
# ✅ CORRECT - Validate environment variables
from pydantic import BaseSettings, validator

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    jwt_secret: str
    debug: bool = False
    
    @validator('secret_key', 'jwt_secret')
    def secret_min_length(cls, v):
        if len(v) < 32:
            raise ValueError('Secret must be at least 32 characters')
        return v
    
    class Config:
        env_file = '.env'

settings = Settings()

# ❌ WRONG - No validation
DATABASE_URL = os.getenv('DATABASE_URL')  # Might be None!
SECRET_KEY = 'default-secret'  # Weak default!
```

## 6. CORS Configuration

```python
# ✅ CORRECT - Restrictive CORS (FastAPI)
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://yourapp.com",
        "https://staging.yourapp.com"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# ✅ CORRECT - Django CORS
# settings.py
CORS_ALLOWED_ORIGINS = [
    "https://yourapp.com",
    "https://staging.yourapp.com",
]
CORS_ALLOW_CREDENTIALS = True

# ❌ WRONG - Open CORS
CORS_ALLOW_ALL_ORIGINS = True  # Anyone can access!
```

## 7. Rate Limiting

```python
# ✅ CORRECT - Rate limiting (Flask-Limiter)
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["100 per minute"]
)

@app.route("/api/data")
@limiter.limit("10 per minute")
def api_data():
    return {"data": "value"}

@app.route("/login", methods=["POST"])
@limiter.limit("5 per 15 minutes")
def login():
    # Strict limit for auth endpoint
    pass

# ✅ CORRECT - FastAPI rate limiting
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/login")
@limiter.limit("5/15minutes")
async def login(request: Request):
    pass
```

## 8. Error Handling

```python
# ✅ CORRECT - Safe error handling (FastAPI)
from fastapi import Request, status
from fastapi.responses import JSONResponse
import logging

logger = logging.getLogger(__name__)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # Log detailed error
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    
    # Return generic message
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )

# ✅ CORRECT - Django error handling
# settings.py (production)
DEBUG = False
ADMINS = [('Admin', 'admin@yourapp.com')]

# Custom error views
def custom_500(request):
    logger.error(f"500 error at {request.path}", exc_info=True)
    return render(request, '500.html', status=500)

# ❌ WRONG - Expose exception details
@app.exception_handler(Exception)
async def exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        content={"error": str(exc), "traceback": traceback.format_exc()}
    )  # Exposes internals!
```

## AI Self-Check

Before generating Python code, verify:
- [ ] Django ORM or SQLAlchemy for queries (no string formatting)?
- [ ] Bcrypt or Argon2 for passwords?
- [ ] Pydantic models for input validation (FastAPI)?
- [ ] Django forms with validation?
- [ ] HTTPS enforced in production settings?
- [ ] CSRF protection enabled (Django)?
- [ ] Secure cookie settings (HttpOnly, Secure, SameSite)?
- [ ] No `eval()` or `exec()` with user input?
- [ ] No `pickle.loads()` with untrusted data?
- [ ] File uploads validated and use `secure_filename()`?
- [ ] Environment variables validated?
- [ ] CORS configured restrictively?
- [ ] Rate limiting on sensitive endpoints?
- [ ] Error handlers don't expose internals?
- [ ] Dependencies up-to-date (`pip-audit`, `safety`)?

## Testing Security

```python
# ✅ Security testing example (pytest + FastAPI)
from fastapi.testclient import TestClient

def test_protected_endpoint_requires_auth(client: TestClient):
    response = client.get("/protected")
    assert response.status_code == 401

def test_sql_injection_prevented(client: TestClient):
    malicious = "admin'; DROP TABLE users--"
    response = client.get(f"/users/search?q={malicious}")
    assert response.status_code != 500

def test_rate_limiting(client: TestClient):
    for _ in range(6):
        response = client.post("/login", json={"username": "test", "password": "test"})
    assert response.status_code == 429  # Too many requests
```

---

**Python Security: Django and FastAPI have excellent built-in security features. Use them.**

