# Doctrine ORM

> **Scope**: Apply these rules when using Doctrine ORM in PHP projects
> **Applies to**: PHP files using Doctrine
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use attributes for entity mapping (PHP 8+, NOT annotations)
> **ALWAYS**: Use QueryBuilder or DQL (NOT raw SQL without params)
> **ALWAYS**: Use transactions for multi-operation writes
> **ALWAYS**: Use flush() only after all changes (batch operations)
> **ALWAYS**: Use indexes for frequently queried fields
> 
> **NEVER**: Use annotations (deprecated, use attributes)
> **NEVER**: Call flush() in loops (performance killer)
> **NEVER**: Use raw SQL without parameter binding (SQL injection)
> **NEVER**: Forget to cascade operations (orphaned records)
> **NEVER**: Load entire collections in loops (N+1 problem)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| QueryBuilder | Complex queries | `->createQueryBuilder()`, fluent API |
| DQL | Simple queries | String-based queries |
| Native SQL | Performance-critical, complex | `->createNativeQuery()`, parameterized |
| Fetch Joins | Avoid N+1 | `->leftJoin()`, `->addSelect()` |
| Lazy Loading | Default behavior | Proxies, on-demand loading |

## Core Patterns

### Entity with Attributes
```php
<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
#[ORM\Index(columns: ['email'], name: 'email_idx')]
class User
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private ?int $id = null;
    
    #[ORM\Column(type: 'string', length: 180, unique: true)]
    private string $email;
    
    #[ORM\OneToMany(
        targetEntity: Post::class,
        mappedBy: 'author',
        cascade: ['persist', 'remove'],
        orphanRemoval: true
    )]
    private Collection $posts;
    
    #[ORM\Column(type: 'datetime_immutable')]
    private \DateTimeImmutable $createdAt;
    
    public function __construct()
    {
        $this->posts = new ArrayCollection();
        $this->createdAt = new \DateTimeImmutable();
    }
}
```

### Repository with QueryBuilder
```php
<?php

namespace App\Repository;

use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }
    
    public function findActiveUsers(): array
    {
        return $this->createQueryBuilder('u')
            ->where('u.active = :active')
            ->setParameter('active', true)
            ->orderBy('u.createdAt', 'DESC')
            ->getQuery()
            ->getResult();
    }
    
    public function findWithPosts(int $id): ?User
    {
        return $this->createQueryBuilder('u')
            ->leftJoin('u.posts', 'p')
            ->addSelect('p')  // Fetch join to avoid N+1
            ->where('u.id = :id')
            ->setParameter('id', $id)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
```

### Transactions
```php
<?php

public function createUserWithPosts(array $userData, array $posts): User
{
    $this->entityManager->beginTransaction();
    
    try {
        $user = new User();
        $user->setEmail($userData['email']);
        $this->entityManager->persist($user);
        
        foreach ($posts as $postData) {
            $post = new Post();
            $post->setTitle($postData['title']);
            $post->setAuthor($user);
            $this->entityManager->persist($post);
        }
        
        $this->entityManager->flush();  // Single flush
        $this->entityManager->commit();
        
        return $user;
    } catch (\Exception $e) {
        $this->entityManager->rollback();
        throw $e;
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Annotations** | `@ORM\Entity` | `#[ORM\Entity]` | Annotations deprecated |
| **flush() in Loop** | `foreach { persist(); flush(); }` | `foreach { persist(); } flush();` | Performance disaster |
| **Raw SQL** | `"WHERE id = $id"` | `->setParameter('id', $id)` | SQL injection |
| **N+1 Queries** | Lazy load in loop | Fetch join with `addSelect()` | Performance killer |
| **No Cascade** | Manual deletion | `cascade: ['remove']` | Orphaned records |

### Anti-Pattern: flush() in Loop (PERFORMANCE DISASTER)
```php
// ❌ WRONG - flush() in loop
foreach ($users as $userData) {
    $user = new User();
    $user->setEmail($userData['email']);
    $this->entityManager->persist($user);
    $this->entityManager->flush();  // SLOW! Separate DB call each time
}

// ✅ CORRECT - Single flush
foreach ($users as $userData) {
    $user = new User();
    $user->setEmail($userData['email']);
    $this->entityManager->persist($user);
}
$this->entityManager->flush();  // One DB call for all
```

### Anti-Pattern: N+1 Queries (PERFORMANCE KILLER)
```php
// ❌ WRONG - N+1 queries
$users = $userRepository->findAll();
foreach ($users as $user) {
    echo $user->getPosts()->count();  // Separate query for EACH user!
}

// ✅ CORRECT - Fetch join
$users = $userRepository->createQueryBuilder('u')
    ->leftJoin('u.posts', 'p')
    ->addSelect('p')  // Load posts in single query
    ->getQuery()
    ->getResult();

foreach ($users as $user) {
    echo $user->getPosts()->count();  // No additional queries
}
```

## AI Self-Check (Verify BEFORE generating Doctrine code)

- [ ] Using attributes? (#[ORM\Entity], NOT @ORM\Entity)
- [ ] QueryBuilder for complex queries?
- [ ] Parameters for all user input? (setParameter)
- [ ] Single flush() after all persists?
- [ ] Fetch joins to avoid N+1? (addSelect)
- [ ] Transactions for multi-step operations?
- [ ] Cascade operations configured?
- [ ] Indexes on frequently queried fields?
- [ ] No raw SQL without params?
- [ ] Proper relationship mappings?

## Relationships

| Type | Annotation | Inverse Side |
|------|-----------|--------------|
| One-to-Many | `#[ORM\OneToMany]` | `mappedBy` |
| Many-to-One | `#[ORM\ManyToOne]` | `inversedBy` |
| Many-to-Many | `#[ORM\ManyToMany]` | `mappedBy` or `inversedBy` |
| One-to-One | `#[ORM\OneToOne]` | `mappedBy` or `inversedBy` |

## Console Commands

```bash
# Generate migration
php bin/console make:migration

# Run migrations
php bin/console doctrine:migrations:migrate

# Validate schema
php bin/console doctrine:schema:validate

# Show SQL
php bin/console doctrine:query:sql "SELECT * FROM users"
```

## Key Features

- **Attributes**: PHP 8+ entity mapping
- **QueryBuilder**: Type-safe query building
- **Migrations**: Version-controlled schema changes
- **Lazy Loading**: On-demand relationship loading
- **UnitOfWork**: Change tracking and batching

## Key Concepts

- **Persist**: Add entity to UnitOfWork
- **Flush**: Execute all pending database operations
- **Detach**: Remove entity from management
- **Merge**: Reattach detached entity
- **Clear**: Clear all managed entities
