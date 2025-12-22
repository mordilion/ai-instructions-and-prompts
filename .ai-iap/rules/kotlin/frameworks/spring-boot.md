# Spring Boot with Kotlin

## Overview
Spring Boot provides first-class support for Kotlin, offering features like null safety, immutability, and extension functions.

## Controllers

### REST Controllers
```kotlin
// ✅ Good - idiomatic Kotlin, data classes
@RestController
@RequestMapping("/api/users")
class UserController(
    private val userService: UserService
) {
    
    @GetMapping
    fun getUsers(): List<UserDto> = userService.findAll()
    
    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Long): UserDto =
        userService.findById(id)
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createUser(@Valid @RequestBody request: CreateUserRequest): UserDto =
        userService.create(request)
    
    @PutMapping("/{id}")
    fun updateUser(
        @PathVariable id: Long,
        @Valid @RequestBody request: UpdateUserRequest
    ): UserDto = userService.update(id, request)
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteUser(@PathVariable id: Long) {
        userService.delete(id)
    }
}
```

### Exception Handling
```kotlin
// ✅ Good - global exception handler with sealed class
sealed class AppException(message: String) : RuntimeException(message) {
    class UserNotFound(id: Long) : AppException("User not found: $id")
    class InvalidInput(message: String) : AppException(message)
    class Unauthorized(message: String = "Unauthorized") : AppException(message)
}

@RestControllerAdvice
class GlobalExceptionHandler {
    
    @ExceptionHandler(AppException.UserNotFound::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(ex: AppException.UserNotFound): ErrorResponse =
        ErrorResponse(
            status = HttpStatus.NOT_FOUND.value(),
            message = ex.message ?: "Not found",
            timestamp = Instant.now()
        )
    
    @ExceptionHandler(AppException.InvalidInput::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleInvalidInput(ex: AppException.InvalidInput): ErrorResponse =
        ErrorResponse(
            status = HttpStatus.BAD_REQUEST.value(),
            message = ex.message ?: "Invalid input",
            timestamp = Instant.now()
        )
    
    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleValidationError(ex: MethodArgumentNotValidException): ErrorResponse =
        ErrorResponse(
            status = HttpStatus.BAD_REQUEST.value(),
            message = ex.bindingResult.fieldErrors.joinToString(", ") {
                "${it.field}: ${it.defaultMessage}"
            },
            timestamp = Instant.now()
        )
}

data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: Instant
)
```

## Services

### Service Layer
```kotlin
// ✅ Good - interface + implementation pattern
interface UserService {
    suspend fun findAll(): List<UserDto>
    suspend fun findById(id: Long): UserDto
    suspend fun create(request: CreateUserRequest): UserDto
    suspend fun update(id: Long, request: UpdateUserRequest): UserDto
    suspend fun delete(id: Long)
}

@Service
class UserServiceImpl(
    private val userRepository: UserRepository,
    private val userMapper: UserMapper
) : UserService {
    
    override suspend fun findAll(): List<UserDto> = withContext(Dispatchers.IO) {
        userRepository.findAll()
            .map { userMapper.toDto(it) }
    }
    
    override suspend fun findById(id: Long): UserDto = withContext(Dispatchers.IO) {
        val user = userRepository.findById(id)
            .orElseThrow { AppException.UserNotFound(id) }
        userMapper.toDto(user)
    }
    
    override suspend fun create(request: CreateUserRequest): UserDto = withContext(Dispatchers.IO) {
        val user = User(
            name = request.name,
            email = request.email
        )
        val saved = userRepository.save(user)
        userMapper.toDto(saved)
    }
    
    override suspend fun update(id: Long, request: UpdateUserRequest): UserDto = withContext(Dispatchers.IO) {
        val user = userRepository.findById(id)
            .orElseThrow { AppException.UserNotFound(id) }
        
        val updated = user.copy(
            name = request.name ?: user.name,
            email = request.email ?: user.email
        )
        
        val saved = userRepository.save(updated)
        userMapper.toDto(saved)
    }
    
    override suspend fun delete(id: Long): Unit = withContext(Dispatchers.IO) {
        if (!userRepository.existsById(id)) {
            throw AppException.UserNotFound(id)
        }
        userRepository.deleteById(id)
    }
}
```

## Data Layer

### Entities
```kotlin
// ✅ Good - JPA entity with Kotlin
@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val name: String,
    
    @Column(nullable = false, unique = true)
    val email: String,
    
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: Instant = Instant.now(),
    
    @Column(name = "updated_at", nullable = false)
    val updatedAt: Instant = Instant.now()
)
```

### Repositories
```kotlin
// ✅ Good - Spring Data JPA with Kotlin extensions
interface UserRepository : JpaRepository<User, Long> {
    
    fun findByEmail(email: String): User?
    
    fun findByNameContainingIgnoreCase(name: String): List<User>
    
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    fun findRecentUsers(@Param("date") date: Instant): List<User>
}

// Custom repository implementation
interface UserRepositoryCustom {
    fun searchUsers(criteria: SearchCriteria): List<User>
}

@Repository
class UserRepositoryCustomImpl(
    @PersistenceContext private val entityManager: EntityManager
) : UserRepositoryCustom {
    
    override fun searchUsers(criteria: SearchCriteria): List<User> {
        val cb = entityManager.criteriaBuilder
        val query = cb.createQuery(User::class.java)
        val root = query.from(User::class.java)
        
        val predicates = mutableListOf<Predicate>()
        
        criteria.name?.let {
            predicates.add(cb.like(cb.lower(root.get("name")), "%${it.lowercase()}%"))
        }
        
        criteria.email?.let {
            predicates.add(cb.equal(root.get<String>("email"), it))
        }
        
        query.where(*predicates.toTypedArray())
        
        return entityManager.createQuery(query).resultList
    }
}
```

## DTOs and Validation

### Data Transfer Objects
```kotlin
// ✅ Good - immutable DTOs with validation
data class UserDto(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: Instant
)

data class CreateUserRequest(
    @field:NotBlank(message = "Name is required")
    @field:Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    val name: String,
    
    @field:NotBlank(message = "Email is required")
    @field:Email(message = "Email must be valid")
    val email: String
)

data class UpdateUserRequest(
    @field:Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    val name: String? = null,
    
    @field:Email(message = "Email must be valid")
    val email: String? = null
)

data class SearchCriteria(
    val name: String? = null,
    val email: String? = null
)
```

### Mappers
```kotlin
// ✅ Good - explicit mapping
@Component
class UserMapper {
    
    fun toDto(entity: User): UserDto = UserDto(
        id = entity.id,
        name = entity.name,
        email = entity.email,
        createdAt = entity.createdAt
    )
    
    fun toEntity(dto: CreateUserRequest): User = User(
        name = dto.name,
        email = dto.email
    )
}
```

## Configuration

### Application Configuration
```kotlin
// ✅ Good - type-safe configuration
@Configuration
@ConfigurationProperties(prefix = "app")
data class AppProperties(
    val name: String,
    val version: String,
    val api: ApiProperties
) {
    data class ApiProperties(
        val baseUrl: String,
        val timeout: Duration
    )
}

@Configuration
class WebConfig : WebMvcConfigurer {
    
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE")
            .maxAge(3600)
    }
}
```

### Bean Configuration
```kotlin
// ✅ Good - functional bean DSL
@Configuration
class DatabaseConfig {
    
    @Bean
    fun dataSource(): DataSource = HikariDataSource().apply {
        jdbcUrl = "jdbc:postgresql://localhost:5432/mydb"
        username = "user"
        password = "password"
        maximumPoolSize = 10
    }
    
    @Bean
    fun transactionManager(dataSource: DataSource): PlatformTransactionManager =
        DataSourceTransactionManager(dataSource)
}

// ✅ Alternative - Kotlin DSL
fun beans() = beans {
    bean {
        val dataSource = ref<DataSource>()
        DataSourceTransactionManager(dataSource)
    }
}
```

## Security

### Security Configuration
```kotlin
// ✅ Good - Spring Security with Kotlin DSL
@Configuration
@EnableWebSecurity
class SecurityConfig {
    
    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http {
            csrf { disable() }
            authorizeHttpRequests {
                authorize("/api/public/**", permitAll)
                authorize("/api/admin/**", hasRole("ADMIN"))
                authorize("/api/**", authenticated)
            }
            httpBasic { }
            sessionManagement {
                sessionCreationPolicy = SessionCreationPolicy.STATELESS
            }
        }
        return http.build()
    }
    
    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()
}
```

### JWT Authentication
```kotlin
// ✅ Good - JWT service
@Service
class JwtService(
    @Value("\${jwt.secret}") private val secret: String,
    @Value("\${jwt.expiration}") private val expiration: Long
) {
    
    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(secret.toByteArray())
    }
    
    fun generateToken(username: String): String =
        Jwts.builder()
            .setSubject(username)
            .setIssuedAt(Date())
            .setExpiration(Date(System.currentTimeMillis() + expiration))
            .signWith(key)
            .compact()
    
    fun validateToken(token: String): Boolean =
        try {
            Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
            true
        } catch (e: JwtException) {
            false
        }
    
    fun getUsernameFromToken(token: String): String =
        Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .body
            .subject
}
```

## Testing

### Controller Tests
```kotlin
// ✅ Good - MockMvc with Kotlin DSL
@WebMvcTest(UserController::class)
class UserControllerTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var userService: UserService
    
    @Autowired
    private lateinit var objectMapper: ObjectMapper
    
    @Test
    fun `GET users returns list of users`() {
        // Given
        val users = listOf(
            UserDto(1, "John", "john@example.com", Instant.now())
        )
        coEvery { userService.findAll() } returns users
        
        // When & Then
        mockMvc.get("/api/users")
            .andExpect {
                status { isOk() }
                content { contentType(MediaType.APPLICATION_JSON) }
                jsonPath("$[0].name") { value("John") }
            }
    }
    
    @Test
    fun `POST user creates new user`() {
        // Given
        val request = CreateUserRequest("John", "john@example.com")
        val created = UserDto(1, "John", "john@example.com", Instant.now())
        coEvery { userService.create(request) } returns created
        
        // When & Then
        mockMvc.post("/api/users") {
            contentType = MediaType.APPLICATION_JSON
            content = objectMapper.writeValueAsString(request)
        }.andExpect {
            status { isCreated() }
            jsonPath("$.id") { value(1) }
            jsonPath("$.name") { value("John") }
        }
    }
}
```

### Service Tests
```kotlin
// ✅ Good - service layer tests with coroutines
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @MockK
    private lateinit var userMapper: UserMapper
    
    private lateinit var userService: UserService
    
    @BeforeEach
    fun setup() {
        userService = UserServiceImpl(userRepository, userMapper)
    }
    
    @Test
    fun `findById returns user when exists`() = runTest {
        // Given
        val userId = 1L
        val user = User(id = userId, name = "John", email = "john@example.com")
        val dto = UserDto(userId, "John", "john@example.com", Instant.now())
        
        every { userRepository.findById(userId) } returns Optional.of(user)
        every { userMapper.toDto(user) } returns dto
        
        // When
        val result = userService.findById(userId)
        
        // Then
        assertThat(result).isEqualTo(dto)
        verify { userRepository.findById(userId) }
    }
    
    @Test
    fun `findById throws exception when not found`() = runTest {
        // Given
        val userId = 999L
        every { userRepository.findById(userId) } returns Optional.empty()
        
        // When & Then
        assertThrows<AppException.UserNotFound> {
            userService.findById(userId)
        }
    }
}
```

### Integration Tests
```kotlin
// ✅ Good - full integration test
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestDatabase
class UserIntegrationTest {
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @BeforeEach
    fun cleanup() {
        userRepository.deleteAll()
    }
    
    @Test
    fun `create and retrieve user`() {
        // Given
        val request = CreateUserRequest("John", "john@example.com")
        
        // When - Create
        val createResponse = restTemplate.postForEntity(
            "/api/users",
            request,
            UserDto::class.java
        )
        
        // Then
        assertThat(createResponse.statusCode).isEqualTo(HttpStatus.CREATED)
        val created = createResponse.body!!
        assertThat(created.name).isEqualTo("John")
        
        // When - Retrieve
        val getResponse = restTemplate.getForEntity(
            "/api/users/${created.id}",
            UserDto::class.java
        )
        
        // Then
        assertThat(getResponse.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(getResponse.body).isEqualTo(created)
    }
}
```

## Best Practices

### 1. Use Kotlin Coroutines
```kotlin
// ✅ Good - suspend functions for async operations
@Service
class AsyncUserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    
    suspend fun registerUser(request: CreateUserRequest): UserDto = coroutineScope {
        val user = createUser(request)
        
        // Parallel operations
        val emailJob = async { emailService.sendWelcomeEmail(user.email) }
        val profileJob = async { createUserProfile(user) }
        
        emailJob.await()
        profileJob.await()
        
        userMapper.toDto(user)
    }
}
```

### 2. Extension Functions
```kotlin
// ✅ Good - extend Spring types
fun ResponseEntity.BodyBuilder.json(body: Any): ResponseEntity<Any> =
    contentType(MediaType.APPLICATION_JSON).body(body)

// Usage
return ResponseEntity.ok().json(userDto)
```

### 3. Null Safety
```kotlin
// ✅ Good - handle optionals safely
fun findUser(id: Long): UserDto? =
    userRepository.findById(id)
        .map { userMapper.toDto(it) }
        .orElse(null)
```

### 4. DSL-Style Builders
```kotlin
// ✅ Good - builder pattern
fun buildQuery(block: QueryBuilder.() -> Unit): Query =
    QueryBuilder().apply(block).build()

class QueryBuilder {
    private var table: String = ""
    private val conditions = mutableListOf<String>()
    
    fun from(table: String) {
        this.table = table
    }
    
    fun where(condition: String) {
        conditions.add(condition)
    }
    
    fun build(): Query = Query(table, conditions)
}
```

