# Java Architecture

> **Scope**: Apply these rules ONLY when working with `.java` files. These extend the general architecture guidelines.

## 1. Core Principles
- **Modularity**: Small classes (<300 lines). Single responsibility principle.
- **Interface Segregation**: Small, focused interfaces. Avoid god interfaces.
- **Dependency Injection**: Use constructor injection (Spring, Dagger, CDI).

## 2. Project Structure
- **Feature-First**: Organize by feature/domain, NOT by type (controllers/, services/).
- **Package by Feature**: `com.company.users`, `com.company.orders` (NOT `controllers/`, `services/`).
- **Shared Code**: Common utilities in `common` or `core` package.
- **Note**: See structure files for specific folder layouts (Spring Boot, Android, etc.).

## 3. Naming Conventions
- **Classes**: `PascalCase` (e.g., `UserService`, `OrderRepository`).
- **Methods/Variables**: `camelCase` (e.g., `getUser`, `userId`).
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).
- **Packages**: lowercase, no underscores (e.g., `com.company.users`).
- **Interfaces**: NO `I` prefix (e.g., `UserRepository`, not `IUserRepository`).
- **Implementations**: Descriptive names (e.g., `JpaUserRepository implements UserRepository`).

## 4. Package Organization
- **Package by Feature**: Group related classes together.
  - ✅ Good: `com.company.users` (User, UserService, UserRepository)
  - ❌ Bad: `com.company.services` (all services), `com.company.repositories` (all repos)
- **Sub-packages**: Use for large features.
  - Example: `com.company.users.domain`, `com.company.users.api`

## 5. Design Patterns
- **Repository Pattern**: Abstract data access behind interfaces.
- **Service Layer**: Business logic in service classes, NOT in controllers.
- **Dependency Injection**: Constructor injection, NOT field injection.
- **DTOs**: Separate request/response objects from entities.

## 6. Data Layer
- **Entities**: JPA entities for persistence, NOT for API responses.
- **DTOs**: NEVER return raw entities. Always map to DTOs.
- **Repositories**: Use Spring Data JPA or custom repositories.

## 7. Anti-Patterns (MUST avoid)
- **God Classes**: Classes >300 lines = refactor into smaller classes.
- **Field Injection**: NEVER use `@Autowired` on fields.
  - ❌ Bad: `@Autowired private UserService userService;`
  - ✅ Good: `private final UserService userService; @Autowired public UserController(UserService userService) { this.userService = userService; }`
- **Business Logic in Controllers**: Controllers should delegate to services.
  - ❌ Bad: `@GetMapping("/users") User getUser() { User user = userRepo.findById(1); user.setActive(true); return user; }`
  - ✅ Good: `@GetMapping("/users") UserDto getUser() { return userService.getUser(1); }`
- **Cyclic Dependencies**: Avoid circular package dependencies.
- **Package by Layer**: Don't organize by technical layer (controllers/, services/).

