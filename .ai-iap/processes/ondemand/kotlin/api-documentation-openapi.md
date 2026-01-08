# Kotlin API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for Kotlin API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a Kotlin REST API (Ktor or Spring Boot).

CRITICAL REQUIREMENTS:
- ALWAYS use springdoc-openapi (Spring) or ktor-swagger (Ktor)
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use KDoc comments for descriptions

========================================
PHASE 1 - BASIC SETUP
========================================

For Ktor with ktor-swagger:

```kotlin
dependencies {
    implementation("io.github.smiley4:ktor-swagger-ui:2.7.4")
}
```

Configure in Application.kt:
```kotlin
fun Application.module() {
    install(SwaggerUI) {
        swagger {
            swaggerUrl = "swagger"
            forwardRoot = false
        }
        info {
            title = "My API"
            version = "1.0"
            description = "API documentation"
        }
    }
}
```

For Spring Boot (use same as Java):
```kotlin
implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0")
```

Deliverable: Swagger UI running

========================================
PHASE 2 - DOCUMENT ENDPOINTS
========================================

For Ktor:

```kotlin
routing {
    get("/users") {
        call.respond(users)
    } swaggerDoc {
        description = "Get all users"
        response {
            HttpStatusCode.OK to {
                description = "List of users"
                body<List<User>>()
            }
        }
    }
    
    post("/users") {
        val user = call.receive<CreateUserDto>()
        call.respond(HttpStatusCode.Created, createUser(user))
    } swaggerDoc {
        description = "Create a new user"
        request {
            body<CreateUserDto>()
        }
        response {
            HttpStatusCode.Created to {
                description = "User created"
                body<User>()
            }
            HttpStatusCode.BadRequest to {
                description = "Invalid input"
            }
        }
    }
}
```

For Spring Boot with Kotlin:
```kotlin
@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User management")
class UserController {
    
    @GetMapping
    @Operation(summary = "Get all users")
    @ApiResponse(responseCode = "200", description = "Success")
    fun getAllUsers(): List<User> {
        // Implementation
    }
    
    @PostMapping
    @Operation(summary = "Create user")
    fun createUser(@RequestBody @Valid user: CreateUserDto): User {
        // Implementation
    }
}
```

Deliverable: Documented endpoints

========================================
PHASE 3 - SCHEMA DEFINITIONS
========================================

Define data classes with annotations:

```kotlin
@Schema(description = "User entity")
data class User(
    @field:Schema(description = "User ID", example = "1")
    val id: Long,
    
    @field:Schema(description = "User name", example = "John Doe")
    val name: String,
    
    @field:Schema(description = "Email address", example = "john@example.com")
    val email: String
)

@Schema(description = "User creation DTO")
data class CreateUserDto(
    @field:Schema(description = "User name", required = true)
    @field:NotBlank
    val name: String,
    
    @field:Schema(description = "Email address", required = true)
    @field:Email
    val email: String
)
```

Deliverable: Schema documentation

========================================
PHASE 4 - AUTHENTICATION
========================================

For Ktor:

```kotlin
install(SwaggerUI) {
    security {
        securityScheme("BearerAuth") {
            type = AuthType.HTTP
            scheme = AuthScheme.BEARER
            bearerFormat = "JWT"
        }
    }
}
```

For Spring Boot:
```kotlin
@Configuration
class OpenAPIConfig {
    @Bean
    fun customOpenAPI() = OpenAPI()
        .info(Info()
            .title("My API")
            .version("1.0"))
        .addSecurityItem(SecurityRequirement().addList("bearerAuth"))
        .components(Components()
            .addSecuritySchemes("bearerAuth",
                SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")))
}
```

Deliverable: Authentication in docs

========================================
BEST PRACTICES
========================================

- Use ktor-swagger for Ktor, springdoc for Spring Boot
- Document all public endpoints
- Add descriptions to data classes
- Include authentication schemes
- Generate spec in CI
- Version your API
- Validate spec

========================================
EXECUTION
========================================

START: Install dependencies (Phase 1)
CONTINUE: Document endpoints (Phase 2)
CONTINUE: Add schema annotations (Phase 3)
CONTINUE: Configure authentication (Phase 4)
REMEMBER: Framework-specific, validate in CI
```

---

## Quick Reference

**What you get**: Auto-generated OpenAPI documentation from Kotlin code  
**Time**: 2 hours  
**Output**: OpenAPI spec, Swagger UI
