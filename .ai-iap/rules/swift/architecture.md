# Swift Architecture Guidelines

## Core Principles

### 1. Protocol-Oriented Programming
- Favor protocols over class inheritance
- Use protocol extensions for default implementations
- Compose behaviors through protocol conformance
- Enable dependency injection through protocols

### 2. Value Types First
- Prefer structs over classes when possible
- Use classes only when reference semantics are needed
- Leverage copy-on-write for performance
- Immutable by default

### 3. Dependency Injection
- Use constructor injection as primary mechanism
- Keep dependencies explicit and testable
- Avoid singletons unless absolutely necessary
- Use protocols to define dependencies

### 4. SOLID Principles
- Single Responsibility: One class, one purpose
- Open/Closed: Open for extension, closed for modification
- Liskov Substitution: Subtypes must be substitutable
- Interface Segregation: Many specific protocols over one general
- Dependency Inversion: Depend on abstractions, not concretions

### 5. Separation of Concerns
- Separate UI from business logic
- Keep ViewControllers/Views lightweight
- Extract reusable logic into separate types
- Use coordinators/routers for navigation

## Architecture Patterns

### MVVM (Recommended for SwiftUI/UIKit)
```
View ←→ ViewModel → Model
         ↓
    Business Logic
```

- View: UI display only
- ViewModel: Presentation logic, state management
- Model: Business logic, data structures

### MVI (Model-View-Intent)
```
View → Intent → State → View
```

- Unidirectional data flow
- Predictable state management
- Excellent for debugging

### Clean Architecture
```
Presentation → Domain ← Data
     ↓           ↓        ↓
   UIKit     Pure Swift  Network/DB
```

- Framework-independent business logic
- Testable core
- Clear boundaries

## Code Organization

### Feature-First (Recommended)
```
Sources/
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Models/
│   │   └── Services/
│   └── Profile/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
└── Common/
    ├── Extensions/
    ├── Utilities/
    └── Protocols/
```

### Layer-First
```
Sources/
├── Views/
├── ViewModels/
├── Models/
├── Services/
├── Repositories/
└── Utilities/
```

## Anti-Patterns

### ❌ Avoid
- Massive View Controllers (keep < 200 lines)
- Singletons everywhere
- Force unwrapping (`!`) without guard
- Implicitly unwrapped optionals (`!`) unless necessary (IBOutlets)
- Global mutable state
- Deep inheritance hierarchies
- Tight coupling to UIKit/SwiftUI

### ✅ Prefer
- Small, focused types
- Dependency injection
- Optional binding (`if let`, `guard let`)
- Explicit optionals
- Immutable structures
- Protocol composition
- Framework-independent business logic

## Concurrency

### Modern Swift Concurrency (async/await)
```swift
// ✅ Good - structured concurrency
actor DataCache {
    private var cache: [String: Data] = [:]
    
    func get(_ key: String) -> Data? {
        cache[key]
    }
    
    func set(_ key: String, _ value: Data) {
        cache[key] = value
    }
}

// ✅ Good - async/await
func fetchUser() async throws -> User {
    let data = try await networkService.fetch("/user")
    return try decoder.decode(User.self, from: data)
}
```

### Use Combine for Reactive Streams
```swift
// ✅ Good - Combine for reactive programming
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUsers() {
        userService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] users in
                    self?.users = users
                }
            )
            .store(in: &cancellables)
    }
}
```

## Best Practices

### 1. Use Guard for Early Returns
```swift
// ✅ Good
func process(user: User?) {
    guard let user = user else { return }
    // Happy path at main indentation level
}
```

### 2. Leverage Extensions
```swift
// ✅ Good - organize code by protocol conformance
extension UserViewModel: Equatable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
```

### 3. Use Result Type
```swift
// ✅ Good - explicit error handling
func fetchData() -> Result<Data, NetworkError> {
    // Implementation
}
```

### 4. Prefer Composition Over Inheritance
```swift
// ✅ Good - protocol composition
protocol Nameable {
    var name: String { get }
}

protocol Identifiable {
    var id: UUID { get }
}

struct User: Nameable, Identifiable {
    let id: UUID
    let name: String
}
```

