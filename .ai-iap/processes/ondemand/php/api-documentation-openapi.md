# PHP API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for PHP API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
PHP API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a PHP REST API.

CRITICAL REQUIREMENTS:
- ALWAYS use swagger-php annotations
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use PHPDoc comments for descriptions

========================================
PHASE 1 - BASIC SETUP
========================================

Install swagger-php:

```bash
composer require zircote/swagger-php
```

Generate OpenAPI spec:
```bash
vendor/bin/openapi src -o openapi.json
```

Add Swagger UI (using CDN):
```php
<!-- public/api-docs.html -->
<!DOCTYPE html>
<html>
<head>
    <title>API Documentation</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css">
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: '/openapi.json',
            dom_id: '#swagger-ui'
        })
    </script>
</body>
</html>
```

Deliverable: Swagger UI accessible

========================================
PHASE 2 - DOCUMENT ENDPOINTS
========================================

Add OpenAPI annotations to controllers:

```php
use OpenApi\Annotations as OA;

/**
 * @OA\Info(
 *     version="1.0.0",
 *     title="My API",
 *     description="API Documentation"
 * )
 */
class Controller {}

/**
 * @OA\Get(
 *     path="/api/users",
 *     summary="Get all users",
 *     tags={"Users"},
 *     @OA\Response(
 *         response=200,
 *         description="Successful operation",
 *         @OA\JsonContent(type="array", @OA\Items(ref="#/components/schemas/User"))
 *     )
 * )
 */
public function index()
{
    // Implementation
}

/**
 * @OA\Post(
 *     path="/api/users",
 *     summary="Create user",
 *     tags={"Users"},
 *     @OA\RequestBody(
 *         required=true,
 *         @OA\JsonContent(ref="#/components/schemas/CreateUserDto")
 *     ),
 *     @OA\Response(
 *         response=201,
 *         description="User created",
 *         @OA\JsonContent(ref="#/components/schemas/User")
 *     ),
 *     @OA\Response(
 *         response=400,
 *         description="Invalid input"
 *     )
 * )
 */
public function store(Request $request)
{
    // Implementation
}
```

Deliverable: Documented endpoints

========================================
PHASE 3 - SCHEMA DEFINITIONS
========================================

Define schemas in models:

```php
/**
 * @OA\Schema(
 *     schema="User",
 *     type="object",
 *     title="User",
 *     description="User entity",
 *     required={"id", "name", "email"}
 * )
 */
class User
{
    /**
     * @OA\Property(
     *     property="id",
     *     type="integer",
     *     description="User ID",
     *     example=1
     * )
     */
    public int $id;
    
    /**
     * @OA\Property(
     *     property="name",
     *     type="string",
     *     description="User full name",
     *     example="John Doe"
     * )
     */
    public string $name;
    
    /**
     * @OA\Property(
     *     property="email",
     *     type="string",
     *     format="email",
     *     description="User email",
     *     example="john@example.com"
     * )
     */
    public string $email;
}

/**
 * @OA\Schema(
 *     schema="CreateUserDto",
 *     required={"name", "email"}
 * )
 */
class CreateUserDto
{
    /**
     * @OA\Property(example="John Doe")
     */
    public string $name;
    
    /**
     * @OA\Property(example="john@example.com")
     */
    public string $email;
}
```

Deliverable: Schema documentation

========================================
PHASE 4 - AUTHENTICATION
========================================

Add security definitions:

```php
/**
 * @OA\SecurityScheme(
 *     securityScheme="bearerAuth",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */

/**
 * @OA\Get(
 *     path="/api/protected",
 *     security={{"bearerAuth":{}}},
 *     ...
 * )
 */
```

Deliverable: Authentication in docs

========================================
BEST PRACTICES
========================================

- Use swagger-php annotations
- Document all public endpoints
- Add descriptions and examples
- Define schemas for all DTOs
- Include authentication schemes
- Generate spec in CI
- Version your API
- Keep annotations up to date

========================================
EXECUTION
========================================

START: Install swagger-php (Phase 1)
CONTINUE: Document endpoints (Phase 2)
CONTINUE: Add schema annotations (Phase 3)
CONTINUE: Configure authentication (Phase 4)
REMEMBER: Annotations in PHPDoc, regenerate spec
```

---

## Quick Reference

**What you get**: OpenAPI documentation from PHP annotations  
**Time**: 2-3 hours  
**Output**: OpenAPI spec, Swagger UI
