# Vapor Clean Architecture

> **Scope**: Clean Architecture structure for Vapor  
> **Applies to**: Vapor projects with Clean Architecture  
> **Extends**: swift/frameworks/vapor.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no Vapor dependencies
> **ALWAYS**: UseCase protocols for business operations
> **ALWAYS**: Repository protocols in Domain
> **ALWAYS**: Repository implementations in Data
> **ALWAYS**: Controllers in Presentation layer
> 
> **NEVER**: Vapor imports in Domain
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Data or Presentation
> **NEVER**: Business logic in controllers
> **NEVER**: Skip UseCase pattern

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

## AI Self-Check

- [ ] Domain layer has no Vapor dependencies?
- [ ] UseCase protocols for business operations?
- [ ] Repository protocols in Domain?
- [ ] Repository implementations in Data?
- [ ] Controllers in Presentation?
- [ ] No Vapor imports in Domain?
- [ ] No Presentation → Data direct dependency?
- [ ] No business logic in controllers?
- [ ] UseCases pure Swift?
- [ ] Dependency flow correct?

