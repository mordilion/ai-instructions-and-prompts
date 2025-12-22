# SwiftUI Clean Architecture

## Overview
Clean Architecture for SwiftUI with domain-driven design and framework-independent business logic.

## Directory Structure

```
Sources/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/ (protocols)
├── Data/
│   ├── Repositories/
│   ├── DataSources/
│   └── DTOs/
└── Presentation/
    ├── ViewModels/
    └── Views/
```

## Implementation

### Domain
```swift
struct User {
    let id: UUID
    let name: String
}

protocol UserRepository {
    func getUsers() async throws -> [User]
}

struct GetUsersUseCase {
    private let repository: UserRepository
    
    func execute() async throws -> [User] {
        try await repository.getUsers()
    }
}
```

### ViewModel
```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    private let getUsersUseCase: GetUsersUseCase
    
    init(getUsersUseCase: GetUsersUseCase) {
        self.getUsersUseCase = getUsersUseCase
    }
    
    func loadUsers() async {
        do {
            users = try await getUsersUseCase.execute()
        } catch {
            print("Error: \(error)")
        }
    }
}
```

## Benefits
- Framework-independent
- Highly testable
- Scalable

## When to Use
- Large SwiftUI apps
- Complex business logic

