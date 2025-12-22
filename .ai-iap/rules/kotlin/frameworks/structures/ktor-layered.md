# Ktor Layered Structure

## Overview
Traditional layered architecture for Ktor, separating code by technical responsibilities.

## Directory Structure

```
src/main/kotlin/com/app/
├── route/                        # Presentation layer
│   ├── UserRoutes.kt
│   ├── OrderRoutes.kt
│   └── AuthRoutes.kt
├── service/                      # Business logic
│   ├── UserService.kt
│   ├── OrderService.kt
│   └── AuthService.kt
├── repository/                   # Data access
│   ├── UserRepository.kt
│   ├── OrderRepository.kt
│   └── database/
│       └── Tables.kt
├── model/                        # Domain models
│   ├── User.kt
│   ├── Order.kt
│   └── Auth.kt
├── dto/                          # Data transfer objects
│   ├── request/
│   │   ├── CreateUserRequest.kt
│   │   └── UpdateUserRequest.kt
│   └── response/
│       ├── UserResponse.kt
│       └── OrderResponse.kt
├── exception/                    # Exception handling
│   ├── AppException.kt
│   └── StatusPages.kt
├── config/                       # Configuration
│   ├── DatabaseConfig.kt
│   └── JwtConfig.kt
├── plugins/                      # Ktor plugins
│   ├── Routing.kt
│   ├── Serialization.kt
│   ├── Security.kt
│   └── Monitoring.kt
├── util/                         # Utilities
│   └── Extensions.kt
└── Application.kt

src/test/kotlin/com/app/
├── service/
│   └── UserServiceTest.kt
├── repository/
│   └── UserRepositoryTest.kt
└── route/
    └── UserRoutesTest.kt
```

## Implementation

### Model Layer
```kotlin
// model/User.kt
data class User(
    val id: Long = 0,
    val name: String,
    val email: String,
    val createdAt: Instant = Instant.now()
)
```

### DTO Layer
```kotlin
// dto/request/CreateUserRequest.kt
@Serializable
data class CreateUserRequest(
    val name: String,
    val email: String
)

// dto/request/UpdateUserRequest.kt
@Serializable
data class UpdateUserRequest(
    val name: String? = null,
    val email: String? = null
)

// dto/response/UserResponse.kt
@Serializable
data class UserResponse(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: String
)
```

### Repository Layer
```kotlin
// repository/database/Tables.kt
object Users : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    val updatedAt = timestamp("updated_at").defaultExpression(CurrentTimestamp())
    
    override val primaryKey = PrimaryKey(id)
}

// repository/UserRepository.kt
class UserRepository(
    private val database: Database
) {
    
    suspend fun findAll(): List<User> = dbQuery {
        Users.selectAll().map { toUser(it) }
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
    
    suspend fun existsByEmail(email: String): Boolean = dbQuery {
        Users.select { Users.email eq email }.count() > 0
    }
    
    private fun toUser(row: ResultRow): User = User(
        id = row[Users.id],
        name = row[Users.name],
        email = row[Users.email],
        createdAt = row[Users.createdAt]
    )
}

suspend fun <T> dbQuery(block: suspend () -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }
```

### Service Layer
```kotlin
// service/UserService.kt
class UserService(
    private val repository: UserRepository
) {
    
    suspend fun findAll(): List<UserResponse> =
        repository.findAll().map { toResponse(it) }
    
    suspend fun findById(id: Long): UserResponse {
        val user = repository.findById(id)
            ?: throw NotFoundException("User not found: $id")
        return toResponse(user)
    }
    
    suspend fun create(request: CreateUserRequest): UserResponse {
        // Validation
        validateUserRequest(request.name, request.email)
        
        // Check for duplicate email
        if (repository.existsByEmail(request.email)) {
            throw ConflictException("Email already exists: ${request.email}")
        }
        
        val user = User(
            name = request.name,
            email = request.email
        )
        
        val created = repository.create(user)
        return toResponse(created)
    }
    
    suspend fun update(id: Long, request: UpdateUserRequest): UserResponse {
        val existing = repository.findById(id)
            ?: throw NotFoundException("User not found: $id")
        
        // Validate if provided
        request.name?.let { validateName(it) }
        request.email?.let { email ->
            validateEmail(email)
            if (email != existing.email && repository.existsByEmail(email)) {
                throw ConflictException("Email already exists: $email")
            }
        }
        
        val updated = existing.copy(
            name = request.name ?: existing.name,
            email = request.email ?: existing.email
        )
        
        val saved = repository.update(id, updated)
            ?: throw NotFoundException("User not found: $id")
        
        return toResponse(saved)
    }
    
    suspend fun delete(id: Long) {
        if (!repository.delete(id)) {
            throw NotFoundException("User not found: $id")
        }
    }
    
    private fun validateUserRequest(name: String, email: String) {
        validateName(name)
        validateEmail(email)
    }
    
    private fun validateName(name: String) {
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(name.length in 2..100) { "Name must be between 2 and 100 characters" }
    }
    
    private fun validateEmail(email: String) {
        require(email.isNotBlank()) { "Email cannot be blank" }
        require(email.matches(Regex(".+@.+"))) { "Invalid email format" }
    }
    
    private fun toResponse(user: User) = UserResponse(
        id = user.id,
        name = user.name,
        email = user.email,
        createdAt = user.createdAt.toString()
    )
}
```

### Route Layer
```kotlin
// route/UserRoutes.kt
fun Route.userRoutes(service: UserService) {
    route("/users") {
        
        get {
            val users = service.findAll()
            call.respond(HttpStatusCode.OK, users)
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@get call.respond(
                    HttpStatusCode.BadRequest,
                    ErrorResponse(400, "Invalid ID")
                )
            
            val user = service.findById(id)
            call.respond(HttpStatusCode.OK, user)
        }
        
        get("/search") {
            val email = call.request.queryParameters["email"]
            if (email == null) {
                return@get call.respond(
                    HttpStatusCode.BadRequest,
                    ErrorResponse(400, "Email parameter is required")
                )
            }
            
            val user = service.findByEmail(email)
            call.respond(HttpStatusCode.OK, user)
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            val created = service.create(request)
            call.respond(HttpStatusCode.Created, created)
        }
        
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@put call.respond(
                    HttpStatusCode.BadRequest,
                    ErrorResponse(400, "Invalid ID")
                )
            
            val request = call.receive<UpdateUserRequest>()
            val updated = service.update(id, request)
            call.respond(HttpStatusCode.OK, updated)
        }
        
        delete("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@delete call.respond(
                    HttpStatusCode.BadRequest,
                    ErrorResponse(400, "Invalid ID")
                )
            
            service.delete(id)
            call.respond(HttpStatusCode.NoContent)
        }
    }
}
```

### Exception Layer
```kotlin
// exception/AppException.kt
sealed class AppException(message: String) : RuntimeException(message)

class NotFoundException(message: String) : AppException(message)
class ConflictException(message: String) : AppException(message)
class BadRequestException(message: String) : AppException(message)
class UnauthorizedException(message: String = "Unauthorized") : AppException(message)

// exception/StatusPages.kt
@Serializable
data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: String = Instant.now().toString()
)

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
        
        exception<UnauthorizedException> { call, cause ->
            call.respond(
                HttpStatusCode.Unauthorized,
                ErrorResponse(401, cause.message ?: "Unauthorized")
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
```

### Configuration Layer
```kotlin
// config/DatabaseConfig.kt
object DatabaseConfig {
    
    fun init() {
        val jdbcURL = System.getenv("DATABASE_URL") ?: "jdbc:postgresql://localhost:5432/mydb"
        val user = System.getenv("DATABASE_USER") ?: "user"
        val password = System.getenv("DATABASE_PASSWORD") ?: "password"
        
        Database.connect(
            url = jdbcURL,
            driver = "org.postgresql.Driver",
            user = user,
            password = password
        )
        
        transaction {
            SchemaUtils.create(Users, Orders)
        }
    }
}
```

### Plugins
```kotlin
// plugins/Routing.kt
fun Application.configureRouting() {
    DatabaseConfig.init()
    
    val userRepository = UserRepository(Database.connect())
    val userService = UserService(userRepository)
    
    routing {
        route("/api") {
            userRoutes(userService)
            // Add other routes
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
```

## Benefits
- Familiar structure
- Clear technical separation
- Easy to understand
- Works well for CRUD apps

## When to Use
- Traditional web applications
- Teams familiar with layered architecture
- CRUD-focused APIs
- When technical separation is preferred

