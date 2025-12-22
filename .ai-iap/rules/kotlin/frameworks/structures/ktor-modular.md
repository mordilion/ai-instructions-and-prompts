# Ktor Modular Structure

## Overview
Feature-first modular structure for Ktor applications, organizing code by business capabilities.

## Directory Structure

```
src/main/kotlin/com/app/
├── common/                       # Shared utilities
│   ├── config/
│   │   └── AppConfig.kt
│   ├── exception/
│   │   ├── AppException.kt
│   │   └── StatusPages.kt
│   ├── security/
│   │   └── JwtConfig.kt
│   └── util/
│       └── Extensions.kt
├── user/                        # User module
│   ├── User.kt                 # Domain model
│   ├── UserRepository.kt       # Repository
│   ├── UserService.kt          # Business logic
│   ├── UserRoutes.kt           # Routes
│   └── UserDto.kt              # DTOs
├── auth/                        # Auth module
│   ├── Auth.kt
│   ├── AuthService.kt
│   └── AuthRoutes.kt
├── order/                       # Order module
│   ├── Order.kt
│   ├── OrderRepository.kt
│   ├── OrderService.kt
│   ├── OrderRoutes.kt
│   └── OrderDto.kt
├── plugins/                     # Ktor plugins
│   ├── Routing.kt
│   ├── Serialization.kt
│   ├── Security.kt
│   └── Monitoring.kt
└── Application.kt

src/test/kotlin/com/app/
├── user/
│   ├── UserServiceTest.kt
│   └── UserRoutesTest.kt
└── auth/
    └── AuthServiceTest.kt
```

## Implementation

### Domain Model
```kotlin
// user/User.kt
@Serializable
data class User(
    val id: Long = 0,
    val name: String,
    val email: String,
    val createdAt: String = Instant.now().toString()
)
```

### DTOs
```kotlin
// user/UserDto.kt
@Serializable
data class CreateUserRequest(
    val name: String,
    val email: String
)

@Serializable
data class UpdateUserRequest(
    val name: String? = null,
    val email: String? = null
)

@Serializable
data class UserResponse(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: String
)
```

### Repository
```kotlin
// user/UserRepository.kt
class UserRepository(
    private val database: Database
) {
    
    suspend fun findAll(): List<User> = dbQuery {
        Users.selectAll()
            .map { toUser(it) }
    }
    
    suspend fun findById(id: Long): User? = dbQuery {
        Users.select { Users.id eq id }
            .map { toUser(it) }
            .singleOrNull()
    }
    
    suspend fun findByEmail(email: String): User? = dbQuery {
        Users.select { Users.email eq email }
            .map { toUser(it) }
            .singleOrNull()
    }
    
    suspend fun create(user: User): User = dbQuery {
        val id = Users.insert {
            it[name] = user.name
            it[email] = user.email
        } get Users.id
        
        user.copy(id = id)
    }
    
    suspend fun update(id: Long, user: User): User? = dbQuery {
        val updated = Users.update({ Users.id eq id }) {
            it[name] = user.name
            it[email] = user.email
            it[updatedAt] = Instant.now()
        }
        
        if (updated > 0) user.copy(id = id) else null
    }
    
    suspend fun delete(id: Long): Boolean = dbQuery {
        Users.deleteWhere { Users.id eq id } > 0
    }
    
    private fun toUser(row: ResultRow): User = User(
        id = row[Users.id],
        name = row[Users.name],
        email = row[Users.email],
        createdAt = row[Users.createdAt].toString()
    )
}

object Users : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    val updatedAt = timestamp("updated_at").defaultExpression(CurrentTimestamp())
    
    override val primaryKey = PrimaryKey(id)
}
```

### Service
```kotlin
// user/UserService.kt
class UserService(
    private val repository: UserRepository
) {
    
    suspend fun findAll(): List<UserResponse> =
        repository.findAll().map { it.toResponse() }
    
    suspend fun findById(id: Long): UserResponse =
        repository.findById(id)?.toResponse()
            ?: throw NotFoundException("User not found: $id")
    
    suspend fun create(request: CreateUserRequest): UserResponse {
        // Validation
        require(request.name.isNotBlank()) { "Name cannot be blank" }
        require(request.email.matches(Regex(".+@.+"))) { "Invalid email" }
        
        // Check for duplicate email
        repository.findByEmail(request.email)?.let {
            throw ConflictException("Email already exists: ${request.email}")
        }
        
        val user = User(
            name = request.name,
            email = request.email
        )
        
        return repository.create(user).toResponse()
    }
    
    suspend fun update(id: Long, request: UpdateUserRequest): UserResponse {
        val existing = repository.findById(id)
            ?: throw NotFoundException("User not found: $id")
        
        // Check email uniqueness if email is being updated
        request.email?.let { newEmail ->
            if (newEmail != existing.email && repository.findByEmail(newEmail) != null) {
                throw ConflictException("Email already exists: $newEmail")
            }
        }
        
        val updated = existing.copy(
            name = request.name ?: existing.name,
            email = request.email ?: existing.email
        )
        
        return repository.update(id, updated)?.toResponse()
            ?: throw NotFoundException("User not found: $id")
    }
    
    suspend fun delete(id: Long) {
        if (!repository.delete(id)) {
            throw NotFoundException("User not found: $id")
        }
    }
    
    private fun User.toResponse() = UserResponse(
        id = id,
        name = name,
        email = email,
        createdAt = createdAt
    )
}
```

### Routes
```kotlin
// user/UserRoutes.kt
fun Route.userRoutes(service: UserService) {
    route("/users") {
        
        get {
            val users = service.findAll()
            call.respond(HttpStatusCode.OK, users)
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@get call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            val user = service.findById(id)
            call.respond(HttpStatusCode.OK, user)
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            val created = service.create(request)
            call.respond(HttpStatusCode.Created, created)
        }
        
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@put call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            val request = call.receive<UpdateUserRequest>()
            val updated = service.update(id, request)
            call.respond(HttpStatusCode.OK, updated)
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

### Main Application
```kotlin
// Application.kt
fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0") {
        module()
    }.start(wait = true)
}

fun Application.module() {
    configureSerialization()
    configureSecurity()
    configureMonitoring()
    configureStatusPages()
    configureRouting()
}

fun Application.configureRouting() {
    // Initialize services
    val database = Database.connect(
        url = "jdbc:postgresql://localhost:5432/mydb",
        driver = "org.postgresql.Driver",
        user = "user",
        password = "password"
    )
    
    val userRepository = UserRepository(database)
    val userService = UserService(userRepository)
    
    routing {
        route("/api") {
            userRoutes(userService)
            // Add other module routes
        }
    }
}
```

### Plugins
```kotlin
// plugins/Serialization.kt
fun Application.configureSerialization() {
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
            ignoreUnknownKeys = true
        })
    }
}

// plugins/Monitoring.kt
fun Application.configureMonitoring() {
    install(CallLogging) {
        level = Level.INFO
        filter { call -> call.request.path().startsWith("/api") }
    }
}

// plugins/Security.kt
fun Application.configureSecurity() {
    install(CORS) {
        allowMethod(HttpMethod.Options)
        allowMethod(HttpMethod.Get)
        allowMethod(HttpMethod.Post)
        allowMethod(HttpMethod.Put)
        allowMethod(HttpMethod.Delete)
        allowHeader(HttpHeaders.ContentType)
        allowHeader(HttpHeaders.Authorization)
        anyHost()
    }
}
```

### Exception Handling
```kotlin
// common/exception/AppException.kt
sealed class AppException(message: String) : RuntimeException(message) {
    class NotFoundException(message: String) : AppException(message)
    class ConflictException(message: String) : AppException(message)
    class BadRequestException(message: String) : AppException(message)
    class UnauthorizedException(message: String = "Unauthorized") : AppException(message)
}

// common/exception/StatusPages.kt
fun Application.configureStatusPages() {
    install(StatusPages) {
        exception<NotFoundException> { call, cause ->
            call.respond(
                HttpStatusCode.NotFound,
                ErrorResponse(404, cause.message ?: "Not found")
            )
        }
        
        exception<ConflictException> { call, cause ->
            call.respond(
                HttpStatusCode.Conflict,
                ErrorResponse(409, cause.message ?: "Conflict")
            )
        }
        
        exception<BadRequestException> { call, cause ->
            call.respond(
                HttpStatusCode.BadRequest,
                ErrorResponse(400, cause.message ?: "Bad request")
            )
        }
        
        exception<IllegalArgumentException> { call, cause ->
            call.respond(
                HttpStatusCode.BadRequest,
                ErrorResponse(400, cause.message ?: "Bad request")
            )
        }
        
        exception<Throwable> { call, cause ->
            call.application.log.error("Unhandled exception", cause)
            call.respond(
                HttpStatusCode.InternalServerError,
                ErrorResponse(500, "Internal server error")
            )
        }
    }
}

@Serializable
data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: String = Instant.now().toString()
)
```

## Testing

```kotlin
// user/UserRoutesTest.kt
class UserRoutesTest {
    
    @Test
    fun `GET users returns list`() = testApplication {
        application {
            configureSerialization()
            configureRouting()
        }
        
        val response = client.get("/api/users")
        
        assertEquals(HttpStatusCode.OK, response.status)
        val users = response.body<List<UserResponse>>()
        assertTrue(users.isNotEmpty())
    }
    
    @Test
    fun `POST user creates new user`() = testApplication {
        application {
            configureSerialization()
            configureRouting()
        }
        
        val request = CreateUserRequest("John", "john@example.com")
        
        val response = client.post("/api/users") {
            contentType(ContentType.Application.Json)
            setBody(request)
        }
        
        assertEquals(HttpStatusCode.Created, response.status)
        val created = response.body<UserResponse>()
        assertEquals("John", created.name)
    }
}
```

## Benefits
- Simple and intuitive
- Fast development
- All related code in one place
- Easy to navigate

## When to Use
- Small to medium Ktor applications
- Microservices
- Rapid prototyping
- Clear feature boundaries

