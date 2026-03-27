# Vapor Modular Structure

> **Scope**: Modular structure for Vapor  
> **Applies to**: Vapor projects with modular structure  
> **Extends**: swift/frameworks/vapor.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Features in Features/ folder
> **ALWAYS**: Co-locate feature files (models, controllers, services)
> **ALWAYS**: Common folder for cross-feature code
> **ALWAYS**: Features independent
> **ALWAYS**: Repository pattern per feature
> 
> **NEVER**: Cross-feature dependencies (use Common/)
> **NEVER**: Split feature across locations
> **NEVER**: Generic services folder
> **NEVER**: Share state between features
> **NEVER**: Deep folder nesting

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

## AI Self-Check

- [ ] Features in Features/ folder?
- [ ] Feature files co-located?
- [ ] Common folder for cross-feature code?
- [ ] Features independent?
- [ ] Repository pattern per feature?
- [ ] No cross-feature dependencies?
- [ ] No split features?
- [ ] No generic services folder?
- [ ] Features self-contained?
- [ ] Minimal feature coupling?

