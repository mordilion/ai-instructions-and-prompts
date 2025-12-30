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
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

public partial class UserViewModel : ObservableObject
{
    private readonly IUserService _userService;
    
    [ObservableProperty]
    private string _username = "";
    
    [ObservableProperty]
    private bool _isLoading;
    
    public UserViewModel(IUserService userService) => _userService = userService;
    
    [RelayCommand(CanExecute = nameof(CanSave))]
    private async Task SaveAsync()
    {
        IsLoading = true;
        await _userService.SaveUserAsync(Username);
        IsLoading = false;
    }
    
    private bool CanSave() => !string.IsNullOrEmpty(Username);
}
```

### View (XAML)

```xml
<ContentPage xmlns:vm="clr-namespace:MyApp.ViewModels">
    <ContentPage.BindingContext>
        <vm:UserViewModel />
    </ContentPage.BindingContext>
    
    <VerticalStackLayout Padding="20">
        <Entry Text="{Binding Username}" Placeholder="Enter name" />
        <Button Text="Save" Command="{Binding SaveCommand}" />
        <ActivityIndicator IsRunning="{Binding IsLoading}" />
    </VerticalStackLayout>
</ContentPage>
```

### DI Setup

```csharp
// MauiProgram.cs
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts => {});
        
        builder.Services.AddSingleton<IUserService, UserService>();
        builder.Services.AddTransient<UserViewModel>();
        builder.Services.AddTransient<UserPage>();
        
        return builder.Build();
    }
}
```

### Shell Navigation

```csharp
// AppShell.xaml.cs
Routing.RegisterRoute("userdetails", typeof(UserDetailsPage));

// Navigate
await Shell.Current.GoToAsync("userdetails", new Dictionary<string, object>
{
    ["UserId"] = userId
});
```

### Platform-Specific Code

```csharp
#if ANDROID
using Android.Content;
#elif IOS
using UIKit;
#endif

public partial class PlatformService
{
    public string GetDeviceId()
    {
#if ANDROID
        return Android.Provider.Settings.Secure.GetString(
            Android.App.Application.Context.ContentResolver,
            Android.Provider.Settings.Secure.AndroidId);
#elif IOS
        return UIDevice.CurrentDevice.IdentifierForVendor.AsString();
#else
        return "Unknown";
#endif
    }
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
