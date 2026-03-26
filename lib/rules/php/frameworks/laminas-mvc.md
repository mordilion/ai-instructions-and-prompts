# Laminas MVC Framework

> **Scope**: Laminas MVC applications  
> **Applies to**: PHP files in Laminas MVC projects  
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use factories for ALL dependencies
> **ALWAYS**: Use Input Filters for validation
> **ALWAYS**: Return ViewModel from controllers
> **ALWAYS**: Use modules for organization
> **ALWAYS**: Use Table Gateway for database
> 
> **NEVER**: Use new in controllers (use factories)
> **NEVER**: Skip Input Filters
> **NEVER**: Put business logic in controllers
> **NEVER**: Direct database access in controllers
> **NEVER**: Skip module structure

**AVOID**:
- Direct instantiation (use factories)
- Logic in controllers (use services)
- Missing input validation
- Bypassing service manager

## 1. Project Structure
```
module/Application/
├── config/module.config.php
├── src/
│   ├── Controller/
│   ├── Form/
│   ├── Model/
│   └── Service/
├── view/
└── Module.php
config/
├── application.config.php
└── autoload/
```

## 2. Controllers
- Extend `AbstractActionController`
- Use factories for dependency injection
- Return `ViewModel` for views, `JsonModel` for API

```php
class UserController extends AbstractActionController
{
    public function __construct(private UserService $userService) {}

    public function indexAction(): ViewModel
    {
        return new ViewModel(['users' => $this->userService->findAll()]);
    }

    public function viewAction(): ViewModel
    {
        $id = (int) $this->params()->fromRoute('id');
        $user = $this->userService->findById($id);
        if (!$user) return $this->redirect()->toRoute('user');
        return new ViewModel(['user' => $user]);
    }
}
```

## 3. Module Configuration
```php
return [
    'router' => ['routes' => [
        'user' => [
            'type' => Segment::class,
            'options' => [
                'route' => '/user[/:action[/:id]]',
                'defaults' => ['controller' => UserController::class, 'action' => 'index'],
            ],
        ],
    ]],
    'controllers' => ['factories' => [
        UserController::class => UserControllerFactory::class,
    ]],
    'service_manager' => ['factories' => [
        UserService::class => UserServiceFactory::class,
    ]],
];
```

## 4. Factory Pattern
```php
class UserControllerFactory
{
    public function __invoke(ContainerInterface $container): UserController
    {
        return new UserController($container->get(UserService::class));
    }
}
```

## 5. Forms & Validation
```php
class UserForm extends Form implements InputFilterProviderInterface
{
    public function __construct() {
        parent::__construct('user');
        $this->add(['name' => 'email', 'type' => 'email']);
    }

    public function getInputFilterSpecification(): array {
        return ['email' => ['required' => true, 'validators' => [['name' => 'EmailAddress']]]];
    }
}
```

## 6. Table Gateway (Database)
```php
class UserTable
{
    public function __construct(private TableGatewayInterface $tableGateway) {}
    public function fetchAll() { return $this->tableGateway->select(); }
    public function find(int $id) { return $this->tableGateway->select(['id' => $id])->current(); }
}
```

## 7. Best Practices
- **Factories**: Always use factories for DI
- **Input Filters**: Validate all user input
- **View Helpers**: Create helpers for reusable template logic
- **Event Manager**: Use for cross-cutting concerns

## AI Self-Check

- [ ] Factories for ALL dependencies?
- [ ] Input Filters for validation?
- [ ] ViewModel returned from controllers?
- [ ] Modules for organization?
- [ ] Table Gateway for database?
- [ ] Event Manager for cross-cutting concerns?
- [ ] View Helpers for template logic?
- [ ] No new in controllers?
- [ ] No skipped Input Filters?
- [ ] No business logic in controllers?
- [ ] No direct database access in controllers?
- [ ] module.config.php configured?
