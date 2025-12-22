# Ktor Clean Architecture

## Overview
Clean Architecture for Ktor enforces strict separation between layers with dependency inversion, making business logic framework-independent.

## Directory Structure

```
src/main/kotlin/com/app/
├── core/                         # Shared components
│   ├── config/
│   │   └── DatabaseConfig.kt
│   ├── exception/
│   │   ├── AppException.kt
│   │   └── StatusPages.kt
│   └── util/
│       └── Extensions.kt
├── feature/                      # Feature modules
│   ├── user/
│   │   ├── domain/              # Business logic (no Ktor deps)
│   │   │   ├── model/
│   │   │   │   └── User.kt
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.kt  # Interface
│   │   │   └── usecase/
│   │   │       ├── GetUserUseCase.kt
│   │   │       ├── CreateUserUseCase.kt
│   │   │       └── UpdateUserUseCase.kt
│   │   ├── data/                # Data implementations
│   │   │   ├── repository/
│   │   │   │   └── UserRepositoryImpl.kt
│   │   │   ├── table/
│   │   │   │   └── UsersTable.kt
│   │   │   └── mapper/
│   │   │       └── UserMapper.kt
│   │   └── presentation/        # API layer
│   │       ├── route/
│   │       │   └── UserRoutes.kt
│   │       └── dto/
│   │           ├── UserDto.kt
│   │           └── UserRequest.kt
│   └── order/
│       ├── domain/
│       ├── data/
│       └── presentation/
├── plugins/                      # Ktor plugins
│   ├── Routing.kt
│   ├── Serialization.kt
│   ├── Security.kt
│   └── Monitoring.kt
└── Application.kt

src/test/kotlin/com/app/
├── feature/
│   └── user/
│       ├── domain/              # Pure Kotlin tests
│       ├── data/                # Repository tests
│       └── presentation/        # Route tests
```

## Implementation

### Domain Layer (Pure Kotlin)

```kotlin
// feature/user/domain/model/User.kt
data class User(
    val id: Long = 0,
    val name: String,
    val email: String,
    val createdAt: Instant = Instant.now()
)

// feature/user/domain/repository/UserRepository.kt
interface UserRepository {
    suspend fun findAll(): Result<List<User>>
    suspend fun findById(id: Long): Result<User>
    suspend fun findByEmail(email: String): Result<User?>
    suspend fun save(user: User): Result<User>
    suspend fun delete(id: Long): Result<Unit>
}

// feature/user/domain/usecase/GetUserUseCase.kt
class GetUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: Long): Result<User> =
        repository.findById(id)
}

// feature/user/domain/usecase/CreateUserUseCase.kt
class CreateUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(name: String, email: String): Result<User> {
        // Business validation
        if (name.isBlank()) return Result.failure(ValidationException("Name cannot be blank"))
        if (!email.matches(Regex(".+@.+"))) return Result.failure(ValidationException("Invalid email"))
        
        // Check duplicate email
        repository.findByEmail(email).getOrNull()?.let {
            return Result.failure(ConflictException("Email already exists"))
        }
        
        val user = User(name = name, email = email)
        return repository.save(user)
    }
}

// feature/user/domain/usecase/UpdateUserUseCase.kt
class UpdateUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: Long, name: String?, email: String?): Result<User> {
        val existing = repository.findById(id).getOrElse {
            return Result.failure(NotFoundException("User not found: $id"))
        }
        
        // Validate
        name?.let {
            if (it.isBlank()) return Result.failure(ValidationException("Name cannot be blank"))
        }
        
        email?.let {
            if (!it.matches(Regex(".+@.+"))) return Result.failure(ValidationException("Invalid email"))
            if (it != existing.email) {
                repository.findByEmail(it).getOrNull()?.let {
                    return Result.failure(ConflictException("Email already exists"))
                }
            }
        }
        
        val updated = existing.copy(
            name = name ?: existing.name,
            email = email ?: existing.email
        )
        
        return repository.save(updated)
    }
}

// feature/user/domain/usecase/DeleteUserUseCase.kt
class DeleteUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: Long): Result<Unit> =
        repository.delete(id)
}
```

### Data Layer

```kotlin
// feature/user/data/table/UsersTable.kt
object UsersTable : Table("users") {
    val id = long("id").autoIncrement()
    val name = varchar("name", 100)
    val email = varchar("email", 100).uniqueIndex()
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    
    override val primaryKey = PrimaryKey(id)
}

// feature/user/data/mapper/UserMapper.kt
class UserMapper {
    
    fun toDomain(row: ResultRow): User = User(
        id = row[UsersTable.id],
        name = row[UsersTable.name],
        email = row[UsersTable.email],
        createdAt = row[UsersTable.createdAt]
    )
}

// feature/user/data/repository/UserRepositoryImpl.kt
class UserRepositoryImpl(
    private val database: Database,
    private val mapper: UserMapper
) : UserRepository {
    
    override suspend fun findAll(): Result<List<User>> = withContext(Dispatchers.IO) {
        try {
            val users = dbQuery {
                UsersTable.selectAll().map { mapper.toDomain(it) }
            }
            Result.success(users)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun findById(id: Long): Result<User> = withContext(Dispatchers.IO) {
        try {
            val user = dbQuery {
                UsersTable.select { UsersTable.id eq id }
                    .map { mapper.toDomain(it) }
                    .singleOrNull()
            } ?: return@withContext Result.failure(NotFoundException("User not found: $id"))
            
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun findByEmail(email: String): Result<User?> = withContext(Dispatchers.IO) {
        try {
            val user = dbQuery {
                UsersTable.select { UsersTable.email eq email }
                    .map { mapper.toDomain(it) }
                    .singleOrNull()
            }
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun save(user: User): Result<User> = withContext(Dispatchers.IO) {
        try {
            val saved = dbQuery {
                if (user.id == 0L) {
                    // Insert
                    val id = UsersTable.insert {
                        it[name] = user.name
                        it[email] = user.email
                    } get UsersTable.id
                    user.copy(id = id)
                } else {
                    // Update
                    UsersTable.update({ UsersTable.id eq user.id }) {
                        it[name] = user.name
                        it[email] = user.email
                    }
                    user
                }
            }
            Result.success(saved)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun delete(id: Long): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            dbQuery {
                val deleted = UsersTable.deleteWhere { UsersTable.id eq id }
                if (deleted == 0) throw NotFoundException("User not found: $id")
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

suspend fun <T> dbQuery(block: suspend () -> T): T =
    newSuspendedTransaction(Dispatchers.IO) { block() }
```

### Presentation Layer

```kotlin
// feature/user/presentation/dto/UserDto.kt
@Serializable
data class UserResponse(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: String
)

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

// feature/user/presentation/route/UserRoutes.kt
fun Route.userRoutes(
    getUserUseCase: GetUserUseCase,
    getAllUsersUseCase: GetAllUsersUseCase,
    createUserUseCase: CreateUserUseCase,
    updateUserUseCase: UpdateUserUseCase,
    deleteUserUseCase: DeleteUserUseCase
) {
    route("/users") {
        
        get {
            getAllUsersUseCase()
                .onSuccess { users ->
                    call.respond(HttpStatusCode.OK, users.map { it.toResponse() })
                }
                .onFailure { error ->
                    throw error
                }
        }
        
        get("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@get call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            getUserUseCase(id)
                .onSuccess { user ->
                    call.respond(HttpStatusCode.OK, user.toResponse())
                }
                .onFailure { error ->
                    throw error
                }
        }
        
        post {
            val request = call.receive<CreateUserRequest>()
            
            createUserUseCase(request.name, request.email)
                .onSuccess { user ->
                    call.respond(HttpStatusCode.Created, user.toResponse())
                }
                .onFailure { error ->
                    throw error
                }
        }
        
        put("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@put call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            val request = call.receive<UpdateUserRequest>()
            
            updateUserUseCase(id, request.name, request.email)
                .onSuccess { user ->
                    call.respond(HttpStatusCode.OK, user.toResponse())
                }
                .onFailure { error ->
                    throw error
                }
        }
        
        delete("/{id}") {
            val id = call.parameters["id"]?.toLongOrNull()
                ?: return@delete call.respond(HttpStatusCode.BadRequest, "Invalid ID")
            
            deleteUserUseCase(id)
                .onSuccess {
                    call.respond(HttpStatusCode.NoContent)
                }
                .onFailure { error ->
                    throw error
                }
        }
    }
}

private fun User.toResponse() = UserResponse(
    id = id,
    name = name,
    email = email,
    createdAt = createdAt.toString()
)
```

### Exception Handling

```kotlin
// core/exception/AppException.kt
sealed class AppException(message: String) : RuntimeException(message)

class NotFoundException(message: String) : AppException(message)
class ConflictException(message: String) : AppException(message)
class ValidationException(message: String) : AppException(message)
class UnauthorizedException(message: String = "Unauthorized") : AppException(message)
```

### Dependency Injection & Setup

```kotlin
// plugins/Routing.kt
fun Application.configureRouting() {
    val database = Database.connect(
        url = "jdbc:postgresql://localhost:5432/mydb",
        driver = "org.postgresql.Driver",
        user = "user",
        password = "password"
    )
    
    // Initialize tables
    transaction {
        SchemaUtils.create(UsersTable)
    }
    
    // Build dependency graph
    val userMapper = UserMapper()
    val userRepository: UserRepository = UserRepositoryImpl(database, userMapper)
    
    val getUserUseCase = GetUserUseCase(userRepository)
    val getAllUsersUseCase = GetAllUsersUseCase(userRepository)
    val createUserUseCase = CreateUserUseCase(userRepository)
    val updateUserUseCase = UpdateUserUseCase(userRepository)
    val deleteUserUseCase = DeleteUserUseCase(userRepository)
    
    routing {
        route("/api") {
            userRoutes(
                getUserUseCase,
                getAllUsersUseCase,
                createUserUseCase,
                updateUserUseCase,
                deleteUserUseCase
            )
        }
    }
}
```

## Testing

### Domain Tests (Pure Kotlin)
```kotlin
class CreateUserUseCaseTest {
    
    private lateinit var repository: UserRepository
    private lateinit var useCase: CreateUserUseCase
    
    @BeforeEach
    fun setup() {
        repository = mockk()
        useCase = CreateUserUseCase(repository)
    }
    
    @Test
    fun `invoke creates user when valid`() = runTest {
        // Given
        val user = User(1, "John", "john@example.com")
        coEvery { repository.findByEmail(any()) } returns Result.success(null)
        coEvery { repository.save(any()) } returns Result.success(user)
        
        // When
        val result = useCase("John", "john@example.com")
        
        // Then
        assertTrue(result.isSuccess)
        assertEquals(user, result.getOrNull())
    }
    
    @Test
    fun `invoke fails when email exists`() = runTest {
        // Given
        val existing = User(1, "Jane", "john@example.com")
        coEvery { repository.findByEmail(any()) } returns Result.success(existing)
        
        // When
        val result = useCase("John", "john@example.com")
        
        // Then
        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull() is ConflictException)
    }
}
```

## Benefits
- Framework-independent business logic
- Testable without Ktor
- Clear boundaries
- Easy to migrate frameworks
- Scalable architecture

## When to Use
- Large, complex applications
- Long-term projects
- When testability is critical
- Multi-platform projects (domain is pure Kotlin)

