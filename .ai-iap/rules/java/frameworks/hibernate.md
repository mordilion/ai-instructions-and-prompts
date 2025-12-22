# Hibernate ORM

## Overview
Hibernate: powerful, mature ORM (Object-Relational Mapper) for Java with JPA implementation.
Handles object-to-database mapping, lazy loading, caching, and query optimization automatically.
Best for complex data models, when you need caching, or working with legacy databases.

## Entity Mapping

```java
@Entity
@Table(name = "users")
@Getter @Setter
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
    }
}
```

## Relationships

```java
// One-to-Many
@Entity
public class User {
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Post> posts = new ArrayList<>();
}

@Entity
public class Post {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}

// Many-to-Many
@Entity
public class Student {
    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private Set<Course> courses = new HashSet<>();
}
```

## Querying

### HQL
```java
@Repository
public class UserRepository {
    @PersistenceContext
    private EntityManager entityManager;
    
    public List<User> findByName(String name) {
        return entityManager.createQuery(
            "SELECT u FROM User u WHERE u.name LIKE :name", User.class
        )
        .setParameter("name", "%" + name + "%")
        .getResultList();
    }
}
```

### Criteria API
```java
public List<User> findUsers(String name, String email) {
    CriteriaBuilder cb = entityManager.getCriteriaBuilder();
    CriteriaQuery<User> query = cb.createQuery(User.class);
    Root<User> user = query.from(User.class);
    
    List<Predicate> predicates = new ArrayList<>();
    if (name != null) {
        predicates.add(cb.like(user.get("name"), "%" + name + "%"));
    }
    if (email != null) {
        predicates.add(cb.equal(user.get("email"), email));
    }
    
    query.where(predicates.toArray(new Predicate[0]));
    return entityManager.createQuery(query).getResultList();
}
```

### Named Queries
```java
@Entity
@NamedQuery(
    name = "User.findByEmail",
    query = "SELECT u FROM User u WHERE u.email = :email"
)
public class User {
    // ...
}

public Optional<User> findByEmail(String email) {
    return entityManager.createNamedQuery("User.findByEmail", User.class)
        .setParameter("email", email)
        .getResultStream()
        .findFirst();
}
```

## Transactions

```java
@Service
@Transactional(readOnly = true)
public class UserService {
    
    @Transactional
    public void transferData(Long fromId, Long toId) {
        User from = userRepository.findById(fromId)
            .orElseThrow(() -> new UserNotFoundException(fromId));
        User to = userRepository.findById(toId)
            .orElseThrow(() -> new UserNotFoundException(toId));
        
        // Business logic
        userRepository.save(from);
        userRepository.save(to);
    }
}
```

## Lazy Loading

```java
@OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
private List<Post> posts;

// Fetch eagerly when needed
@Query("SELECT u FROM User u LEFT JOIN FETCH u.posts WHERE u.id = :id")
Optional<User> findByIdWithPosts(@Param("id") Long id);
```

## Caching

### Second-Level Cache
```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class User {
    // ...
}

// application.properties
// spring.jpa.properties.hibernate.cache.use_second_level_cache=true
// spring.jpa.properties.hibernate.cache.region.factory_class=org.hibernate.cache.jcache.JCacheRegionFactory
```

## Best Practices

**MUST**:
- Use `fetch = FetchType.LAZY` for collections (default for @OneToMany, @ManyToMany)
- Use `@EntityGraph` or `JOIN FETCH` to prevent N+1 queries
- Override `equals()` and `hashCode()` for entities (use business key or ID)
- Use `@Transactional` for write operations
- Always specify `cascade` and `orphanRemoval` explicitly

**SHOULD**:
- Use DTOs for returning data from service layer (NOT entities)
- Use second-level cache for read-heavy entities
- Use batch fetching for collections
- Use `@Query` with JPQL for complex queries
- Use protected no-arg constructor for entities

**AVOID**:
- N+1 queries (use eager loading strategically)
- Exposing entities outside service layer
- Bi-directional relationships without careful management
- `fetch = FetchType.EAGER` (causes performance issues)
- Forgetting to configure connection pool properly

## Common Patterns

### Entity equals/hashCode
```java
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)  // Required by Hibernate
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // ✅ GOOD: equals/hashCode based on ID (after persist)
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        return id != null && id.equals(((User) o).id);  // null-safe
    }
    
    @Override
    public int hashCode() {
        return getClass().hashCode();  // Stable across persist
    }
    
    // ❌ BAD: Using all fields
    // Don't use Objects.hash(id, name, email) - breaks when entity changes
}
```

### Avoiding N+1 Queries
```java
// ❌ BAD: N+1 queries (1 query for users + N queries for posts)
List<User> users = userRepository.findAll();
for (User user : users) {
    System.out.println(user.getPosts().size());  // New query each time!
}

// ✅ GOOD: Single query with JOIN FETCH
@Query("SELECT u FROM User u LEFT JOIN FETCH u.posts")
List<User> findAllWithPosts();

// ✅ GOOD: EntityGraph (cleaner for simple cases)
@EntityGraph(attributePaths = {"posts"})
List<User> findAll();

// ✅ GOOD: Separate query (better for large collections)
@EntityGraph(attributePaths = {"posts"})
@Query("SELECT DISTINCT u FROM User u")
List<User> findAllWithPostsSeparately();
```

### Lazy Loading Pitfalls
```java
// ❌ BAD: LazyInitializationException
@Transactional
public User getUser(Long id) {
    return userRepository.findById(id).orElseThrow();
}

// In controller (outside transaction):
User user = userService.getUser(1L);
user.getPosts().size();  // LazyInitializationException!

// ✅ GOOD: Fetch within transaction or use DTO
@Transactional
public UserDto getUser(Long id) {
    User user = userRepository.findById(id).orElseThrow();
    return new UserDto(user.getId(), user.getName(), user.getPosts().size());
    // Posts loaded within transaction
}
```

### Batch Operations
```java
// Use @Modifying for bulk updates
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.createdAt < :date")
int updateOldUsers(@Param("status") String status, @Param("date") LocalDateTime date);

// Use DTO projections to avoid loading full entities
@Query("SELECT new com.app.dto.UserDto(u.id, u.name, u.email) FROM User u")
List<UserDto> findAllDtos();  // Only selects needed columns
```
