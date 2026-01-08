# FastAPI Clean Architecture

> **Scope**: FastAPI with Clean Architecture (DDD-inspired)
> **Use When**: Complex domain, clear boundaries, high testability needs

## CRITICAL REQUIREMENTS

> **ALWAYS**: Separate domain, application, infrastructure, presentation layers
> **ALWAYS**: Domain entities are pure (no framework dependencies)
> **ALWAYS**: Use interfaces for external dependencies
> **ALWAYS**: Dependency rule: inner layers don't know outer layers
> 
> **NEVER**: Import infrastructure in domain
> **NEVER**: Put business logic in API layer
> **NEVER**: Skip repository interfaces

## Structure

```
src/
├── domain/              # Enterprise rules (pure Python)
│   ├── entities/       # Business objects
│   ├── repositories/   # Interfaces only
│   └── exceptions/
├── application/         # Use cases
│   ├── use_cases/
│   └── dto/
├── infrastructure/      # External interfaces
│   ├── database/
│   ├── services/
│   └── config/
└── presentation/        # API layer
    └── api/
```

## Core Patterns

| Layer | Pattern | Dependencies |
|-------|---------|--------------|
| **Domain** | Pure entities (@dataclass) + Abstract repositories (ABC) | None (business logic only) |
| **Application** | Use cases with execute() method | Domain entities + repository interfaces |
| **Infrastructure** | Repository implementations (SQLAlchemy, etc.) | Domain interfaces + external libs |
| **Presentation** | FastAPI routers with Depends() | Use cases (injected) + DTOs |

**Flow**: API → Use Case → Repository → Database

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Domain Depends on Infra** | Import SQLAlchemy in domain | Pure Python entities |
| **Logic in API** | Business rules in router | Use cases |
| **No Interfaces** | Direct DB access | Repository interface |
| **Wrong Direction** | Domain imports API | API imports domain |

## AI Self-Check

- [ ] Domain layer pure (no framework imports)?
- [ ] Repository interfaces in domain?
- [ ] Use cases in application layer?
- [ ] Dependency rule followed?
- [ ] DTOs for API boundary?
- [ ] No business logic in routers?
- [ ] Infrastructure implements interfaces?
- [ ] Testable without DB?

## Benefits

- ✅ Testable (mock repositories)
- ✅ Framework-independent business logic
- ✅ Clear boundaries
- ✅ Easy to change infrastructure

## When to Use

- ✅ Complex domain logic
- ✅ Long-term projects
- ✅ High testability requirements
- ❌ Simple CRUD apps (over-engineering)
