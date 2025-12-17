# Doctrine ORM

> **Scope**: Apply these rules when using Doctrine ORM in PHP projects.

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

## 6. Best Practices
- **Flush Strategically**: Don't flush after every persist
- **Lazy Loading**: Be aware of N+1 queries, use joins
- **Clear EntityManager**: For long-running processes
- **Indexes**: Add `#[ORM\Index]` for query performance
- **IEntityTypeConfiguration**: Separate config files for complex entities
