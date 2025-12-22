# Swift Code Style

## General Rules

- **Swift 5.9+**
- **SwiftLint** for linting
- **Swift Format** for formatting
- **Immutability** preferred

## Naming Conventions

```swift
// PascalCase for types
struct User {}
class UserService {}
enum UserRole {}

// camelCase for variables, functions
let userName = "John"
func getUser() {}

// UPPER_SNAKE_CASE for static constants
static let MAX_ATTEMPTS = 3
```

## Type Annotations

```swift
// Explicit for public APIs
func getUser(id: UUID) -> User? {
    return users[id]
}

// Infer for locals
let count = 10
var name = "John"
```

## Functions

```swift
// Use trailing closures
users.map { $0.name }

// Named parameters
func createUser(name: String, email: String) -> User {
    User(name: name, email: email)
}
```

## Optionals

```swift
// Optional binding
if let user = findUser(id: id) {
    print(user.name)
}

// Guard let
guard let user = findUser(id: id) else { return }

// Optional chaining
let email = user?.profile?.email
```

## Best Practices

```swift
// Use value types
struct User {}

// Immutability
let users: [User] = []

// Async/await
async func fetchData() -> Data {
    try await URLSession.shared.data(from: url).0
}

// Pattern matching
switch result {
case .success(let user):
    print(user)
case .failure(let error):
    print(error)
}
```
