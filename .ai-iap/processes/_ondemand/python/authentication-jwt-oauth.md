# Authentication Setup Process - Python

> **Purpose**: Implement secure authentication and authorization in Python applications

> **Core Stack**: bcrypt/Argon2, PyJWT, OAuth (authlib), framework-specific tools

---

## Phase 1: Password Hashing

> **ALWAYS use**: bcrypt ⭐ or Argon2 (NOT md5, sha1)
> **NEVER**: Store plain text passwords

**Install**:
```bash
pip install bcrypt  # or argon2-cffi
```

**Hash & Verify**:
```python
import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12)).decode()

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())
```

> **Git**: `git commit -m "feat: add password hashing"`

---

## Phase 2: JWT Authentication

> **ALWAYS**:
> - Use PyJWT or python-jose
> - Store secret in environment variables
> - Token expiration: 1h access, 7d refresh

**Install**:
```bash
pip install pyjwt[crypto]
```

**JWT Functions**:
```python
import jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv("JWT_SECRET")

def create_access_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "type": "access",
        "exp": datetime.utcnow() + timedelta(hours=1),
        "iat": datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

def verify_token(token: str) -> dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise ValueError("Token expired")
    except jwt.InvalidTokenError:
        raise ValueError("Invalid token")
```

**FastAPI Dependency**:
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer

security = HTTPBearer()

async def get_current_user(token: str = Depends(security)):
    try:
        payload = verify_token(token.credentials)
        user_id = payload["sub"]
        user = await get_user_by_id(user_id)
        return user
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid authentication")
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 / Social Login

> **ALWAYS use**: authlib ⭐ (OAuth 1.0/2.0 support)

**Install**:
```bash
pip install authlib httpx
```

**OAuth Setup** (FastAPI):
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
    user_info = token['userinfo']
    # Find or create user, issue JWT
    return {"access_token": create_access_token(user.id)}
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

> **ALWAYS**: Check permissions, not just authentication

**Role Dependency** (FastAPI):
```python
def require_role(*roles: str):
    async def dependency(current_user: User = Depends(get_current_user)):
        if current_user.role not in roles:
            raise HTTPException(status_code=403, detail="Forbidden")
        return current_user
    return dependency

# Usage
@app.delete("/users/{user_id}", dependencies=[Depends(require_role("admin"))])
async def delete_user(user_id: int): ...
```

**Permission-Based**:
```python
def require_permission(permission: str):
    async def dependency(current_user: User = Depends(get_current_user)):
        if permission not in current_user.permissions:
            raise HTTPException(status_code=403, detail="Forbidden")
        return current_user
    return dependency
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (slowapi or fastapi-limiter)
> - CORS configuration
> - Security headers
> - HTTPS enforcement

**Rate Limiting** (FastAPI):
```bash
pip install slowapi
```

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/auth/login")
@limiter.limit("5/15minutes")
async def login(request: Request, credentials: LoginSchema): ...
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### FastAPI
- OAuth2PasswordBearer for JWT
- Depends for dependency injection
- HTTPBearer for Authorization header

### Django
- django.contrib.auth (built-in User model)
- djangorestframework-simplejwt for JWT
- django-allauth for OAuth

### Flask
- Flask-Login for sessions
- Flask-JWT-Extended for JWT
- Authlib for OAuth

---

## AI Self-Check

- [ ] Passwords hashed with bcrypt/Argon2
- [ ] JWT signed with strong secret
- [ ] Access tokens expire in ≤1h
- [ ] OAuth configured (if needed)
- [ ] Authorization checks implemented
- [ ] Rate limiting on auth endpoints
- [ ] HTTPS enforced
- [ ] Security headers configured

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When implementing authentication system with JWT and OAuth

### Complete Implementation Prompt

```
CONTEXT:
You are implementing authentication system with JWT and OAuth for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use strong JWT secret (min 256 bits, from environment variable)
- ALWAYS set appropriate token expiration (15-60 minutes for access, days for refresh)
- ALWAYS validate tokens on protected endpoints
- ALWAYS hash passwords with bcrypt/Argon2
- NEVER store passwords in plain text
- NEVER commit secrets to version control
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - JWT AUTHENTICATION:
1. Install JWT library
2. Configure JWT secret (from environment variable)
3. Implement token generation (login endpoint)
4. Implement token validation middleware
5. Set up token expiration and refresh mechanism

Deliverable: JWT authentication working

PHASE 2 - USER MANAGEMENT:
1. Create User model/entity
2. Implement password hashing
3. Create registration endpoint
4. Create login endpoint
5. Implement password reset flow

Deliverable: User management complete

PHASE 3 - OAUTH INTEGRATION (Optional):
1. Choose OAuth providers (Google, GitHub, etc.)
2. Register application with providers
3. Implement OAuth callback handling
4. Link OAuth accounts with local users

Deliverable: OAuth authentication working

PHASE 4 - ROLE-BASED ACCESS CONTROL:
1. Define user roles
2. Implement role checking middleware
3. Protect endpoints by role
4. Add role management endpoints

Deliverable: RBAC implemented

SECURITY BEST PRACTICES:
- Use HTTPS only in production
- Implement rate limiting
- Add account lockout after failed attempts
- Log authentication events
- Use secure cookie flags (httpOnly, secure, sameSite)

START: Execute Phase 1. Install JWT library and configure token generation.
```
