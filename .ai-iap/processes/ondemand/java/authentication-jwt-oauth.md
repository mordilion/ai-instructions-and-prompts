# Authentication Setup Process - Java

> **Purpose**: Implement secure authentication and authorization in Java applications

> **Core Stack**: Spring Security, JWT, OAuth 2.0

---

## Phase 1: Spring Security Setup

> **ALWAYS use**: Spring Security ⭐ (industry standard)
> **NEVER**: Roll your own security

**Dependencies** (Maven):
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-crypto</artifactId>
</dependency>
```

**Password Encoding**:
```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12); // 12 rounds
}
```

> **Git**: `git commit -m "feat: add Spring Security"`

---

## Phase 2: JWT Authentication

> **ALWAYS**:
> - Use jjwt library (io.jsonwebtoken)
> - Store secret in application.properties (encrypted) or vault
> - Token expiration: 1h access, 7d refresh

**Dependencies**:
```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

**JWT Util**:
```java
@Component
public class JwtUtil {
    @Value("${jwt.secret}")
    private String secret;
    
    public String generateToken(UserDetails userDetails) {
        return Jwts.builder()
            .setSubject(userDetails.getUsername())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 3600000)) // 1h
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
    }
}
```

**JWT Filter**:
```java
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain filterChain) {
        String token = extractToken(request);
        if (token != null && jwtUtil.validateToken(token)) {
            String username = jwtUtil.extractUsername(token);
            UsernamePasswordAuthenticationToken auth = 
                new UsernamePasswordAuthenticationToken(username, null, authorities);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        filterChain.doFilter(request, response);
    }
}
```

> **Git**: `git commit -m "feat: add JWT authentication"`

---

## Phase 3: OAuth 2.0 / Social Login

> **ALWAYS use**: Spring Security OAuth 2.0 Client

**Dependencies**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>
```

**Configuration** (application.yml):
```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
            scope: profile, email
```

> **Git**: `git commit -m "feat: add OAuth 2.0 (Google)"`

---

## Phase 4: Authorization & RBAC

> **ALWAYS use**: Method security with @PreAuthorize

**Enable Method Security**:
```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        http.authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/admin/**").hasRole("ADMIN")
            .requestMatchers("/api/public/**").permitAll()
            .anyRequest().authenticated()
        );
        return http.build();
    }
}
```

**Method-Level**:
```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) { }

@PreAuthorize("hasAuthority('PERMISSION_WRITE')")
public void updatePost(Post post) { }
```

> **Git**: `git commit -m "feat: add role-based authorization"`

---

## Phase 5: Security Hardening

> **ALWAYS implement**:
> - Rate limiting (Bucket4j or Resilience4j)
> - CORS configuration
> - CSRF protection (stateless: disable; stateful: enable)
> - Security headers

**Rate Limiting** (Bucket4j):
```java
@Bean
public Bucket bucket() {
    return Bucket.builder()
        .addLimit(Limit.of(5, Duration.ofMinutes(15)))
        .build();
}
```

> **Git**: `git commit -m "feat: add authentication security hardening"`

---

## Framework-Specific Notes

### Spring Boot
- Spring Security autoconfiguration
- UserDetailsService for custom user loading
- SecurityFilterChain for configuration

### Quarkus
- SmallRye JWT for JWT
- Elytron for security
- @RolesAllowed annotation

---

## AI Self-Check

- [ ] Spring Security configured
- [ ] BCryptPasswordEncoder with 12+ rounds
- [ ] JWT authentication working
- [ ] OAuth 2.0 configured (if needed)
- [ ] Authorization rules defined
- [ ] Rate limiting enabled
- [ ] HTTPS enforced
- [ ] Security headers configured

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
