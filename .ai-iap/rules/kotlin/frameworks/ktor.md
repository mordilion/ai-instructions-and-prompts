# Ktor Framework

## Overview
Ktor: Lightweight, Kotlin-native asynchronous web framework built by JetBrains, fully embracing coroutines.
Unopinionated and modular - you choose components (routing, serialization, auth) you need.
Best for microservices, APIs, and when you want a lightweight Kotlin-first framework without Spring's complexity.

## Application Setup

```kotlin
fun main() {
    embeddedServer(Netty, port = 8080) {
        configureRouting()
        configureSerialization()
        configureSecurity()
    }.start(wait = true)
}

fun Application.configureSerialization() {
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            ignoreUnknownKeys = true
        })
    }
}
```

## Routing

```kotlin
fun Route.userRoutes(service: UserService) {
    route("/users") {
        get {
            call.respond(HttpStatusCode.OK, service.findAll())
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@get call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            call.respond(HttpStatusCode.OK, service.findById(id))
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            call.respond(HttpStatusCode.Created, service.create(request))
        }
        
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@put call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            val request = call.receive<UpdateUserRequest>()
            call.respond(HttpStatusCode.OK, service.update(id, request))
        }
        
        delete("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@delete call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            service.delete(id)
            call.respond(HttpStatusCode.NoContent)
        }
    }
}
```

### Authentication
```kotlin
fun Route.authenticatedRoutes() {
    authenticate("auth-jwt") {
        get("/profile") {
            val principal = call.principal<JWTPrincipal>()
            val username = principal?.payload?.getClaim("username")?.asString()
                ?: return@get call.respond(HttpStatusCode.Unauthorized)
            call.respond(service.findByUsername(username))
        }
    }
}
```

## Request Handling

### Validation
```kotlin
sealed class ValidationResult {
    data object Valid : ValidationResult()
    data class Invalid(val errors: List<String>) : ValidationResult()
}

fun CreateUserRequest.validate(): ValidationResult {
    val errors = mutableListOf<String>()
    if (name.isBlank()) errors.add("Name required")
    if (!email.matches(Regex(".+@.+"))) errors.add("Invalid email")
    return if (errors.isEmpty()) ValidationResult.Valid else ValidationResult.Invalid(errors)
}

post {
    val request = call.receive<CreateUserRequest>()
    when (val result = request.validate()) {
        is ValidationResult.Valid -> call.respond(HttpStatusCode.Created, service.create(request))
        is ValidationResult.Invalid -> call.respond(HttpStatusCode.BadRequest, mapOf("errors" to result.errors))
    }
}
```

## Services

```kotlin
class UserService(
    private val repository: UserRepository,
    private val emailService: EmailService
) {
    suspend fun findAll(): List<UserDTO> = withContext(Dispatchers.IO) {
        repository.findAll().map { it.toDTO() }
    }
    
    suspend fun create(request: CreateUserRequest): UserDTO = withContext(Dispatchers.IO) {
        val user = User(name = request.name, email = request.email)
        val saved = repository.save(user)
        launch { emailService.sendWelcome(saved.email) }
        saved.toDTO()
    }
}
```

## Exception Handling

```kotlin
sealed class AppException(message: String) : RuntimeException(message) {
    class NotFoundException(message: String) : AppException(message)
    class ConflictException(message: String) : AppException(message)
}

fun Application.configureStatusPages() {
    install(StatusPages) {
        exception<NotFoundException> { call, cause ->
            call.respond(HttpStatusCode.NotFound, ErrorResponse(404, cause.message ?: ""))
        }
        exception<ConflictException> { call, cause ->
            call.respond(HttpStatusCode.Conflict, ErrorResponse(409, cause.message ?: ""))
        }
        exception<Throwable> { call, cause ->
            call.application.log.error("Unhandled", cause)
            call.respond(HttpStatusCode.InternalServerError, ErrorResponse(500, "Internal error"))
        }
    }
}

@Serializable
data class ErrorResponse(val status: Int, val message: String, val timestamp: String = Instant.now().toString())
```

## Authentication & Security

### JWT
```kotlin
fun Application.configureSecurity() {
    val jwtSecret = environment.config.property("jwt.secret").getString()
    val jwtAudience = environment.config.property("jwt.audience").getString()
    
    install(Authentication) {
        jwt("auth-jwt") {
            verifier(JWT.require(Algorithm.HMAC256(jwtSecret)).build())
            validate { credential ->
                if (credential.payload.audience.contains(jwtAudience))
                    JWTPrincipal(credential.payload)
                else null
            }
        }
    }
}

class JwtService(private val secret: String, private val audience: String) {
    fun generateToken(username: String): String =
        JWT.create()
            .withAudience(audience)
            .withClaim("username", username)
            .withExpiresAt(Date(System.currentTimeMillis() + 3_600_000))
            .sign(Algorithm.HMAC256(secret))
}
```

## Testing

```kotlin
class UserRoutesTest {
    @Test
    fun `GET users returns list`() = testApplication {
        application { configureRouting() }
        
        val response = client.get("/api/users")
        
        assertEquals(HttpStatusCode.OK, response.status)
        val users = response.body<List<UserDTO>>()
        assertTrue(users.isNotEmpty())
    }
    
    @Test
    fun `POST user creates new user`() = testApplication {
        application { configureRouting() }
        
        val response = client.post("/api/users") {
            contentType(ContentType.Application.Json)
            setBody(CreateUserRequest("John", "john@test.com"))
        }
        
        assertEquals(HttpStatusCode.Created, response.status)
    }
}
```

## Best Practices

**MUST**:
- Use `suspend` functions in route handlers (coroutines are core to Ktor)
- Use ContentNegotiation plugin with JSON serialization
- Use StatusPages plugin for error handling
- Validate input explicitly (no automatic validation like Spring)
- Install authentication/authorization plugins when needed

**SHOULD**:
- Use Koin or manual DI (Ktor has no built-in DI)
- Use extension functions for common response patterns
- Use sealed classes for API responses
- Structure routes in separate functions/files
- Use CallLogging plugin for request logging

**AVOID**:
- Blocking calls in suspend route handlers
- Manual JSON parsing (use ContentNegotiation)
- Not handling exceptions (install StatusPages)
- Returning domain entities (use DTOs)
- Complex logic in routes (move to services)

## Common Patterns

### Dependency Injection (Manual or Koin)
```kotlin
// ✅ GOOD: Simple service container
object ServiceContainer {
    val database by lazy { Database.connect() }
    val userRepository by lazy { UserRepository(database) }
    val userService by lazy { UserService(userRepository) }
}

// Usage in routes
fun Route.userRoutes() {
    val service = ServiceContainer.userService
    
    get("/users") {
        call.respond(service.findAll())
    }
}

// ✅ GOOD: Koin (more sophisticated)
val appModule = module {
    single { Database.connect() }
    single { UserRepository(get()) }
    single { UserService(get()) }
}
```

### Extension Functions for Common Patterns
```kotlin
// ✅ GOOD: Useful extensions
suspend fun ApplicationCall.respondCreated(data: Any) =
    respond(HttpStatusCode.Created, data)

suspend fun ApplicationCall.respondNotFound(message: String = "Not found") =
    respond(HttpStatusCode.NotFound, mapOf("error" to message))

fun Parameters.getLongOrNull(name: String) = this[name]?.toLongOrNull()

// Usage
post("/users") {
    val user = service.create(call.receive())
    call.respondCreated(user)  // Clean!
}
```

### Error Handling Pattern
```kotlin
// ✅ GOOD: Centralized error handling
sealed class AppException(message: String) : RuntimeException(message) {
    class NotFoundException(message: String) : AppException(message)
    class ValidationException(message: String) : AppException(message)
}

fun Application.configureStatusPages() {
    install(StatusPages) {
        exception<NotFoundException> { call, cause ->
            call.respond(HttpStatusCode.NotFound, ErrorResponse(404, cause.message ?: ""))
        }
        exception<ValidationException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, ErrorResponse(400, cause.message ?: ""))
        }
    }
}

// ❌ BAD: No error handling
get("/users/{id}") {
    val id = call.parameters["id"]?.toLongOrNull()!!  // Crash if null!
    val user = service.findById(id)  // Crash if not found!
    call.respond(user)
}
```
