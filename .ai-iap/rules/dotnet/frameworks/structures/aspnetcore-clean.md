# ASP.NET Core Clean Architecture

> **Scope**: Use this structure for enterprise .NET apps with clean architecture.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base ASP.NET Core rules.

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

