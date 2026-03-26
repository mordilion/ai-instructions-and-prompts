# Swift Authentication (JWT/OAuth) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Implementing authentication for Swift server API (Vapor)  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT AUTHENTICATION - JWT/OAUTH
========================================

CONTEXT:
You are implementing JWT and OAuth authentication for a Swift server application using Vapor.

CRITICAL REQUIREMENTS:
- ALWAYS use Bcrypt for password hashing
- ALWAYS validate JWT tokens on protected routes
- NEVER store passwords in plain text
- NEVER expose JWT secrets

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - JWT AUTHENTICATION
========================================

Add dependencies to Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2")
]
```

Configure JWT in configure.swift:
```swift
import Vapor
import JWT

public func configure(_ app: Application) throws {
    // JWT configuration
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "secret"))
    
    try routes(app)
}
```

Create JWT payload:
```swift
import JWT

struct UserPayload: JWTPayload {
    let userId: UUID
    let email: String
    let exp: ExpirationClaim
    
    init(userId: UUID, email: String) {
        self.userId = userId
        self.email = email
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(86400)) // 24 hours
    }
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
```

Create auth middleware:
```swift
import Vapor
import JWT

struct JWTAuthenticator: AsyncBearerAuthenticator {
    typealias User = AppUser
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        do {
            let payload = try request.jwt.verify(as: UserPayload.self)
            guard let user = try await AppUser.find(payload.userId, on: request.db) else {
                return
            }
            request.auth.login(user)
        } catch {
            // Invalid token
        }
    }
}
```

Deliverable: JWT configured

========================================
PHASE 2 - USER MODEL & AUTH ENDPOINTS
========================================

Create user model:

```swift
import Vapor
import Fluent

final class AppUser: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    init() {}
    
    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("email", .string, .required)
            .unique(on: "email")
            .field("password_hash", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
```

Create auth controller:
```swift
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
        
        let protected = auth.grouped(JWTAuthenticator())
        protected.get("me", use: getMe)
    }
    
    func register(req: Request) async throws -> TokenResponse {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)
        
        // Check if user exists
        if let _ = try await AppUser.query(on: req.db)
            .filter(\.$email == registerRequest.email)
            .first() {
            throw Abort(.conflict, reason: "User already exists")
        }
        
        // Hash password
        let passwordHash = try Bcrypt.hash(registerRequest.password)
        
        // Create user
        let user = AppUser(email: registerRequest.email, passwordHash: passwordHash)
        try await user.save(on: req.db)
        
        // Generate token
        let payload = UserPayload(userId: user.id!, email: user.email)
        let token = try req.jwt.sign(payload)
        
        return TokenResponse(token: token)
    }
    
    func login(req: Request) async throws -> TokenResponse {
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        // Find user
        guard let user = try await AppUser.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        // Verify password
        guard try Bcrypt.verify(loginRequest.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        // Generate token
        let payload = UserPayload(userId: user.id!, email: user.email)
        let token = try req.jwt.sign(payload)
        
        return TokenResponse(token: token)
    }
    
    func getMe(req: Request) async throws -> UserResponse {
        let user = try req.auth.require(AppUser.self)
        return UserResponse(id: user.id!, email: user.email)
    }
}

struct RegisterRequest: Content, Validatable {
    let email: String
    let password: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

struct TokenResponse: Content {
    let token: String
}

struct UserResponse: Content {
    let id: UUID
    let email: String
}
```

Deliverable: Auth endpoints working

========================================
PHASE 3 - OAUTH 2.0 (OPTIONAL)
========================================

Add Imperial for OAuth:

```swift
dependencies: [
    .package(url: "https://github.com/vapor-community/Imperial.git", from: "1.0.0")
]
```

Configure Google OAuth:
```swift
import Imperial

app.sessions.use(.fluent)

try app.oAuth(from: Google.self, authenticate: "google", callback: "http://localhost:8080/auth/google/callback") { request, token in
    // Handle OAuth callback
    let googleUser = try await GoogleAPI.getUser(on: request, with: token)
    
    // Find or create user
    let user = try await AppUser.query(on: request.db)
        .filter(\.$email == googleUser.email)
        .first() ?? {
            let newUser = AppUser(email: googleUser.email, passwordHash: "")
            try await newUser.save(on: request.db)
            return newUser
        }()
    
    // Generate JWT
    let payload = UserPayload(userId: user.id!, email: user.email)
    let jwtToken = try request.jwt.sign(payload)
    
    return request.redirect(to: "/auth-success?token=\(jwtToken)")
}
```

Deliverable: OAuth configured

========================================
PHASE 4 - SECURITY BEST PRACTICES
========================================

Implement security measures:

```swift
// Rate limiting
import RateLimiter

app.middleware.use(RateLimitMiddleware(
    config: .init(maxRequests: 5, per: .minute)
))

// Password validation
extension RegisterRequest {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
        validations.add("password", as: String.self, is: .characterSet(.alphanumerics + .punctuationCharacters))
    }
}

// Refresh tokens
struct RefreshToken: Model {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: AppUser
    
    @Field(key: "expires_at")
    var expiresAt: Date
}
```

Deliverable: Enhanced security

========================================
BEST PRACTICES
========================================

- Use Bcrypt for password hashing
- Store JWT secrets in environment variables
- Use Fluent ORM for database
- Set reasonable token expiry
- Implement refresh tokens
- Add rate limiting
- Use HTTPS only
- Validate input thoroughly
- Consider Imperial for OAuth

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Configure JWT (Phase 1)
CONTINUE: Create user model and endpoints (Phase 2)
OPTIONAL: Add OAuth (Phase 3)
CONTINUE: Add security measures (Phase 4)
FINISH: Update all documentation files
REMEMBER: Bcrypt, Fluent, secure secrets, document for catch-up
```

---

## Quick Reference

**What you get**: Complete JWT/OAuth authentication for Vapor  
**Time**: 3-4 hours  
**Output**: Auth service, protected routes, OAuth
