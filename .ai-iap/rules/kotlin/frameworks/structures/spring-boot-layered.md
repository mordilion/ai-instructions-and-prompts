# Spring Boot Layered Structure

## Overview
Traditional layered architecture separates code by technical responsibilities: presentation, service, data access.

## Directory Structure

```
src/main/kotlin/com/app/
├── config/                       # Configuration
│   ├── SecurityConfig.kt
│   ├── DatabaseConfig.kt
│   └── WebConfig.kt
├── controller/                   # Presentation layer
│   ├── UserController.kt
│   ├── OrderController.kt
│   └── ProductController.kt
├── service/                      # Business logic
│   ├── UserService.kt
│   ├── OrderService.kt
│   └── ProductService.kt
├── repository/                   # Data access
│   ├── UserRepository.kt
│   ├── OrderRepository.kt
│   └── ProductRepository.kt
├── entity/                       # JPA entities
│   ├── UserEntity.kt
│   ├── OrderEntity.kt
│   └── ProductEntity.kt
├── dto/                          # Data transfer objects
│   ├── request/
│   │   ├── CreateUserRequest.kt
│   │   └── UpdateUserRequest.kt
│   └── response/
│       ├── UserResponse.kt
│       └── OrderResponse.kt
├── mapper/                       # Entity ↔ DTO mappers
│   ├── UserMapper.kt
│   └── OrderMapper.kt
├── exception/                    # Exception handling
│   ├── AppException.kt
│   └── GlobalExceptionHandler.kt
├── util/                         # Utilities
│   └── Extensions.kt
└── Application.kt

src/test/kotlin/com/app/
├── controller/
│   ├── UserControllerTest.kt
│   └── OrderControllerTest.kt
├── service/
│   ├── UserServiceTest.kt
│   └── OrderServiceTest.kt
└── repository/
    └── UserRepositoryTest.kt
```

## Implementation

### Entity Layer
```kotlin
// entity/UserEntity.kt
@Entity
@Table(name = "users")
data class UserEntity(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val name: String,
    
    @Column(nullable = false, unique = true)
    val email: String,
    
    @Column(name = "created_at", nullable = false)
    val createdAt: Instant = Instant.now(),
    
    @Column(name = "updated_at", nullable = false)
    val updatedAt: Instant = Instant.now()
)
```

### Repository Layer
```kotlin
// repository/UserRepository.kt
@Repository
interface UserRepository : JpaRepository<UserEntity, Long> {
    
    fun findByEmail(email: String): UserEntity?
    
    fun findByNameContainingIgnoreCase(name: String): List<UserEntity>
    
    @Query("SELECT u FROM UserEntity u WHERE u.createdAt > :date")
    fun findRecentUsers(@Param("date") date: Instant): List<UserEntity>
}
```

### DTO Layer
```kotlin
// dto/response/UserResponse.kt
data class UserResponse(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: Instant
)

// dto/request/CreateUserRequest.kt
data class CreateUserRequest(
    @field:NotBlank(message = "Name is required")
    @field:Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    val name: String,
    
    @field:NotBlank(message = "Email is required")
    @field:Email(message = "Email must be valid")
    val email: String
)

// dto/request/UpdateUserRequest.kt
data class UpdateUserRequest(
    @field:Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    val name: String? = null,
    
    @field:Email(message = "Email must be valid")
    val email: String? = null
)
```

### Mapper Layer
```kotlin
// mapper/UserMapper.kt
@Component
class UserMapper {
    
    fun toResponse(entity: UserEntity): UserResponse = UserResponse(
        id = entity.id,
        name = entity.name,
        email = entity.email,
        createdAt = entity.createdAt
    )
    
    fun toEntity(request: CreateUserRequest): UserEntity = UserEntity(
        name = request.name,
        email = request.email
    )
    
    fun updateEntity(entity: UserEntity, request: UpdateUserRequest): UserEntity =
        entity.copy(
            name = request.name ?: entity.name,
            email = request.email ?: entity.email,
            updatedAt = Instant.now()
        )
}
```

### Service Layer
```kotlin
// service/UserService.kt
@Service
class UserService(
    private val repository: UserRepository,
    private val mapper: UserMapper
) {
    
    suspend fun findAll(): List<UserResponse> = withContext(Dispatchers.IO) {
        repository.findAll().map { mapper.toResponse(it) }
    }
    
    suspend fun findById(id: Long): UserResponse = withContext(Dispatchers.IO) {
        val entity = repository.findById(id)
            .orElseThrow { UserNotFoundException(id) }
        mapper.toResponse(entity)
    }
    
    suspend fun findByEmail(email: String): UserResponse? = withContext(Dispatchers.IO) {
        repository.findByEmail(email)?.let { mapper.toResponse(it) }
    }
    
    suspend fun create(request: CreateUserRequest): UserResponse = withContext(Dispatchers.IO) {
        // Check for duplicate email
        repository.findByEmail(request.email)?.let {
            throw EmailAlreadyExistsException(request.email)
        }
        
        val entity = mapper.toEntity(request)
        val saved = repository.save(entity)
        mapper.toResponse(saved)
    }
    
    suspend fun update(id: Long, request: UpdateUserRequest): UserResponse = withContext(Dispatchers.IO) {
        val entity = repository.findById(id)
            .orElseThrow { UserNotFoundException(id) }
        
        // Check email uniqueness if email is being updated
        request.email?.let { newEmail ->
            if (newEmail != entity.email && repository.findByEmail(newEmail) != null) {
                throw EmailAlreadyExistsException(newEmail)
            }
        }
        
        val updated = mapper.updateEntity(entity, request)
        val saved = repository.save(updated)
        mapper.toResponse(saved)
    }
    
    suspend fun delete(id: Long) = withContext(Dispatchers.IO) {
        if (!repository.existsById(id)) {
            throw UserNotFoundException(id)
        }
        repository.deleteById(id)
    }
    
    suspend fun search(query: String): List<UserResponse> = withContext(Dispatchers.IO) {
        repository.findByNameContainingIgnoreCase(query)
            .map { mapper.toResponse(it) }
    }
}
```

### Controller Layer
```kotlin
// controller/UserController.kt
@RestController
@RequestMapping("/api/users")
class UserController(
    private val service: UserService
) {
    
    @GetMapping
    suspend fun getAll(): ResponseEntity<List<UserResponse>> =
        ResponseEntity.ok(service.findAll())
    
    @GetMapping("/{id}")
    suspend fun getById(@PathVariable id: Long): ResponseEntity<UserResponse> =
        ResponseEntity.ok(service.findById(id))
    
    @GetMapping("/search")
    suspend fun search(@RequestParam query: String): ResponseEntity<List<UserResponse>> =
        ResponseEntity.ok(service.search(query))
    
    @PostMapping
    suspend fun create(
        @Valid @RequestBody request: CreateUserRequest
    ): ResponseEntity<UserResponse> {
        val created = service.create(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(created)
    }
    
    @PutMapping("/{id}")
    suspend fun update(
        @PathVariable id: Long,
        @Valid @RequestBody request: UpdateUserRequest
    ): ResponseEntity<UserResponse> =
        ResponseEntity.ok(service.update(id, request))
    
    @DeleteMapping("/{id}")
    suspend fun delete(@PathVariable id: Long): ResponseEntity<Void> {
        service.delete(id)
        return ResponseEntity.noContent().build()
    }
}
```

### Exception Layer
```kotlin
// exception/AppException.kt
sealed class AppException(message: String) : RuntimeException(message) {
    class UserNotFoundException(id: Long) : AppException("User not found: $id")
    class EmailAlreadyExistsException(email: String) : AppException("Email already exists: $email")
    class ValidationException(message: String) : AppException(message)
}

// exception/GlobalExceptionHandler.kt
@RestControllerAdvice
class GlobalExceptionHandler {
    
    @ExceptionHandler(AppException.UserNotFoundException::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(ex: AppException.UserNotFoundException): ErrorResponse =
        ErrorResponse(
            status = HttpStatus.NOT_FOUND.value(),
            message = ex.message ?: "Not found",
            timestamp = Instant.now()
        )
    
    @ExceptionHandler(AppException.EmailAlreadyExistsException::class)
    @ResponseStatus(HttpStatus.CONFLICT)
    fun handleEmailAlreadyExists(ex: AppException.EmailAlreadyExistsException): ErrorResponse =
        ErrorResponse(
            status = HttpStatus.CONFLICT.value(),
            message = ex.message ?: "Conflict",
            timestamp = Instant.now()
        )
    
    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleValidationError(ex: MethodArgumentNotValidException): ErrorResponse {
        val errors = ex.bindingResult.fieldErrors.joinToString(", ") {
            "${it.field}: ${it.defaultMessage}"
        }
        return ErrorResponse(
            status = HttpStatus.BAD_REQUEST.value(),
            message = errors,
            timestamp = Instant.now()
        )
    }
    
    @ExceptionHandler(Exception::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun handleGenericError(ex: Exception): ErrorResponse {
        // Log the exception
        return ErrorResponse(
            status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
            message = "Internal server error",
            timestamp = Instant.now()
        )
    }
}

data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: Instant
)
```

### Configuration Layer
```kotlin
// config/DatabaseConfig.kt
@Configuration
class DatabaseConfig {
    
    @Bean
    fun dataSource(): DataSource = HikariDataSource().apply {
        jdbcUrl = "jdbc:postgresql://localhost:5432/mydb"
        username = "user"
        password = "password"
        maximumPoolSize = 10
    }
}

// config/WebConfig.kt
@Configuration
class WebConfig : WebMvcConfigurer {
    
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .maxAge(3600)
    }
}
```

## Testing

### Repository Tests
```kotlin
// repository/UserRepositoryTest.kt
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {
    
    @Autowired
    private lateinit var repository: UserRepository
    
    @Test
    fun `findByEmail returns user when exists`() {
        // Given
        val entity = UserEntity(name = "John", email = "john@example.com")
        repository.save(entity)
        
        // When
        val found = repository.findByEmail("john@example.com")
        
        // Then
        assertNotNull(found)
        assertEquals("John", found?.name)
    }
}
```

### Service Tests
```kotlin
// service/UserServiceTest.kt
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var repository: UserRepository
    
    @MockK
    private lateinit var mapper: UserMapper
    
    private lateinit var service: UserService
    
    @BeforeEach
    fun setup() {
        service = UserService(repository, mapper)
    }
    
    @Test
    fun `create throws exception when email exists`() = runTest {
        // Given
        val request = CreateUserRequest("John", "john@example.com")
        val existing = UserEntity(1, "Jane", "john@example.com")
        
        every { repository.findByEmail(request.email) } returns existing
        
        // When & Then
        assertThrows<AppException.EmailAlreadyExistsException> {
            service.create(request)
        }
    }
}
```

### Controller Tests
```kotlin
// controller/UserControllerTest.kt
@WebMvcTest(UserController::class)
class UserControllerTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var service: UserService
    
    @Autowired
    private lateinit var objectMapper: ObjectMapper
    
    @Test
    fun `GET users returns list`() {
        // Given
        val users = listOf(
            UserResponse(1, "John", "john@example.com", Instant.now())
        )
        coEvery { service.findAll() } returns users
        
        // When & Then
        mockMvc.get("/api/users")
            .andExpect {
                status { isOk() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$[0].name") { value("John") }
            }
    }
}
```

## Benefits
- Familiar structure for most developers
- Clear technical separation
- Easy to understand for new team members
- Works well for CRUD-heavy applications

## When to Use
- Traditional enterprise applications
- Teams familiar with layered architecture
- CRUD-focused applications
- When technical separation is preferred

