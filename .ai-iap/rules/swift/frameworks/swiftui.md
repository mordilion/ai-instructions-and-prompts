# SwiftUI Development

## Overview
SwiftUI is Apple's modern, declarative UI framework for building user interfaces across all Apple platforms.

## Views

### Basic View Structure
```swift
// ✅ Good - simple, focused view
struct UserView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.name)
                .font(.headline)
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
```

### Extract Subviews
```swift
// ✅ Good - extract complex views
struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                UserHeaderView(user: user)
                UserStatsView(user: user)
                UserPostsView(user: user)
            }
        }
    }
}

// Extracted subview
private struct UserHeaderView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.title)
                Text(user.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

## State Management

### @State for Local State
```swift
// ✅ Good - @State for view-local state
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

### @StateObject for View Models
```swift
// ✅ Good - @StateObject for owned view models
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

@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service: UserService
    
    init(service: UserService = UserService()) {
        self.service = service
    }
    
    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            users = try await service.fetchUsers()
        } catch {
            self.error = error
        }
    }
}
```

### @ObservedObject for Passed View Models
```swift
// ✅ Good - @ObservedObject when passed from parent
struct UserDetailView: View {
    @ObservedObject var viewModel: UserDetailViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.user.name)
        }
    }
}
```

### @EnvironmentObject for Shared State
```swift
// ✅ Good - @EnvironmentObject for shared dependencies
struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authManager)
    }
}

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Text("Welcome, \(authManager.currentUser?.name ?? "")")
            Button("Logout") {
                authManager.logout()
            }
        }
    }
}
```

### @Binding for Two-Way Communication
```swift
// ✅ Good - @Binding for parent-child communication
struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            ResultsList(query: searchText)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}
```

## Lists & Collections

### List with ForEach
```swift
// ✅ Good - List with identifiable items
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

// Make model Identifiable
struct User: Identifiable, Hashable {
    let id: UUID
    let name: String
    let email: String
}
```

### LazyVGrid for Grids
```swift
// ✅ Good - LazyVGrid for grid layouts
struct PhotoGridView: View {
    let photos: [Photo]
    
    private let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
    }
}
```

## Navigation

### NavigationStack (iOS 16+)
```swift
// ✅ Good - modern navigation with NavigationStack
struct AppRootView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            UserListView()
                .navigationDestination(for: User.self) { user in
                    UserDetailView(user: user)
                }
                .navigationDestination(for: Post.self) { post in
                    PostDetailView(post: post)
                }
        }
    }
}
```

### Sheets & Modals
```swift
// ✅ Good - sheets for modals
struct ContentView: View {
    @State private var showingSheet = false
    @State private var selectedUser: User?
    
    var body: some View {
        Button("Show User") {
            showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            if let user = selectedUser {
                UserDetailView(user: user)
            }
        }
    }
}

// ✅ Good - item-based sheets
struct ContentView: View {
    @State private var selectedUser: User?
    
    var body: some View {
        List(users) { user in
            Button(user.name) {
                selectedUser = user
            }
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
// ✅ Good - use .task for async work
struct UserDetailView: View {
    @StateObject private var viewModel: UserDetailViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                UserContentView(user: user)
            }
        }
        .task {
            await viewModel.loadUser()
        }
    }
}
```

### Refreshable
```swift
// ✅ Good - pull-to-refresh with refreshable
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}
```

## Custom View Modifiers

### Reusable Modifiers
```swift
// ✅ Good - custom view modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

## Environment Values

### Custom Environment Keys
```swift
// ✅ Good - custom environment values
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// Usage
struct ContentView: View {
    @State private var theme: Theme = .light
    
    var body: some View {
        HomeView()
            .environment(\.theme, theme)
    }
}

struct HomeView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Text("Hello")
            .foregroundColor(theme.primaryColor)
    }
}
```

## Preference Keys

### Child-to-Parent Communication
```swift
// ✅ Good - PreferenceKey for child-to-parent data flow
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct MeasureView<Content: View>: View {
    let content: Content
    @State private var size: CGSize = .zero
    
    var body: some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                size = newSize
            }
    }
}
```

## Testing

### View Testing
```swift
// ✅ Good - test view logic
@MainActor
class UserListViewModelTests: XCTestCase {
    
    func testLoadUsers_Success() async throws {
        // Given
        let mockService = MockUserService()
        mockService.usersToReturn = [
            User(id: UUID(), name: "John", email: "john@example.com")
        ]
        let viewModel = UserListViewModel(service: mockService)
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, 1)
        XCTAssertEqual(viewModel.users.first?.name, "John")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadUsers_Failure() async {
        // Given
        let mockService = MockUserService()
        mockService.shouldFail = true
        let viewModel = UserListViewModel(service: mockService)
        
        // When
        await viewModel.loadUsers()
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }
}
```

### Preview Providers
```swift
// ✅ Good - useful previews
struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserView(user: User.sample)
                .previewDisplayName("Default")
            
            UserView(user: User.sampleWithLongName)
                .previewDisplayName("Long Name")
            
            UserView(user: User.sample)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

extension User {
    static let sample = User(
        id: UUID(),
        name: "John Doe",
        email: "john@example.com"
    )
    
    static let sampleWithLongName = User(
        id: UUID(),
        name: "John Jacob Jingleheimer Schmidt",
        email: "john@example.com"
    )
}
```

## Best Practices

### 1. Keep Views Small
```swift
// ✅ Good - extract complex logic
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
        HStack {
            // Header content
        }
    }
    
    private var statsView: some View {
        HStack {
            // Stats content
        }
    }
    
    private var postsView: some View {
        LazyVStack {
            // Posts content
        }
    }
}
```

### 2. Use @MainActor for View Models
```swift
// ✅ Good - ensure UI updates on main thread
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    func loadUsers() async {
        // Automatically on MainActor
        users = try await service.fetchUsers()
    }
}
```

### 3. Avoid Heavy Computation in Body
```swift
// ❌ Avoid - expensive computation in body
var body: some View {
    let sortedUsers = users.sorted { $0.name < $1.name }  // Recomputes every render
    // ...
}

// ✅ Good - compute once
@State private var sortedUsers: [User] = []

var body: some View {
    List(sortedUsers) { user in
        // ...
    }
    .onChange(of: users) { newUsers in
        sortedUsers = newUsers.sorted { $0.name < $1.name }
    }
}
```

### 4. Use Equatable for Performance
```swift
// ✅ Good - conform to Equatable for efficient updates
struct UserView: View, Equatable {
    let user: User
    
    var body: some View {
        Text(user.name)
    }
    
    static func == (lhs: UserView, rhs: UserView) -> Bool {
        lhs.user.id == rhs.user.id
    }
}
```

### 5. Handle Loading & Error States
```swift
// ✅ Good - proper state handling
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let users):
                UserList(users: users)
            case .error(let message):
                ErrorView(message: message) {
                    Task {
                        await viewModel.retry()
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}
```

### 6. Use Animation Wisely
```swift
// ✅ Good - explicit animations
@State private var isExpanded = false

var body: some View {
    VStack {
        // ...
    }
    .frame(height: isExpanded ? 200 : 100)
    .animation(.spring(), value: isExpanded)
}
```

