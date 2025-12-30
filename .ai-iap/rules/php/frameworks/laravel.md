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

### Resource Controller (Thin)

```php
class UserController extends Controller
{
    public function __construct(private UserService $userService) {}
    
    public function index(): ResourceCollection
    {
        return UserResource::collection($this->userService->getAll());
    }
    
    public function store(StoreUserRequest $request): UserResource
    {
        return new UserResource($this->userService->create($request->validated()));
    }
}
```

### Form Request

```php
class StoreUserRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
        ];
    }
}
```

### API Resource

```php
class UserResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

### Eloquent Model

```php
class User extends Model
{
    protected $fillable = ['name', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
    protected $casts = ['email_verified_at' => 'datetime'];
    
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
}
```

### Service

```php
class UserService
{
    public function __construct(private UserRepository $repository) {}
    
    public function create(array $data): User
    {
        $data['password'] = Hash::make($data['password']);
        return $this->repository->create($data);
    }
    
    public function getAll(): Collection
    {
        return $this->repository->all();
    }
}
```

### Routes

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('users', UserController::class);
});
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
