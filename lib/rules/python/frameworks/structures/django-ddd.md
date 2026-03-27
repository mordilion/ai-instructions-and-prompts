# Django Domain-Driven Design Structure

> **Scope**: Django with DDD/Clean Architecture  
> **Use When**: Complex domain, clear bounded contexts

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, infrastructure, presentation
> **ALWAYS**: Domain has no framework dependencies
> **ALWAYS**: Use repository interfaces
> **ALWAYS**: Dependency rule: inner layers independent
> 
> **NEVER**: Import Django in domain
> **NEVER**: Skip repository interfaces
> **NEVER**: Put business logic in views

## Structure

```
src/users/              # Bounded Context
├── domain/             # Pure business logic
│   ├── entities/       # User, Profile
│   ├── value_objects/  # Email, UserRole
│   ├── repositories/   # Interfaces
│   ├── services/       # Domain services
│   └── events/
├── application/        # Use cases
│   ├── commands/       # CreateUser, UpdateProfile
│   ├── queries/        # GetUser, ListUsers
│   └── dto/
├── infrastructure/     # Django-specific
│   ├── models.py       # Django ORM
│   ├── repositories/   # Implementations
│   ├── serializers.py
│   └── admin.py
└── presentation/       # API layer
    ├── views.py
    ├── urls.py
    └── serializers.py
```

## Core Patterns

```python
# 1. Domain Entity (NO Django!)
@dataclass
class User:
    id: Optional[int]
    email: str
    name: str

# 2. Repository Interface
class UserRepository(ABC):
    @abstractmethod
    def save(self, user: User) -> User: pass

# 3. Command (Use Case)
class CreateUserCommand:
    def execute(self, email: str, name: str) -> User:
        return self.repository.save(User(None, email, name))

# 4. Repository Implementation
class DjangoUserRepository(UserRepository):
    def save(self, user: User) -> User:
        model = UserModel.objects.create(email=user.email, name=user.name)
        return User(model.id, model.email, model.name)

# 5. View
class UserCreateView(APIView):
    def post(self, request):
        return Response(CreateUserCommand().execute(**request.data).to_dict(), status=201)
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Django** | `from django.db` | Pure Python |
| **No Interfaces** | Direct ORM | Repository interface |
| **Logic in View** | Business rules | Command/Use case |
| **Wrong Direction** | Domain imports infra | Infra imports domain |

## AI Self-Check

- [ ] Domain pure Python?
- [ ] Repository interfaces in domain?
- [ ] Commands for use cases?
- [ ] Dependency rule followed?
- [ ] No Django in domain?
- [ ] DTOs for boundaries?
- [ ] Infrastructure implements interfaces?
- [ ] Mappers between model and entity?

## Benefits

- ✅ Framework-independent business logic
- ✅ Highly testable
- ✅ Clear boundaries
- ✅ Easy infrastructure changes

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability needs
- ❌ Simple CRUD
