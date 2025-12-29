# API Documentation Process - PHP (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: L5-Swagger ⭐ (Laravel), NelmioApiDocBundle (Symfony)

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

## AI Self-Check

- [ ] L5-Swagger or Nelmio configured
- [ ] All endpoints annotated
- [ ] Swagger UI accessible
- [ ] JWT auth documented

---

**Process Complete** ✅

