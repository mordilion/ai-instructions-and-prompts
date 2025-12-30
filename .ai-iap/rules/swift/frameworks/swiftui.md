# SwiftUI Framework

> **Scope**: SwiftUI applications (iOS 13+, macOS 10.15+)  
> **Applies to**: Swift files in SwiftUI projects
> **Extends**: swift/architecture.md, swift/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use @State for view-local state
> **ALWAYS**: Use @StateObject for owned ObservableObjects
> **ALWAYS**: Use @Binding for two-way data flow
> **ALWAYS**: Use @EnvironmentObject for DI
> **ALWAYS**: Extract subviews when body > 10 lines
> 
> **NEVER**: Use @ObservedObject for view-owned objects
> **NEVER**: Mutate state off main thread
> **NEVER**: Create ObservableObject inside body
> **NEVER**: Forget @Published on properties
> **NEVER**: Force unwrap in views

## Property Wrappers

| Wrapper | Use When | Ownership |
|---------|----------|-----------|
| @State | View-local simple values | View owns |
| @StateObject | View-owned ObservableObject | View owns (survives re-renders) |
| @ObservedObject | Passed-in ObservableObject | Parent owns |
| @Binding | Two-way binding to parent | Parent owns |
| @EnvironmentObject | Dependency injection | Ancestor provides |

## Core Patterns

### State & Binding

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
            ChildView(count: $count)  // Pass binding
        }
    }
}

struct ChildView: View {
    @Binding var count: Int
    var body: some View {
        Button("Decrement") { count -= 1 }
    }
}
```

### ObservableObject & StateObject

```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    
    func loadUsers() async {
        isLoading = true
        users = await api.fetchUsers()
        isLoading = false
    }
}

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
        .task { await viewModel.loadUsers() }
    }
}
```

### EnvironmentObject

```swift
class UserStore: ObservableObject {
    @Published var currentUser: User?
}

@main
struct MyApp: App {
    @StateObject private var userStore = UserStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(userStore)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        Text(userStore.currentUser?.name ?? "Guest")
    }
}
```

### Async/Await

```swift
struct UsersView: View {
    @State private var users: [User] = []
    
    var body: some View {
        List(users, id: \.id) { user in
            Text(user.name)
        }
        .task {
            users = await fetchUsers()
        }
    }
    
    func fetchUsers() async -> [User] {
        // Async network call
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **ObservedObject** | `@ObservedObject var vm = VM()` | `@StateObject` |
| **Background Mutation** | `DispatchQueue.global { state = x }` | `@MainActor` |
| **Body Creation** | `let vm = VM()` in body | `@StateObject` |
| **No @Published** | `var users: [User]` | `@Published var users` |

## AI Self-Check

- [ ] @State for local state?
- [ ] @StateObject for owned objects?
- [ ] @Binding for two-way flow?
- [ ] @EnvironmentObject for DI?
- [ ] Subviews extracted?
- [ ] @Published on properties?
- [ ] Main thread mutations?
- [ ] No body creation?
- [ ] No force unwraps?

## Key Features

| Feature | Purpose |
|---------|---------|
| @State | Local state |
| @StateObject | Owned objects |
| @Binding | Two-way binding |
| @EnvironmentObject | DI |
| @Published | Reactivity |

## Best Practices

**MUST**: Correct property wrappers, @Published, main thread, extract subviews
**SHOULD**: async/await, @MainActor, preview providers
**AVOID**: @ObservedObject for owned, background mutations, force unwraps
