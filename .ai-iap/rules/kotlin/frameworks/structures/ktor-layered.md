# Ktor Layered Architecture

> **Scope**: Apply to Ktor projects using traditional layered architecture
> **Applies to**: Kotlin files in Ktor layered projects
> **Extends**: kotlin/architecture.md, kotlin/frameworks/ktor.md
> **Precedence**: Structure rules OVERRIDE framework rules

## Structure Overview

```
src/main/kotlin/
├── Application.kt              # Entry point
├── plugins/                    # Ktor plugins
│   ├── Routing.kt
│   ├── Serialization.kt
│   └── Security.kt
├── routes/                     # Route definitions
│   ├── UserRoutes.kt
│   └── ProductRoutes.kt
├── controllers/                # Request handlers
│   ├── UserController.kt
│   └── ProductController.kt
├── services/                   # Business logic
│   ├── UserService.kt
│   └── ProductService.kt
├── repositories/               # Data access
│   ├── UserRepository.kt
│   └── ProductRepository.kt
├── models/                     # Domain models
│   ├── User.kt
│   └── Product.kt
├── dto/                        # DTOs for API
│   ├── UserDto.kt
│   └── CreateUserRequest.kt
└── config/                     # Configuration
    └── DatabaseConfig.kt
```

## Layer Responsibilities

| Layer | Purpose | Dependencies | Keywords |
|-------|---------|--------------|----------|
| Routes | Define endpoints | Controllers | `routing { }`, `get()`, `post()` |
| Controllers | Validate, call services | Services | `call.receive()`, `call.respond()` |
| Services | Business logic | Repositories | Business rules, orchestration |
| Repositories | Data access | Database | `transaction { }`, queries |
| Models | Domain entities | None | Data classes |
| DTOs | API contracts | Models | Request/Response objects |

## Critical Rules

> **ALWAYS**: Routes → Controllers → Services → Repositories (strict layering)
> **ALWAYS**: Return DTOs from controllers (NEVER domain models)
> **ALWAYS**: Keep controllers thin (only validation and service calls)
> **ALWAYS**: Use dependency injection (Koin or manual)
> **ALWAYS**: Transaction boundaries in service layer
> 
> **NEVER**: Skip layers (e.g., routes directly to repositories)
> **NEVER**: Business logic in controllers or routes
> **NEVER**: Return domain models in API responses
> **NEVER**: Database access outside repository layer
> **NEVER**: Circular dependencies between layers

## Implementation Pattern

| Layer | Responsibility | Pattern |
|-------|---------------|---------|
| **Routes** | Routing | `fun Route.userRoutes()` calls controller methods |
| **Controllers** | HTTP handling | `suspend fun(call: ApplicationCall)` + service injection |
| **Services** | Business logic | `suspend fun` with transactions, calls repository |
| **Repositories** | Data access | Exposed/Ktorm queries in transactions |

**Flow**: Route → Controller → Service (transaction) → Repository → Database

## Common Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Skip Layers** | Route calls repository directly | Route → Controller → Service → Repository |
| **Fat Controllers** | Business logic in controller | Move to service layer |
| **Expose Models** | Return domain `User` from API | Return `UserDto` |
| **Wrong Transaction Placement** | Transactions in controller | Transactions in service |

## AI Self-Check

- [ ] Strict layer flow: Routes → Controllers → Services → Repositories?
- [ ] Controllers only validate and call services?
- [ ] Business logic in service layer?
- [ ] Data access only in repository layer?
- [ ] Returns DTOs (NOT domain models)?
- [ ] Transactions in service layer?
- [ ] Dependency injection used?
- [ ] No circular dependencies?
- [ ] Each layer in correct directory?
- [ ] Single Responsibility per class?

## Dependency Injection

```kotlin
// Manual DI in Application.kt
fun Application.module() {
    val userRepository = UserRepository()
    val userService = UserService(userRepository)
    val userController = UserController(userService)
    
    routing {
        userRoutes(userController)
    }
}

// Or use Koin
val appModule = module {
    single { UserRepository() }
    single { UserService(get()) }
    single { UserController(get()) }
}
```

## Key Principles

- **Layering**: Strict one-way dependencies (top → bottom)
- **Separation**: Each layer has distinct responsibility
- **Testability**: Easy to mock dependencies
- **Maintainability**: Changes isolated to specific layers
