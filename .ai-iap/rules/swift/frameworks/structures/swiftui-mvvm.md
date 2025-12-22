# SwiftUI MVVM Structure

## Overview
MVVM pattern optimized for SwiftUI with @Published properties and @StateObject.

## Directory Structure

```
Sources/
├── Features/
│   └── User/
│       ├── Models/
│       │   └── User.swift
│       ├── ViewModels/
│       │   ├── UserListViewModel.swift
│       │   └── UserDetailViewModel.swift
│       ├── Views/
│       │   ├── UserListView.swift
│       │   ├── UserDetailView.swift
│       │   └── Components/
│       │       └── UserRow.swift
│       └── Services/
│           └── UserService.swift
```

## Implementation

### ViewModel
```swift
@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    
    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            users = try await service.fetchUsers()
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### View
```swift
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}
```

## Benefits
- Native SwiftUI integration
- Reactive updates
- Clean separation

## When to Use
- SwiftUI apps
- Modern iOS development

