# Django Modular Structure

> **Scope**: This structure extends the Django framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── manage.py
├── config/                     # Project config
│   ├── __init__.py
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── users/                  # User domain module
│   │   ├── __init__.py
│   │   ├── models/
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   └── profile.py
│   │   ├── views/
│   │   │   ├── __init__.py
│   │   │   ├── user_views.py
│   │   │   └── auth_views.py
│   │   ├── serializers/
│   │   │   ├── __init__.py
│   │   │   ├── user_serializer.py
│   │   │   └── profile_serializer.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── user_service.py
│   │   │   └── auth_service.py
│   │   ├── repositories/
│   │   │   ├── __init__.py
│   │   │   └── user_repository.py
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── tests/
│   │   │   ├── test_models.py
│   │   │   ├── test_views.py
│   │   │   └── test_services.py
│   │   └── migrations/
│   ├── posts/
│   │   ├── models/
│   │   ├── views/
│   │   ├── serializers/
│   │   ├── services/
│   │   └── ...
│   └── orders/
├── core/                       # Shared utilities
│   ├── __init__.py
│   ├── exceptions.py
│   ├── permissions.py
│   ├── pagination.py
│   ├── middleware.py
│   └── utils.py
└── requirements/
```

## Module Structure (users/)
```
users/
├── models/
│   ├── __init__.py             # Export: User, Profile
│   ├── user.py                 # User model
│   └── profile.py              # Profile model
├── views/
│   ├── __init__.py
│   ├── user_views.py           # UserListView, UserDetailView
│   └── auth_views.py           # LoginView, RegisterView
├── serializers/
│   ├── __init__.py
│   ├── user_serializer.py
│   └── profile_serializer.py
├── services/
│   ├── __init__.py
│   ├── user_service.py         # UserService class
│   └── auth_service.py         # AuthService class
├── repositories/
│   ├── __init__.py
│   └── user_repository.py      # UserRepository class
├── urls.py
├── admin.py
└── tests/
```

## Rules
- **Organized by Type**: Models, views, serializers in separate files.
- **Service Layer**: Business logic in `services/`.
- **Repository Pattern**: Data access in `repositories/` (optional).
- **Explicit Exports**: Use `__init__.py` to expose public API.
- **Tests by Type**: Separate test files for models, views, services.

## Example: Service Layer
```python
# apps/users/services/user_service.py
from django.db import transaction
from ..models import User, Profile
from ..repositories.user_repository import UserRepository

class UserService:
    def __init__(self):
        self.user_repo = UserRepository()
    
    @transaction.atomic
    def create_user(self, email: str, password: str) -> User:
        user = self.user_repo.create(email=email, password=password)
        Profile.objects.create(user=user)
        return user
    
    def get_active_users(self) -> list[User]:
        return self.user_repo.get_active()
```

## Example: Repository
```python
# apps/users/repositories/user_repository.py
from ..models import User

class UserRepository:
    def create(self, **kwargs) -> User:
        return User.objects.create_user(**kwargs)
    
    def get_active(self) -> list[User]:
        return list(User.objects.filter(is_active=True))
    
    def get_by_email(self, email: str) -> User | None:
        return User.objects.filter(email=email).first()
```

## Example: View with Service
```python
# apps/users/views/user_views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from ..services.user_service import UserService
from ..serializers import UserSerializer

user_service = UserService()

@api_view(['POST'])
def create_user(request):
    serializer = UserSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    user = user_service.create_user(
        email=serializer.validated_data['email'],
        password=serializer.validated_data['password']
    )
    
    return Response(UserSerializer(user).data, status=201)
```

## When to Use
- Medium to large Django projects
- Clear separation of concerns needed
- Multiple developers per module
- Complex business logic requiring service layer
- Potential for extracting modules to microservices

