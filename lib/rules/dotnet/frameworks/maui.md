# .NET MAUI Framework

> **Scope**: Multi-platform App UI for cross-platform mobile/desktop  
> **Applies to**: C# files using .NET MAUI
> **Extends**: dotnet/architecture.md, dotnet/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use MVVM pattern
> **ALWAYS**: Use Community Toolkit.Mvvm
> **ALWAYS**: Use DI for services
> **ALWAYS**: Use Shell for navigation
> **ALWAYS**: Handle platform differences
> 
> **NEVER**: Put logic in code-behind
> **NEVER**: Block UI thread
> **NEVER**: Use static state
> **NEVER**: Skip platform testing
> **NEVER**: Create memory leaks

## Core Patterns

### ViewModel (CommunityToolkit)

```csharp
public partial class UserViewModel : ObservableObject
{
    [ObservableProperty]
    private string _username = "";
    
    [RelayCommand(CanExecute = nameof(CanSave))]
    private async Task SaveAsync() => await _userService.SaveUserAsync(Username);
    
    private bool CanSave() => !string.IsNullOrEmpty(Username);
}
```

### View (XAML)

```xml
<Entry Text="{Binding Username}" />
<Button Text="Save" Command="{Binding SaveCommand}" />
<ActivityIndicator IsRunning="{Binding IsLoading}" />
```

### DI Setup

```csharp
builder.Services.AddSingleton<IUserService, UserService>();
builder.Services.AddTransient<UserViewModel>();
builder.Services.AddTransient<UserPage>();
```

### Shell Navigation

```csharp
Routing.RegisterRoute("userdetails", typeof(UserDetailsPage));
await Shell.Current.GoToAsync("userdetails", new Dictionary<string, object> { ["UserId"] = userId });
```

### Platform-Specific Code

```csharp
public partial class PlatformService
{
    public string GetDeviceId() =>
#if ANDROID
        Android.Provider.Settings.Secure.GetString(...);
#elif IOS
        UIDevice.CurrentDevice.IdentifierForVendor.AsString();
#endif
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Logic in Code-Behind** | Click handler logic | ViewModel command |
| **@ObservedObject** | Manual INotifyPropertyChanged | `[ObservableProperty]` |
| **Blocking UI** | `.Result` on Task | `async`/`await` |
| **Static State** | `public static User` | DI service |

## AI Self-Check

- [ ] Using MVVM?
- [ ] CommunityToolkit.Mvvm?
- [ ] DI configured?
- [ ] Shell navigation?
- [ ] Platform differences handled?
- [ ] No code-behind logic?
- [ ] Async operations?
- [ ] No static state?
- [ ] Event unsubscription?

## Key Features

| Feature | Purpose |
|---------|---------|
| CommunityToolkit.Mvvm | Boilerplate reduction |
| Shell | Navigation |
| DI | Service injection |
| Platform-specific | Native features |
| Data Binding | MVVM |

## Best Practices

**MUST**: MVVM, CommunityToolkit.Mvvm, DI, Shell, async
**SHOULD**: Platform-specific code, value converters, behaviors
**AVOID**: Code-behind logic, static state, blocking operations
