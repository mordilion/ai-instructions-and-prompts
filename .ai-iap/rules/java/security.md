# Java Security

> **Scope**: Java-specific security practices (Spring Boot, Android)
> **Extends**: general/security.md
> **Applies to**: *.java files

## 1. Spring Security

### Configuration
- **ALWAYS**: `@EnableWebSecurity` with `SecurityFilterChain` bean.
- **ALWAYS**: Specific path matchers (`/api/public/**` permitAll, `/api/admin/**` hasRole).
- **ALWAYS**: CSRF enabled (default). Only disable for stateless REST APIs with JWT.
- **ALWAYS**: HTTPS redirect in production (`requiresSecure()`).

### Authentication
- **ALWAYS**: `BCryptPasswordEncoder(12)` for passwords. NEVER MD5/SHA1.
- **ALWAYS**: Spring Security's `UserDetailsService` for user loading.
- **JWT**: Validate with `JwtTokenProvider`. Set expiration (15 min).

### Authorization
- **ALWAYS**: `@PreAuthorize("hasRole('ADMIN')")` on methods.
- **ALWAYS**: `@EnableMethodSecurity(prePostEnabled = true)`.
- **Custom**: SpEL expressions for complex checks (`@postSecurity.isOwner(#id, authentication)`).

## 2. SQL Injection Prevention

### JPA/Hibernate
- **ALWAYS**: JPQL with named parameters (`:email`) or Criteria API.
- **ALWAYS**: Spring Data query methods (type-safe).
- **NEVER**: String concatenation in `@Query` or native queries.

### JDBC
- **ALWAYS**: `PreparedStatement` with `?` placeholders and `setString()`.
- **NEVER**: `Statement` with concatenated strings.

## 3. Input Validation

### Bean Validation
- **ALWAYS**: `@Valid` on `@RequestBody`.
- **ALWAYS**: Annotations (`@NotBlank`, `@Email`, `@Size(min=12, max=128)`, `@Pattern`).
- **Custom**: `@Constraint` for complex validation.

## 4. Android Security

### Keystore
- **ALWAYS**: `AndroidKeyStore` for sensitive data (tokens, keys).
- **ALWAYS**: Encryption with AES/GCM mode from Keystore keys.
- **NEVER**: `SharedPreferences` for secrets (plaintext).

### Network
- **ALWAYS**: Network security config XML (certificate pinning, no cleartext traffic).
- **ALWAYS**: OkHttp `CertificatePinner` for API calls.
- **NEVER**: `HostnameVerifier` that accepts all (disables SSL validation).

## 5. Infrastructure

### HTTPS
- **ALWAYS**: application.properties → `server.ssl.enabled=true`.
- **ALWAYS**: Redirect HTTP → HTTPS via `SecurityFilterChain`.

### CORS
- **ALWAYS**: `CorsRegistry` with specific origins. NEVER `allowedOrigins("*")` with credentials.

### Error Handling
- **ALWAYS**: `@RestControllerAdvice` for global exception handling.
- **ALWAYS**: Generic messages to clients. Log stack traces server-side.
- **NEVER**: Return `ex.getMessage()` or stack trace to client.

### File Uploads
- **ALWAYS**: Validate type (content-based), size limit, sanitize filename.
- **ALWAYS**: Generate UUID filenames. Store outside webroot.

## 6. Security Headers

- **ALWAYS**: Configure via `HttpSecurity` or reverse proxy.
- **Headers**: `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`.

## 7. Dependency Security

- **ALWAYS**: OWASP Dependency Check plugin.
- **ALWAYS**: Maven/Gradle dependency scanning (Snyk, Dependabot).

## AI Self-Check

Before generating Java code:
- [ ] Spring Security configured with `SecurityFilterChain`?
- [ ] `BCryptPasswordEncoder` (12 rounds)?
- [ ] `PreparedStatement` or JPA (no string concatenation)?
- [ ] `@Valid` on request bodies?
- [ ] `@PreAuthorize` on protected methods?
- [ ] HTTPS enabled?
- [ ] Android Keystore for sensitive data?
- [ ] Network security config (no cleartext)?
- [ ] CORS specific origins?
- [ ] Global exception handler (no stack traces)?
