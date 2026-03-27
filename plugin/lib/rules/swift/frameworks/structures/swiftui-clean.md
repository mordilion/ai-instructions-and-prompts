# SwiftUI Clean Architecture

> **Scope**: Clean Architecture structure for SwiftUI  
> **Applies to**: SwiftUI projects with Clean Architecture  
> **Extends**: swift/frameworks/swiftui.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Domain layer has no SwiftUI dependencies
> **ALWAYS**: UseCase protocols for business operations
> **ALWAYS**: Repository protocols in Domain
> **ALWAYS**: Repository implementations in Data
> **ALWAYS**: Dependency flow: Presentation → Domain ← Data
> 
> **NEVER**: SwiftUI imports in Domain
> **NEVER**: Presentation depends on Data directly
> **NEVER**: Domain depends on Data or Presentation
> **NEVER**: Skip UseCase pattern
> **NEVER**: Expose DTOs outside Data layer

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

## AI Self-Check

- [ ] Domain layer has no SwiftUI dependencies?
- [ ] UseCase protocols for business operations?
- [ ] Repository protocols in Domain?
- [ ] Repository implementations in Data?
- [ ] Dependency flow: Presentation → Domain ← Data?
- [ ] No SwiftUI imports in Domain?
- [ ] No Presentation → Data direct dependency?
- [ ] No Domain → Presentation/Data dependency?
- [ ] UseCases pure Swift?
- [ ] Entities in Domain?

