# Symfony Framework

> **Scope**: Apply these rules when working with Symfony applications.

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

## 8. Events
- **Event Dispatcher**: For decoupled communication.
- **Event Subscribers**: Preferred over listeners.
- **Kernel Events**: For request/response lifecycle.

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

