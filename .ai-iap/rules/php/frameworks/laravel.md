# Laravel Framework

> **Scope**: Apply these rules when working with Laravel applications.

## 1. Controllers
- **Thin Controllers**: Validate, delegate, respond.
- **Form Requests**: Move validation to dedicated classes.
- **API Resources**: Transform models for responses.
- **Single Action**: Use `__invoke()` for single-action controllers.

```php
// ✅ Good
class UserController extends Controller
{
    public function store(StoreUserRequest $request, CreateUserAction $action): UserResource
    {
        $user = $action->execute($request->validated());
        return new UserResource($user);
    }
}

// ❌ Bad - Logic in controller
public function store(Request $request)
{
    $request->validate(['email' => 'required|email']);
    $user = User::create($request->all());
    return response()->json($user);
}
```

## 2. Eloquent
- **Scopes**: Encapsulate query logic.
- **Accessors/Mutators**: Use `Attribute` cast (Laravel 9+).
- **Relationships**: Define all relationships.
- **No Raw Queries in Controllers**: Use scopes or repositories.

```php
// ✅ Good - Query scope
class User extends Model
{
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }
}

// Usage
User::active()->get();
```

## 3. Validation
- **Form Requests**: Dedicated validation classes.
- **Custom Rules**: Create `Rule` classes for complex validation.
- **Messages**: Define custom error messages.

```php
class StoreUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', Password::min(8)->mixedCase()],
        ];
    }
}
```

## 4. Services & Actions
- **Services**: Stateless classes for complex business logic.
- **Actions**: Single-purpose classes (`CreateUser`, `SendInvoice`).
- **Dependency Injection**: Inject via constructor.

```php
// ✅ Good - Action class
class CreateUserAction
{
    public function __construct(private UserRepository $users) {}

    public function execute(array $data): User
    {
        return $this->users->create($data);
    }
}
```

## 5. API Resources
- **Transform Data**: Never expose models directly.
- **Conditional Fields**: Use `when()` for optional fields.
- **Collections**: Use `ResourceCollection` for lists.

```php
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'posts' => PostResource::collection($this->whenLoaded('posts')),
        ];
    }
}
```

## 6. Events & Listeners
- **Decouple Logic**: Fire events for side effects.
- **Queued Listeners**: For heavy operations (emails, notifications).
- **Observers**: For model lifecycle events.

## 7. Testing
- **Feature Tests**: Test HTTP endpoints.
- **Unit Tests**: Test services/actions in isolation.
- **Factories**: Use factories for test data.
- **RefreshDatabase**: Clean state per test.

