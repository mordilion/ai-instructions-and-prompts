# Laravel Framework

> **Scope**: Apply these rules when working with Laravel applications.

## Overview

Laravel is a PHP web framework emphasizing elegant syntax, developer experience, and modern features. It provides a complete ecosystem including ORM (Eloquent), routing, authentication, queuing, and more.

**Key Capabilities**:
- **Eloquent ORM**: Active Record pattern for database
- **Blade Templates**: Powerful templating engine
- **Artisan CLI**: Code generation and tasks
- **Queue System**: Background job processing
- **API Resources**: Transform models for JSON responses

## Pattern Selection

### Controller Organization
**Use Single Action Controllers when**:
- Controller has one responsibility
- Route has complex logic
- Want explicit naming

**Use Resource Controllers when**:
- Standard CRUD operations
- RESTful API
- Following conventions

### Data Flow
**Controllers MUST**:
- Validate using Form Requests
- Delegate to Actions/Services
- Return Resources (NOT models)

**Services/Actions MUST**:
- Contain business logic
- Be framework-agnostic
- Return domain objects

### Validation Strategy
**Use Form Requests when**:
- HTTP validation
- Authorization logic needed
- Want reusable validation

**Use Validator facade when**:
- Simple one-off validation
- Testing scenarios

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

## Best Practices

**MUST**:
- Use Form Requests for validation (NO validation in controllers)
- Return API Resources (NEVER expose models directly)
- Use Actions/Services for business logic (thin controllers)
- Use Eloquent scopes for reusable queries
- Use database transactions for multi-step operations

**SHOULD**:
- Use single action controllers for complex operations
- Use route model binding for automatic entity loading
- Use API Resources for all JSON responses
- Use queued listeners for heavy operations
- Use factories for test data

**AVOID**:
- Logic in controllers (use Actions/Services)
- Raw queries in controllers (use scopes/repositories)
- Exposing models in API responses
- Validation in controllers
- God controllers (split into smaller controllers)

## Common Patterns

### Form Requests + Actions
```php
// ✅ GOOD: Form Request for validation
// app/Http/Requests/StoreUserRequest.php
class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', User::class);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', Password::min(8)->mixedCase()->numbers()],
        ];
    }
}

// app/Actions/CreateUserAction.php
class CreateUserAction
{
    public function __construct(
        private UserRepository $users,
        private HashService $hasher
    ) {}

    public function execute(array $data): User
    {
        $data['password'] = $this->hasher->make($data['password']);
        return $this->users->create($data);
    }
}

// app/Http/Controllers/UserController.php
class UserController extends Controller
{
    public function store(
        StoreUserRequest $request, 
        CreateUserAction $action
    ): UserResource {
        $user = $action->execute($request->validated());  // Type-safe, validated
        return new UserResource($user);
    }
}

// ❌ BAD: Everything in controller
class UserController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([  // Validation in controller
            'email' => 'required|email|unique:users',
        ]);
        
        $user = User::create([  // Business logic in controller
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);
        
        return response()->json($user);  // Exposing model
    }
}
```

### API Resources
```php
// ✅ GOOD: API Resource transforms data
// app/Http/Resources/UserResource.php
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toIso8601String(),
            // Conditional fields
            'posts' => PostResource::collection($this->whenLoaded('posts')),
            'admin' => $this->when($this->isAdmin(), true),
            // NO password, internal fields
        ];
    }
}

// Usage in controller
public function show(User $user): UserResource
{
    return new UserResource($user->load('posts'));  // Eager load
}

// ❌ BAD: Exposing model directly
public function show(User $user)
{
    return response()->json($user);  // Exposes ALL fields including password
}
```

### Eloquent Scopes
```php
// ✅ GOOD: Reusable query scopes
// app/Models/User.php
class User extends Model
{
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active')
                    ->whereNotNull('email_verified_at');
    }

    public function scopeWithRecentPosts(Builder $query, int $days = 30): Builder
    {
        return $query->with(['posts' => function ($q) use ($days) {
            $q->where('created_at', '>=', now()->subDays($days));
        }]);
    }

    public function scopeSearch(Builder $query, string $term): Builder
    {
        return $query->where(function ($q) use ($term) {
            $q->where('name', 'like', "%{$term}%")
              ->orWhere('email', 'like', "%{$term}%");
        });
    }
}

// Usage (chainable, readable)
$users = User::active()
            ->withRecentPosts(7)
            ->search($request->query('q'))
            ->paginate(20);

// ❌ BAD: Raw queries in controller
$users = User::where('status', 'active')
            ->whereNotNull('email_verified_at')
            ->with(['posts' => function ($q) {
                $q->where('created_at', '>=', now()->subDays(30));
            }])
            ->get();  // Repeated in multiple places
```

### Transactions
```php
// ✅ GOOD: Transaction for multi-step operations
use Illuminate\Support\Facades\DB;

class CreateOrderAction
{
    public function execute(array $items, User $user): Order
    {
        return DB::transaction(function () use ($items, $user) {
            // All or nothing
            $order = Order::create([
                'user_id' => $user->id,
                'total' => $this->calculateTotal($items),
            ]);

            foreach ($items as $item) {
                $order->items()->create($item);
                
                // Update inventory
                Product::find($item['product_id'])
                       ->decrement('stock', $item['quantity']);
            }

            // Send notification
            $user->notify(new OrderCreatedNotification($order));

            return $order;
        });  // Auto-rollback on any exception
    }
}

// ❌ BAD: No transaction (partial state possible)
$order = Order::create(['user_id' => $user->id]);
$order->items()->createMany($items);  // If this fails, order exists!
Product::find($item['product_id'])->decrement('stock', $qty);  // Inconsistent
```

### Route Model Binding
```php
// ✅ GOOD: Automatic model loading
// routes/api.php
Route::get('/users/{user}', [UserController::class, 'show']);

// Controller
public function show(User $user): UserResource
{
    return new UserResource($user);  // Already loaded, 404 if not found
}

// Custom key binding
public function resolveRouteBinding($value, $field = null)
{
    return $this->where('slug', $value)->firstOrFail();
}

// ❌ BAD: Manual loading
public function show(int $id): UserResource
{
    $user = User::findOrFail($id);  // Manual, repetitive
    return new UserResource($user);
}
```

## Common Anti-Patterns

**❌ Fat controllers**:
```php
// BAD
public function store(Request $request)
{
    // 50 lines of validation, business logic, DB operations
}
```

**✅ Thin controllers**:
```php
// GOOD
public function store(StoreUserRequest $request, CreateUserAction $action): UserResource
{
    return new UserResource($action->execute($request->validated()));
}
```

**❌ N+1 queries**:
```php
// BAD
$users = User::all();
foreach ($users as $user) {
    echo $user->posts->count();  // Query for each user!
}
```

**✅ Eager loading**:
```php
// GOOD
$users = User::withCount('posts')->get();  // Single query
foreach ($users as $user) {
    echo $user->posts_count;
}
```

## 7. Testing
- **Feature Tests**: Test HTTP endpoints with `RefreshDatabase`
- **Unit Tests**: Test services/actions in isolation
- **Factories**: Use factories for test data (NOT manual creation)
- **RefreshDatabase**: Clean state per test

