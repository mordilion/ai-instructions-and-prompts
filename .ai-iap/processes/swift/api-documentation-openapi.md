# API Documentation Process - Swift (Vapor)

> **Purpose**: Auto-generate API documentation for Vapor applications

> **Tools**: VaporToOpenAPI, SwiftOpenAPI

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

---

## Phase 1: OpenAPI Generation Options

### Option A: VaporToOpenAPI (Code-First) ⭐

**Install**:
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.0.0")
]
```

**Configure**:
```swift
import VaporToOpenAPI

try app.openAPI(
    info: .init(
        title: "My API",
        version: "1.0.0"
    ),
    servers: [.init(url: "http://localhost:8080")]
)

// Automatically generates OpenAPI from routes
app.get("users", ":id") { req -> User in
    // OpenAPI generated automatically from route and return type
}

// Access at: http://localhost:8080/openapi.json
```

### Option B: Swift OpenAPI Generator (Spec-First)

**Install**:
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0")
]
```

**Create openapi.yaml** (specification):
```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
paths:
  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: User found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
components:
  schemas:
    User:
      type: object
      properties:
        id: { type: string }
        name: { type: string }
```

**Generate Code**:
```bash
swift package plugin generate-openapi-code \
  --input openapi.yaml \
  --output Sources/Generated
```

### Option C: Manual OpenAPI (Fallback)

**Create OpenAPI Spec** (openapi.yaml) and serve via Vapor as static file.

---

## Phase 2: Swagger UI

**Add Swagger UI** (static files):
- Download Swagger UI dist
- Serve from Public/swagger-ui/
- Point to openapi.yaml

**Route**:
```swift
app.get("api-docs") { req in
    return req.view.render("swagger-ui")
}
```

---

## Phase 3: Security & Authentication

### 3.1 Document JWT Authentication

**OpenAPI Spec**:
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
security:
  - bearerAuth: []
```

**Vapor Route Documentation**:
```swift
// Document in comments or separate spec
// GET /api/users/{id}
// Security: Bearer token required
// Responses:
//   200: User found
//   401: Unauthorized
//   404: Not found
app.get("api", "users", ":id") { req -> User in
    // ...
}
```

### 3.2 API Versioning

**URL-based Versioning**:
```yaml
paths:
  /api/v1/users:
    get:
      summary: Get users (V1)
  /api/v2/users:
    get:
      summary: Get users (V2 - includes email field)
```

**Vapor Implementation**:
```swift
let v1 = app.grouped("api", "v1")
v1.get("users") { req in /* V1 logic */ }

let v2 = app.grouped("api", "v2")
v2.get("users") { req in /* V2 logic */ }
```

### 3.3 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format

**Vapor Implementation**:
```swift
struct ErrorResponse: Content {
    let error: ErrorDetail
}

struct ErrorDetail: Content {
    let code: String
    let message: String
    let details: [ValidationError]
    let timestamp: String
    let requestId: String?
}

struct ValidationError: Content {
    let field: String
    let issue: String
}

// Middleware for consistent error handling
app.middleware.use(ErrorMiddleware { req, error in
    return req.eventLoop.makeSucceededFuture(
        Response(
            status: .badRequest,
            body: .init(string: try! JSONEncoder().encode(ErrorResponse(
                error: ErrorDetail(
                    code: "VALIDATION_ERROR",
                    message: error.localizedDescription,
                    details: [],
                    timestamp: ISO8601DateFormatter().string(from: Date()),
                    requestId: req.headers.first(name: "X-Request-ID")
                )
            )).utf8String!)
        )
    )
})
```

### 3.4 Rate Limiting Documentation

**OpenAPI Spec**:
```yaml
paths:
  /api/users:
    get:
      description: Rate limit 100 requests/minute per IP
      responses:
        '429':
          description: Too many requests
          headers:
            X-RateLimit-Limit:
              schema: { type: integer }
            X-RateLimit-Remaining:
              schema: { type: integer }
```

---

## Phase 4: CI/CD Integration

> **ALWAYS**:
> - Version control openapi.yaml
> - Validate spec in CI/CD
> - Generate client SDKs from spec

**Validate Spec**:
```bash
npx @openapitools/openapi-generator-cli validate -i openapi.yaml
```

**CI/CD Example**:
```yaml
- name: Validate OpenAPI Spec
  run: |
    npm install -g @openapitools/openapi-generator-cli
    openapi-generator-cli validate -i openapi.yaml
```

### 4.2 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate Swift Client**:
```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g swift5 \
  -o sdks/swift-client
```

**Generate TypeScript Client**:
```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-axios \
  -o sdks/typescript-client
```

**Usage Example**:
```swift
import MyAPIClient

let api = UsersAPI()
api.getUser(userId: "123") { result in
    switch result {
    case .success(let user):
        print(user.name)
    case .failure(let error):
        print(error)
    }
}
```

---

## Best Practices

> **ALWAYS**:
> - Keep OpenAPI spec in sync with routes
> - Document all HTTP status codes
> - Include request/response examples
> - Use `$ref` for reusable schemas
> - Document authentication requirements

> **NEVER**:
> - Hardcode secrets in examples
> - Skip documenting error responses
> - Forget to update spec when routes change

---

## Troubleshooting

### Issue: Swagger UI not loading
- **Solution**: Check static file serving, verify swagger-ui dist files present

### Issue: CORS errors in Try-it-out
- **Solution**: Configure CORS middleware in Vapor to allow swagger-ui origin

### Issue: Spec not validating
- **Solution**: Use online validator (swagger.io/tools/swagger-editor), check for syntax errors

### Issue: Want auto-generation from code
- **Solution**: Consider using VaporToOpenAPI package (experimental) or maintain spec manually

---

## AI Self-Check

- [ ] VaporToOpenAPI or Swift OpenAPI Generator configured
- [ ] OpenAPI specification created and validated
- [ ] All endpoints documented with paths, methods, parameters
- [ ] JWT authentication documented in security schemes
- [ ] Swagger UI configured and accessible
- [ ] CI/CD validates OpenAPI spec
- [ ] Client SDKs generated for target languages
- [ ] Spec version controlled in repository
- [ ] Error responses follow consistent format (see general standards)
- [ ] All status codes documented (see general standards)

---

**Process Complete** ✅

