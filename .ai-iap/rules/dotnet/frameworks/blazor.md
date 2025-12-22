# Blazor Framework

> **Scope**: Apply these rules when working with Blazor WebAssembly or Blazor Server applications.

## Overview

Blazor enables building interactive web UIs using C# instead of JavaScript. Blazor WebAssembly runs in browser via WebAssembly; Blazor Server runs on server with SignalR connection.

**Key Capabilities**:
- **C# for Web**: Write frontend in C#/.NET
- **Component-Based**: Reusable Razor components
- **Two Hosting Models**: WebAssembly (client) or Server (SignalR)
- **Full .NET**: Access entire .NET ecosystem
- **Hot Reload**: Fast development cycle

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

## 1. Component Design
- **Single Responsibility**: One component, one purpose.
- **Parameters**: Use `[Parameter]` for parent-to-child data.
- **Cascading**: Use `CascadingParameter` for deep data (theme, auth).

```razor
@* ✅ Good *@
<UserCard User="@user" OnDelete="HandleDelete" />

@* ❌ Bad *@
<div class="user-card">
    @* 200 lines of inline HTML and logic *@
</div>
```

## 2. Component Structure
```
Components/
├── Layout/           # MainLayout, NavMenu
├── Shared/           # Reusable components
├── Pages/            # Routable components (@page)
└── Features/
    └── Users/
        ├── UserList.razor
        ├── UserCard.razor
        └── UserService.cs
```

## 3. State Management
- **Component State**: For UI-only state.
- **Cascading State**: For shared UI state (theme).
- **Services**: For application state (inject scoped/singleton services).
- **Fluxor**: For complex state with Redux pattern.

```csharp
// ✅ Good - Injected service
@inject IUserService UserService

// ❌ Bad - Static state
private static List<User> _users = new();
```

## 4. Event Handling
- **EventCallback**: For child-to-parent communication.
- **Async Handlers**: Use `async Task`, not `async void`.
- **Prevent Default**: Use `@onclick:preventDefault` when needed.

```razor
@* ✅ Good *@
<button @onclick="HandleClickAsync">Submit</button>

@code {
    private async Task HandleClickAsync()
    {
        await SaveAsync();
    }
}
```

## 5. Forms & Validation
- **EditForm**: Use with `DataAnnotationsValidator`.
- **InputBase Components**: `InputText`, `InputNumber`, etc.
- **Custom Validation**: Implement `ValidationAttribute`.

```razor
<EditForm Model="@model" OnValidSubmit="HandleSubmit">
    <DataAnnotationsValidator />
    <ValidationSummary />
    <InputText @bind-Value="model.Name" />
    <button type="submit">Save</button>
</EditForm>
```

## 6. Performance
- **Virtualization**: Use `<Virtualize>` for large lists.
- **ShouldRender**: Override to prevent unnecessary renders.
- **StateHasChanged**: Call only when needed (avoid in loops).
- **Lazy Loading**: Use `@onclick:stopPropagation` to prevent bubbling.

## 7. Blazor Server vs WASM
| Aspect | Server | WebAssembly |
|--------|--------|-------------|
| **State** | Scoped per circuit | Singleton per tab |
| **DB Access** | Direct | Via API |
| **Authentication** | Server-side | Token-based |
| **Offline** | No | Yes (PWA) |

## Best Practices

**MUST**:
- Use `[Parameter]` for component inputs
- Use `EventCallback` for component outputs  
- Use async Task (NO async void)
- Use dependency injection for services
- Implement `IAsyncDisposable` for cleanup

**SHOULD**:
- Use CommunityToolkit.Mvvm for MVVM
- Use EditForm for forms with validation
- Override ShouldRender for performance
- Use Virtualize for large lists
- Use cascading parameters sparingly

**AVOID**:
- Static state (use services)
- Async void event handlers
- Forgetting to call StateHasChanged
- Too many components in one file
- Exposing implementation details

## 8. JavaScript Interop
- **IJSRuntime**: For JS calls from C#
- **Minimize Interop**: Keep in C# when possible
- **Dispose**: Implement `IAsyncDisposable` for JS references

