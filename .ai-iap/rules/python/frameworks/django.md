# Django Framework

> **Scope**: Apply these rules when working with Django applications.

## 1. Views
- **Class-Based Views (CBV)**: Use generic views for CRUD operations.
- **Function-Based Views (FBV)**: Use for complex, custom logic.
- **Thin Views**: Validate, delegate to services, return response.
- **API Views**: Use Django REST Framework (DRF) for APIs.

```python
# ✅ Good - Thin view with service layer
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['POST'])
def create_user(request):
    serializer = UserSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = user_service.create_user(serializer.validated_data)
    return Response(UserSerializer(user).data, status=201)

# ❌ Bad - Business logic in view
@api_view(['POST'])
def create_user(request):
    user = User.objects.create(**request.data)
    send_welcome_email(user.email)
    create_default_profile(user)
    return Response({'id': user.id})
```

## 2. Models
- **Fat Models, Thin Views**: Business logic in models/managers.
- **Managers**: Custom query logic in model managers.
- **Properties**: Use `@property` for computed fields.
- **No Business Logic in Migrations**: Keep migrations schema-only.

```python
# ✅ Good - Custom manager
class ActiveUserManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)

class User(models.Model):
    email = models.EmailField(unique=True)
    is_active = models.BooleanField(default=True)
    
    objects = models.Manager()
    active = ActiveUserManager()
    
    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"
```

## 3. Serializers (DRF)
- **Validation**: Use serializer validation methods.
- **Nested Serializers**: For related objects.
- **Read-Only Fields**: Mark computed/auto fields as read-only.
- **Custom Fields**: Create custom serializer fields for complex types.

```python
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(read_only=True)
    posts_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'posts_count']
        read_only_fields = ['id', 'created_at']
    
    def validate_email(self, value: str) -> str:
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value.lower()
```

## 4. Services Layer
- **Complex Logic**: Move complex business logic to service classes.
- **Transactions**: Use `@transaction.atomic` for multi-step operations.
- **Dependency Injection**: Pass dependencies via constructor.

```python
from django.db import transaction

class UserService:
    def __init__(self, email_service: EmailService):
        self.email_service = email_service
    
    @transaction.atomic
    def create_user(self, data: dict) -> User:
        user = User.objects.create(**data)
        Profile.objects.create(user=user)
        self.email_service.send_welcome_email(user.email)
        return user
```

## 5. URL Configuration
- **App URLs**: Each app has its own `urls.py`.
- **Namespaces**: Use namespaces for app URLs.
- **Naming**: Name all URL patterns for reverse lookups.

```python
# app/urls.py
from django.urls import path
from . import views

app_name = 'users'

urlpatterns = [
    path('', views.UserListView.as_view(), name='list'),
    path('<int:pk>/', views.UserDetailView.as_view(), name='detail'),
]
```

## 6. Settings Management
- **Environment Variables**: Use `django-environ` or `python-decouple`.
- **Multiple Settings**: Separate files for dev/staging/prod.
- **Secrets**: NEVER commit secrets. Use `.env` files.

```python
# settings/base.py
import environ

env = environ.Env()
environ.Env.read_env()

SECRET_KEY = env('SECRET_KEY')
DEBUG = env.bool('DEBUG', default=False)
DATABASE_URL = env('DATABASE_URL')
```

## 7. Signals
- **Side Effects**: Use signals for decoupled side effects.
- **Avoid Overuse**: Don't use signals for core business logic.
- **Receivers**: Keep signal receivers simple and fast.

```python
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)
```

## 8. Testing
- **Test Cases**: Use `TestCase` for DB tests, `SimpleTestCase` for non-DB.
- **Factories**: Use `factory_boy` for test data.
- **API Tests**: Use DRF's `APITestCase` and `APIClient`.
- **Coverage**: Aim for >80% test coverage.

```python
from rest_framework.test import APITestCase

class UserAPITest(APITestCase):
    def test_create_user(self):
        data = {'email': 'test@example.com', 'password': 'secure123'}
        response = self.client.post('/api/users/', data)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(User.objects.count(), 1)
```

## 9. Admin
- **Customization**: Customize admin for better UX.
- **List Display**: Show relevant fields in list view.
- **Filters**: Add filters for common queries.
- **Search**: Enable search on text fields.

```python
@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['email', 'full_name', 'is_active', 'created_at']
    list_filter = ['is_active', 'created_at']
    search_fields = ['email', 'first_name', 'last_name']
    readonly_fields = ['created_at', 'updated_at']
```

## 10. Anti-Patterns (MUST avoid)
- **N+1 Queries**: Use `select_related()` and `prefetch_related()`.
  - ❌ Bad: `for user in User.objects.all(): print(user.profile.bio)`
  - ✅ Good: `for user in User.objects.select_related('profile'): print(user.profile.bio)`
- **Raw SQL**: Use ORM. Only use raw SQL for complex queries.
- **Circular Imports**: Structure apps to avoid circular dependencies.
- **Business Logic in Templates**: Keep templates for presentation only.

