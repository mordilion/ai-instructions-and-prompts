# ASP.NET Core Clean Architecture

> **Scope**: Use this structure for enterprise .NET apps with clean architecture.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base ASP.NET Core rules.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Dependency Rule - Domain/Application MUST NOT depend on Infrastructure/WebApi
> **ALWAYS**: MediatR for application layer (CQRS)
> **ALWAYS**: Repository pattern in Infrastructure
> **ALWAYS**: DTOs for API contracts (not entities)
> **ALWAYS**: DependencyInjection.cs per layer
> 
> **NEVER**: Domain depends on Infrastructure
> **NEVER**: Domain depends on WebApi
> **NEVER**: Infrastructure depends on WebApi
> **NEVER**: Return entities from controllers
> **NEVER**: Put business logic in WebApi layer

## Project Structure
```
src/
├── Domain/                     # Enterprise business rules
│   ├── Entities/
│   │   └── User.cs
│   ├── ValueObjects/
│   ├── Enums/
│   ├── Events/
│   └── Exceptions/
├── Application/                # Application business rules
│   ├── Common/
│   │   ├── Behaviors/          # MediatR pipelines
│   │   ├── Interfaces/         # Abstractions
│   │   └── Models/
│   ├── Users/
│   │   ├── Commands/
│   │   │   └── CreateUser/
│   │   ├── Queries/
│   │   │   └── GetUser/
│   │   └── EventHandlers/
│   └── DependencyInjection.cs
├── Infrastructure/             # External concerns
│   ├── Persistence/
│   │   ├── ApplicationDbContext.cs
│   │   └── Configurations/
│   ├── Services/
│   ├── Identity/
│   └── DependencyInjection.cs
└── WebApi/                     # Presentation
    ├── Controllers/
    ├── Filters/
    ├── Middleware/
    └── Program.cs
```

## Dependency Rule
```
WebApi → Application → Domain
           ↓
      Infrastructure
```
- Domain has NO dependencies
- Application depends only on Domain
- Infrastructure implements Application interfaces
- WebApi references all, but only uses Application

## When to Use
- Enterprise applications
- Domain-driven design
- Long-lived projects
- Large teams

## AI Self-Check

- [ ] Dependency Rule enforced (Domain/Application ← Infrastructure)?
- [ ] Domain layer has no external dependencies?
- [ ] Application layer uses MediatR (CQRS)?
- [ ] Infrastructure implements Application interfaces?
- [ ] WebApi references all but only uses Application?
- [ ] DTOs for API contracts (not entities)?
- [ ] DependencyInjection.cs per layer?
- [ ] Repository pattern in Infrastructure?
- [ ] No business logic in WebApi layer?
- [ ] Feature-organized (Commands/Queries per feature)?

