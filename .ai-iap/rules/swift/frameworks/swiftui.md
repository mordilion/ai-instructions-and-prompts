# SwiftUI Development

## Overview
SwiftUI: Apple's declarative UI framework introduced in 2019, replacing UIKit for all Apple platforms (iOS, macOS, watchOS, tvOS).
Data-driven with automatic UI updates when state changes. Compiles to native views on each platform.
Best for new iOS 13+ projects, cross-platform Apple apps, and when you want modern declarative UI.

## Views

### Basic Structure
```swift
struct UserView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.name).font(.headline)
            Text(user.email).font(.subheadline).foregroundColor(.secondary)
        }.padding()
    }
}
```

### Extract Subviews
```swift
struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserHeaderView(user: user)
                UserStatsView(user: user)
            }
        }
    }
}
```

## State Management

### @State
```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
        }
    }
}
```

### @StateObject
```swift
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .task { await viewModel.loadUsers() }
    }
}

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
            print(error)
        }
    }
}
```

### @ObservedObject & @EnvironmentObject
```swift
struct UserDetailView: View {
    @ObservedObject var viewModel: UserDetailViewModel
    @EnvironmentObject var authManager: AuthManager
}
```

### @Binding
```swift
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .textFieldStyle(.roundedBorder)
    }
}
```

## Lists & Collections

### List
```swift
struct UserListView: View {
    let users: [User]
    
    var body: some View {
        List(users) { user in
            NavigationLink(value: user) {
                UserRow(user: user)
            }
        }
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user)
        }
    }
}
```

### LazyVGrid
```swift
struct PhotoGridView: View {
    let photos: [Photo]
    private let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
```

## Navigation

### NavigationStack
```swift
struct AppRootView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            UserListView()
                .navigationDestination(for: User.self) { UserDetailView(user: $0) }
                .navigationDestination(for: Post.self) { PostDetailView(post: $0) }
        }
    }
}
```

### Sheets
```swift
struct ContentView: View {
    @State private var selectedUser: User?
    
    var body: some View {
        List(users) { user in
            Button(user.name) { selectedUser = user }
        }
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)
        }
    }
}
```

## Async Operations

### Task Modifier
```swift
struct UserDetailView: View {
    @StateObject private var viewModel: UserDetailViewModel
    
    var body: some View {
        content
            .task { await viewModel.loadUser() }
    }
}
```

### Refreshable
```swift
List(viewModel.users) { user in
    UserRow(user: user)
}
.refreshable {
    await viewModel.refresh()
}
```

## Custom View Modifiers

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
```

## Environment Values

```swift
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct HomeView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Text("Hello").foregroundColor(theme.primaryColor)
    }
}
```

## Testing

```swift
@MainActor
class UserListViewModelTests: XCTestCase {
    func testLoadUsers_Success() async throws {
        let mockService = MockUserService()
        mockService.usersToReturn = [User(id: UUID(), name: "John", email: "john@test.com")]
        let viewModel = UserListViewModel(service: mockService)
        
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

### Preview Providers
```swift
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserView(user: User.sample)
            UserView(user: User.sample).preferredColorScheme(.dark)
        }
    }
}
```

## Pattern Selection

### State Management
**Use @State when**:
- Local view state (counter, toggle, text field value)
- State doesn't need to persist across view recreation
- Simple value types

**Use @StateObject when**:
- Creating ViewModel instance owned by the view
- Need ObservableObject with @Published properties
- State should survive view updates

**Use @ObservedObject when**:
- ViewModel passed from parent
- Not responsible for creating the object
- Observing external object

**Use @EnvironmentObject when**:
- Sharing data across many views
- Avoiding prop drilling
- App-wide state (theme, auth, settings)

## Best Practices

**MUST**:
- Use @StateObject for ViewModels (NOT @ObservedObject for owned objects)
- Mark ViewModels with @MainActor (UI updates must be on main thread)
- Keep views small (< 200 lines - extract subviews)
- Use PreviewProvider for all views (design-time feedback)
- Handle all states (loading, success, error, empty)

**SHOULD**:
- Use Equatable protocol on views with expensive rendering
- Extract computed properties to avoid recalculation
- Use `.task` modifier for async operations (auto-cancellation)
- Use private for view properties and subviews
- Use @Binding for two-way communication with parent

**AVOID**:
- Heavy computation in body (use @State with .onChange)
- @StateObject in subviews receiving ViewModel (use @ObservedObject)
- Force unwrapping (use optional binding or nil coalescing)
- Complex logic in views (move to ViewModel)
- God views (split if >200 lines)

## Common Patterns

### StateObject vs ObservedObject
```swift
// ✅ GOOD: @StateObject in parent (creates and owns)
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()  // Created here
    
    var body: some View {
        UserDetailView(viewModel: viewModel)  // Pass to child
    }
}

// ✅ GOOD: @ObservedObject in child (receives from parent)
struct UserDetailView: View {
    @ObservedObject var viewModel: UserListViewModel  // Passed in, not owned
}

// ❌ BAD: @StateObject in child
struct UserDetailView: View {
    @StateObject var viewModel: UserListViewModel  // WRONG: Creates new instance!
}
```

### Keep Views Small
```swift
// ✅ GOOD: Extracted subviews
struct UserProfileView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                statsView
                postsView
            }
        }
    }
    
    private var headerView: some View {
        VStack {
            AsyncImage(url: user.avatarURL)
            Text(user.name).font(.title)
        }
    }
    
    private var statsView: some View { /* ... */ }
    private var postsView: some View { /* ... */ }
}

// ❌ BAD: God view
struct UserProfileView: View {
    var body: some View {
        ScrollView {
            VStack {
                // 500 lines of UI code...
            }
        }
    }
}
```

### MainActor for ViewModels
```swift
// ✅ GOOD: @MainActor ensures UI updates on main thread
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    func loadUsers() async {  // Automatically on MainActor
        users = try await service.fetchUsers()
        // No need for DispatchQueue.main.async
    }
}

// ❌ BAD: Not @MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    func loadUsers() async {
        let fetchedUsers = try await service.fetchUsers()
        DispatchQueue.main.async {  // Manual dispatch needed!
            self.users = fetchedUsers
        }
    }
}
```

### Performance with Equatable
```swift
// ✅ GOOD: Equatable prevents unnecessary redraws
struct UserRow: View, Equatable {
    let user: User
    
    static func == (lhs: UserRow, rhs: UserRow) -> Bool {
        lhs.user.id == rhs.user.id  // Only redraw if ID changes
    }
    
    var body: some View {
        // Complex rendering...
    }
}

// Usage
ForEach(users) { user in
    UserRow(user: user)
        .equatable()  // Enable equatable optimization
}
```

### State Handling
```swift
// ✅ GOOD: Exhaustive state handling
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

var body: some View {
    switch viewModel.state {
    case .idle:
        EmptyStateView()
    case .loading:
        ProgressView()
    case .loaded(let users):
        UserList(users: users)
    case .error(let message):
        ErrorView(message: message)
    }
}
```
