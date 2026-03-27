# ASP.NET Core Vertical Slice Architecture

> **Scope**: Feature-organized structure for ASP.NET Core (vertical slices)  
> **Applies to**: ASP.NET Core projects with feature-first structure  
> **Extends**: dotnet/frameworks/aspnetcore.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: One file per feature operation (CreateUser.cs)
> **ALWAYS**: MediatR for request handling
> **ALWAYS**: Feature contains Command/Query + Handler + Endpoint
> **ALWAYS**: Shared folder for cross-cutting concerns
> **ALWAYS**: Keep features independent (minimal coupling)
> 
> **NEVER**: Share state between features (use Shared/)
> **NEVER**: Deep folder nesting (keep flat)
> **NEVER**: Controllers (use minimal APIs or feature endpoints)
> **NEVER**: Generic Services folder (feature-specific only)
> **NEVER**: Split feature across multiple files unnecessarily

## Project Structure
```
src/
├── Features/                   # Each feature = vertical slice
│   ├── Users/
│   │   ├── CreateUser.cs       # Command + Handler + Endpoint
│   │   ├── GetUser.cs          # Query + Handler + Endpoint
│   │   ├── UpdateUser.cs
│   │   ├── DeleteUser.cs
│   │   └── User.cs             # Entity
│   ├── Orders/
│   │   ├── CreateOrder.cs
│   │   ├── GetOrders.cs
│   │   └── Order.cs
│   └── Auth/
├── Shared/                     # Cross-cutting concerns
│   ├── Infrastructure/
│   │   └── AppDbContext.cs
│   ├── Behaviors/
│   └── Extensions/
└── Program.cs
```

## Single File Per Feature
```csharp
// Features/Users/CreateUser.cs
public record CreateUserCommand(string Email, string Name) : IRequest<int>;

public class CreateUserHandler : IRequestHandler<CreateUserCommand, int>
{
    public async Task<int> Handle(CreateUserCommand request, CancellationToken ct) { ... }
}

public class CreateUserEndpoint : ICarterModule
{
    public void AddRoutes(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/users", async (CreateUserCommand cmd, ISender sender) 
            => Results.Created($"/api/users/{await sender.Send(cmd)}", null));
    }
}
```

## Rules
- **One File Per Operation**: Request + Handler + Endpoint together
- **No Layers**: Each slice contains everything it needs
- **Minimal Abstractions**: Only abstract what's truly shared
- **Copy > Abstract**: Prefer duplication over wrong abstraction

## When to Use
- CQRS applications
- Rapid feature development
- Microservices
- When features rarely share code

## AI Self-Check

- [ ] One file per feature operation?
- [ ] MediatR for request handling?
- [ ] Feature contains Command/Query + Handler + Endpoint?
- [ ] Shared folder for cross-cutting concerns?
- [ ] Features independent (minimal coupling)?
- [ ] No shared state between features?
- [ ] Flat structure (not deep nesting)?
- [ ] No controllers (using minimal APIs or feature endpoints)?
- [ ] No generic Services folder?
- [ ] Features self-contained?

