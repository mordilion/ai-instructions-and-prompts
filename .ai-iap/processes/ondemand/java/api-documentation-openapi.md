# Java API Documentation (OpenAPI) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Setting up OpenAPI/Swagger documentation for Java API  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
JAVA API DOCUMENTATION - OPENAPI
========================================

CONTEXT:
You are implementing OpenAPI/Swagger documentation for a Java REST API using Spring Boot.

CRITICAL REQUIREMENTS:
- ALWAYS use springdoc-openapi
- ALWAYS keep docs in sync with code
- NEVER document internal/private endpoints
- Use Javadoc comments for descriptions

========================================
PHASE 1 - BASIC SETUP
========================================

Add to pom.xml:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.3.0</version>
</dependency>
```

Configure in application.yml:
```yaml
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
```

Access Swagger UI at http://localhost:8080/swagger-ui.html

Deliverable: Swagger UI running

========================================
PHASE 2 - ANNOTATIONS
========================================

Add OpenAPI annotations to controllers:

```java
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User management endpoints")
public class UserController {
    
    @GetMapping
    @Operation(summary = "Get all users", description = "Returns a list of all users")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successful operation",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = User.class)))),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    public List<User> getAllUsers() {
        // Implementation
    }
    
    @PostMapping
    @Operation(summary = "Create user", description = "Creates a new user")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "User created",
            content = @Content(schema = @Schema(implementation = User.class))),
        @ApiResponse(responseCode = "400", description = "Invalid input")
    })
    public User createUser(@RequestBody @Valid CreateUserDto user) {
        // Implementation
    }
}
```

Add schema annotations to DTOs:
```java
@Schema(description = "User creation DTO")
public class CreateUserDto {
    @Schema(description = "User's full name", example = "John Doe", required = true)
    @NotBlank
    private String name;
    
    @Schema(description = "User's email address", example = "john@example.com", required = true)
    @Email
    private String email;
}
```

Deliverable: Enhanced API documentation

========================================
PHASE 3 - CONFIGURATION
========================================

Add OpenAPI configuration class:

```java
@Configuration
public class OpenAPIConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("My API")
                .version("1.0")
                .description("API Documentation")
                .contact(new Contact()
                    .name("Your Name")
                    .email("your@email.com")
                    .url("https://example.com")))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth", 
                    new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")));
    }
}
```

Deliverable: Configured OpenAPI with authentication

========================================
PHASE 4 - CI INTEGRATION
========================================

Generate OpenAPI spec in Maven:

Add to pom.xml:
```xml
<plugin>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-maven-plugin</artifactId>
    <version>1.4</version>
    <executions>
        <execution>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Add to .github/workflows/ci.yml:
```yaml
    - name: Generate OpenAPI spec
      run: mvn springdoc-openapi:generate
    
    - name: Validate spec
      run: |
        npm install -g @apidevtools/swagger-cli
        swagger-cli validate target/openapi.json
```

Deliverable: OpenAPI spec in CI

========================================
BEST PRACTICES
========================================

- Use springdoc-openapi for Spring Boot
- Document all public endpoints
- Use @Operation and @ApiResponses annotations
- Add schema descriptions to DTOs
- Include authentication schemes
- Generate spec in CI
- Version your API
- Validate spec in CI

========================================
EXECUTION
========================================

START: Add springdoc dependency (Phase 1)
CONTINUE: Add annotations (Phase 2)
CONTINUE: Configure OpenAPI (Phase 3)
CONTINUE: Add CI generation (Phase 4)
REMEMBER: Annotations, validate in CI
```

---

## Quick Reference

**What you get**: Auto-generated OpenAPI documentation from Spring Boot  
**Time**: 2 hours  
**Output**: OpenAPI spec, Swagger UI, CI integration
