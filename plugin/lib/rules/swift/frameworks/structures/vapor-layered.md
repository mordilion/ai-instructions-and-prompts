# Vapor Layered Structure

> **Scope**: Layered structure for Vapor  
> **Applies to**: Vapor projects with layered structure  
> **Extends**: swift/frameworks/vapor.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Controllers in Controllers/ folder
> **ALWAYS**: Models in Models/ folder
> **ALWAYS**: Services in Services/ folder
> **ALWAYS**: DTOs for API contracts
> **ALWAYS**: Controllers thin (delegate to services)
> 
> **NEVER**: Business logic in controllers
> **NEVER**: Controllers access database directly
> **NEVER**: Return models from controllers
> **NEVER**: Fat controllers
> **NEVER**: Skip service layer

## Directory Structure

```
Sources/
├── Controllers/
│   ├── UserController.swift
│   └── AuthController.swift
├── Models/
│   ├── User.swift
│   └── Post.swift
├── Services/
│   ├── UserService.swift
│   └── AuthService.swift
├── Repositories/
│   └── UserRepository.swift
├── DTOs/
│   ├── UserDTO.swift
│   └── CreateUserRequest.swift
├── Migrations/
│   └── CreateUser.swift
└── configure.swift
```

## Implementation

### Controller
```swift
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
    }
}
```

### Service
```swift
struct UserService {
    func getUsers(db: Database) async throws -> [UserDTO] {
        try await User.query(on: db)
            .all()
            .map { $0.toDTO() }
    }
}
```

## Benefits
- Familiar structure
- Clear technical separation
- Easy to understand

## When to Use
- Traditional web applications
- CRUD-focused APIs

## AI Self-Check

- [ ] Controllers in Controllers/ folder?
- [ ] Models in Models/ folder?
- [ ] Services in Services/ folder?
- [ ] DTOs for API contracts?
- [ ] Controllers thin?
- [ ] Services handle business logic?
- [ ] No business logic in controllers?
- [ ] No controllers accessing database directly?
- [ ] No models returned from controllers?
- [ ] Fluent ORM for database?

