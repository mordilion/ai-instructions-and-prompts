# API Documentation Process - Python (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: FastAPI ⭐ (built-in), drf-spectacular (Django REST), flask-smorest (Flask)

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

## AI Self-Check

- [ ] OpenAPI docs auto-generated
- [ ] Swagger UI accessible
- [ ] All endpoints documented
- [ ] Schemas defined with Pydantic/Marshmallow

---

**Process Complete** ✅

