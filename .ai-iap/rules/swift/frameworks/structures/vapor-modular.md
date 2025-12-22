# Vapor Modular Structure

## Overview
Feature-first modular structure for Vapor applications.

## Directory Structure

```
Sources/
├── Features/
│   ├── User/
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── Controllers/
│   │   │   └── UserController.swift
│   │   ├── Services/
│   │   │   └── UserService.swift
│   │   └── Migrations/
│   │       └── CreateUser.swift
│   └── Auth/
├── Common/
│   ├── Middleware/
│   └── Extensions/
└── configure.swift
```

## Implementation

### Model
```swift
final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() { }
}
```

### Controller
```swift
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
    }
}
```

## Benefits
- Simple and intuitive
- Fast development
- All related code together

## When to Use
- Small to medium APIs
- Microservices

