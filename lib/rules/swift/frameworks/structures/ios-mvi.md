# iOS MVI Structure

> **Scope**: MVI structure for iOS  
> **Applies to**: iOS projects with MVI  
> **Extends**: swift/frameworks/ios.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Intent enum for user actions
> **ALWAYS**: State struct for UI state
> **ALWAYS**: Immutable state
> **ALWAYS**: Single state flow
> **ALWAYS**: ViewModel processes intents → updates state
> 
> **NEVER**: Mutable state
> **NEVER**: Multiple state sources
> **NEVER**: Business logic in ViewControllers
> **NEVER**: Skip Intent classes
> **NEVER**: Direct state mutation

## Directory Structure

```
Sources/
├── Features/
│   └── User/
│       ├── Models/
│       │   └── User.swift
│       ├── Intent/
│       │   └── UserIntent.swift
│       ├── State/
│       │   └── UserState.swift
│       ├── Effect/
│       │   └── UserEffect.swift
│       ├── ViewModel/
│       │   └── UserViewModel.swift
│       └── Views/
│           └── UserViewController.swift
```

## Implementation

### Intent
```swift
enum UserIntent {
    case loadUsers
    case selectUser(User)
    case retry
}
```

### State
```swift
struct UserState {
    var users: [User] = []
    var isLoading: Bool = false
    var error: Error?
}
```

### Effect
```swift
enum UserEffect {
    case navigateToDetail(User)
    case showError(String)
}
```

### ViewModel
```swift
class UserViewModel: ObservableObject {
    @Published private(set) var state = UserState()
    let effectPublisher = PassthroughSubject<UserEffect, Never>()
    
    func processIntent(_ intent: UserIntent) {
        switch intent {
        case .loadUsers:
            loadUsers()
        case .selectUser(let user):
            effectPublisher.send(.navigateToDetail(user))
        case .retry:
            loadUsers()
        }
    }
}
```

## Benefits
- Unidirectional data flow
- Predictable state management
- Time-travel debugging possible

## When to Use
- Complex state management needs
- Apps requiring predictable behavior

## AI Self-Check

- [ ] Intent enum for user actions?
- [ ] State struct for UI state?
- [ ] Immutable state?
- [ ] Single state flow?
- [ ] ViewModel processes intents?
- [ ] No mutable state?
- [ ] No multiple state sources?
- [ ] No business logic in ViewControllers?
- [ ] Intent pattern followed?
- [ ] State transitions clear?

