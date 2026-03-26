# Laravel Framework

> **Scope**: Laravel 9+ applications  
> **Applies to**: PHP files in Laravel projects
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Eloquent ORM for database
> **ALWAYS**: Validate with Form Requests
> **ALWAYS**: Return API resources (NOT raw models)
> **ALWAYS**: Use dependency injection
> **ALWAYS**: Resource controllers for REST
> 
> **NEVER**: Use `DB::raw` without binding
> **NEVER**: Return Eloquent models directly
> **NEVER**: Put business logic in controllers
> **NEVER**: Validate in controllers
> **NEVER**: Use `env()` outside config

## Core Patterns

```php
// Controller (thin)
class UserController extends Controller {
    public function store(StoreUserRequest $request) {
        return new UserResource($this->userService->create($request->validated()));
    }
}

// Form Request (validation)
class StoreUserRequest extends FormRequest {
    public function rules(): array {
        return ['name' => ['required', 'string'], 'email' => ['email', 'unique:users']];
    }
}

// API Resource (transformation)
class UserResource extends JsonResource {
    public function toArray($request): array {
        return ['id' => $this->id, 'name' => $this->name];
    }
}

// Model
class User extends Model {
    protected $fillable = ['name', 'email'];
    public function posts(): HasMany { return $this->hasMany(Post::class); }
}

// Service (business logic)
class UserService {
    public function create(array $data): User {
        $data['password'] = Hash::make($data['password']);
        return $this->repository->create($data);
    }
}

// Routes
Route::middleware('auth:sanctum')->group(fn() => Route::apiResource('users', UserController::class));
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct Model** | `return User::all()` | `UserResource::collection()` |
| **Controller Validation** | `$request->validate()` | `StoreUserRequest` |
| **Business Logic** | Logic in controller | Service class |
| **env() Usage** | `env('APP_NAME')` | `config('app.name')` |
| **DB::raw** | `DB::raw($input)` | `DB::raw('col = ?', [$input])` |

## AI Self-Check

- [ ] Using Eloquent ORM?
- [ ] Form Requests for validation?
- [ ] API Resources for responses?
- [ ] Thin controllers?
- [ ] Services for business logic?
- [ ] Dependency injection?
- [ ] Resource routes?
- [ ] No env() outside config?
- [ ] No raw models returned?
- [ ] Parameter binding for raw queries?

## Key Features

| Feature | Purpose |
|---------|---------|
| Eloquent | ORM |
| Form Requests | Validation |
| API Resources | Response transformation |
| Service Container | DI |
| Route Model Binding | Automatic injection |

## Best Practices

**MUST**: Eloquent, Form Requests, API Resources, DI, thin controllers
**SHOULD**: Services, repositories, events, jobs, middleware
**AVOID**: Controller logic, direct model returns, env() outside config
