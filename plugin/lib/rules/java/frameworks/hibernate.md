# Hibernate ORM

> **Scope**: Hibernate in Java projects  
> **Applies to**: Java files using Hibernate
> **Extends**: java/architecture.md, java/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use @Entity with proper mapping
> **ALWAYS**: Use Criteria API or JPQL
> **ALWAYS**: Use transactions for writes
> **ALWAYS**: Use fetch joins to avoid N+1
> **ALWAYS**: Close SessionFactory on shutdown
> 
> **NEVER**: Use raw SQL without parameterization
> **NEVER**: Load collections in loops
> **NEVER**: Forget @Transactional
> **NEVER**: Use lazy loading without open session
> **NEVER**: Store Session in instance variables

## Core Patterns

### Entity Mapping

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @OneToMany(mappedBy = "author", cascade = CascadeType.ALL)
    private List<Post> posts = new ArrayList<>();
}
```

### CRUD Operations

```java
// Create
@Transactional
public User createUser(String name, String email) {
    User user = new User(name, email);
    session.persist(user);
    return user;
}

// Read with fetch join (avoid N+1)
@Transactional(readOnly = true)
public User getUserWithPosts(Long id) {
    return session.createQuery(
        "SELECT u FROM User u JOIN FETCH u.posts WHERE u.id = :id",
        User.class
    ).setParameter("id", id).getSingleResult();
}

// Update
@Transactional
public void updateUser(Long id, String name) {
    User user = session.get(User.class, id);
    user.setName(name);
}

// Delete
@Transactional
public void deleteUser(Long id) {
    User user = session.get(User.class, id);
    session.remove(user);
}
```

### Criteria API

```java
CriteriaBuilder cb = session.getCriteriaBuilder();
CriteriaQuery<User> cq = cb.createQuery(User.class);
Root<User> user = cq.from(User.class);

cq.select(user)
  .where(cb.like(user.get("email"), "%@example.com"))
  .orderBy(cb.desc(user.get("id")));

List<User> users = session.createQuery(cq).getResultList();
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **N+1 Queries** | Lazy load in loop | `JOIN FETCH` |
| **No Transaction** | Direct persist | `@Transactional` |
| **Raw SQL** | Unparameterized | Criteria API/JPQL |
| **Instance Session** | Store session | Get from factory |

## AI Self-Check

- [ ] @Entity with mapping?
- [ ] Criteria API/JPQL?
- [ ] Transactions for writes?
- [ ] Fetch joins?
- [ ] SessionFactory closed?
- [ ] No raw SQL without params?
- [ ] No N+1 queries?
- [ ] @Transactional used?
- [ ] Open session for lazy?

## Key Features

| Feature | Purpose |
|---------|---------|
| @Entity | Mapping |
| Criteria API | Type-safe queries |
| JPQL | String queries |
| JOIN FETCH | Avoid N+1 |
| @Transactional | Transaction |

## Best Practices

**MUST**: @Entity, Criteria/JPQL, transactions, fetch joins, close factory
**SHOULD**: Named queries, caching, indexes, batch operations
**AVOID**: Raw SQL, N+1, no transactions, lazy without session
