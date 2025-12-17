# Laravel Traditional Structure

> **Scope**: Use this structure for standard Laravel apps with default conventions.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base Laravel rules.

## Project Structure
```
app/
├── Console/
├── Exceptions/
├── Http/
│   ├── Controllers/
│   │   ├── Auth/
│   │   │   └── LoginController.php
│   │   ├── Api/
│   │   │   └── UserController.php
│   │   └── Web/
│   │       └── DashboardController.php
│   ├── Middleware/
│   ├── Requests/
│   │   ├── StoreUserRequest.php
│   │   └── UpdateUserRequest.php
│   └── Resources/
│       └── UserResource.php
├── Models/
│   ├── User.php
│   └── Order.php
├── Services/                   # Business logic (optional)
│   └── UserService.php
├── Repositories/               # Data access (optional)
│   └── UserRepository.php
├── Events/
├── Listeners/
├── Jobs/
├── Mail/
├── Notifications/
└── Policies/
routes/
├── api.php
├── web.php
└── console.php
```

## Controller Organization
```
Controllers/
├── Auth/           # Authentication controllers
├── Api/            # API controllers (versioned: Api/V1/)
└── Web/            # Web/blade controllers
```

## Rules
- **Follow Laravel Conventions**: Use default folders
- **Thin Controllers**: Move logic to Services or Actions
- **Form Requests**: Validation in dedicated classes
- **API Resources**: Transform models for API responses

## When to Use
- Small to medium applications
- Standard CRUD operations
- Solo developers
- Rapid development

