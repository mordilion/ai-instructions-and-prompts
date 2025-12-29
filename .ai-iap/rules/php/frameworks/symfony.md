# Symfony Framework

> **Scope**: Apply these rules when working with Symfony 6+ applications
> **Applies to**: PHP files in Symfony projects
> **Extends**: php/architecture.md, php/code-style.md
> **Precedence**: Framework rules OVERRIDE PHP rules for Symfony-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use attributes for routing (PHP 8+, NOT annotations)
> **ALWAYS**: Use dependency injection via constructor autowiring
> **ALWAYS**: Return Response objects from controllers (NOT arrays)
> **ALWAYS**: Use Doctrine ORM for database access (type-safe)
> **ALWAYS**: Use serializer groups for API responses
> 
> **NEVER**: Use annotations (deprecated, use attributes)
> **NEVER**: Use service locator pattern (inject dependencies)
> **NEVER**: Return raw arrays from controllers (use Response/JsonResponse)
> **NEVER**: Query database in controllers (use repositories/services)
> **NEVER**: Use global state or static methods

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Attributes | Routing, validation (PHP 8+) | `#[Route]`, `#[Assert]` |
| Autowiring | Dependency injection | Constructor injection, `services.yaml` |
| ParamConverter | Entity from route params | `User $user` in controller params |
| Serializer Groups | Control API output | `context: ['groups' => ['user:read']]` |
| AbstractController | Controllers | `extends AbstractController` |

## Core Patterns

### Controller with Attributes
```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/users', name: 'api_user_')]
class UserController extends AbstractController
{
    public function __construct(
        private UserService $userService
    ) {}
    
    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $users = $this->userService->findAll();
        return $this->json($users, context: ['groups' => ['user:read']]);
    }
    
    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(User $user): JsonResponse  // ParamConverter
    {
        return $this->json($user, context: ['groups' => ['user:read']]);
    }
}
```

### Service with Autowiring
```php
<?php

namespace App\Service;

use App\Repository\UserRepository;

class UserService
{
    public function __construct(
        private UserRepository $userRepository,
        private MailerInterface $mailer
    ) {}  // Autowired by Symfony
    
    public function create(array $data): User
    {
        $user = new User();
        $user->setEmail($data['email']);
        $user->setName($data['name']);
        
        $this->userRepository->save($user);
        $this->mailer->send(/* welcome email */);
        
        return $user;
    }
}
```

### Entity with Attributes
```php
<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;

#[ORM\Entity(repositoryClass: UserRepository::class)]
#[ORM\Table(name: 'users')]
class User
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['user:read'])]
    private ?int $id = null;
    
    #[ORM\Column(length: 180, unique: true)]
    #[Groups(['user:read'])]
    private string $email;
    
    #[ORM\Column]
    private string $password;  // Not in groups = not serialized
    
    #[ORM\Column]
    #[Groups(['user:read'])]
    private \DateTimeImmutable $createdAt;
    
    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
    }
}
```

### Form Type
```php
<?php

namespace App\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\EmailType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Validator\Constraints as Assert;

class UserType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('email', EmailType::class, [
                'constraints' => [
                    new Assert\NotBlank(),
                    new Assert\Email(),
                ],
            ])
            ->add('name', null, [
                'constraints' => [
                    new Assert\NotBlank(),
                    new Assert\Length(min: 2, max: 100),
                ],
            ]);
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Using Annotations** | `@Route("/users")` | `#[Route('/users')]` | Annotations deprecated |
| **Service Locator** | `$this->container->get()` | Constructor injection | Anti-pattern |
| **Raw Arrays** | `return ['data' => $users];` | `return $this->json($users)` | No Response object |
| **DB in Controller** | `$em->getRepository()->find()` | Inject service/repository | Breaks separation |
| **No Serializer Groups** | Expose all entity fields | Use `#[Groups]` | Security risk |

### Anti-Pattern: Annotations (DEPRECATED)
```php
// ❌ WRONG - Annotations (deprecated)
/**
 * @Route("/users", name="user_list")
 */
public function list() {}

// ✅ CORRECT - Attributes (PHP 8+)
#[Route('/users', name: 'user_list')]
public function list(): Response {}
```

### Anti-Pattern: Service Locator (ANTI-PATTERN)
```php
// ❌ WRONG - Service locator
public function create(Request $request): Response
{
    $userService = $this->container->get('app.user_service');  // BAD!
    $user = $userService->create($request->request->all());
    return $this->json($user);
}

// ✅ CORRECT - Constructor injection
public function __construct(
    private UserService $userService
) {}

public function create(Request $request): Response
{
    $user = $this->userService->create($request->request->all());
    return $this->json($user);
}
```

## AI Self-Check (Verify BEFORE generating Symfony code)

- [ ] Using attributes? (#[Route], NOT @Route annotations)
- [ ] Constructor injection for dependencies?
- [ ] Returning Response objects? (JsonResponse, Response)
- [ ] Using serializer groups for API responses?
- [ ] Doctrine entities with attributes?
- [ ] No database queries in controllers?
- [ ] ParamConverter for entity params?
- [ ] Form types for validation?
- [ ] Autowiring enabled in services.yaml?
- [ ] Following Symfony best practices?

## Configuration

```yaml
# config/services.yaml
services:
    _defaults:
        autowire: true
        autoconfigure: true

    App\:
        resource: '../src/'
        exclude:
            - '../src/DependencyInjection/'
            - '../src/Entity/'
            - '../src/Kernel.php'
```

## Console Commands

```bash
# Create controller
symfony console make:controller UserController

# Create entity
symfony console make:entity User

# Create migration
symfony console make:migration
symfony console doctrine:migrations:migrate

# Clear cache
symfony console cache:clear
```

## Key Features

- **Dependency Injection**: Autowiring, service container
- **Doctrine ORM**: Entity management, migrations
- **Serializer**: JSON/XML serialization with groups
- **Validator**: Constraint-based validation
- **Forms**: Form building and validation
- **Messenger**: Message queue/bus

## Key Libraries

- **doctrine/orm**: Database ORM
- **symfony/serializer**: Data serialization
- **symfony/validator**: Data validation
- **symfony/form**: Form handling
- **symfony/messenger**: Message bus
