# Vapor Layered Structure

## Overview
Traditional layered architecture separating concerns by technical responsibilities.

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

