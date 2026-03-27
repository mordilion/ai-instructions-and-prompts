# SwiftUI MVI Structure

> **Scope**: MVI structure for SwiftUI  
> **Applies to**: SwiftUI projects with MVI  
> **Extends**: swift/frameworks/swiftui.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Intent enum for user actions
> **ALWAYS**: State struct for UI state
> **ALWAYS**: @Published state in ViewModel
> **ALWAYS**: Immutable state
> **ALWAYS**: Single state source
> 
> **NEVER**: Mutable state
> **NEVER**: Multiple state sources
> **NEVER**: Business logic in Views
> **NEVER**: Skip Intent pattern
> **NEVER**: Direct state mutation

## Directory Structure

```
Sources/
├── Features/
│   └── User/
│       ├── Intent.swift
│       ├── State.swift
│       ├── Effect.swift
│       ├── ViewModel.swift
│       └── Views/
│           └── UserView.swift
```

## Implementation

### Intent
```swift
enum UserIntent {
    case loadUsers
    case selectUser(UUID)
    case search(String)
}
```

### State
```swift
struct UserState {
    var users: [User] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    
    var filteredUsers: [User] {
        guard !searchQuery.isEmpty else { return users }
        return users.filter { $0.name.contains(searchQuery) }
    }
}
```

### ViewModel
```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published private(set) var state = UserState()
    let effectPublisher = PassthroughSubject<UserEffect, Never>()
    
    func processIntent(_ intent: UserIntent) {
        switch intent {
        case .loadUsers:
            Task { await loadUsers() }
        case .selectUser(let id):
            effectPublisher.send(.navigate(id))
        case .search(let query):
            state.searchQuery = query
        }
    }
}
```

### View
```swift
struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            SearchBar(text: Binding(
                get: { viewModel.state.searchQuery },
                set: { viewModel.processIntent(.search($0)) }
            ))
            
            List(viewModel.state.filteredUsers) { user in
                Button(user.name) {
                    viewModel.processIntent(.selectUser(user.id))
                }
            }
        }
        .task {
            viewModel.processIntent(.loadUsers)
        }
    }
}
```

## Benefits
- Predictable state
- Testable logic
- Clear data flow

## When to Use
- Complex state management
- Apps needing debugging support

## AI Self-Check

- [ ] Intent enum for actions?
- [ ] State struct for UI state?
- [ ] @Published state in ViewModel?
- [ ] Immutable state?
- [ ] Single state source?
- [ ] No mutable state?
- [ ] No multiple state sources?
- [ ] No business logic in Views?
- [ ] Intent pattern followed?
- [ ] State transitions predictable?

