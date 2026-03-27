# PHP Code Style

> **Scope**: PHP formatting and maintainability  
> **Applies to**: *.php files  
> **Extends**: General code style, php/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Follow PSR-12 coding standard
> **ALWAYS**: Enable strict types (declare(strict_types=1))
> **ALWAYS**: Use type hints everywhere
> **ALWAYS**: Use readonly properties (PHP 8.1+)
> **ALWAYS**: Use named arguments for clarity
> 
> **NEVER**: Skip type declarations
> **NEVER**: Mix tabs and spaces
> **NEVER**: Use short tags (<? instead of <?php)
> **NEVER**: Use extract() function
> **NEVER**: Skip return type hints

## Naming Conventions

```php
// PascalCase for classes
class UserService {}

// camelCase for methods and properties
public function getUserById(int $id): ?User {}
private string $userName;

// UPPER_SNAKE_CASE for constants
const MAX_LOGIN_ATTEMPTS = 3;
```

## Type Declarations

```php
declare(strict_types=1);

// Explicit types for parameters and return
function getUser(int $id): User {
    return $repository->find($id);
}

// Nullable types
function findUser(int $id): ?User {
    return $repository->findOrNull($id);
}

// Union types (modern PHP)
function processValue(int|string $value): void {}
```

## Classes

```php
// Use readonly properties (modern PHP)
final readonly class User {
    public function __construct(
        public int $id,
        public string $name,
        public string $email,
    ) {}
}

// Constructor property promotion
class UserService {
    public function __construct(
        private readonly UserRepository $repository,
        private readonly LoggerInterface $logger,
    ) {}
}
```

## Best Practices

```php
// Use match over switch (modern PHP)
$result = match ($status) {
    'pending' => handlePending(),
    'approved' => handleApproved(),
    default => handleDefault(),
};

// Named arguments
$user = createUser(
    name: 'John',
    email: 'john@test.com'
);

// Null coalescing
$name = $user->name ?? 'Anonymous';

// Nullsafe operator
$email = $user?->profile?->email;
```

## AI Self-Check

- [ ] Following PSR-12?
- [ ] strict_types=1 declared?
- [ ] Type hints everywhere?
- [ ] readonly properties used (PHP 8.1+)?
- [ ] Named arguments for clarity?
- [ ] PascalCase for classes?
- [ ] camelCase for methods/properties?
- [ ] No global variables?
- [ ] No extract() function?
- [ ] No short tags (using <?php)?
- [ ] Return type hints present?
- [ ] Constructor property promotion (PHP 8)?
