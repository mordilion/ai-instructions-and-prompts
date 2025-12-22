# Laravel Traditional Structure

> Laravel's conventional MVC structure with models, controllers, and views organized by type. Best for standard CRUD applications.

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
