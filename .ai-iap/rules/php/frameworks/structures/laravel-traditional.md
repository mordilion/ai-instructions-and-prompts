# Laravel Traditional Structure

> **Scope**: Traditional MVC structure for Laravel  
> **Applies to**: Laravel projects with traditional structure  
> **Extends**: php/frameworks/laravel.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Controllers in app/Http/Controllers/
> **ALWAYS**: Models in app/Models/
> **ALWAYS**: Services in app/Services/
> **ALWAYS**: Repositories for data access
> **ALWAYS**: Controllers thin (delegate to services)
> 
> **NEVER**: Business logic in controllers
> **NEVER**: Controllers call models directly (use services)
> **NEVER**: Fat controllers
> **NEVER**: Skip repository pattern
> **NEVER**: Mix concerns

## Directory Structure

```
app/
├── Http/Controllers/UserController.php
├── Models/User.php
├── Services/UserService.php
└── Repositories/UserRepository.php
```

## Implementation

```php
// Models/User.php
class User extends Model {
    protected $fillable = ['name', 'email'];
}

// Repositories/UserRepository.php
class UserRepository {
    public function findById(int $id): ?User {
        return User::find($id);
    }
}

// Services/UserService.php
class UserService {
    public function __construct(
        private readonly UserRepository $repository
    ) {}
    
    public function getUser(int $id): User {
        return $this->repository->findById($id) 
            ?? throw new UserNotFoundException($id);
    }
}

// Http/Controllers/UserController.php
class UserController extends Controller {
    public function __construct(
        private readonly UserService $service
    ) {}
    
    public function show(int $id) {
        return response()->json($this->service->getUser($id));
    }
}
```

## When to Use
- Traditional Laravel apps
- CRUD-focused applications

## AI Self-Check

- [ ] Controllers in app/Http/Controllers/?
- [ ] Models in app/Models/?
- [ ] Services in app/Services/?
- [ ] Repositories for data access?
- [ ] Controllers thin?
- [ ] Services handle business logic?
- [ ] No business logic in controllers?
- [ ] No controllers calling models directly?
- [ ] No fat controllers?
- [ ] Repository pattern used?
