# Vapor Clean Architecture

## Overview
Clean Architecture for Vapor with strict separation of concerns.

## Directory Structure

```
Sources/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/ (protocols)
├── Data/
│   ├── Repositories/
│   └── DTOs/
├── Presentation/
│   ├── Controllers/
│   └── DTOs/
└── Infrastructure/
    ├── Database/
    └── Migrations/
```

## Implementation

### Domain
```swift
struct User {
    let id: UUID
    let name: String
}

protocol UserRepository {
    func getAll() async throws -> [User]
}

struct GetUsersUseCase {
    private let repository: UserRepository
    
    func execute() async throws -> [User] {
        try await repository.getAll()
    }
}
```

### Controller
```swift
struct UserController: RouteCollection {
    private let getUsersUseCase: GetUsersUseCase
    
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await getUsersUseCase.execute()
        return users.map { $0.toDTO() }
    }
}
```

## Benefits
- Framework-independent
- Highly testable
- Scalable

## When to Use
- Large, complex APIs
- Long-term projects

