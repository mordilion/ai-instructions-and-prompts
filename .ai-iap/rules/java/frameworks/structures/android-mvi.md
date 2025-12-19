# Android MVI Structure

> **Scope**: This structure extends the Android framework rules. When selected, use this folder organization instead of the default.

## Project Structure
```
app/src/main/java/com/company/myapp/
├── ui/
│   ├── users/
│   │   ├── UserActivity.java
│   │   ├── UserViewModel.java
│   │   ├── UserIntent.java           # User actions
│   │   ├── UserState.java            # UI state
│   │   └── UserReducer.java          # State updates
│   └── orders/
│       ├── OrderActivity.java
│       ├── OrderViewModel.java
│       ├── OrderIntent.java
│       └── OrderState.java
├── data/
│   ├── repository/
│   │   ├── UserRepository.java
│   │   └── OrderRepository.java
│   ├── local/
│   │   └── database/
│   └── remote/
│       └── ApiService.java
└── di/
    └── AppModule.java
```

## Example: Intent & State
```java
// UserIntent - User actions
public sealed interface UserIntent {
    record LoadUser(long userId) implements UserIntent {}
    record RefreshUser() implements UserIntent {}
    record UpdateUser(String name) implements UserIntent {}
}

// UserState - UI state
public record UserState(
    User user,
    boolean loading,
    String error
) {
    public static UserState initial() {
        return new UserState(null, false, null);
    }
}

// ViewModel
public class UserViewModel extends ViewModel {
    private final MutableLiveData<UserState> state = new MutableLiveData<>(UserState.initial());
    
    public LiveData<UserState> getState() {
        return state;
    }
    
    public void processIntent(UserIntent intent) {
        switch (intent) {
            case UserIntent.LoadUser load -> loadUser(load.userId());
            case UserIntent.RefreshUser refresh -> refreshUser();
            case UserIntent.UpdateUser update -> updateUser(update.name());
        }
    }
}
```

## Rules
- **Unidirectional Data Flow**: Intent → ViewModel → State → View
- **Immutable State**: Use records for state
- **Single State**: One state object per screen
- **Predictable**: Same intent + state = same result

## When to Use
- Complex UI with many states
- Need for predictable state management
- Large teams requiring strict patterns
- Apps with complex user interactions

