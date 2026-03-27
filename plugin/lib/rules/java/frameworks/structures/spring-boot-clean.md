# Spring Boot Clean Architecture

> **Scope**: Spring Boot with Clean Architecture  
> **Use When**: Complex domain, framework independence

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, infrastructure, presentation
> **ALWAYS**: Domain has no Spring dependencies
> **ALWAYS**: Use repository interfaces
> **ALWAYS**: Dependency rule: inner → outer
> 
> **NEVER**: Import Spring in domain
> **NEVER**: Skip repository interfaces
> **NEVER**: Put business logic in controllers

## Structure

```
src/main/java/com/app/
├── domain/             # Pure business logic
│   ├── model/         # User, Order
│   ├── repository/    # Interfaces
│   ├── service/       # Domain services
│   └── exception/
├── application/        # Use cases
│   ├── usecase/       # CreateUserUseCase
│   ├── dto/
│   └── mapper/
├── infrastructure/     # External interfaces
│   ├── persistence/
│   │   ├── entity/    # JPA entities
│   │   └── repository/
│   ├── config/
│   └── external/
└── presentation/       # API layer
    ├── controller/
    ├── dto/
    └── exception/
```

## Core Patterns

| Layer | Pattern | Annotations |
|-------|---------|-------------|
| **Domain** | Immutable models + Repository interfaces | None (pure Java) |
| **Application** | Use cases with execute() method | @Service |
| **Infrastructure** | Repository adapters + JPA entities | @Repository + mapper |
| **Presentation** | REST controllers | @RestController + @Valid DTOs |

**Flow**: Controller → Use Case (@Service) → Repository Interface → Adapter (@Repository) → JPA

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Spring** | `@Entity` in domain | Pure Java |
| **No Interfaces** | Direct JPA | Repository interface |
| **Logic in Controller** | Business rules | Use cases |
| **Wrong Direction** | Domain imports API | API imports domain |

## AI Self-Check

- [ ] Domain layer pure Java?
- [ ] Repository interfaces in domain?
- [ ] Use cases for business logic?
- [ ] Dependency rule followed?
- [ ] No Spring in domain?
- [ ] DTOs for API boundary?
- [ ] Infrastructure implements interfaces?
- [ ] Mappers between entity and domain?

## Benefits

- ✅ Framework-independent business logic
- ✅ Testable (mock repositories)
- ✅ Clear boundaries
- ✅ Easy infrastructure changes

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability needs
- ❌ Simple CRUD
