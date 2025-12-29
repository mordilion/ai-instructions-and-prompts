# Laravel Framework

> **Scope**: Apply these rules when working with Laravel 9+ applications
> **Applies to**: PHP files in Laravel projects
> **Extends**: php/architecture.md, php/code-style.md
> **Precedence**: Framework rules OVERRIDE PHP rules for Laravel-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use Eloquent ORM for database access (type-safe, queryable)
> **ALWAYS**: Validate requests with Form Requests (NOT in controllers)
> **ALWAYS**: Use resource controllers for REST APIs (standard actions)
> **ALWAYS**: Return API resources for responses (NOT raw Eloquent models)
> **ALWAYS**: Use Laravel's dependency injection (constructor injection)
> 
> **NEVER**: Use DB::raw without parameter binding (SQL injection risk)
> **NEVER**: Return Eloquent models directly from controllers (exposes internals)
> **NEVER**: Put business logic in controllers (use services/actions)
> **NEVER**: Validate in controllers (use Form Requests)
> **NEVER**: Use env() outside config files (breaks caching)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Resource Controllers | REST APIs | `Route::apiResource()`, CRUD methods |
| Form Requests | Validation | `FormRequest`, `rules()`, `authorize()` |
| API Resources | API responses | `JsonResource`, `toArray()` |
| Eloquent Models | Database entities | `Model`, relationships |
| Services/Actions | Business logic | Single responsibility classes |

## Core Patterns

### Resource Controller (Thin)
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreUserRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\Resources\Json\ResourceCollection;

class UserController extends Controller
{
    public function __construct(
        private UserService $userService
    ) {}
    
    public function index(): ResourceCollection
    {
        $users = $this->userService->getAll();
        return UserResource::collection($users);
    }
    
    public function store(StoreUserRequest $request): UserResource
    {
        $user = $this->userService->create($request->validated());
        return new UserResource($user);
    }
    
    public function show(int $id): UserResource
    {
        $user = $this->userService->findById($id);
        return new UserResource($user);
    }
}
```

### Form Request (Validation)
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;  // Or check permissions
    }
    
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
        ];
    }
    
    public function messages(): array
    {
        return [
            'email.unique' => 'This email is already registered.',
        ];
    }
}
```

### API Resource (Response Transformation)
```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
            'posts' => PostResource::collection($this->whenLoaded('posts')),
        ];
    }
}
```

### Eloquent Model
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Model
{
    use HasFactory;
    
    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
    protected $casts = [
        'email_verified_at' => 'datetime',
        'created_at' => 'datetime',
    ];
    
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
}
```

### Service Layer (Business Logic)
```php
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function create(array $data): User
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);
    }
    
    public function findById(int $id): User
    {
        return User::with('posts')->findOrFail($id);
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Exposing Models** | Return `User` model from controller | Return `UserResource` | Exposes all fields, breaks encapsulation |
| **Validation in Controller** | Validate in controller method | Use `FormRequest` | Code duplication, violates SRP |
| **Business Logic in Controller** | Controller does DB queries, logic | Service layer | Untestable, unmaintainable |
| **DB::raw Without Binding** | `DB::raw("WHERE id = $id")` | Use Eloquent or bindings | SQL injection vulnerability |
| **env() Outside Config** | `env('APP_KEY')` in code | `config('app.key')` | Breaks config caching |

### Anti-Pattern: Exposing Eloquent Models (FORBIDDEN)
```php
// ❌ WRONG - Returns raw Eloquent model
public function show(int $id)
{
    return User::findOrFail($id);  // Exposes all fields, password hash!
}

// ✅ CORRECT - Returns API Resource
public function show(int $id): UserResource
{
    $user = $this->userService->findById($id);
    return new UserResource($user);  // Controls exposed fields
}
```

### Anti-Pattern: Validation in Controller (LEGACY)
```php
// ❌ WRONG - Validation in controller
public function store(Request $request)
{
    $request->validate([
        'email' => 'required|email|unique:users',
        'name' => 'required|string|max:255',
    ]);  // Repeated across controllers
    
    $user = User::create($request->all());
    return response()->json($user);
}

// ✅ CORRECT - Form Request
public function store(StoreUserRequest $request): UserResource
{
    $user = $this->userService->create($request->validated());
    return new UserResource($user);
}
```

## AI Self-Check (Verify BEFORE generating Laravel code)

- [ ] Using resource controllers for REST APIs?
- [ ] Validation in Form Requests? (NOT in controllers)
- [ ] Returning API Resources? (NOT raw models)
- [ ] Business logic in services? (NOT in controllers)
- [ ] Constructor injection for dependencies?
- [ ] Using Eloquent (NOT raw SQL without bindings)?
- [ ] Using config() (NOT env() outside config files)?
- [ ] Mass assignment protection? ($fillable or $guarded)
- [ ] Relationships defined in models?
- [ ] Following Laravel conventions?

## Routing

```php
// routes/api.php
Route::apiResource('users', UserController::class);

// Equivalent to:
Route::get('/users', [UserController::class, 'index']);
Route::post('/users', [UserController::class, 'store']);
Route::get('/users/{id}', [UserController::class, 'show']);
Route::put('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);
```

## Eloquent Relationships

| Type | Method | Example |
|------|--------|---------|
| One-to-Many | `hasMany()`, `belongsTo()` | User → Posts |
| Many-to-Many | `belongsToMany()` | Users ↔ Roles |
| One-to-One | `hasOne()`, `belongsTo()` | User → Profile |
| Has-Many-Through | `hasManyThrough()` | Country → Posts (via Users) |

## Key Features

- **Eloquent ORM**: Type-safe database access
- **Migrations**: Version-controlled schema changes
- **Seeders**: Test/sample data
- **Factories**: Model factories for testing
- **Queues**: Background job processing
- **Events**: Event-driven architecture
