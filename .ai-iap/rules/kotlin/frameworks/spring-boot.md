# Spring Boot with Kotlin

## Overview
Spring Boot with first-class Kotlin support since Spring Framework 5.0, leveraging null safety, data classes, and coroutines.
Kotlin eliminates boilerplate (no getters/setters needed) while maintaining full Java interoperability.
Best for new Spring Boot projects when team prefers Kotlin's conciseness and safety features.

## Controllers

### REST Controllers
```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(private val userService: UserService) {
    
    @GetMapping
    fun getUsers(): List<UserDto> = userService.findAll()
    
    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Long): UserDto = userService.findById(id)
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createUser(@Valid @RequestBody request: CreateUserRequest): UserDto =
        userService.create(request)
    
    @PutMapping("/{id}")
    fun updateUser(@PathVariable id: Long, @Valid @RequestBody request: UpdateUserRequest): UserDto =
        userService.update(id, request)
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteUser(@PathVariable id: Long) = userService.delete(id)
}
```

### Exception Handling
```kotlin
sealed class AppException(message: String) : RuntimeException(message) {
    class UserNotFound(id: Long) : AppException("User not found: $id")
    class InvalidInput(message: String) : AppException(message)
}

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(AppException.UserNotFound::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(ex: AppException.UserNotFound) =
        ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.message ?: "")
    
    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleValidationError(ex: MethodArgumentNotValidException) =
        ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            ex.bindingResult.fieldErrors.joinToString { "${it.field}: ${it.defaultMessage}" }
        )
}

data class ErrorResponse(val status: Int, val message: String, val timestamp: Instant = Instant.now())
```

## Services

```kotlin
interface UserService {
    suspend fun findAll(): List<UserDto>
    suspend fun findById(id: Long): UserDto
    suspend fun create(request: CreateUserRequest): UserDto
}

@Service
class UserServiceImpl(
    private val repository: UserRepository,
    private val mapper: UserMapper
) : UserService {
    
    override suspend fun findAll(): List<UserDto> = withContext(Dispatchers.IO) {
        repository.findAll().map { mapper.toDto(it) }
    }
    
    override suspend fun findById(id: Long): UserDto = withContext(Dispatchers.IO) {
        repository.findById(id)
            .map { mapper.toDto(it) }
            .orElseThrow { AppException.UserNotFound(id) }
    }
    
    override suspend fun create(request: CreateUserRequest): UserDto = withContext(Dispatchers.IO) {
        val user = User(name = request.name, email = request.email)
        mapper.toDto(repository.save(user))
    }
}
```

## Data Layer

### Entities
```kotlin
@Entity
@Table(name = "users")
data class User(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    @Column(nullable = false) val name: String,
    @Column(nullable = false, unique = true) val email: String,
    @Column(name = "created_at") val createdAt: Instant = Instant.now()
)
```

### Repositories
```kotlin
interface UserRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
    fun findByNameContainingIgnoreCase(name: String): List<User>
    
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    fun findRecentUsers(@Param("date") date: Instant): List<User>
}
```

## DTOs & Validation

```kotlin
data class UserDto(val id: Long, val name: String, val email: String)

data class CreateUserRequest(
    @field:NotBlank @field:Size(min = 2, max = 100) val name: String,
    @field:NotBlank @field:Email val email: String
)

data class UpdateUserRequest(
    @field:Size(min = 2, max = 100) val name: String? = null,
    @field:Email val email: String? = null
)

@Component
class UserMapper {
    fun toDto(entity: User) = UserDto(entity.id, entity.name, entity.email)
    fun toEntity(dto: CreateUserRequest) = User(name = dto.name, email = dto.email)
}
```

## Configuration

### Application Config
```kotlin
@Configuration
@ConfigurationProperties(prefix = "app")
data class AppProperties(
    val name: String,
    val version: String,
    val api: ApiProperties
) {
    data class ApiProperties(val baseUrl: String, val timeout: Duration)
}

@Configuration
class WebConfig : WebMvcConfigurer {
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE")
    }
}
```

## Security

### Security Config
```kotlin
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
        }
        return http.build()
    }
    
    @Bean
    fun passwordEncoder() = BCryptPasswordEncoder()
}
```

### JWT
```kotlin
@Service
class JwtService(
    @Value("\${jwt.secret}") private val secret: String,
    @Value("\${jwt.expiration}") private val expiration: Long
) {
    private val key by lazy { Keys.hmacShaKeyFor(secret.toByteArray()) }
    
    fun generateToken(username: String): String =
        Jwts.builder()
            .setSubject(username)
            .setExpiration(Date(System.currentTimeMillis() + expiration))
            .signWith(key)
            .compact()
    
    fun validateToken(token: String): Boolean =
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token)
            true
        } catch (e: JwtException) {
            false
        }
}
```

## Testing

### Controller Tests
```kotlin
@WebMvcTest(UserController::class)
class UserControllerTest {
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var userService: UserService
    
    @Test
    fun `GET users returns list`() {
        coEvery { userService.findAll() } returns listOf(
            UserDto(1, "John", "john@test.com")
        )
        
        mockMvc.get("/api/users").andExpect {
            status { isOk() }
            jsonPath("$[0].name") { value("John") }
        }
    }
}
```

### Service Tests
```kotlin
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    @MockK
    private lateinit var repository: UserRepository
    @MockK
    private lateinit var mapper: UserMapper
    
    private lateinit var service: UserService
    
    @BeforeEach
    fun setup() {
        service = UserServiceImpl(repository, mapper)
    }
    
    @Test
    fun `findById returns user when exists`() = runTest {
        val user = User(1, "John", "john@test.com")
        val dto = UserDto(1, "John", "john@test.com")
        
        every { repository.findById(1) } returns Optional.of(user)
        every { mapper.toDto(user) } returns dto
        
        val result = service.findById(1)
        
        assertEquals(dto, result)
    }
}
```

### Integration Tests
```kotlin
@SpringBootTest(webEnvironment = RANDOM_PORT)
@AutoConfigureTestDatabase
class UserIntegrationTest {
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var repository: UserRepository
    
    @BeforeEach
    fun cleanup() = repository.deleteAll()
    
    @Test
    fun `create and retrieve user`() {
        val request = CreateUserRequest("John", "john@test.com")
        
        val created = restTemplate.postForEntity("/api/users", request, UserDto::class.java)
        
        assertEquals(HttpStatus.CREATED, created.statusCode)
        assertEquals("John", created.body?.name)
    }
}
```

## Best Practices

**MUST**:
- Use constructor injection with `private val` properties (NOT `@Autowired`)
- Use `suspend` functions for I/O operations with coroutines
- Use data classes for DTOs (automatic equals/hashCode/copy)
- Use `@Transactional` for write operations
- Handle nullable types explicitly (`?` suffix)

**SHOULD**:
- Use `@RestController` with `@RequiredArgsConstructor` pattern
- Use Kotlin coroutines instead of reactive (WebFlux) when possible
- Use sealed classes for type-safe state/result handling
- Use extension functions to enhance Spring APIs
- Use default parameters instead of multiple constructors

**AVOID**:
- Field injection (`@Autowired` on properties)
- Returning nullable entities (use DTOs)
- Platform types (Java types without null annotation)
- Mixing coroutines and blocking calls
- Using `!!` operator (forces non-null, crashes if null)

## Common Patterns

### Coroutines for Async Operations
```kotlin
// ✅ GOOD: Parallel execution with coroutines
suspend fun registerUser(request: CreateUserRequest): UserDto = coroutineScope {
    val userDeferred = async { createUser(request) }
    val emailDeferred = async { sendWelcomeEmail(request.email) }
    
    userDeferred.await()  // Wait for user creation
    emailDeferred.await()  // Wait for email
    userMapper.toDto(userDeferred.await())
}

// ❌ BAD: Sequential blocking calls
fun registerUser(request: CreateUserRequest): UserDto {
    val user = createUser(request)  // Blocks
    sendWelcomeEmail(request.email)  // Blocks
    return userMapper.toDto(user)
}
```

### Null Safety
```kotlin
// ✅ GOOD: Explicit null handling
fun findUser(id: Long): UserDto? =
    userRepository.findById(id)
        .map { userMapper.toDto(it) }
        .orElse(null)  // Explicit nullable return

// ✅ GOOD: Elvis operator for defaults
fun getUser(id: Long): UserDto =
    userRepository.findById(id)
        .map { userMapper.toDto(it) }
        .orElse(null) ?: throw UserNotFoundException(id)

// ❌ BAD: Using !! (crashes if null)
fun getUser(id: Long): UserDto =
    userMapper.toDto(userRepository.findById(id).get()!!)  // Crash if not found!
```

### Extension Functions (Use Sparingly)
```kotlin
// ✅ GOOD: Useful extension
fun ResponseEntity.BodyBuilder.json(body: Any) =
    contentType(MediaType.APPLICATION_JSON).body(body)

// Usage
return ResponseEntity.ok().json(userDto)

// ❌ AVOID: Too broad scope
fun Any.toJson() = objectMapper.writeValueAsString(this)  // Pollutes all classes
```
