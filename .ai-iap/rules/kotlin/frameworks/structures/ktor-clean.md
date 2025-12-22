# Ktor Clean Architecture

## Overview
Clean Architecture for Ktor with strict layer separation and framework-independent business logic.

## Directory Structure

```
src/main/kotlin/com/app/
├── core/
│   ├── config/
│   └── exception/
├── feature/
│   └── user/
│       ├── domain/
│       │   ├── model/User.kt
│       │   ├── repository/UserRepository.kt
│       │   └── usecase/
│       ├── data/
│       │   ├── repository/UserRepositoryImpl.kt
│       │   ├── table/UsersTable.kt
│       │   └── mapper/
│       └── presentation/
│           ├── route/UserRoutes.kt
│           └── dto/
```

## Implementation

### Domain (Pure Kotlin)
```kotlin
data class User(val id: Long = 0, val name: String, val email: String)

interface UserRepository {
    suspend fun findAll(): Result<List<User>>
    suspend fun save(user: User): Result<User>
}

class GetUsersUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(): Result<List<User>> = repository.findAll()
}

class CreateUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(name: String, email: String): Result<User> {
        if (name.isBlank()) return Result.failure(ValidationException("Name required"))
        if (!email.matches(Regex(".+@.+"))) return Result.failure(ValidationException("Invalid email"))
        return repository.save(User(name = name, email = email))
    }
}
```

### Data Layer
```kotlin
object UsersTable : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    override val primaryKey = PrimaryKey(id)
}

class UserRepositoryImpl(private val database: Database) : UserRepository {
    override suspend fun findAll(): Result<List<User>> = withContext(Dispatchers.IO) {
        try {
            val users = dbQuery { UsersTable.selectAll().map { it.toUser() } }
            Result.success(users)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun save(user: User): Result<User> = withContext(Dispatchers.IO) {
        try {
            val id = dbQuery {
                UsersTable.insert {
                    it[name] = user.name
                    it[email] = user.email
                } get UsersTable.id
            }
            Result.success(user.copy(id = id))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### Presentation Layer
```kotlin
@Serializable
data class UserResponse(val id: Long, val name: String, val email: String)

@Serializable
data class CreateUserRequest(val name: String, val email: String)

fun Route.userRoutes(
    getUsersUseCase: GetUsersUseCase,
    createUserUseCase: CreateUserUseCase
) {
    route("/users") {
        get {
            getUsersUseCase()
                .onSuccess { users -> call.respond(HttpStatusCode.OK, users.map { it.toResponse() }) }
                .onFailure { throw it }
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            createUserUseCase(request.name, request.email)
                .onSuccess { call.respond(HttpStatusCode.Created, it.toResponse()) }
                .onFailure { throw it }
        }
    }
}
```

### DI Setup
```kotlin
fun Application.configureRouting() {
    val database = Database.connect("jdbc:postgresql://localhost/db")
    
    val userRepository: UserRepository = UserRepositoryImpl(database)
    val getUsersUseCase = GetUsersUseCase(userRepository)
    val createUserUseCase = CreateUserUseCase(userRepository)
    
    routing {
        route("/api") {
            userRoutes(getUsersUseCase, createUserUseCase)
        }
    }
}
```

## Benefits
- Framework-independent business logic
- Testable without Ktor
- Easy to migrate frameworks

## When to Use
- Large, complex APIs
- Long-term projects
- Multi-platform projects
