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

**Documentation Template**:
```markdown
## Authentication

All API requests require authentication using a Bearer token.

### Obtaining a Token

\`\`\`bash
curl -X POST https://api.example.com/auth/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
\`\`\`

### Using the Token

\`\`\`bash
curl -X GET https://api.example.com/users/me \
  -H "Authorization: Bearer YOUR_TOKEN"
\`\`\`

Tokens expire after 24 hours. Use the refresh endpoint to obtain a new token.
```

---

## Rate Limiting Documentation

> **ALWAYS**: Document rate limits and headers

**Example**:
```markdown
## Rate Limiting

- **Limit**: 100 requests per minute per API key
- **Headers Returned**:
  - `X-RateLimit-Limit`: Maximum requests allowed
  - `X-RateLimit-Remaining`: Requests remaining in window
  - `X-RateLimit-Reset`: Unix timestamp when limit resets

### Rate Limit Exceeded Response

Status: `429 Too Many Requests`

\`\`\`json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests, retry after 45 seconds",
    "retry_after": 45
  }
}
\`\`\`
```

---

## API Versioning Documentation

> **ALWAYS**: Document versioning strategy

| Strategy | Format | Example |
|----------|--------|---------|
| **URL Path** ⭐ | `/v1/users`, `/v2/users` | Most explicit |
| **Header** | `Accept: application/vnd.api+json; version=1` | REST standard |
| **Query Param** | `/users?version=1` | Simple, less common |

**Versioning Template**:
```markdown
## API Versioning

This API uses URL path versioning. Current version: **v1**

- **v1** (current): `https://api.example.com/v1/`
- **v2** (beta): `https://api.example.com/v2/`

### Breaking Changes

Major versions introduce breaking changes. Minor updates are backward-compatible.

### Deprecation Policy

- **Notice**: 6 months before deprecation
- **Support**: 12 months after deprecation notice
- **Sunset Header**: `Sunset: Sat, 01 Jan 2025 00:00:00 GMT`
```

---

## SDK/Client Library Documentation

> **ALWAYS**: Provide code examples in popular languages

**Example**:
```markdown
## SDKs

### JavaScript/TypeScript

\`\`\`bash
npm install @example/api-client
\`\`\`

\`\`\`typescript
import { ApiClient } from '@example/api-client';

const client = new ApiClient({ apiKey: 'YOUR_KEY' });
const user = await client.users.get('123');
\`\`\`

### Python

\`\`\`bash
pip install example-api
\`\`\`

\`\`\`python
from example_api import Client

client = Client(api_key='YOUR_KEY')
user = client.users.get('123')
\`\`\`
```

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
