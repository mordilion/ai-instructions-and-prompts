# Laminas MVC Framework

> **Scope**: Apply these rules when working with Laminas MVC applications.

## Overview

Laminas MVC (formerly Zend Framework) is an enterprise PHP framework with a modular architecture. It provides comprehensive components for large-scale applications.

**Key Capabilities**:
- **Modular Architecture**: Feature-based modules
- **Service Manager**: Powerful DI container
- **Event-Driven**: EventManager for decoupling
- **Enterprise**: Battle-tested for large apps
- **Component Library**: 60+ reusable components

## Best Practices

**MUST**:
- Use factories for ALL dependencies (NO new in controllers)
- Use Input Filters for validation
- Return ViewModel from controllers
- Use modules for organization
- Use Table Gateway for database

**SHOULD**:
- Use event manager for cross-cutting concerns
- Use view helpers for reusable template logic
- Use forms for complex validation
- Configure via module.config.php

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
