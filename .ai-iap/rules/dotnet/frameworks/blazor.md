# Blazor Framework

> **Scope**: Blazor WebAssembly and Blazor Server applications  
> **Applies to**: *.razor, *.cs files in Blazor projects  
> **Extends**: dotnet/architecture.md, dotnet/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use `[Parameter]` for component inputs
> **ALWAYS**: Use `EventCallback<T>` for component outputs
> **ALWAYS**: Use dependency injection for services
> **ALWAYS**: Use async Task for event handlers (not async void)
> **ALWAYS**: Implement IAsyncDisposable for cleanup
> 
> **NEVER**: Use static state in components
> **NEVER**: Use async void for event handlers
> **NEVER**: Forget to call StateHasChanged after async operations
> **NEVER**: Access services after disposal
> **NEVER**: Use SignalR client state in Blazor Server (already connected)

## Pattern Selection

### Hosting Model
**Use Blazor WebAssembly when**:
- Need offline capability
- Want client-side execution
- Can accept larger download size

**Use Blazor Server when**:
- Need small download size
- Want server-side execution
- Need direct database access

### State Management
**Use Component State when**:
- UI-only state (form input)
- Local to component

**Use Cascading Parameters when**:
- Shared UI state (theme, auth)
- Deep component trees

**Use Services when**:
- Application state
- Shared across pages

## Core Patterns

### Component with Parameters

```razor
@* UserCard.razor *@
@inject IUserService UserService

<div class="user-card">
    <h3>@User.Name</h3>
    <button @onclick="HandleDeleteAsync">Delete</button>
</div>

@code {
    [Parameter] public User User { get; set; } = null!;
    [Parameter] public EventCallback<int> OnDelete { get; set; }

    private async Task HandleDeleteAsync()
    {
        await UserService.DeleteAsync(User.Id);
        await OnDelete.InvokeAsync(User.Id);
    }
}
```

### Service Injection & Lifecycle

```csharp
@implements IAsyncDisposable
@inject IUserService UserService
@inject IJSRuntime JS

@code {
    private List<User> users = new();
    private CancellationTokenSource? cts;

    protected override async Task OnInitializedAsync()
    {
        cts = new CancellationTokenSource();
        users = await UserService.GetAllAsync(cts.Token);
    }

    public async ValueTask DisposeAsync()
    {
        cts?.Cancel();
        cts?.Dispose();
    }
}
```

## Hosting Models

| Aspect | Server | WebAssembly |
|--------|--------|-------------|
| **State** | Scoped per circuit | Singleton per tab |
| **DB Access** | Direct | Via API |
| **Offline** | No | Yes (PWA) |

## AI Self-Check

- [ ] Using `[Parameter]` for component inputs?
- [ ] Using `EventCallback<T>` for component outputs?
- [ ] Dependency injection for services (not static)?
- [ ] async Task for event handlers (not async void)?
- [ ] IAsyncDisposable implemented for cleanup?
- [ ] StateHasChanged called after async operations?
- [ ] EditForm for form handling?
- [ ] Virtualize for large lists?
- [ ] No static state in components?
- [ ] No services accessed after disposal?
- [ ] Hosting model appropriate (Server vs WASM)?
- [ ] Cascading parameters for deep trees?

