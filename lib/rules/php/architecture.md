# PHP Architecture

> **Scope**: PHP architectural patterns and principles  
> **Applies to**: *.php files  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use strict types (declare(strict_types=1))
> **ALWAYS**: Use type hints for all parameters and returns
> **ALWAYS**: Use dependency injection (constructor)
> **ALWAYS**: Use readonly properties (PHP 8.1+)
> **ALWAYS**: Use named arguments for clarity
> 
> **NEVER**: Skip type declarations
> **NEVER**: Use global variables
> **NEVER**: Use extract() function
> **NEVER**: Use eval() on user input
> **NEVER**: Mix HTML and business logic

## Core Patterns

### Type Safety (PHP 8+)
```php
class User {
    public function __construct(
        public readonly int $id,
        public readonly string $name,
        public readonly string $email,
    ) {}
}

function getUser(int $id): ?User {
    return $repository->findById($id);
}
```

### Immutability
```php
final readonly class User {
    public function __construct(
        public int $id,
        public string $name,
        public string $email,
    ) {}
    
    public function withName(string $name): self {
        return new self($this->id, $name, $this->email);
    }
}
```

### Dependency Injection
```php
interface UserRepository {
    public function findById(int $id): ?User;
    public function save(User $user): void;
}

class UserService {
    public function __construct(
        private readonly UserRepository $repository
    ) {}
    
    public function getUser(int $id): User {
        $user = $this->repository->findById($id);
        if (!$user) {
            throw new UserNotFoundException($id);
        }
        return $user;
    }
}
```

## Error Handling

```php
class UserNotFoundException extends \Exception {
    public function __construct(int $id) {
        parent::__construct("User {$id} not found");
    }
}

try {
    $user = $service->getUser($id);
} catch (UserNotFoundException $e) {
    // Handle
}
```

## Best Practices

### Use Enums (Modern PHP)
```php
enum UserRole: string {
    case Admin = 'admin';
    case User = 'user';
    case Guest = 'guest';
}
```

### Strict Types
```php
declare(strict_types=1);
```

### Named Arguments
```php
$user = new User(
    id: 1,
    name: 'John',
    email: 'john@test.com'
);
```

### Null Safety
```php
$email = $user?->profile?->email ?? 'default@example.com';
```

## AI Self-Check

- [ ] strict_types=1 declared?
- [ ] Type hints for all parameters/returns?
- [ ] Dependency injection via constructor?
- [ ] readonly properties used (PHP 8.1+)?
- [ ] Named arguments for clarity?
- [ ] Package by feature (not layer)?
- [ ] No global variables?
- [ ] No extract() function?
- [ ] No eval() on user input?
- [ ] No mixed HTML and business logic?
- [ ] final classes where appropriate?
- [ ] Enums for typed constants (PHP 8.1+)?
