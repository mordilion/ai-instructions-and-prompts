# Kotlin Security

> **Scope**: Kotlin-specific security practices (Android, Ktor, Spring Boot)
> **Extends**: general/security.md
> **Applies to**: *.kt files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Android Keystore for sensitive data (Android)
> **ALWAYS**: Use parameterized queries (Room, Exposed, JPA)
> **ALWAYS**: Hash passwords with BCrypt or Argon2
> **ALWAYS**: Use HTTPS/TLS in production
> **ALWAYS**: Validate all user input
> 
> **NEVER**: Use string templates for SQL queries
> **NEVER**: Store secrets in SharedPreferences (Android)
> **NEVER**: Use `eval()` or reflection with user input
> **NEVER**: Disable certificate validation
> **NEVER**: Log sensitive data

## 1. Android Security

### Keystore & Encryption

```kotlin
// ✅ CORRECT - Android Keystore
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

class SecureStorage(private val context: Context) {
    
    private val KEYSTORE_PROVIDER = "AndroidKeyStore"
    private val KEY_ALIAS = "AppSecretKey"
    
    fun encrypt(data: String): ByteArray {
        val cipher = getCipher()
        cipher.init(Cipher.ENCRYPT_MODE, getKey())
        return cipher.doFinal(data.toByteArray())
    }
    
    fun decrypt(encryptedData: ByteArray): String {
        val cipher = getCipher()
        cipher.init(Cipher.DECRYPT_MODE, getKey())
        return String(cipher.doFinal(encryptedData))
    }
    
    private fun getKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        
        return if (keyStore.containsAlias(KEY_ALIAS)) {
            keyStore.getKey(KEY_ALIAS, null) as SecretKey
        } else {
            createKey()
        }
    }
    
    private fun createKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE_PROVIDER
        )
        
        val keyGenSpec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(true)
            .setUserAuthenticationValidityDurationSeconds(300)
            .build()
        
        keyGenerator.init(keyGenSpec)
        return keyGenerator.generateKey()
    }
    
    private fun getCipher() = Cipher.getInstance(
        "${KeyProperties.KEY_ALGORITHM_AES}/" +
        "${KeyProperties.BLOCK_MODE_GCM}/" +
        "${KeyProperties.ENCRYPTION_PADDING_NONE}"
    )
}

// ❌ WRONG - SharedPreferences plaintext
val prefs = context.getSharedPreferences("app", Context.MODE_PRIVATE)
prefs.edit().putString("token", authToken).apply()  // Plaintext!
```

### Network Security

```kotlin
// ✅ CORRECT - Certificate pinning (OkHttp)
import okhttp3.CertificatePinner
import okhttp3.OkHttpClient

val certificatePinner = CertificatePinner.Builder()
    .add("yourapi.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .add("yourapi.com", "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=")
    .build()

val client = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()

// ❌ WRONG - Disable SSL validation
val client = OkHttpClient.Builder()
    .hostnameVerifier { _, _ -> true }  // Accept all certificates!
    .build()
```

```xml
<!-- ✅ CORRECT - Network security config -->
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">yourapi.com</domain>
        <pin-set expiration="2025-12-31">
            <pin digest="SHA-256">7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y=</pin>
            <pin digest="SHA-256">YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

### SQL Injection Prevention (Room)

```kotlin
// ✅ CORRECT - Room DAO (safe)
@Dao
interface UserDao {
    
    @Query("SELECT * FROM users WHERE email = :email")
    suspend fun findByEmail(email: String): User?
    
    @Query("SELECT * FROM users WHERE name LIKE :search")
    suspend fun searchUsers(search: String): List<User>
    
    @Insert
    suspend fun insert(user: User)
}

// ❌ WRONG - Raw query with string template
@Dao
interface UserDao {
    
    @RawQuery
    suspend fun findByEmail(query: SupportSQLiteQuery): User?
}

fun getUserByEmail(email: String): User? {
    val query = SimpleSQLiteQuery("SELECT * FROM users WHERE email = '$email'")
    return userDao.findByEmail(query)  // SQL INJECTION!
}
```

## 2. Ktor Security

### Authentication

```kotlin
// ✅ CORRECT - Ktor JWT authentication
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm

fun Application.configureSecurity() {
    val jwtSecret = environment.config.property("jwt.secret").getString()
    val jwtAlgorithm = Algorithm.HMAC512(jwtSecret)
    
    install(Authentication) {
        jwt("auth-jwt") {
            verifier(JWT
                .require(jwtAlgorithm)
                .withIssuer("yourapp.com")
                .build())
            
            validate { credential ->
                if (credential.payload.getClaim("userId").asString() != "") {
                    JWTPrincipal(credential.payload)
                } else {
                    null
                }
            }
            
            challenge { _, _ ->
                call.respond(HttpStatusCode.Unauthorized, "Token invalid or expired")
            }
        }
    }
}

// Protected route
routing {
    authenticate("auth-jwt") {
        get("/protected") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal!!.payload.getClaim("userId").asString()
            call.respond(mapOf("userId" to userId))
        }
    }
}

// Generate token
fun generateToken(userId: String): String {
    return JWT.create()
        .withIssuer("yourapp.com")
        .withClaim("userId", userId)
        .withExpiresAt(Date(System.currentTimeMillis() + 900000)) // 15 min
        .sign(jwtAlgorithm)
}
```

### Input Validation

```kotlin
// ✅ CORRECT - Ktor input validation
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable

@Serializable
data class CreateUserRequest(
    val email: String,
    val password: String,
    val name: String
)

fun validateCreateUserRequest(request: CreateUserRequest): ValidationResult {
    val errors = mutableListOf<String>()
    
    if (!request.email.matches(Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"))) {
        errors.add("Invalid email format")
    }
    
    if (request.password.length < 12) {
        errors.add("Password must be at least 12 characters")
    }
    
    if (request.name.length < 2 || !request.name.matches(Regex("^[a-zA-Z\\s]+$"))) {
        errors.add("Invalid name")
    }
    
    return if (errors.isEmpty()) {
        ValidationResult.Valid
    } else {
        ValidationResult.Invalid(errors)
    }
}

routing {
    post("/users") {
        val request = call.receive<CreateUserRequest>()
        
        when (val validation = validateCreateUserRequest(request)) {
            is ValidationResult.Valid -> {
                val user = userService.create(request)
                call.respond(HttpStatusCode.Created, user)
            }
            is ValidationResult.Invalid -> {
                call.respond(HttpStatusCode.BadRequest, mapOf("errors" to validation.errors))
            }
        }
    }
}

sealed class ValidationResult {
    object Valid : ValidationResult()
    data class Invalid(val errors: List<String>) : ValidationResult()
}
```

### SQL Injection Prevention (Exposed)

```kotlin
// ✅ CORRECT - Exposed ORM
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

object Users : Table() {
    val id = integer("id").autoIncrement()
    val email = varchar("email", 255)
    val name = varchar("name", 100)
    override val primaryKey = PrimaryKey(id)
}

fun findUserByEmail(email: String): User? = transaction {
    Users.select { Users.email eq email }
        .mapNotNull { it.toUser() }
        .singleOrNull()
}

fun searchUsers(searchTerm: String): List<User> = transaction {
    Users.select { Users.name like "%$searchTerm%" }
        .map { it.toUser() }
}

// ❌ WRONG - Raw SQL with string template
fun findUserByEmail(email: String): User? = transaction {
    exec("SELECT * FROM users WHERE email = '$email'")  // SQL INJECTION!
}
```

## 3. Spring Boot (Kotlin)

### Configuration

```kotlin
// ✅ CORRECT - Spring Security
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain

@Configuration
@EnableWebSecurity
class SecurityConfig {
    
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http {
            authorizeHttpRequests {
                authorize("/api/public/**", permitAll)
                authorize("/api/admin/**", hasRole("ADMIN"))
                authorize(anyRequest, authenticated)
            }
            formLogin { }
            logout {
                logoutUrl = "/logout"
                logoutSuccessUrl = "/login"
            }
            csrf { }
        }
        return http.build()
    }
    
    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder(12)
}
```

### Password Hashing

```kotlin
// ✅ CORRECT - BCrypt hashing
import org.springframework.security.crypto.password.PasswordEncoder

class UserService(private val passwordEncoder: PasswordEncoder) {
    
    fun createUser(email: String, password: String): User {
        val hashedPassword = passwordEncoder.encode(password)
        return User(email = email, password = hashedPassword)
    }
    
    fun validatePassword(rawPassword: String, hashedPassword: String): Boolean {
        return passwordEncoder.matches(rawPassword, hashedPassword)
    }
}

// ❌ WRONG - Weak hashing
import java.security.MessageDigest

fun hashPassword(password: String): String {
    val md = MessageDigest.getInstance("MD5")
    return md.digest(password.toByteArray()).toString()  // MD5 is broken!
}
```

## 4. Coroutines Security

### Timeout & Cancellation

```kotlin
// ✅ CORRECT - Timeout protection
import kotlinx.coroutines.*

suspend fun fetchUserData(userId: String): UserData {
    return withTimeout(5000) {  // 5 second timeout
        userRepository.fetchData(userId)
    }
}

// ✅ CORRECT - Proper exception handling
suspend fun processData(data: String): Result<ProcessedData> {
    return try {
        withContext(Dispatchers.IO) {
            val processed = heavyProcessing(data)
            Result.success(processed)
        }
    } catch (e: Exception) {
        logger.error("Processing failed", e)
        Result.failure(e)
    }
}

// ❌ WRONG - No timeout (DoS risk)
suspend fun fetchUserData(userId: String): UserData {
    return userRepository.fetchData(userId)  // Could hang forever!
}
```

## 5. Kotlin-Specific Security

### Null Safety

```kotlin
// ✅ CORRECT - Null safety
fun processUser(userId: String?): Result<User> {
    return when {
        userId.isNullOrBlank() -> Result.failure(InvalidInputException("User ID required"))
        else -> {
            val user = userRepository.findById(userId)
                ?: return Result.failure(NotFoundException("User not found"))
            Result.success(user)
        }
    }
}

// ❌ DANGEROUS - Force unwrap
fun processUser(userId: String?): User {
    return userRepository.findById(userId!!)!!  // Can crash!
}
```

### Data Classes for DTOs

```kotlin
// ✅ CORRECT - Immutable DTOs
data class UserDto(
    val id: String,
    val email: String,
    val name: String
    // Never include: password, tokens, sensitive data
)

data class CreateUserRequest(
    val email: String,
    val password: String,
    val name: String
) {
    init {
        require(email.isNotBlank()) { "Email required" }
        require(password.length >= 12) { "Password too short" }
        require(name.matches(Regex("^[a-zA-Z\\s]+$"))) { "Invalid name" }
    }
}

// ❌ WRONG - Expose entity directly
@Entity
data class User(
    @Id val id: String,
    val email: String,
    val password: String  // Exposed to API!
)

fun getUser(id: String): User = userRepository.findById(id)  // Returns password!
```

## 6. Error Handling

```kotlin
// ✅ CORRECT - Safe error handling (Ktor)
install(StatusPages) {
    exception<Throwable> { call, cause ->
        logger.error("Unhandled exception", cause)
        call.respond(
            HttpStatusCode.InternalServerError,
            mapOf("error" to "Internal server error")
        )
    }
    
    exception<ValidationException> { call, cause ->
        call.respond(
            HttpStatusCode.BadRequest,
            mapOf("error" to cause.message)
        )
    }
}

// ❌ WRONG - Expose stack trace
exception<Throwable> { call, cause ->
    call.respond(
        HttpStatusCode.InternalServerError,
        mapOf(
            "error" to cause.message,
            "stackTrace" to cause.stackTraceToString()
        )
    )  // Exposes internals!
}
```

## 7. File Upload Security

```kotlin
// ✅ CORRECT - Secure file upload (Ktor)
routing {
    post("/upload") {
        val multipart = call.receiveMultipart()
        val allowedTypes = listOf("image/jpeg", "image/png", "image/gif")
        val maxSize = 5 * 1024 * 1024L  // 5MB
        
        multipart.forEachPart { part ->
            when (part) {
                is PartData.FileItem -> {
                    val contentType = part.contentType?.toString()
                    if (contentType !in allowedTypes) {
                        call.respond(HttpStatusCode.BadRequest, "Invalid file type")
                        return@post
                    }
                    
                    val fileBytes = part.streamProvider().readBytes()
                    if (fileBytes.size > maxSize) {
                        call.respond(HttpStatusCode.BadRequest, "File too large")
                        return@post
                    }
                    
                    val fileName = "${UUID.randomUUID()}.${part.originalFileName?.substringAfterLast('.')}"
                    File("uploads/$fileName").writeBytes(fileBytes)
                    
                    call.respond(HttpStatusCode.Created, mapOf("filename" to fileName))
                }
                else -> part.dispose()
            }
        }
    }
}
```

## AI Self-Check

Before generating Kotlin code, verify:
- [ ] Android Keystore for sensitive data?
- [ ] Room/Exposed for database queries (parameterized)?
- [ ] BCrypt for password hashing (12+ rounds)?
- [ ] Certificate pinning configured (Android)?
- [ ] Network security config (no cleartext traffic)?
- [ ] JWT with expiration (Ktor)?
- [ ] Input validation on all endpoints?
- [ ] Null safety enforced (no `!!` on user input)?
- [ ] Coroutine timeouts configured?
- [ ] DTOs used (not entities) for API responses?
- [ ] HTTPS enforced in production?
- [ ] Error handlers don't expose internals?
- [ ] File uploads validated (type, size)?
- [ ] No logging of sensitive data?
- [ ] Dependencies up-to-date?

## Testing Security

```kotlin
// ✅ Security testing example (JUnit + Ktor)
@Test
fun `protected endpoint requires authentication`() = testApplication {
    val response = client.get("/protected")
    assertEquals(HttpStatusCode.Unauthorized, response.status)
}

@Test
fun `SQL injection is prevented`() = testApplication {
    val malicious = "admin'; DROP TABLE users--"
    val response = client.get("/users/search?q=$malicious")
    assertNotEquals(HttpStatusCode.InternalServerError, response.status)
}
```

---

**Kotlin Security: Leverage type safety and null safety. Use Android Keystore and Ktor's built-in security features.**

