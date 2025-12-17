# .NET Architecture

> **Scope**: Apply these rules ONLY when working with `.cs`, `.csproj`, or `.razor` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Clean Architecture**: Core depends on nothing. Infrastructure depends on Core.
- **CQRS**: Separate Command (Write) and Query (Read) models when >3 write operations.

## 2. Project Structure
```
src/
├── Core/           # Domain Entities, Interfaces, Value Objects
├── Application/    # Use Cases, DTOs, Validators, Handlers
├── Infrastructure/ # EF Core, External Services, Repository Implementations
└── API/            # Controllers, Middleware, Startup
```
- **Feature-First**: Organize by feature, NOT by type.

## 3. Naming Conventions
- **Interfaces**: MUST prefix `I` (e.g., `IUserRepository`).
- **Implementations**: `UserRepository` implements `IUserRepository`.
- **DTOs**: Suffix with `Dto`, `Request`, `Response` (e.g., `UserDto`).

## 4. Design Patterns
- **Service Layer**: Use services or handlers for business logic. Controllers only delegate.
- **Repository Pattern**: Abstract data access behind interfaces.
- **Dependency Injection**: One `DependencyInjection.cs` per layer. Constructor injection only.

## 5. DTOs & Mapping
- NEVER expose EF entities in API responses. Always map to DTOs.
- Use AutoMapper OR explicit mapping extension methods.

## 6. Anti-Patterns (MUST avoid)
- **Async Blocking**: NEVER use `.Result` or `.Wait()`. Async all the way.
- **Fat Controllers**: Controllers only validate input and delegate to services/handlers.
- **Anemic Domain**: Business logic belongs in Domain, not Application layer.
