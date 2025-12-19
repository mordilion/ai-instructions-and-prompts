# Hibernate/JPA Framework

> **Scope**: Apply these rules when using Hibernate or JPA (with Spring Boot, Jakarta EE, or standalone).

## 1. Entities
- **@Entity Annotation**: Mark classes as JPA entities.
- **Primary Keys**: Use `@Id` and `@GeneratedValue`.
- **Immutability**: Prefer immutable entities where possible.
- **No Business Logic**: Entities are data containers, not domain models.

```java
@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    private boolean active;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

## 2. Relationships
- **Lazy Loading**: Default for `@OneToMany` and `@ManyToMany`.
- **Fetch Strategies**: Use `JOIN FETCH` or `@EntityGraph` to avoid N+1 queries.
- **Bidirectional**: Use `mappedBy` on the inverse side.

```java
@Entity
public class User {
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Post> posts = new ArrayList<>();
    
    public void addPost(Post post) {
        posts.add(post);
        post.setUser(this);
    }
}

@Entity
public class Post {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
```

## 3. Repositories
- **Spring Data JPA**: Use for standard CRUD operations.
- **Custom Queries**: Use `@Query` for complex queries.
- **Projections**: Use DTOs or interfaces for read-only queries.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // Method name derivation
    Optional<User> findByEmail(String email);
    List<User> findByActiveTrue();
    
    // Custom query
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.posts WHERE u.id = :id")
    Optional<User> findByIdWithPosts(@Param("id") Long id);
    
    // DTO projection
    @Query("SELECT new com.company.dto.UserDto(u.id, u.email, u.name) FROM User u")
    List<UserDto> findAllDto();
}
```

## 4. Queries (JPQL)
- **Type-Safe**: Use JPQL for complex queries.
- **JOIN FETCH**: Avoid N+1 queries.
- **Pagination**: Use `Pageable` for large result sets.

```java
// N+1 Query Problem
// ❌ Bad
List<User> users = userRepository.findAll();
users.forEach(u -> System.out.println(u.getPosts().size()));  // N+1 queries

// ✅ Good - JOIN FETCH
@Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.posts")
List<User> findAllWithPosts();

// ✅ Good - EntityGraph
@EntityGraph(attributePaths = {"posts"})
List<User> findAll();
```

## 5. Transactions
- **@Transactional**: Use for write operations.
- **Read-Only**: Mark read operations with `@Transactional(readOnly = true)`.
- **Propagation**: Understand propagation levels.

```java
@Service
@Transactional(readOnly = true)
public class UserService {
    
    @Transactional
    public User createUser(CreateUserRequest request) {
        User user = User.builder()
            .email(request.email())
            .name(request.name())
            .build();
        return userRepository.save(user);
    }
    
    public User getUser(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
}
```

## 6. Caching
- **Second-Level Cache**: Use for rarely-changed data.
- **Query Cache**: Cache query results.

```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class User {
    // ...
}
```

## 7. Anti-Patterns (MUST avoid)
- **N+1 Queries**: Use JOIN FETCH or EntityGraph.
- **Open Session in View**: Disable OSIV in production (`spring.jpa.open-in-view=false`).
- **Bidirectional Relationships Without Sync**: Always synchronize both sides.
- **Entities as DTOs**: NEVER return entities from controllers/APIs.

