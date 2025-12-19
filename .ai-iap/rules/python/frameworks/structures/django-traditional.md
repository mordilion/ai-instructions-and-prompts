# Django Traditional Structure

> **Scope**: This structure extends the Django framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
myproject/
├── manage.py
├── myproject/                  # Project config
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/                       # Django apps
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py     # DRF
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── tests.py
│   │   └── migrations/
│   ├── posts/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   └── ...
│   └── orders/
├── core/                       # Shared utilities
│   ├── __init__.py
│   ├── exceptions.py
│   ├── permissions.py
│   ├── pagination.py
│   └── utils.py
├── static/
├── media/
├── templates/
└── requirements/
    ├── base.txt
    ├── development.txt
    └── production.txt
```

## App Structure (users/)
```
users/
├── __init__.py
├── models.py                   # User, Profile models
├── views.py                    # All views
├── serializers.py              # DRF serializers
├── urls.py                     # URL patterns
├── admin.py                    # Admin config
├── apps.py                     # App config
├── managers.py                 # Custom model managers
├── signals.py                  # Signal handlers
├── permissions.py              # Custom permissions
├── tests.py                    # All tests
└── migrations/
```

## Rules
- **One App = One Domain**: Each app represents a domain (users, posts, orders).
- **App Independence**: Apps should be loosely coupled.
- **Shared Code**: Common utilities in `core/` or `common/`.
- **Settings Split**: Separate settings by environment.
- **Flat Files**: Keep models, views, serializers in single files per app (unless >500 lines).

## Example: User Model
```python
# apps/users/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    email = models.EmailField(unique=True)
    bio = models.TextField(blank=True)
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']
    
    class Meta:
        db_table = 'users'
        ordering = ['-date_joined']
```

## Example: View
```python
# apps/users/views.py
from rest_framework import generics
from .models import User
from .serializers import UserSerializer

class UserListView(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
```

## When to Use
- Small to medium Django projects
- Standard Django conventions
- Teams familiar with Django's default structure
- Rapid prototyping

