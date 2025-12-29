# API Documentation Process - Java (OpenAPI/Swagger)

> **Purpose**: Auto-generate interactive API documentation with SpringDoc

> **Tool**: springdoc-openapi ⭐ (Spring Boot 3+)

---

## Phase 1: Setup SpringDoc

**Dependencies** (Maven):
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

**Configuration** (application.properties):
```properties
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
```

**Annotate Controllers**:
```java
@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User management APIs")
public class UserController {
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "User found"),
        @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<User> getUser(@PathVariable Long id) { }
}
```

> **Access**: http://localhost:8080/swagger-ui.html

---

## Phase 2: Security Documentation

**Configure JWT**:
```java
@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info().title("My API").version("1.0"))
            .addSecurityItem(new SecurityRequirement().addList("Bearer Auth"))
            .components(new Components()
                .addSecuritySchemes("Bearer Auth", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")));
    }
}
```

---

## AI Self-Check

- [ ] SpringDoc configured
- [ ] All endpoints annotated
- [ ] JWT security documented
- [ ] Swagger UI accessible

---

**Process Complete** ✅

