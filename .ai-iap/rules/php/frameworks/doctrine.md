# Doctrine ORM

> **Scope**: Doctrine ORM in PHP projects  
> **Applies to**: PHP files using Doctrine
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use attributes for entity mapping (PHP 8+)
> **ALWAYS**: Use QueryBuilder or DQL
> **ALWAYS**: Use transactions for multi-operation writes
> **ALWAYS**: Batch flush() operations
> **ALWAYS**: Use indexes for queried fields
> 
> **NEVER**: Use annotations (deprecated)
> **NEVER**: Call flush() in loops
> **NEVER**: Use raw SQL without params
> **NEVER**: Forget cascade operations
> **NEVER**: Load collections in loops (N+1)

## Core Patterns

### Entity

```php
#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
#[ORM\Index(columns: ['email'], name: 'email_idx')]
class User
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private ?int $id = null;
    
    #[ORM\Column(type: 'string', length: 255, unique: true)]
    private string $email;
    
    #[ORM\OneToMany(targetEntity: Post::class, mappedBy: 'user', cascade: ['persist', 'remove'])]
    private Collection $posts;
    
    public function __construct()
    {
        $this->posts = new ArrayCollection();
    }
}
```

### Repository

```php
class UserRepository extends ServiceEntityRepository
{
    public function findByEmailDomain(string $domain): array
    {
        return $this->createQueryBuilder('u')
            ->where('u.email LIKE :domain')
            ->setParameter('domain', '%@' . $domain)
            ->orderBy('u.email', 'ASC')
            ->getQuery()
            ->getResult();
    }
    
    public function findWithPosts(): array
    {
        return $this->createQueryBuilder('u')
            ->leftJoin('u.posts', 'p')
            ->addSelect('p')  // Fetch join: solves N+1
            ->getQuery()
            ->getResult();
    }
}
```

### Transactions

```php
$em->beginTransaction();
try {
    $user = new User();
    $em->persist($user);
    
    $post = new Post();
    $post->setUser($user);
    $em->persist($post);
    
    $em->flush();
    $em->commit();
} catch (\Exception $e) {
    $em->rollback();
    throw $e;
}
```

### Batch Operations

```php
// ❌ WRONG: flush() in loop
foreach ($users as $user) {
    $user->setActive(true);
    $em->flush();  // Don't do this!
}

// ✅ CORRECT: batch flush
foreach ($users as $user) {
    $user->setActive(true);
}
$em->flush();  // Once after loop
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Annotations** | `@ORM\Entity` | `#[ORM\Entity]` |
| **Loop Flush** | flush() in loop | Single flush after |
| **N+1 Problem** | Lazy load in loop | Fetch join |
| **Raw SQL** | `->query($sql)` | QueryBuilder with params |

## AI Self-Check

- [ ] Using attributes?
- [ ] QueryBuilder/DQL?
- [ ] Transactions for writes?
- [ ] Batch flush()?
- [ ] Indexes on queried fields?
- [ ] No annotations?
- [ ] No flush() in loops?
- [ ] Fetch joins for N+1?
- [ ] Parameterized queries?

## Key Features

| Feature | Purpose |
|---------|---------|
| QueryBuilder | Fluent queries |
| DQL | String-based queries |
| Fetch Joins | Avoid N+1 |
| Attributes | Entity mapping |
| Transactions | Data integrity |

## Best Practices

**MUST**: Attributes, QueryBuilder/DQL, transactions, batch flush, indexes
**SHOULD**: Fetch joins, cascade, repositories, parameter binding
**AVOID**: Annotations, flush() in loops, raw SQL, N+1 queries
