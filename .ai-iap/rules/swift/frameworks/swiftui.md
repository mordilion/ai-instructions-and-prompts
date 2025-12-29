# SwiftUI Framework

> **Scope**: Apply these rules when working with SwiftUI applications
> **Applies to**: Swift files in SwiftUI projects (iOS 13+, macOS 10.15+)
> **Extends**: swift/architecture.md, swift/code-style.md
> **Precedence**: Framework rules OVERRIDE Swift rules for SwiftUI-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use @State for view-local state, @StateObject for owned ObservableObjects
> **ALWAYS**: Use @Binding for two-way data flow from parent
> **ALWAYS**: Use @EnvironmentObject for dependency injection (NOT singletons)
> **ALWAYS**: Extract subviews when body exceeds 10 lines (readability)
> **ALWAYS**: Use @Published for observable properties (enables view updates)
> 
> **NEVER**: Use @ObservedObject for view-owned objects (causes recreation)
> **NEVER**: Mutate state outside the main thread (causes crashes)
> **NEVER**: Create ObservableObject inside body (recreated every render)
> **NEVER**: Forget @Published on observable properties (breaks reactivity)
> **NEVER**: Use force unwrapping (!) in views (causes crashes)

## Pattern Selection

| Property Wrapper | Use When | Ownership | Keywords |
|------------------|----------|-----------|----------|
| @State | View-local simple values | View owns | `@State private var count = 0` |
| @StateObject | View-owned ObservableObject | View owns (survives re-renders) | `@StateObject var viewModel = VM()` |
| @ObservedObject | Passed-in ObservableObject | Parent owns | `@ObservedObject var viewModel: VM` |
| @Binding | Two-way binding to parent | Parent owns | `@Binding var isOn: Bool` |
| @EnvironmentObject | Dependency injection | Ancestor provides | `@EnvironmentObject var user: UserStore` |

## Core Patterns

### View with State & Binding
```swift
struct CounterView: View {
    @State private var count = 0  // View-local state
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
            
            ChildView(count: $count)  // Pass binding with $
        }
    }
}

struct ChildView: View {
    @Binding var count: Int  // Two-way binding to parent
    
    var body: some View {
        Button("Decrement") { count -= 1 }
    }
}
```

### ViewModel Pattern
```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []  // @Published = view updates
    @Published var isLoading = false
    
    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            users = try await UserAPI.fetchUsers()
        } catch {
            print("Error: \(error)")
        }
    }
}

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()  // View owns VM
    
    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
        .task { await viewModel.fetchUsers() }  // Async on appear
    }
}
```

### Environment Objects (Dependency Injection)
```swift
// App.swift
@main
struct MyApp: App {
    @StateObject private var userStore = UserStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userStore)  // Inject into hierarchy
        }
    }
}

// Any descendant view
struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore  // Access injected object
    
    var body: some View {
        Text("User: \(userStore.currentUser.name)")
    }
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Wrong Property Wrapper** | `@ObservedObject` for view-owned object | `@StateObject` for view-owned | Object recreated on re-render |
| **State on Main Thread** | Mutate `@State` from background | `@MainActor` or `DispatchQueue.main` | Crashes, purple runtime warnings |
| **Missing @Published** | Observable property without `@Published` | Add `@Published` to properties | View doesn't update |
| **VM in body** | `let vm = ViewModel()` in body | `@StateObject` or `@ObservedObject` | Recreated every render |
| **Force Unwrapping** | `user!.name` in views | Optional binding `if let`, `??` | Crashes |

### Anti-Pattern: Wrong Property Wrapper (COMMON ERROR)
```swift
// ❌ WRONG - @ObservedObject for view-owned (recreates on re-render)
struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()  // WRONG!
    var body: some View { ... }
}

// ✅ CORRECT - @StateObject for view-owned
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    var body: some View { ... }
}

// ✅ CORRECT - @ObservedObject for passed-in
struct ChildView: View {
    @ObservedObject var viewModel: ViewModel  // Parent owns
    var body: some View { ... }
}
```

### Anti-Pattern: Background State Mutation (CRASHES)
```swift
// ❌ WRONG - Mutate @State from background thread
@State private var data: [Item] = []

Task {
    let items = await fetchItems()
    data = items  // CRASH! Not on main thread
}

// ✅ CORRECT - Use @MainActor or DispatchQueue.main
@State private var data: [Item] = []

Task {
    let items = await fetchItems()
    await MainActor.run {
        data = items  // Safe on main thread
    }
}

// ✅ BETTER - @MainActor on ViewModel
@MainActor
class ViewModel: ObservableObject {
    @Published var data: [Item] = []
    
    func fetch() async {
        data = await fetchItems()  // Already on main thread
    }
}
```

## AI Self-Check (Verify BEFORE generating SwiftUI code)

- [ ] Using @StateObject for view-owned ObservableObjects? (NOT @ObservedObject)
- [ ] Using @State for view-local simple values?
- [ ] Using @Binding for two-way parent-child communication?
- [ ] Using @EnvironmentObject for dependency injection?
- [ ] All @Published properties in ObservableObject?
- [ ] State mutations on main thread? (@MainActor or DispatchQueue.main)
- [ ] No force unwrapping (!) in views?
- [ ] Subviews extracted when body > 10 lines?
- [ ] Using .task for async work?
- [ ] Lists use Identifiable protocol?

## View Lifecycle

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
            .onAppear { print("View appeared") }
            .onDisappear { print("View disappeared") }
            .task { await fetchData() }  // Async work, auto-cancelled
    }
}
```

## Navigation

```swift
// NavigationStack (iOS 16+)
NavigationStack {
    List(items) { item in
        NavigationLink(item.name, value: item)
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}

// NavigationLink (iOS 13+)
NavigationView {
    NavigationLink("Details", destination: DetailView())
}
```

## Key Modifiers

| Modifier | Purpose | Example |
|----------|---------|---------|
| .task | Async work on appear | `.task { await fetch() }` |
| .onChange | React to value changes | `.onChange(of: value) { }` |
| .sheet | Present modal | `.sheet(isPresented: $show) { }` |
| .alert | Show alert | `.alert("Title", isPresented: $show) { }` |
| .toolbar | Add toolbar items | `.toolbar { ToolbarItem { } }` |

## Key Libraries

- **Combine**: Reactive programming, publishers
- **@MainActor**: Ensure main thread execution
- **PreferenceKey**: Child-to-parent communication
- **ViewModifier**: Reusable view modifications
