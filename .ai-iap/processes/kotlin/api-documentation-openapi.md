# API Documentation Process - Kotlin (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation

> **Tools**: SpringDoc ⭐ (Spring Boot), Ktor OpenAPI

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

## AI Self-Check

- [ ] OpenAPI documentation configured
- [ ] Swagger UI accessible
- [ ] All endpoints documented

---

**Process Complete** ✅

