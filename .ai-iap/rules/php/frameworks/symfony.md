# Symfony Framework

> **Scope**: Apply these rules when working with Symfony applications.

## Overview

Symfony is a mature PHP framework providing reusable components and a full-stack solution for web applications. It emphasizes flexibility, best practices, and enterprise-grade features.

**Key Capabilities**:
- **Component-Based**: Reusable, decoupled components
- **Dependency Injection**: Powerful service container
- **Doctrine ORM**: Enterprise ORM integration
- **Flexibility**: Highly configurable
- **Long-Term Support**: LTS versions for stability

## Pattern Selection

### Controller Organization
**Use Attributes (PHP 8+) when**:
- Modern Symfony (5.2+)
- Want cleaner code
- Prefer convention over configuration

**Use YAML/XML when**:
- Complex routing logic
- Need centralized configuration

### Service Configuration
**Use Autowiring when** (recommended):
- Standard dependencies
- Following conventions
- Want less configuration

**Use Manual Configuration when**:
- Complex dependencies
- Need specific instances
- Third-party integrations

## 1. Project Structure
```
src/
├── Controller/
├── Entity/
├── Repository/
├── Service/
├── Form/
├── EventSubscriber/
├── Security/
└── DTO/
config/
├── packages/
├── routes/
└── services.yaml
```

## 2. Controllers
- **AbstractController**: Extend for common shortcuts.
- **Attributes**: Use PHP 8 attributes for routing.
- **ParamConverter**: Auto-convert route params to entities.
- **Response Types**: Return `Response`, `JsonResponse`, or use serializer.

```php
// ✅ Good
#[Route('/users', name: 'user_')]
class UserController extends AbstractController
{
    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(User $user): JsonResponse
    {
        return $this->json($user, context: ['groups' => ['user:read']]);
    }
}

// ❌ Bad
public function show(int $id, UserRepository $repo): Response
{
    $user = $repo->find($id);
    return new Response(json_encode($user));  // Manual serialization
}
```

## 3. Services
- **Autowiring**: Let Symfony inject dependencies automatically.
- **Service Tags**: Use for plugin systems, event subscribers.
- **Constructor Injection**: Standard pattern.

```yaml
# services.yaml - usually not needed with autowiring
services:
    _defaults:
        autowire: true
        autoconfigure: true
    
    App\:
        resource: '../src/'
```

## 4. Doctrine ORM
- **Entities**: Plain PHP objects with attributes/annotations.
- **Repositories**: Custom queries in repository classes.
- **Migrations**: Version-controlled schema changes.
- **DTOs**: Don't expose entities in APIs.

```php
#[Entity(repositoryClass: UserRepository::class)]
class User
{
    #[Id]
    #[GeneratedValue]
    #[Column]
    private ?int $id = null;

    #[Column(length: 255)]
    private string $email;
}
```

## 5. Forms
- **Form Types**: Dedicated classes for forms.
- **Data Class**: Bind to DTOs or entities.
- **Validation**: Use validation constraints on entities/DTOs.

```php
class UserType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('email', EmailType::class)
            ->add('password', PasswordType::class);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults(['data_class' => User::class]);
    }
}
```

## 6. Validation
- **Constraint Attributes**: On entity/DTO properties.
- **Custom Constraints**: Implement `Constraint` + `ConstraintValidator`.
- **Groups**: For context-specific validation.

```php
class CreateUserDTO
{
    #[Assert\NotBlank]
    #[Assert\Email]
    public string $email;

    #[Assert\NotBlank]
    #[Assert\Length(min: 8)]
    public string $password;
}
```

## 7. Security
- **Voters**: For authorization logic.
- **Authenticators**: Custom authentication (API tokens, etc.).
- **#[IsGranted]**: Attribute for route authorization.

```php
#[Route('/admin')]
#[IsGranted('ROLE_ADMIN')]
class AdminController extends AbstractController { }
```

## Best Practices

**MUST**:
- Use attributes for routing (PHP 8+, NO YAML in new code)
- Use constructor injection (NO property injection)
- Return typed responses (Response, JsonResponse)
- Use serialization groups for API responses
- Use ParamConverter for automatic entity loading

**SHOULD**:
- Use autowiring for service configuration
- Use voters for authorization logic
- Use event subscribers (NOT listeners)
- Use DTOs for form data
- Use validation constraints on entities/DTOs

**AVOID**:
- Manual entity loading (use ParamConverter)
- Exposing entities in API responses (use serialization groups)
- Property injection (unreliable)
- Manual JSON encoding (use serializer)
- Logic in controllers (use services)

## Common Patterns

### Controller with Attributes
```php
// ✅ GOOD: Attributes + ParamConverter + Serialization
#[Route('/api/users', name: 'api_user_')]
class UserController extends AbstractController
{
    public function __construct(
        private UserService $userService,
        private SerializerInterface $serializer
    ) {}

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(User $user): JsonResponse  // Auto-loaded
    {
        return $this->json($user, context: [
            'groups' => ['user:read']  // Control exposed fields
        ]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $dto = $this->serializer->deserialize(
            $request->getContent(),
            CreateUserDTO::class,
            'json'
        );

        $user = $this->userService->createUser($dto);
        
        return $this->json($user, Response::HTTP_CREATED, [], [
            'groups' => ['user:read']
        ]);
    }
}

// ❌ BAD: Manual loading, no type safety
class UserController extends AbstractController
{
    #[Route('/api/users/{id}')]
    public function show(int $id, EntityManagerInterface $em): Response
    {
        $user = $em->getRepository(User::class)->find($id);  // Manual
        if (!$user) {
            throw $this->createNotFoundException();
        }
        return new Response(json_encode($user));  // Manual serialization
    }
}
```

### Serialization Groups
```php
// ✅ GOOD: Control API exposure with groups
use Symfony\Component\Serializer\Annotation\Groups;

#[Entity]
class User
{
    #[Id, GeneratedValue, Column]
    #[Groups(['user:read'])]
    private ?int $id = null;

    #[Column(length: 255)]
    #[Groups(['user:read', 'user:write'])]
    private string $name;

    #[Column(length: 255, unique: true)]
    #[Groups(['user:read', 'user:write'])]
    private string $email;

    #[Column]
    private string $password;  // NO group - never exposed

    #[OneToMany(targetEntity: Post::class, mappedBy: 'author')]
    #[Groups(['user:read:with-posts'])]
    private Collection $posts;
}

// Controller
return $this->json($user, context: ['groups' => ['user:read']]);
// Returns: {id, name, email} - NO password

// ❌ BAD: Exposing everything
return $this->json($user);  // Exposes password!
```

### Service with DI
```php
// ✅ GOOD: Constructor injection with autowiring
class UserService
{
    public function __construct(
        private EntityManagerInterface $em,
        private PasswordHasherInterface $hasher,
        private EventDispatcherInterface $dispatcher
    ) {}  // Autowired automatically

    public function createUser(CreateUserDTO $dto): User
    {
        $user = new User(
            $dto->email,
            $this->hasher->hashPassword($user, $dto->password)
        );

        $this->em->persist($user);
        $this->em->flush();

        $this->dispatcher->dispatch(new UserCreatedEvent($user));

        return $user;
    }
}

// ❌ BAD: Property injection
class UserService
{
    #[Autowire]
    private EntityManagerInterface $em;  // Can be null at construction

    public function createUser($dto)  // No types
    {
        // ...
    }
}
```

### Voters for Authorization
```php
// ✅ GOOD: Voter for complex authorization
class PostVoter extends Voter
{
    const EDIT = 'POST_EDIT';
    const DELETE = 'POST_DELETE';

    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::EDIT, self::DELETE])
            && $subject instanceof Post;
    }

    protected function voteOnAttribute(
        string $attribute,
        mixed $subject,
        TokenInterface $token
    ): bool {
        $user = $token->getUser();
        if (!$user instanceof User) {
            return false;
        }

        /** @var Post $post */
        $post = $subject;

        return match($attribute) {
            self::EDIT => $this->canEdit($post, $user),
            self::DELETE => $this->canDelete($post, $user),
            default => false
        };
    }

    private function canEdit(Post $post, User $user): bool
    {
        return $user === $post->getAuthor() || $user->isAdmin();
    }

    private function canDelete(Post $post, User $user): bool
    {
        return $user->isAdmin();
    }
}

// Usage in controller
#[Route('/{id}/edit', name: 'edit', methods: ['PUT'])]
#[IsGranted('POST_EDIT', subject: 'post')]
public function edit(Post $post, Request $request): JsonResponse
{
    // User is authorized - voter checked
    // ...
}

// ❌ BAD: Authorization in controller
public function edit(Post $post, Request $request): JsonResponse
{
    if ($post->getAuthor() !== $this->getUser() && !$this->getUser()->isAdmin()) {
        throw $this->createAccessDeniedException();  // Repeated logic
    }
}
```

### Event Subscribers
```php
// ✅ GOOD: Event subscriber
class UserSubscriber implements EventSubscriberInterface
{
    public function __construct(
        private MailerInterface $mailer,
        private LoggerInterface $logger
    ) {}

    public static function getSubscribedEvents(): array
    {
        return [
            UserCreatedEvent::class => 'onUserCreated',
            UserDeletedEvent::class => ['onUserDeleted', -10],  // Priority
        ];
    }

    public function onUserCreated(UserCreatedEvent $event): void
    {
        $user = $event->getUser();
        
        $email = (new Email())
            ->to($user->getEmail())
            ->subject('Welcome!')
            ->html('<p>Welcome to our platform!</p>');

        $this->mailer->send($email);
        $this->logger->info('Welcome email sent', ['user_id' => $user->getId()]);
    }

    public function onUserDeleted(UserDeletedEvent $event): void
    {
        $this->logger->info('User deleted', ['user_id' => $event->getUserId()]);
    }
}

// ❌ BAD: Logic in controller
public function create(Request $request): JsonResponse
{
    $user = $this->userService->createUser($dto);
    
    // Sending email in controller (should be in subscriber)
    $this->mailer->send($email);
    $this->logger->info('User created');
    
    return $this->json($user);
}
```

## Common Anti-Patterns

**❌ Manual serialization**:
```php
// BAD
return new Response(json_encode($user));
```

**✅ Use serializer**:
```php
// GOOD
return $this->json($user, context: ['groups' => ['user:read']]);
```

**❌ Property injection**:
```php
// BAD
#[Autowire]
private EntityManagerInterface $em;  // Unreliable
```

**✅ Constructor injection**:
```php
// GOOD
public function __construct(private EntityManagerInterface $em) {}
```

## 8. Events
- **Event Dispatcher**: For decoupled communication
- **Event Subscribers**: Preferred over listeners (cleaner, type-safe)
- **Kernel Events**: For request/response lifecycle hooks

```php
class UserSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [UserCreatedEvent::class => 'onUserCreated'];
    }

    public function onUserCreated(UserCreatedEvent $event): void
    {
        // Send welcome email, etc.
    }
}
```

