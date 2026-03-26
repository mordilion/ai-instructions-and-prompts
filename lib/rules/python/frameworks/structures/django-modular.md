# Django Modular Structure

> **Scope**: Feature-first modular structure for Django  
> **Applies to**: *.py files  
> **Extends**: python/frameworks/django.md  
> **Use When**: Medium-large apps, domain-driven design

## CRITICAL REQUIREMENTS

> **ALWAYS**: Organize by feature/domain app
> **ALWAYS**: Each app is self-contained
> **ALWAYS**: Minimize cross-app dependencies
> **ALWAYS**: Use Django app registry
> 
> **NEVER**: Share implementation details between apps
> **NEVER**: Create circular dependencies

## Structure

```
myproject/
├── manage.py
├── config/                # Project config
│   ├── settings/
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── users/            # User app (self-contained)
│   │   ├── models/
│   │   ├── views/
│   │   ├── serializers/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── urls.py
│   │   ├── admin.py
│   │   └── tests/
│   └── posts/            # Posts app
│       ├── models/
│       ├── views/
│       └── services/
└── core/                 # Shared utilities only
    ├── exceptions.py
    └── middleware.py
```

## Core Patterns

### App Organization

```python
# apps/users/models/user.py
class User(models.Model):
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=100)

# apps/users/views/user_views.py
class UserListView(APIView):
    def get(self, request):
        service = UserService()
        users = service.get_all_users()
        return Response(UserSerializer(users, many=True).data)

# apps/users/services/user_service.py
class UserService:
    def __init__(self):
        self.repository = UserRepository()
    
    def get_all_users(self):
        return self.repository.get_all()
```

### Cross-App Communication

```python
# apps/users/public_api.py - Interface for other apps
class UserPublicApi:
    @staticmethod
    def get_user(user_id: int) -> Optional[User]:
        return UserRepository().get_by_id(user_id)

# apps/posts/services/post_service.py - Uses user app via interface
from apps.users.public_api import UserPublicApi

class PostService:
    def create_post(self, user_id: int, title: str):
        user = UserPublicApi.get_user(user_id)
        if not user:
            raise UserNotFoundError()
        return Post.objects.create(user=user, title=title)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Circular Deps** | user → post → user | Use interfaces |
| **Shared Implementation** | Direct model access | Public API |
| **App Coupling** | Access internal classes | Public API only |
| **Core Bloat** | Everything in core/ | Only shared code |

## AI Self-Check

- [ ] Organized by feature?
- [ ] Each app self-contained?
- [ ] Public API for cross-app?
- [ ] No circular dependencies?
- [ ] Core/ has only shared utilities?
- [ ] Tests mirror app structure?
- [ ] Django app registry used?
- [ ] Clear app boundaries?

## Benefits

- ✅ High cohesion, low coupling
- ✅ Easy to understand scope
- ✅ Parallel development
- ✅ Easy to extract services

## When to Use

- ✅ Medium-large apps
- ✅ Clear business domains
- ✅ Multiple teams
- ❌ Simple CRUD apps
