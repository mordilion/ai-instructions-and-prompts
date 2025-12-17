# PHP Architecture

> **Scope**: Apply these rules ONLY when working with `.php` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Domain-Driven**: Domain layer has ZERO external dependencies.
- **Rich Models**: Business logic goes IN entities. Anemic models only for DTOs.

## 2. Project Structure
```
Domain/         # Entities, Value Objects, Repository Interfaces
Application/    # Use Cases, Services, Command/Query Handlers
Infrastructure/ # Doctrine Repos, API Clients, Framework Bindings
UI/Http/        # Controllers, Requests, Resources
```
- **Feature-First**: Organize by feature, NOT by type.

## 3. Naming Conventions
- **Interfaces**: NO `I` prefix (e.g., `UserRepository`).
- **Implementations**: `DoctrineUserRepository implements UserRepository`.
- **DTOs**: Suffix with `Dto`, `Request`, `Response` (e.g., `UserDto`).

## 4. Design Patterns
- **Repository Pattern**: Isolate data fetching from business logic.
- **Value Objects**: Use for Money, Email, Address, UserId. MUST encapsulate validation.
- **Dependency Injection**: Constructor injection ONLY.

## 5. DTOs & Mapping
- NEVER expose Doctrine entities in API responses. Always map to DTOs.
- Use explicit mapping methods or libraries like AutoMapper.

## 6. Anti-Patterns (MUST avoid)
- **Generic Exceptions**: NEVER throw `Exception` or `LogicException` from domain.
  - ✅ Good: `throw new UserNotFoundException($userId);`
  - ❌ Bad: `throw new Exception("User not found");`
- **Fat Controllers**: Controllers only validate and delegate to services.
- **Static Dependencies**: NEVER use static methods for business logic.
