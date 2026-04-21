# .NET Code Style

> **Scope**: .NET/C# formatting and maintainability  
> **Applies to**: *.cs files  
> **Extends**: General code style, dotnet/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Enable nullable reference types
> **ALWAYS**: Use EditorConfig for style
> **ALWAYS**: Use async/await for I/O operations
> **ALWAYS**: Use var when type is obvious
> **ALWAYS**: Use expression-bodied members for single statements
> **ALWAYS**: Use `??` (null coalescing) and `??=` for null fallbacks
>
> **NEVER**: Block on async (.Result, .Wait())
> **NEVER**: Use async void (except event handlers)
> **NEVER**: Skip nullable annotations
> **NEVER**: Use underscores for local variables (private fields use _camelCase by convention)
> **NEVER**: Public fields (use properties)
> **NEVER**: Call the same method twice in one expression (extract to local variable)

## Naming Conventions

```csharp
// PascalCase for public members
public class UserService {}
public string UserName { get; set; }
public void GetUser() {}

// camelCase for private fields with underscore
private readonly IUserRepository _repository;
private string _userName;

// PascalCase for constants
public const int MaxAttempts = 3;
```

## Type Declarations

```csharp
// Use var when type is obvious
var users = new List<User>();
var count = 10;

// Explicit when not obvious
IUserRepository repository = new UserRepository();
```

## Methods

```csharp
// Async suffix for async methods
public async Task<User> GetUserAsync(int id)
{
    return await _repository.GetByIdAsync(id);
}

// Expression-bodied members
public int Double(int x) => x * 2;
public string Name => _name;
```

## Null Safety

```csharp
#nullable enable

// Nullable reference
public User? FindUser(int id) => users.Find(id);

// Null-coalescing
var name = user?.Name ?? "Anonymous";

// Null-conditional
var email = user?.Profile?.Email;
```

## Reduce Method Calls (Extract Variable + `??` / `??=`)

> **ALWAYS**: Extract repeated method calls into a local `var`.
> **ALWAYS**: Collapse null-check ternaries into `??`.

```csharp
// ❌ BAD: GetCompanyName() called 3 times
var displayName = customer.GetCompanyName() != null && customer.GetCompanyName() != ""
    ? customer.GetCompanyName()
    : customer.GetContactPerson();

// ✅ GOOD (null-only fallback): extract + ??
var companyName = customer.GetCompanyName();
var displayName = string.IsNullOrEmpty(companyName) ? customer.GetContactPerson() : companyName;

// ✅ GOOD (when empty string is a valid value): just ??
var displayName = customer.GetCompanyName() ?? customer.GetContactPerson();

// ✅ GOOD: ??= for lazy assignment
_cached ??= ComputeExpensive();
```

> **Note**: C# has no Elvis-style "falsy" operator. For "null OR empty" use `string.IsNullOrEmpty(...)` on an extracted variable.

## Best Practices

```csharp
// Use records for DTOs
public record UserDto(int Id, string Name);

// Init-only properties
public string Name { get; init; }

// Pattern matching
if (obj is User { Role: "Admin" } admin)
{
    // Use admin
}

// String interpolation
var message = $"User {name} created";
```

## AI Self-Check

- [ ] Nullable reference types enabled?
- [ ] EditorConfig configured?
- [ ] async/await for I/O operations?
- [ ] var when type is obvious?
- [ ] Expression-bodied members?
- [ ] PascalCase for public members?
- [ ] camelCase with underscore for private fields?
- [ ] No blocking on async (.Result, .Wait())?
- [ ] No async void (except event handlers)?
- [ ] No missing nullable annotations?
- [ ] No public fields (using properties)?
- [ ] Records for immutable data (C# 9+)?
- [ ] No method called twice in the same expression (extracted to variable)?
- [ ] `??` / `??=` used for null fallbacks instead of ternaries?
