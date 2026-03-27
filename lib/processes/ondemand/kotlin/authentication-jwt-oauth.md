# Kotlin Authentication (JWT/OAuth) - Copy This Prompt

> **Type**: One-time setup process  
> **When to use**: Implementing authentication for Kotlin API (Ktor/Spring Boot)  
> **Instructions**: Copy the complete prompt below and paste into your AI tool

---

## 📋 Complete Self-Contained Prompt

```
========================================
KOTLIN AUTHENTICATION - JWT/OAUTH
========================================

CONTEXT:
You are implementing JWT and OAuth authentication for a Kotlin application (Ktor or Spring Boot).

CRITICAL REQUIREMENTS:
- ALWAYS use secure password hashing (BCrypt)
- ALWAYS validate JWT tokens on protected routes
- NEVER store passwords in plain text
- NEVER expose JWT secrets

========================================
CATCH-UP: READ EXISTING DOCUMENTATION
========================================

BEFORE starting, check for existing documentation:
1. Read PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md if they exist

Use this to continue from where work stopped. If no docs: Start fresh.

========================================
PHASE 1 - JWT AUTHENTICATION (KTOR)
========================================

Add dependencies to build.gradle.kts:

```kotlin
dependencies {
    implementation("io.ktor:ktor-server-auth-jwt:$ktor_version")
    implementation("org.mindrot:jbcrypt:0.4")
}
```

Configure JWT in Application.kt:
```kotlin
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm

fun Application.configureSecurity() {
    val secret = environment.config.property("jwt.secret").getString()
    val issuer = environment.config.property("jwt.issuer").getString()
    val audience = environment.config.property("jwt.audience").getString()
    
    authentication {
        jwt("auth-jwt") {
            verifier(JWT
                .require(Algorithm.HMAC256(secret))
                .withAudience(audience)
                .withIssuer(issuer)
                .build())
            
            validate { credential ->
                if (credential.payload.audience.contains(audience)) {
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

object JwtConfig {
    private val secret = System.getenv("JWT_SECRET") ?: "default-secret-key"
    private const val issuer = "my-issuer"
    private const val audience = "my-audience"
    private const val validityInMs = 24 * 60 * 60 * 1000 // 24 hours
    
    fun generateToken(userId: String): String {
        return JWT.create()
            .withAudience(audience)
            .withIssuer(issuer)
            .withClaim("userId", userId)
            .withExpiresAt(Date(System.currentTimeMillis() + validityInMs))
            .sign(Algorithm.HMAC256(secret))
    }
}
```

Create password hashing utility:
```kotlin
import org.mindrot.jbcrypt.BCrypt

object PasswordUtil {
    fun hashPassword(password: String): String {
        return BCrypt.hashpw(password, BCrypt.gensalt())
    }
    
    fun verifyPassword(password: String, hashedPassword: String): Boolean {
        return BCrypt.checkpw(password, hashedPassword)
    }
}
```

Deliverable: JWT configured

========================================
PHASE 2 - AUTH ENDPOINTS
========================================

Create auth routes:

```kotlin
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

data class RegisterRequest(val email: String, val password: String)
data class LoginRequest(val email: String, val password: String)
data class AuthResponse(val token: String)

fun Route.authRoutes(userService: UserService) {
    route("/auth") {
        post("/register") {
            val request = call.receive<RegisterRequest>()
            
            if (userService.findByEmail(request.email) != null) {
                call.respond(HttpStatusCode.Conflict, "User already exists")
                return@post
            }
            
            val hashedPassword = PasswordUtil.hashPassword(request.password)
            val user = userService.create(request.email, hashedPassword)
            val token = JwtConfig.generateToken(user.id.toString())
            
            call.respond(HttpStatusCode.Created, AuthResponse(token))
        }
        
        post("/login") {
            val request = call.receive<LoginRequest>()
            val user = userService.findByEmail(request.email)
            
            if (user == null || !PasswordUtil.verifyPassword(request.password, user.password)) {
                call.respond(HttpStatusCode.Unauthorized, "Invalid credentials")
                return@post
            }
            
            val token = JwtConfig.generateToken(user.id.toString())
            call.respond(AuthResponse(token))
        }
    }
    
    authenticate("auth-jwt") {
        get("/me") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.payload?.getClaim("userId")?.asString()
            
            val user = userService.findById(userId!!)
            call.respond(user)
        }
    }
}
```

Deliverable: Auth endpoints working

========================================
PHASE 3 - SPRING BOOT (ALTERNATIVE)
========================================

For Spring Boot with Kotlin, use same as Java but with Kotlin syntax:

```kotlin
@Configuration
class SecurityConfig(
    private val jwtFilter: JwtAuthenticationFilter
) {
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { 
                it.requestMatchers("/api/auth/**").permitAll()
                  .anyRequest().authenticated()
            }
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter::class.java)
        
        return http.build()
    }
    
    @Bean
    fun passwordEncoder() = BCryptPasswordEncoder()
}

@RestController
@RequestMapping("/api/auth")
class AuthController(
    private val authenticationManager: AuthenticationManager,
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtUtil: JwtUtil
) {
    @PostMapping("/login")
    fun login(@RequestBody dto: LoginDto): ResponseEntity<AuthResponse> {
        val authentication = authenticationManager.authenticate(
            UsernamePasswordAuthenticationToken(dto.email, dto.password)
        )
        
        val token = jwtUtil.generateToken(dto.email)
        return ResponseEntity.ok(AuthResponse(token))
    }
}
```

Deliverable: Spring Boot auth working

========================================
PHASE 4 - OAUTH 2.0 (OPTIONAL)
========================================

For Ktor with Google OAuth:

```kotlin
install(Authentication) {
    oauth("auth-oauth-google") {
        urlProvider = { "http://localhost:8080/callback" }
        providerLookup = {
            OAuthServerSettings.OAuth2ServerSettings(
                name = "google",
                authorizeUrl = "https://accounts.google.com/o/oauth2/auth",
                accessTokenUrl = "https://accounts.google.com/o/oauth2/token",
                requestMethod = HttpMethod.Post,
                clientId = System.getenv("GOOGLE_CLIENT_ID"),
                clientSecret = System.getenv("GOOGLE_CLIENT_SECRET"),
                defaultScopes = listOf("openid", "email", "profile")
            )
        }
        client = HttpClient(CIO)
    }
}
```

Deliverable: OAuth configured

========================================
BEST PRACTICES
========================================

- Use BCrypt for password hashing
- Store JWT secrets in environment variables
- Set reasonable token expiry
- Implement refresh tokens
- Add rate limiting
- Use HTTPS only
- Validate input thoroughly
- Use Ktor or Spring Security
- Consider OAuth for social login

========================================
DOCUMENTATION
========================================

Create/update: PROJECT-MEMORY.md, LOGIC-ANOMALIES.md, AUTH-SETUP.md

========================================
EXECUTION
========================================

START: Read existing docs (CATCH-UP section)
CONTINUE: Configure JWT (Phase 1)
CONTINUE: Create auth endpoints (Phase 2)
ALTERNATIVE: Use Spring Boot (Phase 3)
OPTIONAL: Add OAuth (Phase 4)
FINISH: Update all documentation files
REMEMBER: BCrypt, secure secrets, HTTPS, document for catch-up
```

---

## Quick Reference

**What you get**: Complete JWT/OAuth authentication for Kotlin  
**Time**: 3-4 hours  
**Output**: Auth service, protected routes, OAuth
