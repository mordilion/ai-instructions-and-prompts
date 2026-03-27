# Laravel Domain-Driven Design Structure

> **Scope**: DDD structure for Laravel apps  
> **Applies to**: Laravel projects with DDD  
> **Extends**: php/frameworks/laravel.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no Laravel dependencies
> **ALWAYS**: Actions for business operations
> **ALWAYS**: Value Objects for domain concepts
> **ALWAYS**: DTOs for data transfer
> **ALWAYS**: Repository pattern for data access
> 
> **NEVER**: Laravel imports in Domain layer
> **NEVER**: Infrastructure depends on Domain
> **NEVER**: Mix concerns across layers
> **NEVER**: Skip Value Objects for domain concepts
> **NEVER**: Expose Eloquent models outside Domain

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

## AI Self-Check

- [ ] Domain layer has no Laravel dependencies?
- [ ] Actions for business operations?
- [ ] Value Objects for domain concepts?
- [ ] DTOs for data transfer?
- [ ] Repository pattern for data access?
- [ ] Dependency flow: Presentation → Application → Domain ← Infrastructure?
- [ ] No Laravel imports in Domain?
- [ ] No Infrastructure → Domain dependency?
- [ ] Domain concepts expressed as Value Objects?
- [ ] Actions encapsulate business logic?

