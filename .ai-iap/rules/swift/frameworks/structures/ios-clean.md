# iOS Clean Architecture

## Overview
Clean Architecture with strict separation between domain, data, and presentation layers.

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

