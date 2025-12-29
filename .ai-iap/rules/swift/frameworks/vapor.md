# Vapor Framework

> **Scope**: Server-side Swift web framework for building APIs
> **Applies to**: Swift files using Vapor
> **Extends**: swift/architecture.md, swift/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use async/await for all route handlers
> **ALWAYS**: Use Fluent ORM for database operations
> **ALWAYS**: Validate input with `req.content.decode()`
> **ALWAYS**: Use dependency injection via `Application`
> **ALWAYS**: Handle errors with `Abort` for HTTP responses
> 
> **NEVER**: Block event loop with synchronous operations
> **NEVER**: Skip input validation
> **NEVER**: Use force unwraps without error handling
> **NEVER**: Hardcode database credentials
> **NEVER**: Forget to run migrations

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| **RouteCollection** | Grouping related routes | Organized, testable |
| **Fluent** | Database ORM | Type-safe queries |
| **Middleware** | Cross-cutting concerns | Auth, CORS, rate limiting |
| **DTO Pattern** | API responses | Decoupled from models |

## Core Patterns

### Application Setup

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
    app.migrations.add(CreateUser())
    try routes(app)
}
```

### Routes (RouteCollection)

```swift
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.get(":id", use: show)
        users.post(use: create)
        users.put(":id", use: update)
        users.delete(":id", use: delete)
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

### Models (Fluent ORM)

```swift
final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
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

### Migrations

```swift
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .unique(on: "email")
            .field("created_at", .datetime)
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

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **No Validation** | `req.body` directly | `req.content.decode()` | Type safety, security |
| **Blocking Event Loop** | Synchronous I/O | async/await | Performance |
| **Force Unwrap** | `user!` | `guard let user = ...` | Crash prevention |
| **No Error Handling** | Ignoring throws | `throw Abort(.notFound)` | User experience |
| **Hardcoded Credentials** | In code | Environment variables | Security |

### Anti-Pattern: No Validation (SECURITY RISK)

```swift
// ❌ WRONG: No validation
func create(req: Request) async throws -> User {
    let name = req.body.string  // Unsafe!
    let user = User(name: name)
    try await user.save(on: req.db)
    return user
}

// ✅ CORRECT: Validated input
func create(req: Request) async throws -> UserDTO {
    let input = try req.content.decode(CreateUserRequest.self)
    let user = User(name: input.name, email: input.email)
    try await user.save(on: req.db)
    return user.toDTO()
}
```

### Anti-Pattern: Blocking Event Loop (PERFORMANCE DISASTER)

```swift
// ❌ WRONG: Blocking
func index(req: Request) throws -> [User] {
    return try User.query(on: req.db).all().wait()  // Blocks thread!
}

// ✅ CORRECT: Async/await
func index(req: Request) async throws -> [UserDTO] {
    try await User.query(on: req.db).all().map { $0.toDTO() }
}
```

## AI Self-Check (Verify BEFORE generating Vapor code)

- [ ] All routes use async/await?
- [ ] Input validation with decode()?
- [ ] Using Fluent ORM for database?
- [ ] Proper error handling with Abort?
- [ ] Migrations defined?
- [ ] Using RouteCollection pattern?
- [ ] DTO pattern for responses?
- [ ] Middleware for cross-cutting concerns?
- [ ] No hardcoded credentials?
- [ ] No force unwrapping without guards?

## Key Features

| Feature | Purpose | Keywords |
|---------|---------|----------|
| **Fluent ORM** | Database abstraction | `@Field`, `@ID`, `query()` |
| **RouteCollection** | Route grouping | Organized endpoints |
| **Middleware** | Request/response pipeline | Auth, CORS, logging |
| **Content** | Request/response coding | JSON, form data |
| **JWT** | Authentication | Token-based auth |
| **WebSockets** | Real-time | Bidirectional communication |

## Authentication (JWT)

```swift
app.jwt.signers.use(.hs256(key: "secret"))

struct SessionToken: Content, Authenticatable, JWTPayload {
    var sub: SubjectClaim
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

func login(req: Request) async throws -> String {
    let credentials = try req.content.decode(LoginRequest.self)
    guard let user = try await User.query(on: req.db).filter(\.$email == credentials.email).first() else {
        throw Abort(.unauthorized)
    }
    
    let payload = SessionToken(sub: .init(value: user.id!.uuidString), exp: .init(value: .distantFuture))
    return try req.jwt.sign(payload)
}
```

## Testing

```swift
@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDown() {
        app.shutdown()
    }
    
    func testCreate() async throws {
        try await app.test(.POST, "users", beforeRequest: { req in
            try req.content.encode(["name": "John", "email": "john@example.com"])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
        })
    }
}
```

## Best Practices

**MUST**:
- async/await for all I/O
- Input validation
- Fluent ORM
- Error handling with Abort
- Environment variables

**SHOULD**:
- RouteCollection pattern
- DTO pattern
- Middleware for cross-cutting
- JWT for auth
- Migrations for schema

**AVOID**:
- Blocking operations
- Force unwraps
- Hardcoded credentials
- Skipping validation
- Direct model exposure
