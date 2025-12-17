# MediatR (CQRS Pattern)

> **Scope**: Apply these rules when using MediatR for CQRS in .NET.

## 1. Project Structure
```
Application/
├── Common/Behaviors/     # Pipeline behaviors
├── Users/
│   ├── Commands/CreateUser/
│   │   ├── CreateUserCommand.cs
│   │   ├── CreateUserCommandHandler.cs
│   │   └── CreateUserCommandValidator.cs
│   └── Queries/GetUser/
│       ├── GetUserQuery.cs
│       └── GetUserQueryHandler.cs
```

## 2. Commands (Write)
```csharp
public record CreateUserCommand(string Email, string Name) : IRequest<Result<int>>;

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, Result<int>>
{
    private readonly IDbContext _context;
    public CreateUserCommandHandler(IDbContext context) => _context = context;

    public async Task<Result<int>> Handle(CreateUserCommand request, CancellationToken ct)
    {
        var user = new User { Email = request.Email, Name = request.Name };
        _context.Users.Add(user);
        await _context.SaveChangesAsync(ct);
        return Result<int>.Success(user.Id);
    }
}
```

## 3. Queries (Read)
```csharp
public record GetUserQuery(int Id) : IRequest<UserDto?>;

public class GetUserQueryHandler : IRequestHandler<GetUserQuery, UserDto?>
{
    private readonly IDbContext _context;
    public GetUserQueryHandler(IDbContext context) => _context = context;

    public async Task<UserDto?> Handle(GetUserQuery request, CancellationToken ct)
        => await _context.Users
            .Where(u => u.Id == request.Id)
            .Select(u => new UserDto(u.Id, u.Email, u.Name))
            .FirstOrDefaultAsync(ct);
}
```

## 4. Validation Behavior
```csharp
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        var failures = _validators.Select(v => v.Validate(request)).SelectMany(r => r.Errors).ToList();
        if (failures.Any()) throw new ValidationException(failures);
        return await next();
    }
}
```

## 5. FluentValidation
```csharp
public class CreateUserCommandValidator : AbstractValidator<CreateUserCommand>
{
    public CreateUserCommandValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
    }
}
```

## 6. Controller Usage
```csharp
[HttpPost]
public async Task<ActionResult<int>> Create(CreateUserCommand command)
{
    var result = await _mediator.Send(command);
    return result.IsSuccess ? CreatedAtAction(nameof(Get), new { id = result.Value }, result.Value) : BadRequest(result.Error);
}
```

## 7. Best Practices
- **One Handler Per Request**: Single responsibility
- **Records for Requests**: Immutable command/query objects
- **DTOs for Queries**: Never return entities
- **Pipeline Behaviors**: Validation, logging, performance
