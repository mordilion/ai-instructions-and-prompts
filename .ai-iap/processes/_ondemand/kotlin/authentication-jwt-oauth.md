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


## Usage - Copy This Complete Prompt

> **Type**: One-time setup process (multi-phase)  
> **When to use**: When implementing authentication system with JWT and OAuth

### Complete Implementation Prompt

```
CONTEXT:
You are implementing authentication system with JWT and OAuth for this project.

CRITICAL REQUIREMENTS:
- ALWAYS use strong JWT secret (min 256 bits, from environment variable)
- ALWAYS set appropriate token expiration (15-60 minutes for access, days for refresh)
- ALWAYS validate tokens on protected endpoints
- ALWAYS hash passwords with bcrypt/Argon2
- NEVER store passwords in plain text
- NEVER commit secrets to version control
- Use team's Git workflow

IMPLEMENTATION PHASES:

PHASE 1 - JWT AUTHENTICATION:
1. Install JWT library
2. Configure JWT secret (from environment variable)
3. Implement token generation (login endpoint)
4. Implement token validation middleware
5. Set up token expiration and refresh mechanism

Deliverable: JWT authentication working

PHASE 2 - USER MANAGEMENT:
1. Create User model/entity
2. Implement password hashing
3. Create registration endpoint
4. Create login endpoint
5. Implement password reset flow

Deliverable: User management complete

PHASE 3 - OAUTH INTEGRATION (Optional):
1. Choose OAuth providers (Google, GitHub, etc.)
2. Register application with providers
3. Implement OAuth callback handling
4. Link OAuth accounts with local users

Deliverable: OAuth authentication working

PHASE 4 - ROLE-BASED ACCESS CONTROL:
1. Define user roles
2. Implement role checking middleware
3. Protect endpoints by role
4. Add role management endpoints

Deliverable: RBAC implemented

SECURITY BEST PRACTICES:
- Use HTTPS only in production
- Implement rate limiting
- Add account lockout after failed attempts
- Log authentication events
- Use secure cookie flags (httpOnly, secure, sameSite)

START: Execute Phase 1. Install JWT library and configure token generation.
```
