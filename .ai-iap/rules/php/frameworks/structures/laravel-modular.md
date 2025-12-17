# Laravel Modular Structure

> **Scope**: Use this structure for large Laravel apps organized by domain/module.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Laravel rules.

## Project Structure
```
app/
├── Modules/                    # Feature modules
│   ├── Auth/
│   │   ├── Controllers/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Requests/
│   │   ├── Resources/
│   │   ├── Routes/
│   │   │   ├── api.php
│   │   │   └── web.php
│   │   └── AuthServiceProvider.php
│   ├── Users/
│   │   ├── Controllers/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── Events/
│   │   ├── Listeners/
│   │   └── UsersServiceProvider.php
│   └── Orders/
├── Shared/                     # Cross-module utilities
│   ├── Traits/
│   ├── Services/
│   └── Helpers/
├── Console/
└── Exceptions/
```

## Module Service Provider
```php
class UsersServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/Routes/api.php');
        $this->loadMigrationsFrom(__DIR__ . '/Database/Migrations');
    }

    public function register(): void
    {
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
    }
}
```

## Register in config/app.php
```php
'providers' => [
    App\Modules\Auth\AuthServiceProvider::class,
    App\Modules\Users\UsersServiceProvider::class,
],
```

## Rules
- **Self-Contained Modules**: Each module has routes, controllers, models
- **Module Service Provider**: Register bindings and routes per module
- **No Cross-Module Model Access**: Use services/events for communication
- **Shared Only Generic**: Only truly reusable code in Shared/

## When to Use
- Large applications
- Multiple teams
- Domain-driven design
- Potential microservice extraction

