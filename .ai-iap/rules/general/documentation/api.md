# API Documentation Standards

> **Scope**: REST APIs, GraphQL, gRPC, SDK documentation

---

## Core Principles

> **ALWAYS**: Document all public endpoints/operations  
> **ALWAYS**: Include request/response examples  
> **ALWAYS**: Document error responses and status codes  
> **ALWAYS**: Keep documentation in sync with implementation  
> **NEVER**: Document internal/private endpoints  
> **NEVER**: Expose sensitive implementation details

---

## OpenAPI/Swagger Standards

> **ALWAYS**: Use OpenAPI 3.0+ for REST APIs  
> **ALWAYS**: Generate from code when possible (single source of truth)

### Endpoint Documentation Template

```yaml
/users/{id}:
  get:
    summary: Get user by ID
    description: Retrieves detailed user information including profile and settings
    tags:
      - Users
    parameters:
      - name: id
        in: path
        required: true
        description: Unique user identifier
        schema:
          type: string
          format: uuid
    responses:
      '200':
        description: User found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
            example:
              id: "123e4567-e89b-12d3-a456-426614174000"
              name: "Jane Doe"
              email: "jane@example.com"
      '404':
        description: User not found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Error'
      '401':
        description: Unauthorized
```

---

## Required Documentation Elements

| Element | Description | Example |
|---------|-------------|---------|
| **Summary** | One-line description | "Get user by ID" |
| **Description** | Detailed explanation | "Retrieves user with profile..." |
| **Parameters** | All inputs (path, query, body) | `id` (path, required, uuid) |
| **Responses** | All status codes | 200, 400, 401, 404, 500 |
| **Examples** | Request/response samples | Complete JSON objects |
| **Authentication** | Auth requirements | "Bearer token required" |
| **Rate Limits** | Throttling rules | "100 requests/minute" |

---

## HTTP Status Code Documentation

> **ALWAYS**: Document all possible status codes for each endpoint

### Standard Status Codes

| Code | Category | When to Use |
|------|----------|-------------|
| **2xx Success** |||
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| **4xx Client Errors** |||
| 400 | Bad Request | Invalid input, validation error |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Valid auth, insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource state conflict |
| 422 | Unprocessable | Valid syntax, semantic errors |
| 429 | Too Many Requests | Rate limit exceeded |
| **5xx Server Errors** |||
| 500 | Internal Server Error | Unexpected server error |
| 503 | Service Unavailable | Temporary downtime |

---

## Error Response Format

> **ALWAYS**: Use consistent error format across all endpoints

**Recommended Structure**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {
        "field": "email",
        "issue": "Must be valid email address"
      }
    ],
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

---

## Authentication Documentation

> **ALWAYS**: Document authentication methods clearly

### Authentication Types

| Method | Header Format | Example |
|--------|---------------|---------|
| **Bearer Token** | `Authorization: Bearer <token>` | JWT, OAuth 2.0 |
| **API Key** | `X-API-Key: <key>` | Public APIs |
| **Basic Auth** | `Authorization: Basic <base64>` | Legacy systems |
| **OAuth 2.0** | `Authorization: Bearer <access_token>` | Third-party integrations |

**Template**: Document auth method, token obtainment, usage example, expiration

---

## Rate Limiting Documentation

> **ALWAYS**: Document rate limits and headers

**Template**: Document limit, headers (`X-RateLimit-*`), 429 response with `retry_after`

---

## API Versioning Documentation

> **ALWAYS**: Document versioning strategy

| Strategy | Format | Example |
|----------|--------|---------|
| **URL Path** ⭐ | `/v1/users`, `/v2/users` | Most explicit |
| **Header** | `Accept: application/vnd.api+json; version=1` | REST standard |
| **Query Param** | `/users?version=1` | Simple, less common |

**Template**: Document strategy (URL/header/query), versions, breaking changes, deprecation policy

---

## SDK/Client Library Documentation

> **ALWAYS**: Provide code examples in popular languages

**Template**: Show install command, basic initialization, and example request for each SDK

---

## Interactive Documentation Tools

| Tool | Use Case | Features |
|------|----------|----------|
| **Swagger UI** ⭐ | OpenAPI visualization | Interactive testing, auto-generated |
| **Redoc** | OpenAPI alternative | Clean UI, responsive |
| **Postman** | API testing | Collections, environment variables |
| **Insomnia** | REST/GraphQL | GraphQL explorer, templates |
| **Stoplight** | API design | Mock servers, style guides |

---

## AI Self-Check

- [ ] All public endpoints documented
- [ ] Every endpoint has request/response examples
- [ ] All status codes documented (2xx, 4xx, 5xx)
- [ ] Error response format is consistent
- [ ] Authentication method clearly explained
- [ ] Rate limiting rules and headers documented
- [ ] API versioning strategy documented
- [ ] Breaking changes marked and dated
- [ ] Code examples provided for popular languages
- [ ] Base URLs and environments listed
- [ ] Deprecation timeline included (if applicable)
- [ ] Interactive documentation (Swagger UI) available
