# Django Traditional Structure

> **Scope**: Traditional structure for Django  
> **Applies to**: Django projects with traditional structure  
> **Extends**: python/frameworks/django.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Models in models.py
> **ALWAYS**: Views in views.py
> **ALWAYS**: URLs in urls.py
> **ALWAYS**: ViewSets for DRF
> **ALWAYS**: Serializers for API
> 
> **NEVER**: Business logic in views
> **NEVER**: Skip serializers (use ModelSerializer)
> **NEVER**: Fat views (extract to services)
> **NEVER**: Skip URL patterns
> **NEVER**: Direct model access in templates

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

## AI Self-Check

- [ ] Models in models.py?
- [ ] Views in views.py?
- [ ] URLs in urls.py?
- [ ] ViewSets for DRF?
- [ ] Serializers for API?
- [ ] No business logic in views?
- [ ] ModelSerializer used?
- [ ] Views kept thin?
- [ ] URL patterns configured?
- [ ] No direct model access in templates?
