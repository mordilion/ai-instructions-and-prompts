# Authentication Setup Process - Swift (Server-Side: Vapor)

> **Purpose**: Implement secure authentication and authorization in Vapor applications

> **Core Stack**: BCrypt, JWT, OAuth2

---

## Phase 1: Password Hashing

> **ALWAYS use**: BCrypt from Vapor
> **NEVER**: MD5, SHA1, or plain text

**Install**:
```swift
// Package.swift
.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0")
```

**Password Hashing**:
```swift
import Vapor

func hashPassword(_ password: String, on req: Request) async throws -> String {
    return try await req.password.async.hash(password)
}

func verifyPassword(_ password: String, hash: String, on req: Request) async throws -> Bool {
    return try await req.password.async.verify(password, created: hash)
}
```

> **Git**: `git commit -m "feat: add password hashing"`

---

## Phase 2: JWT Authentication

> **ALWAYS use**: Vapor's JWT package

**Install**:
```swift
.package(url: "https://github.com/vapor/jwt.git", from: "4.0.0")
```

**JWT Configuration**:
```swift
import JWT

app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET")!))

struct SessionToken: Content, Authenticatable, JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

func generateToken(for user: User, on req: Request) throws -> String {
    let payload = SessionToken(
        subject: SubjectClaim(value: user.id!.uuidString),
        expiration: ExpirationClaim(value: Date().addingTimeInterval(3600)) // 1h
    )
    return try req.jwt.sign(payload)
}
```

**JWT Middleware**:
```swift
let protected = app.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware())

protected.get("profile") { req -> User in
    let payload = try req.auth.require(SessionToken.self)
    return try await User.find(UUID(uuidString: payload.subject.value)!, on: req.db)!
}
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 / Social Login

> **ALWAYS use**: Imperial (Vapor OAuth library)

**Install**:
```swift
.package(url: "https://github.com/vapor-community/Imperial.git", from: "1.0.0")
```

**Google OAuth**:
```swift
import Imperial

app.oAuth(
    from: Google.self,
    authenticate: "login-google",
    callback: "http://localhost:8080/oauth/google"
) { request, token in
    // Create or find user
    return request.eventLoop.future()
}
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

> **ALWAYS**: Use middleware for role checks

**Role Middleware**:
```swift
struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let user = try request.auth.require(User.self)
        
        guard user.role == .admin else {
            throw Abort(.forbidden)
        }
        
        return try await next.respond(to: request)
    }
}

// Usage
let admin = app.grouped(SessionToken.authenticator(), AdminMiddleware())
admin.delete("users", ":id") { req -> HTTPStatus in
    // Admin-only route
    return .noContent
}
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (Redis-based recommended)
> - CORS configuration
> - HTTPS enforcement
> - Security headers

**CORS**:
```swift
app.middleware.use(CORSMiddleware(configuration: .init(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [.accept, .authorization, .contentType, .origin]
)))
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### Vapor
- Fluent for user models
- JWT middleware for authentication
- Custom middleware for authorization
- Imperial for OAuth

---

## AI Self-Check

- [ ] Passwords hashed with BCrypt
- [ ] JWT configured with secret
- [ ] Access tokens expire in ≤1h
- [ ] OAuth configured (if needed)
- [ ] Authorization middleware implemented
- [ ] HTTPS enforced
- [ ] CORS configured

---

**Process Complete** ✅

