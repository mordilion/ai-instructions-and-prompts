# Doctrine ORM

> **Scope**: Apply these rules when using Doctrine ORM in PHP projects.

## Overview

Doctrine is a powerful PHP ORM providing database abstraction, entity management, and a sophisticated query API. It follows the Data Mapper pattern (unlike Active Record in Laravel's Eloquent).

**Key Capabilities**:
- **Data Mapper**: Entities don't know about persistence
- **DQL (Doctrine Query Language)**: Object-oriented queries
- **Query Builder**: Programmatic query construction
- **Migrations**: Version-controlled schema changes
- **Unit of Work**: Automatic change tracking

## Pattern Selection

### Query Strategy
**Use DQL when**:
- Complex queries
- Need portability across databases
- Object-oriented syntax preferred

**Use Query Builder when**:
- Dynamic queries
- Conditional clauses
- Programmatic construction

**Use Repository Methods when**:
- Simple finds
- Reusable queries
- Want encapsulation

**AVOID**:
- Native SQL (unless absolutely necessary)
- Queries in controllers (use repositories)

### Relationship Loading
**Use Eager Loading when**:
- Always need related data
- Want to avoid N+1

**Use Lazy Loading when**:
- Rarely need related data
- Want performance

## 1. Entity Definition
```php
#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
class User
{
    #[ORM\Id, ORM\GeneratedValue, ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255, unique: true)]
    private string $email;

    #[ORM\OneToMany(targetEntity: Post::class, mappedBy: 'author', cascade: ['persist', 'remove'])]
    private Collection $posts;

    public function __construct(string $email) {
        $this->email = $email;
        $this->posts = new ArrayCollection();
    }

    // Getters/setters...
}
```

## 2. Repository
```php
class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry) {
        parent::__construct($registry, User::class);
    }

    public function findByEmail(string $email): ?User {
        return $this->findOneBy(['email' => $email]);
    }

    public function findActiveUsers(\DateTimeImmutable $since): array {
        return $this->createQueryBuilder('u')
            ->where('u.lastLoginAt >= :since')
            ->setParameter('since', $since)
            ->getQuery()->getResult();
    }

    public function save(User $user, bool $flush = true): void {
        $this->getEntityManager()->persist($user);
        if ($flush) $this->getEntityManager()->flush();
    }
}
```

## 3. Query Builder
```php
// Simple
$users = $this->createQueryBuilder('u')
    ->where('u.email LIKE :search')
    ->setParameter('search', '%' . $search . '%')
    ->getQuery()->getResult();

// With joins
$users = $this->createQueryBuilder('u')
    ->select('u', 'p')->leftJoin('u.posts', 'p')
    ->where('p.published = true')
    ->getQuery()->getResult();

// Pagination
$query = $this->createQueryBuilder('u')
    ->setFirstResult(($page - 1) * $limit)
    ->setMaxResults($limit)->getQuery();
$paginator = new Paginator($query);
```

## 4. Transactions
```php
$em->wrapInTransaction(function (EntityManagerInterface $em) use ($data) {
    $user = new User($data['email']);
    $em->persist($user);
    // Auto-flush at end
});
```

## 5. Migrations
```bash
php bin/console doctrine:migrations:diff    # Generate
php bin/console doctrine:migrations:migrate # Apply
```

## Best Practices

**MUST**:
- Use repositories for all queries (NO queries in controllers)
- Use Query Builder for complex queries (NO raw SQL)
- Use transactions for multi-step operations
- Add indexes on frequently queried fields
- Use eager loading to prevent N+1 queries

**SHOULD**:
- Batch persist operations (flush once)
- Use DQL for object-oriented queries
- Use pagination for large result sets
- Define cascade operations on relationships
- Clear EntityManager in long-running processes

**AVOID**:
- Flushing after every persist (batch instead)
- Lazy loading without considering N+1
- Missing indexes on foreign keys
- Raw SQL queries (use DQL/Query Builder)
- Entities in controllers (use repositories)

## Common Patterns

### Repository Pattern
```php
// ✅ GOOD: Repository with typed methods
class UserRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, User::class);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->findOneBy(['email' => $email]);
    }

    public function findActiveUsers(\DateTimeImmutable $since): array
    {
        return $this->createQueryBuilder('u')
            ->where('u.status = :status')
            ->andWhere('u.lastLoginAt >= :since')
            ->setParameter('status', 'active')
            ->setParameter('since', $since)
            ->orderBy('u.lastLoginAt', 'DESC')
            ->getQuery()
            ->getResult();
    }

    public function findWithPosts(int $userId): ?User
    {
        return $this->createQueryBuilder('u')
            ->select('u', 'p')  // Eager load posts
            ->leftJoin('u.posts', 'p')
            ->where('u.id = :id')
            ->setParameter('id', $userId)
            ->getQuery()
            ->getOneOrNullResult();
    }

    public function save(User $user, bool $flush = false): void
    {
        $this->getEntityManager()->persist($user);
        if ($flush) {
            $this->getEntityManager()->flush();
        }
    }
}

// ❌ BAD: Queries in controller
class UserController
{
    public function list(EntityManagerInterface $em)
    {
        $users = $em->createQueryBuilder()
            ->select('u')
            ->from(User::class, 'u')
            ->where('u.status = :status')
            ->getQuery()
            ->getResult();  // Query logic in controller
    }
}
```

### Efficient Query Builder
```php
// ✅ GOOD: Eager loading to prevent N+1
public function findUsersWithPosts(): array
{
    return $this->createQueryBuilder('u')
        ->select('u', 'p')  // SELECT both in one query
        ->leftJoin('u.posts', 'p')
        ->where('p.published = true')
        ->getQuery()
        ->getResult();
}

// Usage
foreach ($users as $user) {
    echo $user->getName();
    foreach ($user->getPosts() as $post) {  // NO extra query
        echo $post->getTitle();
    }
}

// ❌ BAD: N+1 queries
public function findUsers(): array
{
    return $this->findAll();  // Gets users only
}

// Usage
foreach ($users as $user) {
    foreach ($user->getPosts() as $post) {  // Query for EACH user!
        echo $post->getTitle();
    }
}
```

### Transactions
```php
// ✅ GOOD: Transaction for atomic operations
public function transferOwnership(User $from, User $to): void
{
    $this->entityManager->wrapInTransaction(
        function (EntityManagerInterface $em) use ($from, $to) {
            // All or nothing
            $posts = $em->getRepository(Post::class)
                ->findBy(['author' => $from]);

            foreach ($posts as $post) {
                $post->setAuthor($to);
            }

            $from->setPostCount(0);
            $to->setPostCount(count($posts));

            // Auto-flush at end
        }
    );
}

// ❌ BAD: No transaction (partial state possible)
public function transferOwnership(User $from, User $to): void
{
    $posts = $this->postRepository->findBy(['author' => $from]);
    
    foreach ($posts as $post) {
        $post->setAuthor($to);
        $this->entityManager->flush();  // If this fails midway, inconsistent!
    }
    
    $from->setPostCount(0);
    $to->setPostCount(count($posts));
    $this->entityManager->flush();
}
```

### Pagination
```php
// ✅ GOOD: Paginator for large result sets
use Doctrine\ORM\Tools\Pagination\Paginator;

public function findPaginated(int $page, int $limit): Paginator
{
    $query = $this->createQueryBuilder('u')
        ->orderBy('u.createdAt', 'DESC')
        ->setFirstResult(($page - 1) * $limit)
        ->setMaxResults($limit)
        ->getQuery();

    return new Paginator($query, $fetchJoinCollection: true);
}

// Usage
$paginator = $repository->findPaginated($page, 20);
$totalItems = count($paginator);
$users = iterator_to_array($paginator);

// ❌ BAD: Loading everything
public function findAll(): array
{
    return $this->findAll();  // Loads ALL users into memory!
}
```

### Entity Relationships
```php
// ✅ GOOD: Proper relationship configuration
#[Entity(repositoryClass: UserRepository::class)]
class User
{
    #[Id, GeneratedValue, Column]
    private ?int $id = null;

    #[Column(unique: true)]
    private string $email;

    #[OneToMany(
        targetEntity: Post::class,
        mappedBy: 'author',
        cascade: ['persist', 'remove'],  // Cascade operations
        orphanRemoval: true  // Remove orphaned posts
    )]
    private Collection $posts;

    #[ManyToMany(targetEntity: Role::class)]
    #[JoinTable(name: 'user_roles')]
    private Collection $roles;

    public function __construct(string $email)
    {
        $this->email = $email;
        $this->posts = new ArrayCollection();
        $this->roles = new ArrayCollection();
    }

    public function addPost(Post $post): self
    {
        if (!$this->posts->contains($post)) {
            $this->posts->add($post);
            $post->setAuthor($this);  // Maintain bidirectional relationship
        }
        return $this;
    }

    public function removePost(Post $post): self
    {
        if ($this->posts->removeElement($post)) {
            if ($post->getAuthor() === $this) {
                $post->setAuthor(null);
            }
        }
        return $this;
    }
}

#[Entity]
class Post
{
    #[Id, GeneratedValue, Column]
    private ?int $id = null;

    #[ManyToOne(targetEntity: User::class, inversedBy: 'posts')]
    #[JoinColumn(nullable: false, onDelete: 'CASCADE')]  // Database cascade
    private User $author;
}

// ❌ BAD: Missing cascade configuration
#[OneToMany(targetEntity: Post::class, mappedBy: 'author')]
private Collection $posts;  // No cascade - orphaned posts remain
```

### Batch Operations
```php
// ✅ GOOD: Batch persist and flush
public function createUsers(array $userData): void
{
    foreach ($userData as $data) {
        $user = new User($data['email']);
        $this->entityManager->persist($user);
    }
    
    $this->entityManager->flush();  // Single flush for all
}

// For large batches, batch flush
public function importUsers(array $userData): void
{
    $batchSize = 20;
    foreach ($userData as $i => $data) {
        $user = new User($data['email']);
        $this->entityManager->persist($user);
        
        if (($i % $batchSize) === 0) {
            $this->entityManager->flush();
            $this->entityManager->clear();  // Free memory
        }
    }
    
    $this->entityManager->flush();  // Flush remaining
}

// ❌ BAD: Flush after every persist
foreach ($userData as $data) {
    $user = new User($data['email']);
    $this->entityManager->persist($user);
    $this->entityManager->flush();  // Very slow!
}
```

## Common Anti-Patterns

**❌ Flushing in loops**:
```php
// BAD
foreach ($users as $user) {
    $user->setStatus('active');
    $em->flush();  // Flush per user - very slow
}
```

**✅ Batch flush**:
```php
// GOOD
foreach ($users as $user) {
    $user->setStatus('active');
}
$em->flush();  // Single flush
```

**❌ Missing indexes**:
```prisma
#[Entity]
class User
{
    #[Column]
    private string $email;  // Frequently queried but no index
}
```

**✅ Add indexes**:
```php
#[Entity]
#[Index(name: 'idx_email', columns: ['email'])]
class User
{
    #[Column(unique: true)]
    private string $email;
}
```

## 6. Best Practices
- **Flush Strategically**: Batch operations, flush once
- **Lazy Loading**: Be aware of N+1, use eager loading with joins
- **Clear EntityManager**: For long-running processes to free memory
- **Indexes**: Add `#[ORM\Index]` on frequently queried fields
- **Cascade Operations**: Define cascade behavior on relationships
