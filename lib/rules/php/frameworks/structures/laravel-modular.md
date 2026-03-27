# Laravel Modular Structure

> **Scope**: Module-organized structure for Laravel  
> **Applies to**: Laravel projects with modular structure  
> **Extends**: php/frameworks/laravel.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Modules in app/Modules/
> **ALWAYS**: Each module self-contained (Controllers, Models, Services, Routes)
> **ALWAYS**: ServiceProvider per module
> **ALWAYS**: Shared folder for cross-module code
> **ALWAYS**: Modules independent (minimal coupling)
> 
> **NEVER**: Cross-module dependencies (use Shared/)
> **NEVER**: Split module across locations
> **NEVER**: Generic Services folder (module-specific)
> **NEVER**: Share state between modules directly
> **NEVER**: Deep nesting in modules

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

## AI Self-Check

- [ ] Modules in app/Modules/?
- [ ] Each module self-contained?
- [ ] ServiceProvider per module?
- [ ] Shared folder for cross-module code?
- [ ] Modules independent?
- [ ] Module routes in module folder?
- [ ] No cross-module dependencies (using Shared/)?
- [ ] No split modules across locations?
- [ ] No generic Services folder?
- [ ] ModuleServiceProvider registered?

