# API Documentation Process - PHP (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: L5-Swagger ⭐ (Laravel), NelmioApiDocBundle (Symfony)

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

---

## Phase 1: Laravel (L5-Swagger)

**Install**:
```bash
composer require darkaonline/l5-swagger
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"
```

**Annotate Controllers**:
```php
/**
 * @OA\Get(
 *     path="/api/users/{id}",
 *     summary="Get user by ID",
 *     @OA\Parameter(
 *         name="id",
 *         in="path",
 *         required=true,
 *         @OA\Schema(type="integer")
 *     ),
 *     @OA\Response(response=200, description="User found"),
 *     @OA\Response(response=404, description="Not found")
 * )
 */
public function show($id) { }
```

**Generate Docs**:
```bash
php artisan l5-swagger:generate
```

> **Access**: http://localhost:8000/api/documentation

---

## Phase 2: Symfony (NelmioApiDocBundle)

**Install**:
```bash
composer require nelmio/api-doc-bundle
```

**Configure** (config/packages/nelmio_api_doc.yaml):
```yaml
nelmio_api_doc:
    documentation:
        info:
            title: My API
            version: 1.0.0
    areas:
        path_patterns:
            - ^/api(?!/doc$)
```

**Annotate Controllers**:
```php
use OpenApi\Attributes as OA;

#[OA\Get(path: '/api/users/{id}', summary: 'Get user')]
#[OA\Response(response: 200, description: 'Success')]
public function getUser(int $id): Response { }
```

> **Access**: http://localhost:8000/api/doc

---

## Phase 3: Security & Versioning

### 3.1 Document JWT Authentication

**Laravel (L5-Swagger)**:
```php
/**
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */
class Controller extends BaseController
{
    /**
     * @OA\Get(
     *     path="/api/users",
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(response=401, description="Unauthorized")
     * )
     */
    public function index() { }
}
```

**Symfony (Nelmio)**:
```php
use OpenApi\Attributes as OA;

#[OA\SecurityScheme(
    securityScheme: 'bearerAuth',
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'JWT'
)]
class SecurityConfig {}

#[OA\Get(path: '/api/users', security: [['bearerAuth' => []]])]
public function getUsers(): Response { }
```

### 3.2 API Versioning

**URL-based**:
```php
/**
 * @OA\Get(
 *     path="/api/v1/users",
 *     tags={"Users V1"},
 *     deprecated=false
 * )
 */
Route::prefix('v1')->group(function () {
    Route::get('/users', [UserController::class, 'index']);
});

/**
 * @OA\Get(
 *     path="/api/v2/users",
 *     tags={"Users V2"},
 *     description="V2 includes additional email field"
 * )
 */
Route::prefix('v2')->group(function () {
    Route::get('/users', [UserControllerV2::class, 'index']);
});
```

### 3.3 Rate Limiting Documentation

**Document Headers**:
```php
/**
 * @OA\Get(
 *     path="/api/users",
 *     @OA\Header(
 *         header="X-RateLimit-Limit",
 *         description="Request limit per hour",
 *         @OA\Schema(type="integer")
 *     ),
 *     @OA\Response(response=429, description="Too Many Requests")
 * )
 */
```

### 3.4 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format and implementation

---

## Phase 4: CI/CD Integration

> **ALWAYS**:
> - Generate OpenAPI spec in CI/CD
> - Validate with Spectral or swagger-cli
> - Export as artifact

**Laravel**:
```yaml
- name: Generate API Docs
  run: |
    php artisan l5-swagger:generate
    npx @openapitools/openapi-generator-cli validate -i storage/api-docs/api-docs.json
```

**Symfony**:
```yaml
- name: Generate API Docs
  run: |
    php bin/console nelmio:apidoc:dump > openapi.json
    npx swagger-cli validate openapi.json
```

### 4.2 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate PHP Client**:
```bash
openapi-generator-cli generate \
  -i storage/api-docs/api-docs.json \
  -g php \
  -o sdks/php-client
```

**Generate JavaScript Client**:
```bash
openapi-generator-cli generate \
  -i storage/api-docs/api-docs.json \
  -g javascript \
  -o sdks/js-client
```

**Usage Example**:
```php
use MyApi\Client\Api\UsersApi;

$api = new UsersApi();
$user = $api->getUser('123');
```

---

## Best Practices

> **ALWAYS**:
> - Annotate all endpoints with `@OA\` or `#[OA\]`
> - Document request validation rules
> - Include realistic examples
> - Document all status codes (200, 400, 401, 403, 404, 422, 500)
> - Use resource classes for consistent response formats (Laravel)

> **NEVER**:
> - Include API keys or passwords in examples
> - Skip documenting validation errors (422)
> - Expose internal/admin endpoints without security annotations
> - Forget to regenerate docs after API changes

---

## Troubleshooting

### Issue: Swagger UI shows 404
- **Solution**: Run `php artisan l5-swagger:generate`, check config/l5-swagger.php routes

### Issue: Annotations not appearing in docs
- **Solution**: Verify annotation syntax, ensure controllers scanned in config, regenerate docs

### Issue: CORS errors in Try-it-out
- **Solution**: Configure CORS middleware, ensure Swagger UI origin allowed

### Issue: Want to exclude endpoints from docs
- **Solution**: Use `@OA\PathItem(path="/internal/...", description="Internal")` or configure exclude patterns

---

## AI Self-Check

- [ ] L5-Swagger (Laravel) or Nelmio (Symfony) installed
- [ ] Swagger UI accessible at `/api/documentation` or `/api/doc`
- [ ] All endpoints annotated with OpenAPI attributes
- [ ] JWT authentication documented with security scheme
- [ ] Request/response schemas documented
- [ ] CI/CD generates and validates OpenAPI spec
- [ ] Client SDKs generated for target languages
- [ ] Try-it-out functionality works
- [ ] Error responses follow consistent format (see general standards)
- [ ] All status codes documented (see general standards)

---

**Process Complete** ✅


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (simple)  
> **When to use**: When setting up OpenAPI/Swagger API documentation

### Complete Implementation Prompt

```
CONTEXT:
You are setting up auto-generated OpenAPI/Swagger API documentation for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use OpenAPI 3.x specification
- ALWAYS document all endpoints with descriptions
- ALWAYS include request/response schemas
- ALWAYS document authentication requirements
- Use team's Git workflow

IMPLEMENTATION STEPS:

1. INSTALL TOOLS:
   Install OpenAPI/Swagger library for the language (see Tech Stack section)

2. CONFIGURE BASIC SETUP:
   Set up Swagger/OpenAPI generator
   Configure API metadata (title, version, description)
   Set up UI endpoint (e.g., /api-docs, /swagger)

3. DOCUMENT AUTHENTICATION:
   Configure security schemes (JWT, OAuth, API Key)
   Document authentication flows

4. ADD ENDPOINT DOCUMENTATION:
   Document each endpoint:
   - HTTP method and path
   - Parameters (query, path, header)
   - Request body schema
   - Response schemas (success/error)
   - Example requests/responses

5. CONFIGURE AUTO-GENERATION:
   Use framework decorators/annotations
   Enable auto-discovery of endpoints
   Generate schemas from models/DTOs

6. ADD TO CI/CD (Optional):
   Generate OpenAPI spec file in CI
   Validate API spec
   Deploy documentation to hosting

DELIVERABLE:
- Swagger UI accessible
- All endpoints documented
- Request/response schemas complete
- Authentication documented

START: Install OpenAPI tools and configure basic setup with API metadata.
```
