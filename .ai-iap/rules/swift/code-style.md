# Swift Code Style Guidelines

## Language Version
- **Swift 5.9+** (Swift 6 recommended for strict concurrency)
- Enable strict concurrency checking
- Use latest Swift features

## Naming Conventions

### Types
```swift
// PascalCase for types
struct UserProfile { }
class NetworkManager { }
enum Result { }
protocol DataSource { }
actor Cache { }
```

### Properties & Functions
```swift
// camelCase for properties and functions
var userName: String
func fetchUserData() async throws -> User

// Boolean properties use 'is', 'has', 'can', 'should'
var isLoading: Bool
var hasNotifications: Bool
var canEdit: Bool
```

### Constants
```swift
// camelCase even for constants
let maxRetryCount = 3
let apiBaseURL = "https://api.example.com"

// Use static let for type-level constants
struct Config {
    static let timeout: TimeInterval = 30
}
```

### Protocols
```swift
// Protocols describing capabilities end in 'able' or 'ing'
protocol Codable { }
protocol Equatable { }
protocol Networking { }

// Protocols describing types don't need suffix
protocol DataSource { }
protocol Delegate { }
```

## Immutability

### Prefer let over var
```swift
// ✅ Good - immutable
let user = User(id: 1, name: "John")
let items = [1, 2, 3]

// ❌ Avoid - mutable when not needed
var user = User(id: 1, name: "John")  // Never reassigned
```

### Use Structs for Immutable Data
```swift
// ✅ Good - value semantics
struct User {
    let id: Int
    let name: String
    let email: String
}

// ✅ Good - computed properties
struct Rectangle {
    let width: Double
    let height: Double
    
    var area: Double {
        width * height
    }
}
```

## Optionals

### Use Guard for Early Returns
```swift
// ✅ Good - guard for early exit
func process(user: User?) {
    guard let user = user else { return }
    // Continue with unwrapped user
}

// ❌ Avoid - nested if let
func process(user: User?) {
    if let user = user {
        // Nested logic
    }
}
```

### Avoid Force Unwrapping
```swift
// ✅ Good - safe unwrapping
if let name = user?.name {
    print(name)
}

// ✅ Good - nil coalescing
let name = user?.name ?? "Unknown"

// ❌ Avoid - force unwrap (can crash)
let name = user!.name
```

### Implicitly Unwrapped Optionals
```swift
// ✅ Good - only for IBOutlets
@IBOutlet weak var tableView: UITableView!

// ❌ Avoid - elsewhere
var service: NetworkService!  // Don't do this
```

## Functions

### Use Argument Labels
```swift
// ✅ Good - clear intent with labels
func move(from start: Point, to end: Point) { }
func fetch(userID id: Int) async throws -> User { }

// Usage
move(from: origin, to: destination)
```

### Keep Functions Small
```swift
// ✅ Good - single responsibility
func validateEmail(_ email: String) -> Bool {
    email.contains("@") && email.contains(".")
}

func saveUser(_ user: User) async throws {
    try await repository.save(user)
}
```

### Use Trailing Closures
```swift
// ✅ Good - trailing closure syntax
users.filter { $0.isActive }
    .map { $0.name }
    .sorted()

// ✅ Good - multiple trailing closures (Swift 5.3+)
UIView.animate(withDuration: 0.3) {
    view.alpha = 0
} completion: { _ in
    view.removeFromSuperview()
}
```

## Structs vs Classes

### Use Structs by Default
```swift
// ✅ Good - value type for data
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// ✅ Good - struct for view model when possible
struct UserViewModel {
    let name: String
    let email: String
}
```

### Use Classes When Needed
```swift
// ✅ Good - class when reference semantics needed
class NetworkManager {
    // Shared state, lifecycle management
}

// ✅ Good - class for UIKit/AppKit subclasses
class CustomViewController: UIViewController {
    // UIKit inheritance
}

// ✅ Good - class for ObservableObject (SwiftUI)
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
}
```

## Enums

### Use Enums for Fixed Sets
```swift
// ✅ Good - associated values
enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

// ✅ Good - raw values
enum Status: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
}

// ✅ Good - computed properties
enum NetworkError: Error {
    case notFound
    case unauthorized
    case serverError(Int)
    
    var localizedDescription: String {
        switch self {
        case .notFound: return "Resource not found"
        case .unauthorized: return "Not authorized"
        case .serverError(let code): return "Server error: \(code)"
        }
    }
}
```

## Protocols & Extensions

### Protocol-Oriented Programming
```swift
// ✅ Good - protocol with default implementation
protocol Identifiable {
    var id: UUID { get }
}

extension Identifiable {
    func isSame(as other: Self) -> Bool where Self: Equatable {
        self.id == other.id
    }
}

// ✅ Good - composing protocols
protocol User: Identifiable, Codable {
    var name: String { get }
    var email: String { get }
}
```

### Use Extensions for Organization
```swift
// ✅ Good - organize by conformance
extension UserViewModel: ObservableObject {
    // Published properties and methods
}

extension UserViewModel: Equatable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

// ✅ Good - private helpers in private extension
private extension UserViewModel {
    func formatDate(_ date: Date) -> String {
        // Implementation
    }
}
```

## Error Handling

### Use Typed Errors
```swift
// ✅ Good - specific error types
enum ValidationError: Error {
    case emptyName
    case invalidEmail
    case passwordTooShort
}

func validate(user: User) throws {
    guard !user.name.isEmpty else {
        throw ValidationError.emptyName
    }
    guard user.email.contains("@") else {
        throw ValidationError.invalidEmail
    }
}
```

### Use Result Type
```swift
// ✅ Good - Result for async callbacks
func fetchUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
    // Implementation
}

// ✅ Good - async/await with throwing
func fetchUser() async throws -> User {
    // Implementation
}
```

## Async/Await

### Modern Concurrency
```swift
// ✅ Good - async/await
func loadData() async throws -> [User] {
    let data = try await networkService.fetch()
    return try decoder.decode([User].self, from: data)
}

// ✅ Good - async let for parallel execution
func loadUserProfile() async throws -> UserProfile {
    async let user = fetchUser()
    async let posts = fetchPosts()
    async let followers = fetchFollowers()
    
    return try await UserProfile(
        user: user,
        posts: posts,
        followers: followers
    )
}

// ✅ Good - Task for detached work
Task {
    let users = try await loadData()
    await updateUI(with: users)
}
```

### Use Actors for Thread Safety
```swift
// ✅ Good - actor for shared mutable state
actor UserCache {
    private var users: [Int: User] = [:]
    
    func get(id: Int) -> User? {
        users[id]
    }
    
    func set(user: User) {
        users[user.id] = user
    }
}
```

## Property Wrappers

### Use Built-in Property Wrappers
```swift
// ✅ Good - @Published for SwiftUI
class ViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
}

// ✅ Good - @State for SwiftUI
struct ContentView: View {
    @State private var isPresented = false
    @State private var text = ""
}

// ✅ Good - @AppStorage for UserDefaults
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
}
```

### Create Custom Property Wrappers
```swift
// ✅ Good - custom property wrapper
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    
    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(range.lowerBound, wrappedValue), range.upperBound)
    }
}

// Usage
struct Volume {
    @Clamped(0...100) var level: Int = 50
}
```

## Generics

### Use Generics for Reusability
```swift
// ✅ Good - generic types
struct Stack<Element> {
    private var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        items.popLast()
    }
}

// ✅ Good - generic constraints
func findFirst<T: Equatable>(in array: [T], matching predicate: (T) -> Bool) -> T? {
    array.first(where: predicate)
}
```

## Best Practices

### 1. Use Type Inference
```swift
// ✅ Good - let compiler infer
let name = "John"
let count = 42
let users = [User]()

// ✅ Good - explicit when ambiguous
let timeout: TimeInterval = 30
let percentage: Double = 0.5
```

### 2. Avoid Nested Types When Possible
```swift
// ✅ Good - flatten when appropriate
struct UserViewModelError: Error {
    let message: String
}

// ⚠️ OK - nest when tightly coupled
struct UserViewModel {
    enum State {
        case idle, loading, loaded, error
    }
}
```

### 3. Use Where Clauses
```swift
// ✅ Good - where for constraints
extension Array where Element: Numeric {
    func sum() -> Element {
        reduce(0, +)
    }
}

// ✅ Good - where in for loops
for user in users where user.isActive {
    print(user.name)
}
```

### 4. Prefer Map/Filter/Reduce
```swift
// ✅ Good - functional approach
let activeUserNames = users
    .filter { $0.isActive }
    .map { $0.name }
    .sorted()

// ✅ Good - compactMap to filter nils
let ids = users.compactMap { $0.id }
```

### 5. Use KeyPaths
```swift
// ✅ Good - KeyPath for sorting
let sortedUsers = users.sorted(by: \.name)

// ✅ Good - KeyPath in map
let names = users.map(\.name)
```

### 6. Leverage Swift's Type System
```swift
// ✅ Good - phantom types for type safety
enum Celsius { }
enum Fahrenheit { }

struct Temperature<Unit> {
    let value: Double
}

func convert(_ temp: Temperature<Fahrenheit>) -> Temperature<Celsius> {
    let celsius = (temp.value - 32) * 5/9
    return Temperature<Celsius>(value: celsius)
}
```

### 7. Use #if DEBUG for Dev Code
```swift
// ✅ Good - debug-only code
#if DEBUG
func setupMockData() {
    // Mock data for development
}
#endif
```

