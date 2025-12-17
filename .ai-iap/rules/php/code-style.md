# PHP Code Style

> **Scope**: Apply these rules ONLY when working with `.php` files. These extend the general code style guidelines.

## 1. Core Principles
- **Version**: PHP 8.2+ features required.
- **Type Safety**: MUST declare `declare(strict_types=1);` in every file.
- **Immutability**: Use `readonly` classes and properties where possible.

## 2. Structure
- **Files**: One class per file. PSR-4 autoloading.
- **Imports**: Group: PHP → External → Project. Blank line between groups.
- **Classes**: MUST be `final` unless explicitly designed for extension.
- **Member Order**:
  1. Constants
  2. Properties
  3. Constructor
  4. Public methods
  5. Private methods

## 3. Naming
- **Files**: `PascalCase.php` (matches class name).
- **Classes**: `PascalCase`.
- **Methods/Variables**: `camelCase`.
- **Constants**: `UPPER_SNAKE_CASE`.
- **Booleans**: Prefix `is`, `has`, `should`, `can`.
- **Interfaces**: NO `I` prefix (e.g., `UserRepository`, not `IUserRepository`).

## 4. Language Features
- **Types**: MUST type all parameters, returns (including `void`), and properties.
- **Constructor**: Use Constructor Property Promotion.
- **Enums**: Use native Enums. NEVER class constants for fixed value sets.
- **Null Handling**: Use `?Type`, `??`, `?->`. NEVER use `isset()` on objects.
- **Attributes**: Use PHP 8 attributes over docblocks where supported.

## 5. Best Practices
- **Async**: Use Fibers or async libraries when needed. Avoid blocking I/O.
- **Error Handling**: Throw domain-specific exceptions. NEVER generic `Exception`.
  - ✅ Good: `throw new UserNotFoundException($userId);`
  - ❌ Bad: `throw new Exception("User not found");`
- **DI**: Constructor injection ONLY. NEVER `new` inside business logic.
- **Composition**: Over inheritance. Max 1 level of inheritance.
