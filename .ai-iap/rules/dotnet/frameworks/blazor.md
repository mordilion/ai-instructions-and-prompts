# Blazor Framework

> **Scope**: Apply these rules when working with Blazor WebAssembly or Blazor Server applications.

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

## 8. JavaScript Interop
- **IJSRuntime**: For JS calls from C#.
- **Minimize Interop**: Keep in C# when possible.
- **Dispose**: Implement `IAsyncDisposable` for JS references.

