# Ktor Modular Structure

## Overview
Feature-first modular structure for Ktor.

## Directory Structure

```
src/main/kotlin/com/app/
├── common/
│   ├── config/
│   ├── exception/
│   └── security/
├── user/
│   ├── User.kt
│   ├── UserRepository.kt
│   ├── UserService.kt
│   ├── UserRoutes.kt
│   └── UserDto.kt
├── auth/
└── plugins/
```

## Implementation

### Domain Model
```kotlin
@Serializable
data class User(val id: Long = 0, val name: String, val email: String)

@Serializable
data class CreateUserRequest(val name: String, val email: String)
```

### Repository
```kotlin
class UserRepository(private val database: Database) {
    suspend fun findAll(): List<User> = dbQuery {
        Users.selectAll().map { toUser(it) }
    }
    
    suspend fun create(user: User): User = dbQuery {
        val id = Users.insert {
            it[name] = user.name
            it[email] = user.email
        } get Users.id
        user.copy(id = id)
    }
}

object Users : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    override val primaryKey = PrimaryKey(id)
}
```

### Service
```kotlin
class UserService(private val repository: UserRepository) {
    suspend fun findAll(): List<UserResponse> =
        repository.findAll().map { it.toResponse() }
    
    suspend fun create(request: CreateUserRequest): UserResponse {
        require(request.name.isNotBlank()) { "Name required" }
        val user = User(name = request.name, email = request.email)
        return repository.create(user).toResponse()
    }
}
```

### Routes
```kotlin
fun Route.userRoutes(service: UserService) {
    route("/users") {
        get {
            call.respond(HttpStatusCode.OK, service.findAll())
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            call.respond(HttpStatusCode.Created, service.create(request))
        }
    }
}
```

### Exception Handling
```kotlin
sealed class AppException(message: String) : RuntimeException(message) {
    class NotFoundException(message: String) : AppException(message)
}

fun Application.configureStatusPages() {
    install(StatusPages) {
        exception<NotFoundException> { call, cause ->
            call.respond(HttpStatusCode.NotFound, ErrorResponse(404, cause.message ?: ""))
        }
    }
}
```

## Benefits
- Simple, intuitive
- Fast development
- All related code together

## When to Use
- Small to medium APIs
- Microservices
