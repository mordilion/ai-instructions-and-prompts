# Laminas Mezzio Framework

> **Scope**: Apply these rules when working with Laminas Mezzio (PSR-15 middleware).

## Overview

Laminas Mezzio is a PSR-15 middleware microframework. It's lightweight, standards-compliant, and perfect for APIs and microservices.

**Key Capabilities**:
- **PSR-15 Middleware**: Standard middleware pattern
- **PSR-7 HTTP Messages**: Immutable request/response
- **Micro-Framework**: Minimal, flexible
- **DI Container**: Multiple container support
- **Pipeline Architecture**: Layered middleware processing

## Best Practices

**MUST**:
- Use RequestHandlerInterface for handlers
- Use MiddlewareInterface for middleware
- Return ResponseInterface (NO echo/print)
- Use factories for ALL dependencies
- Use immutable request attributes

**SHOULD**:
- One handler per endpoint
- Use pipeline for global middleware
- Use ConfigProvider for DI
- Use route-specific middleware

**AVOID**:
- Mutable request modifications
- Logic in handlers (use services)
- Direct instantiation (use factories)
- Bypassing middleware pipeline

## 1. Project Structure
```
src/App/
├── src/
│   ├── Handler/          # Request handlers
│   ├── Middleware/
│   └── ConfigProvider.php
├── templates/
config/
├── pipeline.php          # Middleware pipeline
├── routes.php
└── autoload/
```

## 2. Request Handlers (PSR-15)
- Implement `RequestHandlerInterface`
- One handler per endpoint
- Return `ResponseInterface`

```php
class UserHandler implements RequestHandlerInterface
{
    public function __construct(private UserService $userService) {}

    public function handle(ServerRequestInterface $request): ResponseInterface
    {
        $id = $request->getAttribute('id');
        $user = $this->userService->findById((int) $id);
        return $user ? new JsonResponse($user) : new JsonResponse(['error' => 'Not found'], 404);
    }
}
```

## 3. Middleware
```php
class AuthMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $token = $request->getHeaderLine('Authorization');
        if (!$token) {
            return new JsonResponse(['error' => 'Unauthorized'], 401);
        }
        return $handler->handle($request->withAttribute('user', $this->validate($token)));
    }
}
```

## 4. Routes
```php
return static function (Application $app): void {
    $app->get('/api/users', UserListHandler::class, 'users.list');
    $app->get('/api/users/{id:\d+}', UserHandler::class, 'users.get');
    $app->post('/api/users', [AuthMiddleware::class, CreateUserHandler::class], 'users.create');
};
```

## 5. Pipeline
```php
return static function (Application $app): void {
    $app->pipe(ErrorHandler::class);
    $app->pipe(RouteMiddleware::class);
    $app->pipe(DispatchMiddleware::class);
    $app->pipe(NotFoundHandler::class);
};
```

## 6. ConfigProvider (DI)
```php
class ConfigProvider
{
    public function __invoke(): array
    {
        return [
            'dependencies' => [
                'factories' => [
                    UserHandler::class => UserHandlerFactory::class,
                ],
            ],
        ];
    }
}
```

## 7. Best Practices
- **PSR-7/PSR-15**: Strict adherence to PSR standards
- **Immutable Requests**: Use `withAttribute()` to pass data
- **Pipeline Order**: Error handling → Routing → Dispatch → NotFound
- **Single Action**: One handler per HTTP endpoint
