# iOS Clean Architecture

> **Scope**: Clean Architecture structure for iOS  
> **Applies to**: iOS projects with Clean Architecture  
> **Extends**: swift/frameworks/ios.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no UIKit/SwiftUI dependencies
> **ALWAYS**: UseCase protocols for business operations
> **ALWAYS**: Repository protocols in Domain
> **ALWAYS**: Repository implementations in Data
> **ALWAYS**: Dependency flow: Presentation → Domain ← Data
> 
> **NEVER**: UIKit/SwiftUI imports in Domain
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Data or Presentation
> **NEVER**: Skip UseCase pattern
> **NEVER**: Expose DTOs outside Data layer

## Directory Structure

```
Sources/
├── Domain/
│   ├── Entities/
│   │   └── User.swift
│   ├── UseCases/
│   │   ├── GetUserUseCase.swift
│   │   └── SaveUserUseCase.swift
│   └── Repositories/
│       └── UserRepository.swift (protocol)
├── Data/
│   ├── Repositories/
│   │   └── UserRepositoryImpl.swift
│   ├── DataSources/
│   │   ├── RemoteDataSource.swift
│   │   └── LocalDataSource.swift
│   └── DTOs/
│       └── UserDTO.swift
└── Presentation/
    ├── ViewModels/
    │   └── UserViewModel.swift
    └── Views/
        └── UserViewController.swift
```

## Implementation

### Domain Layer
```swift
// Pure business logic, no UIKit
struct User {
    let id: UUID
    let name: String
}

protocol UserRepository {
    func getUsers() async throws -> [User]
}

class GetUserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        try await repository.getUsers()
    }
}
```

## Benefits
- Framework-independent business logic
- Highly testable
- Scalable for large apps

## When to Use
- Large, complex applications
- Long-term projects

## AI Self-Check

- [ ] Domain layer has no UIKit dependencies?
- [ ] UseCase protocols for business operations?
- [ ] Repository protocols in Domain?
- [ ] Repository implementations in Data?
- [ ] Dependency flow: Presentation → Domain ← Data?
- [ ] No UIKit/SwiftUI in Domain?
- [ ] No Presentation → Data direct dependency?
- [ ] No Domain → Presentation/Data dependency?
- [ ] UseCases pure Swift?
- [ ] Entities in Domain layer?

