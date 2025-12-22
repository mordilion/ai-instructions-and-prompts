# Swift Architecture

## Overview
Protocol-oriented, value-type architecture with immutability and type safety.

## Core Principles

### Protocol-Oriented Programming
```swift
protocol UserRepository {
    func findById(_ id: UUID) async throws -> User?
    func save(_ user: User) async throws
}

struct DatabaseUserRepository: UserRepository {
    func findById(_ id: UUID) async throws -> User? {
        // Implementation
    }
}
```

### Value Types
```swift
struct User {
    let id: UUID
    let name: String
    let email: String
    
    func with(name: String) -> User {
        User(id: id, name: name, email: email)
    }
}
```

### Async/Await
```swift
func fetchUser(id: UUID) async throws -> User {
    let user = try await repository.findById(id)
    guard let user = user else {
        throw UserError.notFound(id)
    }
    return user
}
```

## Error Handling

```swift
enum UserError: Error {
    case notFound(UUID)
    case invalidEmail(String)
}

do {
    let user = try await service.fetchUser(id: id)
} catch UserError.notFound(let id) {
    print("User \(id) not found")
}
```

## Best Practices

### Optionals
```swift
// Optional chaining
let email = user?.profile?.email

// Nil coalescing
let name = user?.name ?? "Anonymous"

// Guard let
guard let user = findUser(id) else { return }
```

### Result Type
```swift
func fetchUser(id: UUID) -> Result<User, Error> {
    // Implementation
}
```

### Property Wrappers
```swift
@propertyWrapper
struct Capitalized {
    private var value: String
    
    var wrappedValue: String {
        get { value }
        set { value = newValue.capitalized }
    }
}
```
