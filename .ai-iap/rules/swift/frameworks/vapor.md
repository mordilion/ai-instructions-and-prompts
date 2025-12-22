# Vapor Framework

## Overview
Vapor is a server-side Swift web framework for building APIs and web applications.

## Application Setup

### Main Entry Point
```swift
// ✅ Good - configure application
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = Application(env)
        defer { app.shutdown() }
        
        try configure(app)
        try app.run()
    }
}

// configure.swift
func configure(_ app: Application) throws {
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(CORSMiddleware())
    
    // Register routes
    try routes(app)
    
    // Configure database
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "vapor"
    ), as: .psql)
    
    // Migrations
    app.migrations.add(CreateUser())
}
```

## Routing

### Route Definitions
```swift
// ✅ Good - organized routes
func routes(_ app: Application) throws {
    app.get { req async in
        "Server is running"
    }
    
    let api = app.grouped("api")
    try api.register(collection: UserController())
    try api.register(collection: AuthController())
}

// UserController.swift
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
        try await User.query(on: req.db)
            .all()
            .map { $0.toDTO() }
    }
    
    func show(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user.toDTO()
    }
    
    func create(req: Request) async throws -> UserDTO {
        let input = try req.content.decode(CreateUserRequest.self)
        
        let user = User(
            name: input.name,
            email: input.email
        )
        
        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    func update(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let input = try req.content.decode(UpdateUserRequest.self)
        user.name = input.name ?? user.name
        user.email = input.email ?? user.email
        
        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.delete(on: req.db)
        return .noContent
    }
}
```

## Models (Fluent ORM)

### Model Definition
```swift
// ✅ Good - Fluent model
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
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

// DTO
struct UserDTO: Content {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date?
}

extension User {
    func toDTO() -> UserDTO {
        UserDTO(
            id: id!,
            name: name,
            email: email,
            createdAt: createdAt
        )
    }
}
```

### Relationships
```swift
// ✅ Good - model relationships
final class Post: Model, Content {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Children(for: \.$post)
    var comments: [Comment]
    
    init() { }
}

final class Comment: Model, Content {
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Parent(key: "post_id")
    var post: Post
    
    init() { }
}
```

## Migrations

### Create Migration
```swift
// ✅ Good - migration
struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
```

## Middleware

### Custom Middleware
```swift
// ✅ Good - custom middleware
struct RateLimitMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let key = "rate_limit:\(request.remoteAddress?.description ?? "unknown")"
        
        let count = try await request.application.redis.get(key, as: Int.self) ?? 0
        
        if count >= 100 {
            throw Abort(.tooManyRequests)
        }
        
        try await request.application.redis.increment(key)
        try await request.application.redis.expire(key, after: 60)
        
        return try await next.respond(to: request)
    }
}

// Register middleware
app.middleware.use(RateLimitMiddleware())
```

## Authentication

### JWT Authentication
```swift
// ✅ Good - JWT authentication
import JWT

struct UserPayload: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case email
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var email: String
    
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

// Login route
func login(req: Request) async throws -> TokenResponse {
    let credentials = try req.content.decode(LoginRequest.self)
    
    guard let user = try await User.query(on: req.db)
        .filter(\.$email == credentials.email)
        .first() else {
        throw Abort(.unauthorized)
    }
    
    guard try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
        throw Abort(.unauthorized)
    }
    
    let payload = UserPayload(
        subject: SubjectClaim(value: user.id!.uuidString),
        expiration: ExpirationClaim(value: Date().addingTimeInterval(3600)),
        email: user.email
    )
    
    let token = try req.jwt.sign(payload)
    
    return TokenResponse(token: token)
}

// Protected routes
let protected = app.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())
protected.get("profile") { req async throws -> UserDTO in
    let payload = try req.auth.require(UserPayload.self)
    // ...
}
```

## Validation

### Request Validation
```swift
// ✅ Good - validated input
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

// Use in controller
func create(req: Request) async throws -> UserDTO {
    try CreateUserRequest.validate(content: req)
    let input = try req.content.decode(CreateUserRequest.self)
    // ...
}
```

## Error Handling

### Custom Errors
```swift
// ✅ Good - custom error types
enum UserError: Error {
    case notFound
    case emailExists
    case invalidCredentials
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .notFound:
            return .notFound
        case .emailExists:
            return .conflict
        case .invalidCredentials:
            return .unauthorized
        }
    }
    
    var reason: String {
        switch self {
        case .notFound:
            return "User not found"
        case .emailExists:
            return "Email already exists"
        case .invalidCredentials:
            return "Invalid credentials"
        }
    }
}
```

## Testing

### Application Testing
```swift
// ✅ Good - integration tests
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
        // Given
        let user = User(name: "John", email: "john@example.com")
        try await user.save(on: app.db)
        
        // When
        try app.test(.GET, "/api/users") { res in
            // Then
            XCTAssertEqual(res.status, .ok)
            
            let users = try res.content.decode([UserDTO].self)
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users.first?.name, "John")
        }
    }
    
    func testCreateUser() async throws {
        // Given
        let input = CreateUserRequest(
            name: "Jane",
            email: "jane@example.com",
            password: "password123"
        )
        
        // When
        try app.test(.POST, "/api/users", beforeRequest: { req in
            try req.content.encode(input)
        }, afterResponse: { res in
            // Then
            XCTAssertEqual(res.status, .ok)
            
            let user = try res.content.decode(UserDTO.self)
            XCTAssertEqual(user.name, "Jane")
            XCTAssertEqual(user.email, "jane@example.com")
        })
    }
    
    func testGetUser_NotFound() async throws {
        // When
        try app.test(.GET, "/api/users/\(UUID())") { res in
            // Then
            XCTAssertEqual(res.status, .notFound)
        }
    }
}
```

## Best Practices

### 1. Use Dependency Injection
```swift
// ✅ Good - inject dependencies
struct UserService {
    let database: Database
    let redis: RedisClient
    
    func createUser(_ input: CreateUserRequest) async throws -> User {
        // Check cache
        if let cached = try await redis.get("user:\(input.email)", as: User.self) {
            throw UserError.emailExists
        }
        
        // Create user
        let user = User(name: input.name, email: input.email)
        try await user.save(on: database)
        
        // Cache
        try await redis.set("user:\(user.id!)", to: user)
        
        return user
    }
}
```

### 2. Use Repository Pattern
```swift
// ✅ Good - repository pattern
protocol UserRepository {
    func find(_ id: UUID) async throws -> User?
    func findByEmail(_ email: String) async throws -> User?
    func create(_ user: User) async throws
    func update(_ user: User) async throws
    func delete(_ id: UUID) async throws
}

struct DatabaseUserRepository: UserRepository {
    let database: Database
    
    func find(_ id: UUID) async throws -> User? {
        try await User.find(id, on: database)
    }
    
    func findByEmail(_ email: String) async throws -> User? {
        try await User.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    func create(_ user: User) async throws {
        try await user.save(on: database)
    }
    
    func update(_ user: User) async throws {
        try await user.save(on: database)
    }
    
    func delete(_ id: UUID) async throws {
        guard let user = try await find(id) else {
            throw UserError.notFound
        }
        try await user.delete(on: database)
    }
}
```

### 3. Environment Configuration
```swift
// ✅ Good - environment-based config
extension Application {
    var config: AppConfig {
        AppConfig(
            jwtSecret: Environment.get("JWT_SECRET") ?? "secret",
            databaseURL: Environment.get("DATABASE_URL") ?? "postgres://localhost/vapor",
            redisURL: Environment.get("REDIS_URL") ?? "redis://localhost:6379"
        )
    }
}

struct AppConfig {
    let jwtSecret: String
    let databaseURL: String
    let redisURL: String
}
```

### 4. Use Content Protocol
```swift
// ✅ Good - conform to Content for automatic encoding/decoding
struct UserResponse: Content {
    let id: UUID
    let name: String
    let email: String
}
```

### 5. Async/Await Throughout
```swift
// ✅ Good - use async/await for all async operations
func getAllUsers(req: Request) async throws -> [UserDTO] {
    let users = try await User.query(on: req.db).all()
    return users.map { $0.toDTO() }
}
```

