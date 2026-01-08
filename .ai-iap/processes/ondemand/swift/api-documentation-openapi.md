# Swift API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for Swift server API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
SWIFT API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a Swift server API (Vapor).

CRITICAL REQUIREMENTS:
- ALWAYS use VaporOpenAPI package
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use Swift types for automatic schema generation

========================================
PHASE 1 - BASIC SETUP
========================================

Add VaporOpenAPI to Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/vapor-community/VaporOpenAPI.git", from: "0.1.0")
]

targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "VaporOpenAPI", package: "VaporOpenAPI")
        ]
    )
]
```

Configure in configure.swift:
```swift
import Vapor
import VaporOpenAPI

public func configure(_ app: Application) throws {
    app.openAPI.info = .init(
        title: "My API",
        description: "API documentation",
        version: "1.0.0"
    )
    
    // Serve OpenAPI spec
    app.get("openapi.json") { req async throws -> Response in
        let spec = try req.application.openAPI.document()
        return Response(status: .ok, body: .init(string: spec))
    }
    
    try routes(app)
}
```

Deliverable: OpenAPI spec at /openapi.json

========================================
PHASE 2 - DOCUMENT ENDPOINTS
========================================

Document routes in routes.swift:

```swift
import Vapor

struct CreateUserDTO: Content {
    var name: String
    var email: String
}

struct User: Content {
    var id: UUID
    var name: String
    var email: String
}

func routes(_ app: Application) throws {
    app.get("users") { req async throws -> [User] in
        // Implementation
    }
    .openAPI(
        summary: "Get all users",
        description: "Returns a list of all users",
        response: .type([User].self)
    )
    
    app.post("users") { req async throws -> User in
        let dto = try req.content.decode(CreateUserDTO.self)
        // Implementation
    }
    .openAPI(
        summary: "Create user",
        description: "Creates a new user",
        body: .type(CreateUserDTO.self),
        response: .type(User.self, status: .created)
    )
    
    app.get("users", ":id") { req async throws -> User in
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        // Implementation
    }
    .openAPI(
        summary: "Get user by ID",
        description: "Returns a single user",
        parameters: [.path("id", type: .string)],
        response: .type(User.self),
        responses: [
            .notFound: .init(description: "User not found")
        ]
    )
}
```

Deliverable: Documented endpoints

========================================
PHASE 3 - SCHEMA DEFINITIONS
========================================

Add schema descriptions:

```swift
extension User: OpenAPIDescribed {
    static var openAPIDescription: OpenAPIDescription {
        .init(
            description: "User entity",
            example: User(
                id: UUID(),
                name: "John Doe",
                email: "john@example.com"
            )
        )
    }
}

extension CreateUserDTO: OpenAPIDescribed {
    static var openAPIDescription: OpenAPIDescription {
        .init(
            description: "User creation DTO",
            example: CreateUserDTO(
                name: "John Doe",
                email: "john@example.com"
            )
        )
    }
}
```

Deliverable: Schema documentation

========================================
PHASE 4 - AUTHENTICATION
========================================

Add JWT authentication:

```swift
app.openAPI.securitySchemes["bearerAuth"] = .http(
    scheme: "bearer",
    bearerFormat: "JWT"
)

// Protect routes
app.grouped(JWTMiddleware())
    .get("protected") { req async throws -> String in
        return "Protected"
    }
    .openAPI(
        summary: "Protected endpoint",
        security: [.bearerAuth: []]
    )
```

Deliverable: Authentication in docs

========================================
BEST PRACTICES
========================================

- Use VaporOpenAPI for Vapor projects
- Document all public routes
- Add descriptions and examples
- Use Swift types for schemas
- Include authentication schemes
- Serve OpenAPI spec at /openapi.json
- Use Swagger UI with CDN
- Keep models in sync
- Version your API

========================================
EXECUTION
========================================

START: Add VaporOpenAPI (Phase 1)
CONTINUE: Document routes (Phase 2)
CONTINUE: Add schema descriptions (Phase 3)
CONTINUE: Configure authentication (Phase 4)
REMEMBER: Swift types, automatic schema generation
```

---

## Quick Reference

**What you get**: OpenAPI documentation from Swift Vapor code  
**Time**: 2-3 hours  
**Output**: OpenAPI spec at /openapi.json
