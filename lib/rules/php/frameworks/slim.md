# Slim Framework

> **Scope**: Slim PHP micro-framework  
> **Applies to**: PHP files in Slim projects  
> **Extends**: php/architecture.md, php/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use single-action classes (not traditional controllers)
> **ALWAYS**: Use PSR-7 Request/Response (not echo/print)
> **ALWAYS**: Use middleware for cross-cutting concerns
> **ALWAYS**: Use DI container for dependencies
> **ALWAYS**: Return Response objects
> 
> **NEVER**: Use echo/print (return Response)
> **NEVER**: Put logic in actions (use services)
> **NEVER**: Direct database access in actions
> **NEVER**: Fat actions (delegate to services)
> **NEVER**: Skip input validation

## 1. Project Structure
```
src/
├── Actions/           # Request handlers (one per endpoint)
├── Middleware/
├── Domain/            # Business logic
└── Infrastructure/
public/index.php
app/
├── dependencies.php   # DI container
├── middleware.php
├── routes.php
└── settings.php
```

## 2. Actions (Single-Action Controllers)
- **One class per endpoint** with `__invoke()` method
- Inject dependencies via constructor
- Return PSR-7 Response

```php
class GetUserAction
{
    public function __construct(private UserService $userService) {}

    public function __invoke(Request $request, Response $response, array $args): Response
    {
        $user = $this->userService->findById((int) $args['id']);
        if (!$user) {
            return $response->withStatus(404)->withJson(['error' => 'Not found']);
        }
        return $response->withJson($user);
    }
}
```

## 3. Routes
```php
$app->group('/api', function (RouteCollectorProxy $group) {
    $group->get('/users', ListUsersAction::class);
    $group->get('/users/{id:[0-9]+}', GetUserAction::class);
    $group->post('/users', CreateUserAction::class);
})->add(AuthMiddleware::class);
```

## 4. Middleware (PSR-15)
```php
class AuthMiddleware implements MiddlewareInterface
{
    public function process(Request $request, RequestHandlerInterface $handler): Response
    {
        $token = $request->getHeaderLine('Authorization');
        if (empty($token)) {
            return (new Response())->withStatus(401)->withJson(['error' => 'Unauthorized']);
        }
        return $handler->handle($request->withAttribute('user', $this->validate($token)));
    }
}
```

## 5. Dependency Injection (PHP-DI)
```php
return function (ContainerBuilder $containerBuilder) {
    $containerBuilder->addDefinitions([
        UserRepository::class => DI\autowire(UserRepositoryImpl::class),
        PDO::class => fn($c) => new PDO($c->get('settings')['db']['dsn']),
    ]);
};
```

## 6. Error Handling
- Use `addErrorMiddleware()` for global error handling
- Create custom `ErrorHandler` for consistent JSON responses
- Throw `HttpException` subclasses (`HttpNotFoundException`, etc.)

## 7. Best Practices
- **PSR-7/PSR-15**: Follow PSR standards
- **Thin Actions**: Delegate to services
- **Validate Input**: Use validation library (Respect, Rakit)
- **JSON Responses**: Use `withJson()` helper method

## AI Self-Check

- [ ] Single-action classes (not traditional controllers)?
- [ ] PSR-7 Request/Response (not echo/print)?
- [ ] Middleware for cross-cutting concerns?
- [ ] DI container for dependencies?
- [ ] Response objects returned?
- [ ] Route groups for organization?
- [ ] Input validation (Respect/Rakit)?
- [ ] Services for business logic?
- [ ] No echo/print?
- [ ] No logic in actions?
- [ ] No direct database access in actions?
- [ ] Error middleware configured?
