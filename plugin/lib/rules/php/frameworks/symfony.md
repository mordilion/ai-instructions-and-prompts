# Symfony Framework

> **Scope**: Symfony 6+ applications  
> **Applies to**: PHP files in Symfony projects
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use attributes for routing (PHP 8+)
> **ALWAYS**: Use constructor autowiring
> **ALWAYS**: Return Response objects
> **ALWAYS**: Use Doctrine ORM
> **ALWAYS**: Use serializer groups
> 
> **NEVER**: Use annotations (deprecated)
> **NEVER**: Use service locator pattern
> **NEVER**: Return raw arrays
> **NEVER**: Query database in controllers
> **NEVER**: Use global state

## Core Patterns

```php
// Controller with Attributes
#[Route('/api/users')]
class UserController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function index(): JsonResponse {
        return $this->json($this->userService->getAll());
    }
}

// Entity (Doctrine)
#[ORM\Entity, ORM\Table(name: 'users')]
class User {
    #[ORM\Id, ORM\GeneratedValue, ORM\Column]
    private ?int $id = null;
    
    #[ORM\Column(length: 255), Groups(['user:read'])]
    private string $name;
}

// Service
class UserService {
    public function create(UserDto $dto): User {
        $user = new User();
        $user->setName($dto->name);
        $this->em->persist($user);
        $this->em->flush();
        return $user;
    }
}

// DTO with Validation
class UserDto {
    public function __construct(
        #[Assert\NotBlank, Assert\Length(min: 3)]
        public string $name,
    ) {}
}

// Repository
class UserRepository extends ServiceEntityRepository {
    public function findByEmail(string $email): ?User {
        return $this->createQueryBuilder('u')
            ->where('u.email = :email')
            ->setParameter('email', $email)
            ->getQuery()
            ->getOneOrNullResult();
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Annotations** | `@Route("/users")` | `#[Route('/users')]` |
| **Service Locator** | `$this->get()` | Constructor injection |
| **Raw Arrays** | `return ['data' => ...]` | `return $this->json()` |
| **Controller Queries** | Query in controller | Repository/Service |

## AI Self-Check

- [ ] Using attributes?
- [ ] Constructor autowiring?
- [ ] Returning Response objects?
- [ ] Doctrine ORM?
- [ ] Serializer groups?
- [ ] No annotations?
- [ ] No service locator?
- [ ] Validation with attributes?
- [ ] Thin controllers?
- [ ] Repository for queries?

## Key Features

| Feature | Purpose |
|---------|---------|
| Attributes | Routing, validation |
| Autowiring | DI |
| Doctrine | ORM |
| Serializer | API responses |
| ParamConverter | Entity injection |

## Best Practices

**MUST**: Attributes, autowiring, Response objects, Doctrine, serializer groups
**SHOULD**: DTOs, validation attributes, repositories, thin controllers
**AVOID**: Annotations, service locator, raw arrays, controller queries
