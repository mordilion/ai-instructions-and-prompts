# Java Security

> **Scope**: Java-specific security practices (Spring Boot, Android, Jakarta EE)
> **Extends**: general/security.md
> **Applies to**: *.java files

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Spring Security for web authentication
> **ALWAYS**: Use PreparedStatement for database queries (NEVER Statement)
> **ALWAYS**: Use BCryptPasswordEncoder for password hashing
> **ALWAYS**: Validate all input with Bean Validation (@Valid)
> **ALWAYS**: Use HTTPS in production
> 
> **NEVER**: Use String concatenation for SQL queries
> **NEVER**: Store passwords in plaintext
> **NEVER**: Disable CSRF protection
> **NEVER**: Return stack traces to clients
> **NEVER**: Use default credentials

## 1. Spring Security Configuration

### Basic Security Setup

```java
// ✅ CORRECT - Spring Security configuration
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .defaultSuccessUrl("/dashboard")
                .failureUrl("/login?error=true")
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )
            .csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()))
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .maximumSessions(1)
                .maxSessionsPreventsLogin(true)
            );
        
        return http.build();
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);  // 12 rounds minimum
    }
}

// ❌ WRONG - No security configuration
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests().anyRequest().permitAll();  // Open to everyone!
    }
}
```

### JWT Authentication

```java
// ✅ CORRECT - JWT authentication
@Component
public class JwtTokenProvider {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    private static final long JWT_EXPIRATION = 900000; // 15 minutes
    
    public String generateToken(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + JWT_EXPIRATION);
        
        return Jwts.builder()
                .setSubject(userDetails.getUsername())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}

// ❌ WRONG - No expiration, weak algorithm
public String generateToken(String username) {
    return Jwts.builder()
            .setSubject(username)
            .signWith(SignatureAlgorithm.NONE, "secret")  // Algorithm: none!
            .compact();
}
```

## 2. Input Validation

### Bean Validation

```java
// ✅ CORRECT - Bean Validation
public class CreateUserRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 255)
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 12, max = 128)
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{12,}$",
             message = "Password must contain uppercase, lowercase, digit, and special character")
    private String password;
    
    @NotBlank
    @Size(min = 2, max = 100)
    @Pattern(regexp = "^[a-zA-Z\\s]+$", message = "Name must contain only letters")
    private String name;
    
    @Min(18)
    @Max(120)
    private Integer age;
}

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        // Validation automatic via @Valid
        User user = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
}
```

## 3. SQL Injection Prevention

### PreparedStatement (JDBC)

```java
// ✅ CORRECT - PreparedStatement
public User findByEmail(String email) {
    String sql = "SELECT * FROM users WHERE email = ?";
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setString(1, email);
        ResultSet rs = stmt.executeQuery();
        return mapToUser(rs);
    }
}

// ❌ WRONG - String concatenation
public User findByEmail(String email) {
    String sql = "SELECT * FROM users WHERE email = '" + email + "'";
    Statement stmt = connection.createStatement();
    return stmt.executeQuery(sql);  // SQL INJECTION!
}
```

### JPA/Hibernate

```java
// ✅ CORRECT - JPA named parameters
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmail(@Param("email") String email);
    
    // Query methods (type-safe)
    Optional<User> findByEmailAndActiveTrue(String email);
    List<User> findByNameContainingIgnoreCase(String name);
}

// ✅ CORRECT - Criteria API (type-safe)
public List<User> searchUsers(String searchTerm) {
    CriteriaBuilder cb = entityManager.getCriteriaBuilder();
    CriteriaQuery<User> query = cb.createQuery(User.class);
    Root<User> user = query.from(User.class);
    
    query.where(cb.like(user.get("name"), "%" + searchTerm + "%"));
    
    return entityManager.createQuery(query).getResultList();
}

// ❌ WRONG - Native query with concatenation
@Query(value = "SELECT * FROM users WHERE name LIKE '%" + "?1" + "%'", nativeQuery = true)
List<User> searchUsers(String searchTerm);  // SQL INJECTION!
```

## 4. Authentication & Password Security

### Password Encoding

```java
// ✅ CORRECT - BCrypt password encoding
@Service
public class UserService {
    
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    
    public UserService(PasswordEncoder passwordEncoder, UserRepository userRepository) {
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
    }
    
    public User createUser(CreateUserRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        return userRepository.save(user);
    }
    
    public boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}

// ❌ WRONG - Weak hashing
public User createUser(CreateUserRequest request) {
    User user = new User();
    user.setPassword(DigestUtils.md5Hex(request.getPassword()));  // MD5 is broken!
    return userRepository.save(user);
}
```

## 5. Authorization

### Method Security

```java
// ✅ CORRECT - Method-level security
@Configuration
@EnableMethodSecurity(prePostEnabled = true)
public class MethodSecurityConfig {
}

@Service
public class PostService {
    
    @PreAuthorize("hasRole('ADMIN')")
    public void deletePost(Long postId) {
        postRepository.deleteById(postId);
    }
    
    @PreAuthorize("hasRole('USER')")
    @PostAuthorize("returnObject.author.id == authentication.principal.id")
    public Post getPost(Long postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new NotFoundException("Post not found"));
    }
    
    @PreAuthorize("@postSecurity.isOwner(#postId, authentication)")
    public void updatePost(Long postId, UpdatePostRequest request) {
        // Custom security check
    }
}

@Component("postSecurity")
public class PostSecurity {
    
    public boolean isOwner(Long postId, Authentication authentication) {
        Post post = postRepository.findById(postId).orElse(null);
        if (post == null) return false;
        
        String username = authentication.getName();
        return post.getAuthor().getUsername().equals(username);
    }
}
```

## 6. HTTPS Configuration

```java
// ✅ CORRECT - application.properties
server.port=8443
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=${SSL_KEY_STORE_PASSWORD}
server.ssl.key-store-type=PKCS12
server.ssl.key-alias=tomcat

# Force HTTPS
security.require-ssl=true

// ✅ CORRECT - Redirect HTTP to HTTPS
@Bean
public ServletWebServerFactory servletContainer() {
    TomcatServletWebServerFactory tomcat = new TomcatServletWebServerFactory() {
        @Override
        protected void postProcessContext(Context context) {
            SecurityConstraint securityConstraint = new SecurityConstraint();
            securityConstraint.setUserConstraint("CONFIDENTIAL");
            SecurityCollection collection = new SecurityCollection();
            collection.addPattern("/*");
            securityConstraint.addCollection(collection);
            context.addConstraint(securityConstraint);
        }
    };
    tomcat.addAdditionalTomcatConnectors(redirectConnector());
    return tomcat;
}

private Connector redirectConnector() {
    Connector connector = new Connector("org.apache.coyote.http11.Http11NioProtocol");
    connector.setScheme("http");
    connector.setPort(8080);
    connector.setSecure(false);
    connector.setRedirectPort(8443);
    return connector;
}
```

## 7. CORS Configuration

```java
// ✅ CORRECT - Restrictive CORS
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("https://yourapp.com", "https://staging.yourapp.com")
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}

// ❌ WRONG - Open CORS
@CrossOrigin(origins = "*")  // Anyone can access!
@RestController
public class UserController {
}
```

## 8. Error Handling

```java
// ✅ CORRECT - Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception ex, WebRequest request) {
        // Log detailed error
        logger.error("Unhandled exception", ex);
        
        // Return generic message
        ErrorResponse error = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "An error occurred",
                LocalDateTime.now()
        );
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex) {
        
        Map<String, String> errors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .collect(Collectors.toMap(
                        FieldError::getField,
                        FieldError::getDefaultMessage
                ));
        
        return ResponseEntity.badRequest().body(new ValidationErrorResponse(errors));
    }
}

// ❌ WRONG - Expose stack trace
catch (Exception ex) {
    return ResponseEntity.status(500).body(ex.getMessage() + "\n" + ex.getStackTrace());
}
```

## 9. Android Security

### Keystore

```java
// ✅ CORRECT - Android Keystore
public class SecureStorage {
    
    private static final String ANDROID_KEYSTORE = "AndroidKeyStore";
    private static final String KEY_ALIAS = "MyAppKey";
    
    public void saveSecureData(String data) throws Exception {
        KeyStore keyStore = KeyStore.getInstance(ANDROID_KEYSTORE);
        keyStore.load(null);
        
        if (!keyStore.containsAlias(KEY_ALIAS)) {
            KeyGenerator keyGenerator = KeyGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE);
            
            keyGenerator.init(
                    new KeyGenParameterSpec.Builder(KEY_ALIAS,
                            KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                            .setUserAuthenticationRequired(true)
                            .build());
            
            keyGenerator.generateKey();
        }
        
        // Encrypt and store data
        SecretKey key = (SecretKey) keyStore.getKey(KEY_ALIAS, null);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        
        byte[] encrypted = cipher.doFinal(data.getBytes());
        // Store encrypted data
    }
}

// ❌ WRONG - SharedPreferences without encryption
SharedPreferences prefs = context.getSharedPreferences("app", MODE_PRIVATE);
prefs.edit().putString("token", authToken).apply();  // Plaintext!
```

### Network Security

```xml
<!-- ✅ CORRECT - Network security config -->
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">yourapp.com</domain>
        <pin-set expiration="2025-12-31">
            <pin digest="SHA-256">7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y=</pin>
            <pin digest="SHA-256">YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=</pin>
        </pin-set>
    </domain-config>
</network-security-config>

<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config">
</application>
```

## 10. File Upload Security

```java
// ✅ CORRECT - Secure file upload
@PostMapping("/upload")
public ResponseEntity<FileUploadResponse> uploadFile(@RequestParam("file") MultipartFile file) {
    
    // Validate file type
    List<String> allowedTypes = Arrays.asList("image/jpeg", "image/png", "image/gif");
    if (!allowedTypes.contains(file.getContentType())) {
        throw new InvalidFileTypeException("Invalid file type");
    }
    
    // Validate file size (5MB)
    long maxSize = 5 * 1024 * 1024;
    if (file.getSize() > maxSize) {
        throw new FileSizeExceededException("File too large");
    }
    
    // Generate safe filename
    String originalFilename = file.getOriginalFilename();
    String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
    String safeFilename = UUID.randomUUID().toString() + extension;
    
    // Store file
    Path uploadPath = Paths.get("uploads", safeFilename);
    Files.copy(file.getInputStream(), uploadPath, StandardCopyOption.REPLACE_EXISTING);
    
    return ResponseEntity.ok(new FileUploadResponse(safeFilename));
}
```

## AI Self-Check

Before generating Java code, verify:
- [ ] Spring Security configured?
- [ ] BCryptPasswordEncoder for passwords (12+ rounds)?
- [ ] PreparedStatement for SQL queries (no concatenation)?
- [ ] @Valid annotation on request bodies?
- [ ] @PreAuthorize on protected methods?
- [ ] HTTPS enabled in production?
- [ ] CORS configured restrictively?
- [ ] Global exception handler (no stack traces to client)?
- [ ] Secrets in environment variables?
- [ ] File uploads validated (type, size)?
- [ ] Android Keystore for sensitive data?
- [ ] No hardcoded credentials?
- [ ] Rate limiting configured?
- [ ] Security headers configured?
- [ ] Dependency scanning (OWASP Dependency Check)?

## Testing Security

```java
// ✅ Security testing example
@SpringBootTest
@AutoConfigureMockMvc
class SecurityTests {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void protectedEndpoint_requiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isUnauthorized());
    }
    
    @Test
    void sqlInjection_isPrevented() throws Exception {
        String malicious = "admin'; DROP TABLE users--";
        
        mockMvc.perform(get("/api/users/search")
                        .param("query", malicious))
                .andExpect(status().isNotEqualTo(500));
    }
}
```

---

**Security in Java: Use Spring Security's built-in features. Don't roll your own authentication/authorization.**

