# Vapor Framework

> **Scope**: Server-side Swift web framework
> **Applies to**: Swift files using Vapor
> **Extends**: swift/architecture.md, swift/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use async/await for handlers
> **ALWAYS**: Use Fluent ORM for database
> **ALWAYS**: Validate with `req.content.decode()`
> **ALWAYS**: Use DI via `Application`
> **ALWAYS**: Handle errors with `Abort`
> 
> **NEVER**: Block event loop
> **NEVER**: Skip validation
> **NEVER**: Force unwrap without guards
> **NEVER**: Hardcode credentials

## Core Patterns

### Setup

```swift
@main
enum Entrypoint {
    static func main() async throws {
        let app = Application(try Environment.detect())
        defer { app.shutdown() }
        try configure(app)
        try app.run()
    }
}

func configure(_ app: Application) throws {
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "password", database: "vapor"), as: .psql)
    try routes(app)
}
```

### Routes

```swift
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.get(":id", use: show)
    }
    
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }
    
    func create(req: Request) async throws -> UserDTO {
        let input = try req.content.decode(CreateUserRequest.self)
        let user = User(name: input.name, email: input.email)
        try await user.save(on: req.db)
        return user.toDTO()
    }
}
```

### Model (Fluent)

```swift
final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Children(for: \.$user)
    var posts: [Post]
    
    init() {}
    init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
```

### Migration

```swift
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
```

### Middleware

```swift
struct AuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        
        let payload = try request.jwt.verify(token, as: SessionToken.self)
        request.auth.login(payload)
        
        return try await next.respond(to: request)
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Blocking** | `Thread.sleep()` | `delay()` |
| **No Validation** | Direct access | `req.content.decode()` |
| **No DI** | `UserService()` | `inject<UserService>()` |
| **Force Unwrap** | `user!` | `guard let user = ...` |

### Anti-Pattern: Blocking

```swift
// ❌ WRONG
get("/users") {
    Thread.sleep(1)  // Blocks!
    return users
}

// ✅ CORRECT
get("/users") {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return users
}
```

## AI Self-Check

- [ ] async/await for I/O?
- [ ] Fluent ORM?
- [ ] Input validation?
- [ ] DI configured?
- [ ] Error handling with Abort?
- [ ] Migrations defined?
- [ ] RouteCollection pattern?
- [ ] No blocking operations?
- [ ] Guard statements for optionals?
- [ ] Environment variables not hardcoded?

## Key Features

| Feature | Purpose |
|---------|---------|
| Fluent ORM | Database abstraction |
| RouteCollection | Route grouping |
| Middleware | Request pipeline |
| Content | JSON coding |
| JWT | Authentication |

## Best Practices

**MUST**: async/await, Fluent, validation, DI, Abort errors
**SHOULD**: RouteCollection, middleware, migrations, JWT
**AVOID**: Blocking, skipping validation, force unwraps, hardcoded config
