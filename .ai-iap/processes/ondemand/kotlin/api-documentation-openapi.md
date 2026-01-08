# API Documentation Process - Kotlin (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: SpringDoc ⭐ (Spring Boot), Ktor OpenAPI

> **Reference**: See general documentation standards for HTTP status codes, error formats, and best practices

---

## Phase 1: Spring Boot (Same as Java)

**Dependencies** (Gradle):
```kotlin
implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0")
```

**Annotate Controllers**:
```kotlin
@RestController
@RequestMapping("/api/users")
@Tag(name = "Users")
class UserController {
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    fun getUser(@PathVariable id: Long): User { }
}
```

> **Access**: http://localhost:8080/swagger-ui.html

---

## Phase 2: Ktor OpenAPI

**Install**:
```kotlin
implementation("io.github.smiley4:ktor-swagger-ui:$version")
```

**Configure**:
```kotlin
install(SwaggerUI) {
    swagger {
        swaggerUrl = "swagger-ui"
        forwardRoot = true
    }
    info {
        title = "My API"
        version = "1.0.0"
    }
}
```

---

## Phase 3: Security & Versioning

### 3.1 Document JWT Authentication (Spring Boot)

**Security Configuration**:
```kotlin
@Bean
fun customOpenAPI(): OpenAPI {
    return OpenAPI()
        .info(Info().title("My API").version("1.0"))
        .addSecurityItem(SecurityRequirement().addList("Bearer"))
        .components(Components()
            .addSecuritySchemes("Bearer", SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")))
}
```

### 3.2 API Versioning

**URL-based**:
```kotlin
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "Users V1")
class UserControllerV1

@RestController
@RequestMapping("/api/v2/users")
@Tag(name = "Users V2")
class UserControllerV2
```

### 3.3 Ktor Security Documentation

**Configure JWT**:
```kotlin
install(SwaggerUI) {
    security {
        securityScheme("JWT") {
            type = HttpSecuritySchemeType.HTTP
            scheme = HttpAuthScheme.BEARER
            bearerFormat = "JWT"
        }
    }
}
```

### 3.4 Consistent Error Response Format

> **Reference**: See general documentation standards for recommended error format

**Spring Boot Implementation**:
```kotlin
data class ErrorResponse(val error: ErrorDetail)

data class ErrorDetail(
    val code: String,
    val message: String,
    val details: List<ValidationError> = emptyList(),
    val timestamp: String,
    val requestId: String?
)

data class ValidationError(
    val field: String,
    val issue: String
)

@RestControllerAdvice
class GlobalExceptionHandler {
    
    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(
        ex: MethodArgumentNotValidException,
        request: HttpServletRequest
    ): ResponseEntity<ErrorResponse> {
        val details = ex.bindingResult.fieldErrors.map {
            ValidationError(it.field, it.defaultMessage ?: "Invalid value")
        }
        
        val error = ErrorDetail(
            code = "VALIDATION_ERROR",
            message = "Invalid input",
            details = details,
            timestamp = Instant.now().toString(),
            requestId = request.getHeader("X-Request-ID")
        )
        
        return ResponseEntity.badRequest().body(ErrorResponse(error))
    }
}
```

**Ktor Implementation**:
```kotlin
install(StatusPages) {
    exception<Throwable> { call, cause ->
        call.respond(HttpStatusCode.InternalServerError, ErrorResponse(
            error = ErrorDetail(
                code = "INTERNAL_ERROR",
                message = cause.message ?: "Unknown error",
                timestamp = Clock.System.now().toString(),
                requestId = call.request.header("X-Request-ID")
            )
        ))
    }
}
```

### 3.5 Rate Limiting Documentation

> **Document rate limits**:
```kotlin
@Operation(
    summary = "Get user",
    description = "Rate limit: 100 requests/minute per user"
)
@ApiResponse(responseCode = "429", description = "Too many requests")
fun getUser(@PathVariable id: Long): User { }
```

---

## Phase 4: CI/CD Integration

> **ALWAYS**:
> - Generate OpenAPI spec during build
> - Validate with Spectral or swagger-cli
> - Export as artifact

**Gradle Task**:
```kotlin
tasks.register("generateOpenApi") {
    dependsOn("build")
    doLast {
        // Export OpenAPI JSON from running app or use springdoc plugin
        println("OpenAPI spec generated")
    }
}
```

### 4.2 Generate Client SDKs

> **ALWAYS**: Generate type-safe client SDKs from OpenAPI spec

**Generate Kotlin Client**:
```bash
openapi-generator-cli generate \
  -i openapi.json \
  -g kotlin \
  -o sdks/kotlin-client
```

**Generate TypeScript Client**:
```bash
openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-axios \
  -o sdks/typescript-client
```

**Usage Example**:
```kotlin
val api = UsersApi()
val user = api.getUser("123")
```

---

## Best Practices

> **ALWAYS**:
> - Use data classes for request/response models
> - Add KDoc comments to endpoints (included in docs)
> - Document all HTTP status codes
> - Group endpoints with `@Tag`
> - Use `@Parameter` for path/query params

> **NEVER**:
> - Expose internal endpoints without security
> - Include tokens/passwords in examples
> - Skip error response documentation

---

## Troubleshooting

### Issue: Swagger UI not loading (Spring Boot)
- **Solution**: Check `springdoc.swagger-ui.enabled=true`, verify path

### Issue: Endpoints missing (Ktor)
- **Solution**: Ensure routes are registered before SwaggerUI plugin

### Issue: Security schemes not appearing
- **Solution**: Verify both security scheme and requirement configured

---

## AI Self-Check

- [ ] SpringDoc or Ktor OpenAPI configured
- [ ] Swagger UI accessible
- [ ] All endpoints documented with annotations
- [ ] JWT/OAuth security documented
- [ ] Request/response schemas defined with data classes
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
