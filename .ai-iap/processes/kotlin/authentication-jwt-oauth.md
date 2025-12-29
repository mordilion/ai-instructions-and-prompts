# Authentication Setup Process - Kotlin

> **Purpose**: Implement secure authentication and authorization in Kotlin applications

> **Core Stack**: Spring Security (Spring Boot), JWT (Ktor), BCrypt

---

## Phase 1: Password Hashing

> **ALWAYS use**: BCrypt from Spring Security or jBCrypt
> **NEVER**: MD5, SHA1, or plain text

**Install** (Gradle):
```kotlin
implementation("org.springframework.security:spring-security-crypto")
// Or for Ktor: implementation("org.mindrot:jbcrypt:0.4")
```

**Password Encoding**:
```kotlin
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

val passwordEncoder = BCryptPasswordEncoder(12)

fun hashPassword(password: String): String = passwordEncoder.encode(password)

fun verifyPassword(password: String, hash: String): Boolean = 
    passwordEncoder.matches(password, hash)
```

> **Git**: `git commit -m "feat: add password hashing"`

---

## Phase 2: JWT Authentication

### Spring Boot (Kotlin)

> **Same as Java Spring Security** - use jjwt library

### Ktor

> **ALWAYS use**: ktor-auth-jwt

**Install**:
```kotlin
implementation("io.ktor:ktor-server-auth-jwt:$ktor_version")
```

**JWT Config**:
```kotlin
install(Authentication) {
    jwt("auth-jwt") {
        realm = "my-app"
        verifier(
            JWT.require(Algorithm.HMAC256(secret))
                .withIssuer(issuer)
                .build()
        )
        validate { credential ->
            if (credential.payload.getClaim("sub").asString() != "") {
                JWTPrincipal(credential.payload)
            } else null
        }
    }
}
```

**Protected Routes**:
```kotlin
authenticate("auth-jwt") {
    get("/api/protected") {
        val principal = call.principal<JWTPrincipal>()
        val userId = principal!!.payload.getClaim("sub").asString()
        call.respond(mapOf("message" to "Authenticated", "userId" to userId))
    }
}
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 (Ktor)

> **ALWAYS use**: ktor-auth-oauth

**Install**:
```kotlin
implementation("io.ktor:ktor-server-auth:$ktor_version")
implementation("io.ktor:ktor-client-apache:$ktor_version")
```

**OAuth Setup**:
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
                clientSecret = System.getenv("GOOGLE_CLIENT_SECRET")
            )
        }
        client = HttpClient(Apache)
    }
}
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

### Spring Boot

> **Same as Java** - use @PreAuthorize, SecurityFilterChain

### Ktor

**Role-Based Routing**:
```kotlin
fun Route.requireRole(role: String, build: Route.() -> Unit): Route {
    return authenticate {
        intercept(ApplicationCallPipeline.Call) {
            val principal = call.principal<JWTPrincipal>()
            val userRole = principal?.payload?.getClaim("role")?.asString()
            
            if (userRole != role) {
                call.respond(HttpStatusCode.Forbidden, "Insufficient permissions")
                finish()
            }
        }
        build()
    }
}

// Usage
requireRole("admin") {
    delete("/users/{id}") { /* ... */ }
}
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (ktor-server-rate-limit or custom)
> - CORS configuration
> - HTTPS enforcement

**Rate Limiting** (Ktor):
```kotlin
install(RateLimit) {
    register(RateLimitName("login")) {
        rateLimiter(limit = 5, refillPeriod = 15.minutes)
    }
}

post("/auth/login") {
    rateLimit(RateLimitName("login"))
    // ... login logic
}
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### Spring Boot (Kotlin)
- Identical to Java Spring Security
- Kotlin DSL for configuration
- Use sealed classes for permissions

### Ktor
- Lightweight, explicit authentication
- JWT plugin for token validation
- Custom interceptors for authorization

---

## AI Self-Check

- [ ] Passwords hashed with BCrypt
- [ ] JWT configured with secret
- [ ] Access tokens expire in ≤1h
- [ ] OAuth configured (if needed)
- [ ] Authorization checks implemented
- [ ] Rate limiting enabled
- [ ] HTTPS enforced

---

**Process Complete** ✅

