# Laravel Domain-Driven Design Structure

> **Scope**: Use this structure for complex Laravel apps with DDD approach.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Laravel rules.

## Project Structure
```
app/
├── Domain/                     # Core business logic (no Laravel)
│   ├── Users/
│   │   ├── Models/
│   │   │   └── User.php        # Eloquent model
│   │   ├── ValueObjects/
│   │   │   └── Email.php
│   │   ├── Actions/
│   │   │   ├── CreateUserAction.php
│   │   │   └── UpdateUserAction.php
│   │   ├── DataTransferObjects/
│   │   │   └── UserData.php
│   │   └── Exceptions/
│   └── Orders/
│       ├── Models/
│       ├── Actions/
│       └── States/             # State machine
├── Application/                # Use cases, commands
│   ├── Users/
│   │   └── Commands/
│   └── Orders/
├── Infrastructure/             # External services
│   ├── Persistence/
│   │   └── Repositories/
│   └── Services/
│       └── PaymentGateway/
└── Http/                       # Web layer
    ├── Controllers/
    ├── Requests/
    └── Resources/
```

## Action Class
```php
class CreateUserAction
{
    public function execute(UserData $data): User
    {
        return User::create([
            'email' => $data->email,
            'name' => $data->name,
        ]);
    }
}
```

## Data Transfer Object
```php
class UserData extends DataTransferObject
{
    public string $email;
    public string $name;
    public ?string $phone = null;
}
```

## Rules
- **Domain Layer**: Pure business logic, framework-agnostic where possible
- **Actions**: Single-purpose classes for operations
- **DTOs**: Type-safe data containers
- **No Eloquent in Controllers**: Use Actions and DTOs

## When to Use
- Complex business domains
- Long-lived enterprise apps
- Need for testability
- Teams with DDD experience

