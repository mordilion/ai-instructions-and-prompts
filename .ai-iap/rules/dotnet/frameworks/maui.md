# .NET MAUI Framework

> **Scope**: Apply these rules when working with .NET MAUI cross-platform applications.

## Overview

.NET MAUI (Multi-platform App UI) is a cross-platform framework for creating native mobile and desktop apps with C# and XAML. Single codebase runs on Android, iOS, macOS, and Windows.

**Key Capabilities**:
- **Cross-Platform**: One codebase, multiple platforms
- **Native Performance**: Compiles to native code
- **MVVM Pattern**: Built-in data binding
- **Hot Reload**: Fast development cycle
- **Platform-Specific**: Access platform APIs

## Best Practices

**MUST**:
- Use MVVM pattern (ViewModels separate from Views)
- Use CommunityToolkit.Mvvm for boilerplate reduction
- Use dependency injection for services
- Handle platform differences gracefully
- Test on all target platforms

**SHOULD**:
- Use Shell for navigation
- Use data binding (NO code-behind logic)
- Use converters for UI transformations
- Use async/await for operations
- Use platform-specific code when needed

**AVOID**:
- Logic in code-behind (use ViewModels)
- Blocking UI thread
- Platform-specific code in shared layer
- Static state
- Memory leaks (unsubscribe events)

## 1. Project Structure
```
MyApp/
├── App.xaml(.cs)           # Application entry
├── AppShell.xaml(.cs)      # Shell navigation
├── MauiProgram.cs          # DI configuration
├── Platforms/              # Platform-specific code
│   ├── Android/
│   ├── iOS/
│   ├── MacCatalyst/
│   └── Windows/
├── Resources/
│   ├── Images/
│   ├── Fonts/
│   └── Styles/
├── Models/
├── ViewModels/
├── Views/
├── Services/
└── Converters/
```

## 2. MVVM Pattern
- **CommunityToolkit.Mvvm**: Use for boilerplate reduction.
- **ObservableProperty**: Auto-generate property changed.
- **RelayCommand**: Auto-generate commands.

```csharp
// ViewModels/MainViewModel.cs
public partial class MainViewModel : ObservableObject
{
    private readonly IUserService _userService;

    public MainViewModel(IUserService userService)
    {
        _userService = userService;
    }

    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(SaveCommand))]
    private string _name = string.Empty;

    [ObservableProperty]
    private bool _isBusy;

    [ObservableProperty]
    private string? _errorMessage;

    public bool CanSave => !string.IsNullOrWhiteSpace(Name) && !IsBusy;

    [RelayCommand(CanExecute = nameof(CanSave))]
    private async Task SaveAsync()
    {
        try
        {
            IsBusy = true;
            ErrorMessage = null;
            await _userService.SaveAsync(Name);
        }
        catch (Exception ex)
        {
            ErrorMessage = ex.Message;
        }
        finally
        {
            IsBusy = false;
        }
    }
}
```

## 3. Views (XAML)
- **Bindings**: Use `{Binding}` for MVVM.
- **x:DataType**: For compiled bindings (performance).
- **Styles**: Define in ResourceDictionary.

```xml
<!-- Views/MainPage.xaml -->
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             xmlns:vm="clr-namespace:MyApp.ViewModels"
             x:Class="MyApp.Views.MainPage"
             x:DataType="vm:MainViewModel">

    <VerticalStackLayout Padding="20" Spacing="10">
        <Entry Text="{Binding Name}"
               Placeholder="Enter name" />
        
        <Button Text="Save"
                Command="{Binding SaveCommand}" />
        
        <ActivityIndicator IsRunning="{Binding IsBusy}"
                          IsVisible="{Binding IsBusy}" />
        
        <Label Text="{Binding ErrorMessage}"
               TextColor="Red"
               IsVisible="{Binding ErrorMessage, Converter={StaticResource StringNotNullConverter}}" />
    </VerticalStackLayout>
</ContentPage>
```

## 4. Dependency Injection
```csharp
// MauiProgram.cs
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
            });

        // Services
        builder.Services.AddSingleton<IUserService, UserService>();
        builder.Services.AddSingleton<INavigationService, NavigationService>();

        // ViewModels
        builder.Services.AddTransient<MainViewModel>();
        builder.Services.AddTransient<DetailsViewModel>();

        // Views
        builder.Services.AddTransient<MainPage>();
        builder.Services.AddTransient<DetailsPage>();

        return builder.Build();
    }
}
```

## 5. Shell Navigation
```csharp
// AppShell.xaml.cs
public partial class AppShell : Shell
{
    public AppShell()
    {
        InitializeComponent();
        
        // Register routes
        Routing.RegisterRoute(nameof(DetailsPage), typeof(DetailsPage));
    }
}

// Navigation with parameters
await Shell.Current.GoToAsync($"{nameof(DetailsPage)}?id={user.Id}");

// Receive parameters
[QueryProperty(nameof(UserId), "id")]
public partial class DetailsViewModel : ObservableObject
{
    [ObservableProperty]
    private string _userId = string.Empty;

    partial void OnUserIdChanged(string value)
    {
        // Load user data
        LoadUserAsync(value);
    }
}
```

## 6. Platform-Specific Code
```csharp
// Conditional compilation
#if ANDROID
    // Android-specific code
#elif IOS
    // iOS-specific code
#endif

// Platform service
public partial class DeviceService
{
    public partial string GetDeviceId();
}

// Platforms/Android/DeviceService.cs
public partial class DeviceService
{
    public partial string GetDeviceId() =>
        Android.Provider.Settings.Secure.GetString(
            Android.App.Application.Context.ContentResolver,
            Android.Provider.Settings.Secure.AndroidId);
}
```

## 7. Best Practices
- **Compiled Bindings**: Use `x:DataType` for performance.
- **Async Commands**: Always use async for I/O operations.
- **Memory Management**: Unsubscribe from events in `OnDisappearing`.
- **Platform Checks**: Use `DeviceInfo.Platform` for runtime checks.
- **Accessibility**: Add `SemanticProperties` to controls.

## 8. Testing
```csharp
// Unit test ViewModel
[Fact]
public async Task SaveCommand_WhenNameValid_CallsService()
{
    var mockService = new Mock<IUserService>();
    var viewModel = new MainViewModel(mockService.Object) { Name = "John" };

    await viewModel.SaveCommand.ExecuteAsync(null);

    mockService.Verify(s => s.SaveAsync("John"), Times.Once);
}
```

