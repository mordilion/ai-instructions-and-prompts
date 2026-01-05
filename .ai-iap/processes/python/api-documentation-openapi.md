# API Documentation Process - Python (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: FastAPI ⭐ (built-in), drf-spectacular (Django REST), flask-smorest (Flask)

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

---

## Phase 1: FastAPI (Built-in)

**FastAPI auto-generates OpenAPI docs!**

```python
from fastapi import FastAPI

app = FastAPI(
    title="My API",
    description="API description",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

@app.get("/users/{user_id}", summary="Get user by ID")
async def get_user(user_id: int) -> User:
    """
    Get a user by their ID.
    
    - **user_id**: User ID (integer)
    """
    return User(id=user_id)
```

> **Access**: 
> - Swagger UI: http://localhost:8000/docs
> - ReDoc: http://localhost:8000/redoc

---

## Phase 2: Django REST Framework

**Install**:
```bash
pip install drf-spectacular
```

**Configure** (settings.py):
```python
INSTALLED_APPS = ['drf_spectacular']

REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

SPECTACULAR_SETTINGS = {
    'TITLE': 'My API',
    'VERSION': '1.0.0',
}
```

**URLs**:
```python
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema')),
]
```

---

## Phase 3: Flask

**Install**:
```bash
pip install flask-smorest
```

**Configure**:
```python
from flask_smorest import Api, Blueprint

app.config['API_TITLE'] = 'My API'
app.config['API_VERSION'] = 'v1'
app.config['OPENAPI_VERSION'] = '3.0.2'
api = Api(app)

blp = Blueprint('users', __name__, url_prefix='/api/users')

@blp.route('/<int:user_id>')
@blp.response(200, UserSchema)
def get_user(user_id):
    """Get user by ID"""
    pass
```

---

## Phase 4: Security & Versioning

### 4.1 Document Authentication (FastAPI)

**JWT Security**:
```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

@app.get("/protected", dependencies=[Depends(security)])
async def protected_route():
    """Protected endpoint requiring JWT token"""
    pass
```

**OAuth 2.0**:
```python
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.get("/users/me")
async def read_users_me(token: str = Depends(oauth2_scheme)):
    """Get current user. Requires OAuth 2.0 token"""
    pass
```

### 4.2 API Versioning

**URL Versioning**:
```python
app = FastAPI()

v1 = FastAPI(title="My API V1", version="1.0.0")
v2 = FastAPI(title="My API V2", version="2.0.0")

app.mount("/api/v1", v1)
app.mount("/api/v2", v2)
```

### 4.3 Rate Limiting Documentation

**Document Limits**:
```python
@app.get("/users", 
    summary="Get users",
    description="Rate limit: 100 requests/minute per user",
    responses={
        200: {"description": "Success"},
        429: {"description": "Too Many Requests"}
    })
async def get_users():
    pass
```

### 4.4 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format

**FastAPI Implementation**:
```python
from pydantic import BaseModel
from datetime import datetime

class ErrorDetail(BaseModel):
    field: str
    issue: str

class ErrorResponse(BaseModel):
    error: dict[str, any]

@app.exception_handler(ValidationError)
async def validation_exception_handler(request: Request, exc: ValidationError):
    return JSONResponse(
        status_code=400,
        content={
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Invalid input",
                "details": [{"field": e["loc"][-1], "issue": e["msg"]} for e in exc.errors()],
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "request_id": request.state.request_id
            }
        }
    )
```

**Django REST Framework**:
```python
from rest_framework.views import exception_handler

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is not None:
        response.data = {
            "error": {
                "code": exc.default_code.upper(),
                "message": str(exc),
                "details": response.data if isinstance(response.data, list) else [],
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "request_id": context['request'].META.get('HTTP_X_REQUEST_ID')
            }
        }
    return response
```

---

## Phase 5: CI/CD Integration

> **ALWAYS**:
> - Export OpenAPI JSON/YAML
> - Validate spec in CI/CD
> - Version control the spec

**Export Spec** (FastAPI):
```python
import json
from app import app

with open("openapi.json", "w") as f:
    json.dump(app.openapi(), f)
```

**CI/CD**:
```yaml
- name: Generate OpenAPI Spec
  run: |
    python -c "import json; from app import app; json.dump(app.openapi(), open('openapi.json', 'w'))"
    npx @openapitools/openapi-generator-cli validate -i openapi.json
```

### 5.2 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate Python Client**:
```bash
openapi-generator-cli generate \
  -i openapi.json \
  -g python \
  -o sdks/python-client
```

**Generate TypeScript Client**:
```bash
openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-axios \
  -o sdks/typescript-client
```

**Usage Example**:
```python
from python_client import ApiClient, UsersApi

client = ApiClient(configuration)
api = UsersApi(client)
user = api.get_user('123')
```

---

## Best Practices

> **ALWAYS**:
> - Use Pydantic models for request/response schemas
> - Add docstrings to all endpoints (auto-included in docs)
> - Document all response codes with `responses` parameter
> - Use `tags` to group related endpoints
> - Provide examples with `example` in schema fields

> **NEVER**:
> - Return raw dict without Pydantic model (breaks schema generation)
> - Include sensitive data in examples
> - Skip documenting error responses
> - Use generic descriptions ("Get data")

---

## Troubleshooting

### Issue: Docs not showing at /docs
- **Solution**: Ensure `docs_url="/docs"` in FastAPI(), check if disabled in production

### Issue: Schemas not appearing correctly
- **Solution**: Use Pydantic models, not plain dicts; ensure `response_model` specified

### Issue: Authentication not working in Try-it-out
- **Solution**: Add security scheme configuration, check CORS settings

### Issue: Want to customize Swagger UI
- **Solution**: Use `swagger_ui_parameters` in FastAPI() for custom configuration

---

## AI Self-Check

- [ ] FastAPI/Django/Flask OpenAPI configured
- [ ] Swagger UI accessible at `/docs`
- [ ] ReDoc accessible at `/redoc` (FastAPI)
- [ ] Pydantic models used for request/response schemas
- [ ] Authentication/security documented
- [ ] CI/CD generates and validates OpenAPI spec
- [ ] Client SDKs generated for target languages
- [ ] Try-it-out functionality works
- [ ] Error responses follow consistent format (see general standards)
- [ ] All status codes documented (see general standards)

---

**Process Complete** ✅

