# Ktor Framework

## Overview
Ktor is a Kotlin-native asynchronous framework for building web applications and microservices, fully embracing coroutines.

## Application Setup

### Main Application
```kotlin
// ✅ Good - Ktor application with routing
fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0") {
        configureRouting()
        configureSerialization()
        configureMonitoring()
        configureSecurity()
    }.start(wait = true)
}

fun Application.configureRouting() {
    routing {
        route("/api") {
            userRoutes()
            authRoutes()
        }
    }
}

fun Application.configureSerialization() {
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
            ignoreUnknownKeys = true
        })
    }
}

fun Application.configureMonitoring() {
    install(CallLogging) {
        level = Level.INFO
        filter { call -> call.request.path().startsWith("/api") }
    }
}
```

## Routing

### Route Definitions
```kotlin
// ✅ Good - modular routing with extension functions
fun Route.userRoutes() {
    route("/users") {
        get {
            val users = userService.findAll()
            call.respond(HttpStatusCode.OK, users)
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@get call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            val user = userService.findById(id)
                ?: return@get call.respond(HttpStatusCode.NotFound, "User not found")
            
            call.respond(HttpStatusCode.OK, user)
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            val created = userService.create(request)
            call.respond(HttpStatusCode.Created, created)
        }
        
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@put call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            val request = call.receive<UpdateUserRequest>()
            val updated = userService.update(id, request)
            call.respond(HttpStatusCode.OK, updated)
        }
        
        delete("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@delete call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            userService.delete(id)
            call.respond(HttpStatusCode.NoContent)
        }
    }
}
```

### Route Authentication
```kotlin
// ✅ Good - authenticated routes
fun Route.authenticatedRoutes() {
    authenticate("auth-jwt") {
        get("/profile") {
            val principal = call.principal<JWTPrincipal>()
            val username = principal?.payload?.getClaim("username")?.asString()
                ?: return@get call.respond(HttpStatusCode.Unauthorized)
            
            val user = userService.findByUsername(username)
            call.respond(HttpStatusCode.OK, user)
        }
    }
}
```

## Request Handling

### Request Validation
```kotlin
// ✅ Good - validation with sealed class results
sealed class ValidationResult {
    data object Valid : ValidationResult()
    data class Invalid(val errors: List<String>) : ValidationResult()
}

fun CreateUserRequest.validate(): ValidationResult {
    val errors = mutableListOf<String>()
    
    if (name.isBlank()) errors.add("Name is required")
    if (name.length < 2 || name.length > 100) {
        errors.add("Name must be between 2 and 100 characters")
    }
    
    if (email.isBlank()) errors.add("Email is required")
    if (!email.matches(Regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))) {
        errors.add("Invalid email format")
    }
    
    return if (errors.isEmpty()) ValidationResult.Valid else ValidationResult.Invalid(errors)
}

// Usage in route
post {
    val request = call.receive<CreateUserRequest>()
    
    when (val result = request.validate()) {
        is ValidationResult.Valid -> {
            val created = userService.create(request)
            call.respond(HttpStatusCode.Created, created)
        }
        is ValidationResult.Invalid -> {
            call.respond(HttpStatusCode.BadRequest, mapOf("errors" to result.errors))
        }
    }
}
```

### Query Parameters
```kotlin
// ✅ Good - query parameter handling
get("/search") {
    val name = call.request.queryParameters["name"]
    val email = call.request.queryParameters["email"]
    val page = call.request.queryParameters["page"]?.toIntOrNull() ?: 0
    val size = call.request.queryParameters["size"]?.toIntOrNull() ?: 20
    
    val results = userService.search(
        SearchCriteria(
            name = name,
            email = email,
            page = page,
            size = size
        )
    )
    
    call.respond(HttpStatusCode.OK, results)
}
```

## Services and Business Logic

### Service Layer
```kotlin
// ✅ Good - service with dependency injection
class UserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    
    suspend fun findAll(): List<UserDto> = withContext(Dispatchers.IO) {
        userRepository.findAll()
            .map { it.toDto() }
    }
    
    suspend fun findById(id: Long): UserDto? = withContext(Dispatchers.IO) {
        userRepository.findById(id)?.toDto()
    }
    
    suspend fun create(request: CreateUserRequest): UserDto = withContext(Dispatchers.IO) {
        val user = User(
            name = request.name,
            email = request.email,
            createdAt = Instant.now()
        )
        
        val saved = userRepository.save(user)
        
        // Send welcome email asynchronously
        launch {
            emailService.sendWelcomeEmail(saved.email)
        }
        
        saved.toDto()
    }
    
    suspend fun update(id: Long, request: UpdateUserRequest): UserDto = withContext(Dispatchers.IO) {
        val existing = userRepository.findById(id)
            ?: throw NotFoundException("User not found: $id")
        
        val updated = existing.copy(
            name = request.name ?: existing.name,
            email = request.email ?: existing.email,
            updatedAt = Instant.now()
        )
        
        userRepository.update(updated).toDto()
    }
    
    suspend fun delete(id: Long): Unit = withContext(Dispatchers.IO) {
        if (!userRepository.existsById(id)) {
            throw NotFoundException("User not found: $id")
        }
        userRepository.deleteById(id)
    }
}
```

## Exception Handling

### Custom Exceptions
```kotlin
// ✅ Good - sealed class for exceptions
sealed class AppException(message: String) : RuntimeException(message) {
    class NotFoundException(message: String) : AppException(message)
    class BadRequestException(message: String) : AppException(message)
    class UnauthorizedException(message: String = "Unauthorized") : AppException(message)
    class ForbiddenException(message: String = "Forbidden") : AppException(message)
}

// Error response model
@Serializable
data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: String = Instant.now().toString()
)
```

### Status Pages Plugin
```kotlin
// ✅ Good - global exception handling
fun Application.configureStatusPages() {
    install(StatusPages) {
        exception<AppException.NotFoundException> { call, cause ->
            call.respond(
                HttpStatusCode.NotFound,
                ErrorResponse(
                    status = HttpStatusCode.NotFound.value,
                    message = cause.message ?: "Not found"
                )
            )
        }
        
        exception<AppException.BadRequestException> { call, cause ->
            call.respond(
                HttpStatusCode.BadRequest,
                ErrorResponse(
                    status = HttpStatusCode.BadRequest.value,
                    message = cause.message ?: "Bad request"
                )
            )
        }
        
        exception<AppException.UnauthorizedException> { call, cause ->
            call.respond(
                HttpStatusCode.Unauthorized,
                ErrorResponse(
                    status = HttpStatusCode.Unauthorized.value,
                    message = cause.message ?: "Unauthorized"
                )
            )
        }
        
        exception<Throwable> { call, cause ->
            call.application.log.error("Unhandled exception", cause)
            call.respond(
                HttpStatusCode.InternalServerError,
                ErrorResponse(
                    status = HttpStatusCode.InternalServerError.value,
                    message = "Internal server error"
                )
            )
        }
    }
}
```

## Authentication & Security

### JWT Authentication
```kotlin
// ✅ Good - JWT configuration
fun Application.configureSecurity() {
    val jwtSecret = environment.config.property("jwt.secret").getString()
    val jwtAudience = environment.config.property("jwt.audience").getString()
    val jwtIssuer = environment.config.property("jwt.issuer").getString()
    val jwtRealm = environment.config.property("jwt.realm").getString()
    
    install(Authentication) {
        jwt("auth-jwt") {
            realm = jwtRealm
            verifier(
                JWT
                    .require(Algorithm.HMAC256(jwtSecret))
                    .withAudience(jwtAudience)
                    .withIssuer(jwtIssuer)
                    .build()
            )
            validate { credential ->
                if (credential.payload.audience.contains(jwtAudience)) {
                    JWTPrincipal(credential.payload)
                } else {
                    null
                }
            }
            challenge { _, _ ->
                call.respond(HttpStatusCode.Unauthorized, "Token is not valid or has expired")
            }
        }
    }
}

// JWT token generation
class JwtService(
    private val secret: String,
    private val issuer: String,
    private val audience: String,
    private val expirationMs: Long = 3_600_000 // 1 hour
) {
    
    fun generateToken(username: String): String =
        JWT.create()
            .withAudience(audience)
            .withIssuer(issuer)
            .withClaim("username", username)
            .withExpiresAt(Date(System.currentTimeMillis() + expirationMs))
            .sign(Algorithm.HMAC256(secret))
}
```

### Login Route
```kotlin
// ✅ Good - login endpoint
fun Route.authRoutes() {
    val jwtService = JwtService(
        secret = environment.config.property("jwt.secret").getString(),
        issuer = environment.config.property("jwt.issuer").getString(),
        audience = environment.config.property("jwt.audience").getString()
    )
    
    post("/login") {
        val credentials = call.receive<LoginRequest>()
        
        val user = userService.authenticate(credentials.username, credentials.password)
            ?: return@post call.respond(
                HttpStatusCode.Unauthorized,
                ErrorResponse(401, "Invalid credentials")
            )
        
        val token = jwtService.generateToken(user.username)
        
        call.respond(
            HttpStatusCode.OK,
            LoginResponse(token = token, user = user.toDto())
        )
    }
}

@Serializable
data class LoginRequest(
    val username: String,
    val password: String
)

@Serializable
data class LoginResponse(
    val token: String,
    val user: UserDto
)
```

## Testing

### Route Tests
```kotlin
// ✅ Good - route testing with test client
class UserRoutesTest {
    
    @Test
    fun `GET users returns list of users`() = testApplication {
        application {
            configureRouting()
            configureSerialization()
        }
        
        val response = client.get("/api/users")
        
        assertEquals(HttpStatusCode.OK, response.status)
        val users = response.body<List<UserDto>>()
        assertTrue(users.isNotEmpty())
    }
    
    @Test
    fun `POST user creates new user`() = testApplication {
        application {
            configureRouting()
            configureSerialization()
        }
        
        val request = CreateUserRequest(
            name = "John Doe",
            email = "john@example.com"
        )
        
        val response = client.post("/api/users") {
            contentType(ContentType.Application.Json)
            setBody(request)
        }
        
        assertEquals(HttpStatusCode.Created, response.status)
        val created = response.body<UserDto>()
        assertEquals("John Doe", created.name)
    }
    
    @Test
    fun `GET user by invalid ID returns 400`() = testApplication {
        application {
            configureRouting()
            configureSerialization()
        }
        
        val response = client.get("/api/users/invalid")
        
        assertEquals(HttpStatusCode.BadRequest, response.status)
    }
}
```

### Service Tests
```kotlin
// ✅ Good - service testing with MockK
class UserServiceTest {
    
    private lateinit var userRepository: UserRepository
    private lateinit var emailService: EmailService
    private lateinit var userService: UserService
    
    @BeforeEach
    fun setup() {
        userRepository = mockk()
        emailService = mockk()
        userService = UserService(userRepository, emailService)
    }
    
    @Test
    fun `findById returns user when exists`() = runTest {
        // Given
        val userId = 1L
        val user = User(
            id = userId,
            name = "John",
            email = "john@example.com",
            createdAt = Instant.now()
        )
        
        coEvery { userRepository.findById(userId) } returns user
        
        // When
        val result = userService.findById(userId)
        
        // Then
        assertNotNull(result)
        assertEquals("John", result?.name)
        coVerify { userRepository.findById(userId) }
    }
    
    @Test
    fun `create sends welcome email`() = runTest {
        // Given
        val request = CreateUserRequest("John", "john@example.com")
        val saved = User(1L, "John", "john@example.com", Instant.now())
        
        coEvery { userRepository.save(any()) } returns saved
        coEvery { emailService.sendWelcomeEmail(any()) } just Runs
        
        // When
        userService.create(request)
        
        // Then
        coVerify { emailService.sendWelcomeEmail("john@example.com") }
    }
}
```

## Best Practices

### 1. Use Dependency Injection
```kotlin
// ✅ Good - manual DI or use Koin
object ServiceContainer {
    val database by lazy { Database.connect() }
    val userRepository by lazy { UserRepository(database) }
    val emailService by lazy { EmailService() }
    val userService by lazy { UserService(userRepository, emailService) }
}

// Or with Koin
val appModule = module {
    single { Database.connect() }
    single { UserRepository(get()) }
    single { EmailService() }
    single { UserService(get(), get()) }
}
```

### 2. Use Extension Functions
```kotlin
// ✅ Good - extend ApplicationCall
suspend fun ApplicationCall.respondCreated(data: Any) {
    respond(HttpStatusCode.Created, data)
}

suspend fun ApplicationCall.respondNoContent() {
    respond(HttpStatusCode.NoContent)
}

// Usage
call.respondCreated(user)
```

### 3. Type-Safe Request Parameters
```kotlin
// ✅ Good - extension for safe parameter extraction
fun Parameters.getLongOrNull(name: String): Long? =
    this[name]?.toLongOrNull()

fun Parameters.getIntOrNull(name: String): Int? =
    this[name]?.toIntOrNull()

// Usage
val userId = call.parameters.getLongOrNull("id")
    ?: return@get call.respond(HttpStatusCode.BadRequest, "Invalid ID")
```

### 4. Structured Logging
```kotlin
// ✅ Good - structured logging
suspend fun logRequest(call: ApplicationCall) {
    call.application.log.info(
        "Request: ${call.request.httpMethod.value} ${call.request.uri}"
    )
}
```

### 5. CORS Configuration
```kotlin
// ✅ Good - CORS setup
fun Application.configureCORS() {
    install(CORS) {
        allowMethod(HttpMethod.Options)
        allowMethod(HttpMethod.Get)
        allowMethod(HttpMethod.Post)
        allowMethod(HttpMethod.Put)
        allowMethod(HttpMethod.Delete)
        allowHeader(HttpHeaders.ContentType)
        allowHeader(HttpHeaders.Authorization)
        anyHost() // For development only
    }
}
```

