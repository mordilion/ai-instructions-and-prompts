# Django Traditional Structure

> Django's conventional "app" structure with files organized by type (models, views, urls). Best for small apps and quick prototypes.

## Directory Structure

```
myapp/
├── models.py
├── views.py
├── urls.py
├── serializers.py
├── admin.py
└── tests.py
```

## Implementation

```python
# models.py
class User(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)

# serializers.py
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'email']

# views.py
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

# urls.py
router = DefaultRouter()
router.register(r'users', UserViewSet)
```

## When to Use
- Small Django apps
- Quick prototypes
