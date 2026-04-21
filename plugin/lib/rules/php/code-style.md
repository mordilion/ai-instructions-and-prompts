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
> **ALWAYS**: Use `??` (null coalescing) when the fallback should apply only for `null`
> **ALWAYS**: Use `?:` (Elvis) only when ALL falsy values (`''`, `0`, `'0'`, `[]`, `false`, `null`) should trigger the fallback
>
> **NEVER**: Skip type declarations
> **NEVER**: Mix tabs and spaces
> **NEVER**: Use short tags (<? instead of <?php)
> **NEVER**: Use extract() function
> **NEVER**: Skip return type hints
> **NEVER**: Call the same method twice in one expression (extract to local variable)
> **NEVER**: Use `?:` when only `null` should trigger the fallback (use `??` instead)

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

// Null coalescing (?? triggers only on null / undefined)
$name = $user->name ?? 'Anonymous';

// Nullsafe operator
$email = $user?->profile?->email;

// Elvis (?:) triggers on ANY falsy value — '', 0, '0', [], false, null
$displayName = $customer->getCompanyName() ?: $customer->getContactPerson();
```

## Reduce Method Calls (Extract Variable + `??` / `?:`)

> **ALWAYS**: Extract repeated method calls into a local variable.
> **ALWAYS**: Prefer `??` / `?:` over verbose ternaries when the logic is "value OR fallback".

```php
// ❌ BAD: getCompanyName() called 3 times, logic duplicated
$displayName = $customer->getCompanyName() !== null && $customer->getCompanyName() !== ''
    ? $customer->getCompanyName()
    : $customer->getContactPerson();

// ✅ GOOD: Elvis — empty string AND null both fall through
$displayName = $customer->getCompanyName() ?: $customer->getContactPerson();

// ✅ GOOD (when only null should fall through): extract variable + ??
$companyName = $customer->getCompanyName();
$displayName = $companyName !== '' ? $companyName : $customer->getContactPerson();
```

**Operator cheat sheet**:

| Operator | Falls through on | Use when |
|---|---|---|
| `??` | only `null` / undefined | Nullable value, empty string is valid data |
| `?:` | any falsy (`''`, `0`, `'0'`, `[]`, `false`, `null`) | Empty-ish values should trigger fallback |
| `?->` | chain stops on `null` | Traversing nullable object chains |

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
- [ ] No method called twice in the same expression (extracted to variable)?
- [ ] `??` used for null-only fallback, `?:` for any-falsy fallback?
