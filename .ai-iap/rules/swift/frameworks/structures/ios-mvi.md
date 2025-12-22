# iOS MVI Structure

## Overview
Model-View-Intent provides unidirectional data flow with clear separation between user intents and state updates.

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

