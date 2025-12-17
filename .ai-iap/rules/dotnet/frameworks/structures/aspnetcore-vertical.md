# ASP.NET Core Vertical Slice Architecture

> **Scope**: Use this structure for .NET apps organized by feature (vertical slices).
> **Precedence**: When loaded, this structure overrides any default folder organization from the base ASP.NET Core rules.

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

