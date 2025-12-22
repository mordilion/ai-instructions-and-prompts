# Django Framework

## Overview
Django: high-level Python web framework with batteries included (ORM, admin panel, authentication, forms).
Follows MVT (Model-View-Template) pattern. Best for rapid development of database-driven web applications.
Use Django REST Framework (shown here) for building REST APIs.

## Pattern Selection

### Views
**Use Function-Based Views when**:
- Simple logic (< 50 lines)
- Single HTTP method
- Quick prototypes

**Use Class-Based Views when**:
- Complex logic, multiple methods
- Need inheritance/mixins
- Standard patterns (List, Detail, Create)

**Use ViewSets when**:
- Building REST API
- Standard CRUD operations
- Want automatic URL routing

## Models

```python
from django.db import models

class User(models.Model):
    email = models.EmailField(unique=True)  # Unique constraint at DB level
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)  # Set once on create
    updated_at = models.DateTimeField(auto_now=True)  # Update on every save
    
    class Meta:
        db_table = "users"  # Explicit table name
        ordering = ["-created_at"]  # Default ordering (newest first)
        indexes = [models.Index(fields=["email"])]  # Index for query performance
    
    def __str__(self):
        return self.name  # String representation in admin

class Post(models.Model):
    # ForeignKey: Many posts -> One user
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE,  # Delete posts when user deleted
        related_name="posts"  # Access via user.posts.all()
    )
    title = models.CharField(max_length=200)
    content = models.TextField()
    
    class Meta:
        db_table = "posts"
```

## Views

### Function-Based Views
```python
from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse

def user_list(request):
    users = User.objects.all()
    return JsonResponse({
        "users": [{"id": u.id, "name": u.name} for u in users]
    })

def user_detail(request, pk):
    user = get_object_or_404(User, pk=pk)
    return JsonResponse({"id": user.id, "name": user.name})
```

### Class-Based Views
```python
from django.views.generic import ListView, DetailView, CreateView

class UserListView(ListView):
    model = User
    template_name = "users/list.html"
    context_object_name = "users"
    paginate_by = 20
    
    def get_queryset(self):
        return User.objects.select_related("profile")

class UserDetailView(DetailView):
    model = User
    template_name = "users/detail.html"
```

## Django REST Framework

### Serializers
```python
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    posts_count = serializers.IntegerField(source="posts.count", read_only=True)
    
    class Meta:
        model = User
        fields = ["id", "name", "email", "posts_count"]
        read_only_fields = ["id"]
    
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value

class CreateUserSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
    email = serializers.EmailField()
```

### ViewSets
```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        search = self.request.query_params.get("search")
        if search:
            queryset = queryset.filter(name__icontains=search)
        return queryset
    
    @action(detail=True, methods=["post"])
    def activate(self, request, pk=None):
        user = self.get_object()
        user.is_active = True
        user.save()
        return Response({"status": "activated"})
```

## URLs

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r"users", UserViewSet)

urlpatterns = [
    path("api/", include(router.urls)),
    path("users/<int:pk>/", user_detail, name="user-detail"),
]
```

## Querysets

```python
# Select related (1-to-1, ForeignKey)
users = User.objects.select_related("profile").all()

# Prefetch related (Many-to-Many, reverse ForeignKey)
users = User.objects.prefetch_related("posts").all()

# Complex queries
users = User.objects.filter(
    created_at__gte=datetime(2024, 1, 1),
    posts__isnull=False
).distinct()

# Aggregation
from django.db.models import Count, Avg
stats = User.objects.aggregate(
    total=Count("id"),
    avg_posts=Avg("posts__count")
)
```

## Forms

```python
from django import forms

class UserForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ["name", "email"]
        widgets = {
            "email": forms.EmailInput(attrs={"class": "form-control"}),
        }
    
    def clean_email(self):
        email = self.cleaned_data.get("email")
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError("Email already exists")
        return email
```

## Authentication

```python
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def protected_view(request):
    return Response({"user": request.user.username})

# Custom permission
from rest_framework import permissions

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.user == request.user
```

## Middleware

```python
class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Before view
        print(f"Request: {request.path}")
        
        response = self.get_response(request)
        
        # After view
        print(f"Response: {response.status_code}")
        return response
```

## Signals

```python
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)
```

## Testing

```python
from django.test import TestCase
from rest_framework.test import APITestCase

class UserModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(name="John", email="john@test.com")
    
    def test_user_creation(self):
        self.assertEqual(self.user.name, "John")
        self.assertIsNotNone(self.user.created_at)

class UserAPITest(APITestCase):
    def test_get_users(self):
        response = self.client.get("/api/users/")
        self.assertEqual(response.status_code, 200)
```

## Best Practices

**MUST**:
- Use `select_related()` for ForeignKey/OneToOne (JOIN)
- Use `prefetch_related()` for ManyToMany/reverse ForeignKey (separate queries)
- Add indexes to fields used in filters, ordering, or foreign keys
- Use ViewSets for REST APIs (not function-based views)
- Validate data at serializer level (NOT in views)

**SHOULD**:
- Use Class-Based Views for complex logic
- Use `get_object_or_404()` instead of try/except
- Use transactions for multi-step database operations
- Use `bulk_create()` for inserting multiple records
- Use Django signals for decoupled side effects

**AVOID**:
- N+1 queries (always use `select_related`/`prefetch_related`)
- Business logic in views (move to services/models)
- Returning model instances from serializers (use `SerializerMethodField`)
- Ignoring database indexes (add for frequently queried fields)
- Mixing Django templates with REST Framework (use one approach)

## Query Optimization

### Avoiding N+1 Queries
```python
# ❌ BAD: N+1 queries (1 query for users + N queries for posts)
users = User.objects.all()
for user in users:
    print(user.posts.all())  # Additional query per user!

# ✅ GOOD: 2 queries total (users + all posts)
users = User.objects.prefetch_related('posts')
for user in users:
    print(user.posts.all())  # No additional query - already loaded

# ✅ GOOD: 1 query with JOIN (for ForeignKey)
posts = Post.objects.select_related('user').all()
for post in posts:
    print(post.user.name)  # No additional query - JOINed
```

### Complex Queries
```python
from django.db.models import Count, Q, Prefetch

# Annotate with aggregation
users_with_post_count = User.objects.annotate(
    post_count=Count('posts')
).filter(post_count__gt=0)

# Complex filtering with Q objects
active_users = User.objects.filter(
    Q(created_at__gte=datetime(2024, 1, 1)) &
    (Q(email__contains='@company.com') | Q(is_staff=True))
)

# Custom prefetch with filtering
users = User.objects.prefetch_related(
    Prefetch('posts', queryset=Post.objects.filter(published=True))
)
```
