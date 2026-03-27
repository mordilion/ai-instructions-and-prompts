# API Documentation Standards

> **Scope**: REST APIs, GraphQL, gRPC, SDK documentation

## CRITICAL REQUIREMENTS

> **ALWAYS**: Document all public endpoints/operations
> **ALWAYS**: Include request/response examples
> **ALWAYS**: Document error responses and status codes
> **ALWAYS**: Keep documentation in sync with implementation
> **ALWAYS**: Use OpenAPI 3.0+ for REST APIs
> 
> **NEVER**: Document internal/private endpoints
> **NEVER**: Expose sensitive implementation details
> **NEVER**: Skip authentication/authorization docs

---

## OpenAPI/Swagger Standards

> **ALWAYS**: Use OpenAPI 3.0+ for REST APIs  
> **ALWAYS**: Generate from code when possible (single source of truth)

### Endpoint Documentation Template

```yaml
/users/{id}:
  get:
    summary: Get user by ID
    parameters:
      - name: id
        in: path
        required: true
        schema: { type: string, format: uuid }
    responses:
      '200':
        description: User found
        content:
          application/json:
            schema: { $ref: '#/components/schemas/User' }
            example: { id: "123...", name: "Jane Doe", email: "jane@example.com" }
      '404': { description: User not found }
      '401': { description: Unauthorized }
```

---

## Required Documentation Elements

**MUST document**: Summary, description, parameters, responses (all status codes), request/response examples, authentication, rate limits

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

> **ALWAYS**: Use consistent error format: `{ error: { code, message, details[], timestamp, request_id } }`

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

## API Versioning & SDKs

**Versioning**: Document strategy (URL path `/v1/`, header, or query param), versions, breaking changes, deprecation timeline

**SDK Documentation**: Show install command, initialization, and example request for popular languages

---

## Interactive Documentation Tools

**Recommended**: Swagger UI ⭐ (OpenAPI, interactive), Redoc (clean UI), Postman (testing), Insomnia (GraphQL), Stoplight (design)

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
