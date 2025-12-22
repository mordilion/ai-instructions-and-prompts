# Vapor Framework

## Overview
Vapor: server-side Swift web framework for building APIs.

## Application Setup

```swift
@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        let app = Application(env)
        defer { app.shutdown() }
        try configure(app)
        try app.run()
    }
}

func configure(_ app: Application) throws {
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    try routes(app)
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: "vapor",
        password: "password",
        database: "vapor"
    ), as: .psql)
    
    app.migrations.add(CreateUser())
}
```

## Routing

```swift
func routes(_ app: Application) throws {
    let api = app.grouped("api")
    try api.register(collection: UserController())
}

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
    
    func show(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self),
              let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return user.toDTO()
    }
    
    func create(req: Request) async throws -> UserDTO {
        let input = try req.content.decode(CreateUserRequest.self)
        let user = User(name: input.name, email: input.email)
        try await user.save(on: req.db)
        return user.toDTO()
    }
}
```

## Models (Fluent ORM)

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
    
    init() { }
    
    init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

struct UserDTO: Content {
    let id: UUID
    let name: String
    let email: String
}

extension User {
    func toDTO() -> UserDTO {
        UserDTO(id: id!, name: name, email: email)
    }
}
```

### Relationships
```swift
final class Post: Model {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Children(for: \.$post)
    var comments: [Comment]
}
```

## Migrations

```swift
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
```

## Middleware

```swift
struct RateLimitMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let key = "rate_limit:\(request.remoteAddress?.description ?? "unknown")"
        let count = try await request.application.redis.get(key, as: Int.self) ?? 0
        
        if count >= 100 { throw Abort(.tooManyRequests) }
        
        try await request.application.redis.increment(key)
        return try await next.respond(to: request)
    }
}
```

## Authentication

### JWT
```swift
import JWT

struct UserPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var email: String
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

func login(req: Request) async throws -> TokenResponse {
    let credentials = try req.content.decode(LoginRequest.self)
    
    guard let user = try await User.query(on: req.db)
        .filter(\.$email == credentials.email)
        .first(),
          try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
        throw Abort(.unauthorized)
    }
    
    let payload = UserPayload(
        subject: SubjectClaim(value: user.id!.uuidString),
        expiration: ExpirationClaim(value: Date().addingTimeInterval(3600)),
        email: user.email
    )
    
    return TokenResponse(token: try req.jwt.sign(payload))
}

let protected = app.grouped(UserPayload.authenticator())
protected.get("profile") { req async throws -> UserDTO in
    let payload = try req.auth.require(UserPayload.self)
    // ...
}
```

## Validation

```swift
struct CreateUserRequest: Content, Validatable {
    let name: String
    let email: String
    let password: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .count(2...100))
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

func create(req: Request) async throws -> UserDTO {
    try CreateUserRequest.validate(content: req)
    let input = try req.content.decode(CreateUserRequest.self)
    // ...
}
```

## Error Handling

```swift
enum UserError: Error, AbortError {
    case notFound
    case emailExists
    
    var status: HTTPResponseStatus {
        switch self {
        case .notFound: return .notFound
        case .emailExists: return .conflict
        }
    }
    
    var reason: String {
        switch self {
        case .notFound: return "User not found"
        case .emailExists: return "Email already exists"
        }
    }
}
```

## Testing

```swift
@testable import App
import XCTVapor

final class UserControllerTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        app = Application(.testing)
        try configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws {
        try await app.autoRevert()
        app.shutdown()
    }
    
    func testGetUsers() async throws {
        let user = User(name: "John", email: "john@test.com")
        try await user.save(on: app.db)
        
        try app.test(.GET, "/api/users") { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([UserDTO].self)
            XCTAssertEqual(users.count, 1)
        }
    }
}
```

## Best Practices

**MUST**:
- Use `async`/`await` (Vapor 4+ is fully async)
- Use Fluent ORM for database operations (NOT raw SQL)
- Validate all input using `Validatable` protocol
- Use middleware for cross-cutting concerns (auth, logging, CORS)
- Use environment variables for configuration (NO hardcoded secrets)

**SHOULD**:
- Use repository pattern for complex data access
- Use `Content` protocol for request/response types
- Use `@Middleware` for reusable route logic
- Use Vapor's built-in JWT support (NOT custom implementations)
- Structure routes with `RouteCollection`

**AVOID**:
- Blocking operations in routes (use async/await)
- Exposing Fluent models directly (use DTOs)
- Hardcoded configuration (use environment variables)
- Manual JSON parsing (use `Content` protocol)
- Not validating input (security risk)

## Common Patterns

### Repository Pattern
```swift
// ✅ GOOD: Repository for testability
protocol UserRepository {
    func getAll() async throws -> [User]
    func find(_ id: UUID) async throws -> User?
    func create(_ user: User) async throws -> User
}

struct DatabaseUserRepository: UserRepository {
    let database: Database
    
    func getAll() async throws -> [User] {
        try await User.query(on: database).all()
    }
}

// Usage in route
func boot(routes: RoutesBuilder) throws {
    let repo: UserRepository = DatabaseUserRepository(database: app.db)
    routes.get("users") { req async throws in
        try await repo.getAll()
    }
}

// ❌ BAD: Direct database access in routes
routes.get("users") { req async throws in
    try await User.query(on: req.db).all()  // Hard to test, tightly coupled
}
```

### Environment Configuration
```swift
// ✅ GOOD: Environment-based config
struct AppConfig {
    let jwtSecret: String
    let databaseURL: String
    
    static func load() -> AppConfig {
        AppConfig(
            jwtSecret: Environment.get("JWT_SECRET") ?? fatalError("JWT_SECRET required"),
            databaseURL: Environment.get("DATABASE_URL") ?? fatalError("DATABASE_URL required")
        )
    }
}

extension Application {
    var config: AppConfig {
        AppConfig.load()
    }
}

// ❌ BAD: Hardcoded secrets
let jwtSecret = "hardcoded-secret-key"  // NEVER do this!
```

### Content Protocol (Type-Safe JSON)
```swift
// ✅ GOOD: Use Content for automatic encoding/decoding
struct UserResponse: Content {
    let id: UUID
    let name: String
    let email: String
}

routes.get("users", ":id") { req async throws -> UserResponse in
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw Abort(.badRequest)
    }
    let user = try await User.find(id, on: req.db)
    return UserResponse(user)  // Automatically encoded to JSON
}

// ❌ BAD: Manual JSON encoding
routes.get("users", ":id") { req async throws -> Response in
    let json = try JSONEncoder().encode(user)  // Manual, error-prone
    return Response(body: .init(data: json))
}
```
