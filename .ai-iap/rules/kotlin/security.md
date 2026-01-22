# Kotlin Security

> **Scope**: Kotlin-specific security (Android, Ktor, Spring Boot)
> **Extends**: General security rules
> **Applies to**: *.kt, *.kts files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use parameterized queries / prepared statements
> **ALWAYS**: AndroidKeyStore for sensitive data (Android)
> **ALWAYS**: Certificate pinning for critical APIs
> **ALWAYS**: JWT validation with expiration
> **ALWAYS**: BCrypt for password hashing
> 
> **NEVER**: Concatenate untrusted input into SQL
> **NEVER**: Store secrets in SharedPreferences/plaintext
> **NEVER**: Disable SSL validation
> **NEVER**: Use MD5/SHA1 for passwords
> **NEVER**: Expose stack traces to clients

## 0. Embedded SQL (when SQL appears inside Kotlin)
- Use parameterized queries / prepared statements (or a safe ORM)
- NEVER concatenate or template untrusted input into SQL
- If dynamic table/column names needed: use strict allowlists

## 1. Android Security

### Keystore
- **ALWAYS**: `AndroidKeyStore` for sensitive data (tokens, keys).
- **ALWAYS**: `KeyGenParameterSpec` with `setUserAuthenticationRequired(true)`.
- **ALWAYS**: AES/GCM encryption mode.
- **NEVER**: `SharedPreferences` for secrets (plaintext).

### Network
- **ALWAYS**: Network security config XML (certificate pinning, `cleartextTrafficPermitted="false"`).
- **ALWAYS**: OkHttp `CertificatePinner` for critical APIs.
- **NEVER**: Disable SSL validation (`hostnameVerifier { _, _ -> true }`).

### SQL Injection Prevention
- **ALWAYS**: Room DAO with parameterized queries (`@Query("SELECT * FROM users WHERE email = :email")`).
- **NEVER**: `@RawQuery` with string templates or concatenation.

## 2. Ktor Security

### Authentication
- **ALWAYS**: `install(Authentication)` with JWT validation.
- **ALWAYS**: `com.auth0.jwt` with algorithm (HS512/RS256) and expiration.
- **ALWAYS**: `authenticate("auth-jwt")` block for protected routes.

### Input Validation
- **ALWAYS**: Validate request data (regex, length, type checks).
- **ALWAYS**: Return `HttpStatusCode.BadRequest` for invalid input.

### SQL Injection Prevention
- **ALWAYS**: Exposed ORM (type-safe, parameterized).
- **NEVER**: String templates in raw SQL (`exec("SELECT * FROM users WHERE id = '$id'")`).

### CORS
- **ALWAYS**: `install(CORS)` with specific origins. NEVER `anyHost()` with credentials.

## 3. Spring Boot (Kotlin)

### Configuration
- **ALWAYS**: Spring Security DSL (`http { authorize { ... } }`).
- **ALWAYS**: `BCryptPasswordEncoder(12)` bean.
- **ALWAYS**: `@PreAuthorize` on protected methods.

### SQL Injection Prevention
- **ALWAYS**: JPA with named parameters or Spring Data query methods.
- **NEVER**: String concatenation in `@Query`.

## 4. Coroutines Security

### Timeouts
- **ALWAYS**: `withTimeout()` for external calls (prevent DoS).
- **ALWAYS**: Proper exception handling in coroutines (`try-catch`).

## 5. Kotlin-Specific

### Null Safety
- **ALWAYS**: Validate nullable inputs. Use `?:`, `?.let`, `require()`, `check()`.
- **NEVER**: Force unwrap (`!!`) on user input.

### Data Classes
- **ALWAYS**: Use DTOs (data classes) for API responses.
- **NEVER**: Expose entities with passwords/sensitive fields.

### Type Safety
- **ALWAYS**: Use sealed classes for result types (success/failure).
- **ALWAYS**: Avoid `Any` type for user data.

## 6. Error Handling

- **ALWAYS**: Global exception handlers (Ktor `install(StatusPages)`, Spring `@RestControllerAdvice`).
- **ALWAYS**: Generic error messages to clients. Log details server-side.
- **NEVER**: Expose stack traces to clients.

## AI Self-Check

Before generating Kotlin code:
- [ ] Android Keystore for sensitive data?
- [ ] Room/Exposed parameterized queries?
- [ ] BCrypt for passwords (12 rounds)?
- [ ] Certificate pinning configured?
- [ ] Network security config (no cleartext)?
- [ ] JWT with expiration?
- [ ] Coroutine timeouts configured?
- [ ] Null safety (no `!!` on user input)?
- [ ] DTOs for API responses (not entities)?
- [ ] HTTPS enforced?
