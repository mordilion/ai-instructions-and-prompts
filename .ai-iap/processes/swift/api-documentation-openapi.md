# API Documentation Process - Swift (Vapor)

> **Purpose**: Auto-generate API documentation for Vapor applications

> **Tools**: VaporToOpenAPI, SwiftOpenAPI

---

## Phase 1: Manual OpenAPI

**Create OpenAPI Spec** (openapi.yaml):
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
            type: integer
      responses:
        '200':
          description: User found
```

**Serve with Vapor**:
```swift
app.get("docs") { req in
    return req.fileio.streamFile(at: "openapi.yaml")
}
```

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

## AI Self-Check

- [ ] OpenAPI spec created
- [ ] Swagger UI configured
- [ ] All endpoints documented

---

**Process Complete** ✅

