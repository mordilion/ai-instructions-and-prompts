# iOS Development with UIKit

## Overview
UIKit: Apple's mature, imperative UI framework for iOS (2008-present), still widely used in production apps.
Event-driven with manual view lifecycle management and imperative UI updates.
Best for maintaining existing iOS apps, complex UI animations, or when targeting iOS 12 and below.

## View Controllers

### Lifecycle
```swift
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
}
```

### Keep Lightweight
```swift
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    private lazy var dataSource = UserTableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
}

class UserTableViewDataSource: NSObject, UITableViewDataSource {
    var users: [User] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure cell
    }
}
```

## Auto Layout

```swift
private func setupConstraints() {
    label.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
}

extension UIView {
    func pinToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
```

## UITableView & UICollectionView

### Diffable Data Source
```swift
class UserListViewController: UIViewController {
    private enum Section { case main }
    private var dataSource: UITableViewDiffableDataSource<Section, User>!
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, User>(tableView: tableView) { 
            tableView, indexPath, user in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserCell
            cell.configure(with: user)
            return cell
        }
    }
    
    private func applySnapshot(users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
```

### Custom Cells
```swift
class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        emailLabel.text = nil
    }
}
```

## Delegation Pattern

```swift
protocol UserSelectionDelegate: AnyObject {
    func userViewController(_ controller: UserViewController, didSelect user: User)
}

class UserViewController: UIViewController {
    weak var delegate: UserSelectionDelegate?
    
    private func handleSelection(_ user: User) {
        delegate?.userViewController(self, didSelect: user)
    }
}
```

## Navigation

### Coordinator Pattern
```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

class UserCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = UserViewModel()
        let viewController = UserViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

## Networking

```swift
protocol NetworkService {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
}

class URLSessionNetworkService: NetworkService {
    private let baseURL: URL
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## Data Persistence

### UserDefaults
```swift
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

struct Settings {
    @UserDefault(key: "isDarkMode", defaultValue: false)
    static var isDarkMode: Bool
}
```

## Testing

### Unit Tests
```swift
class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var mockService: MockUserService!
    
    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        sut = UserViewModel(service: mockService)
    }
    
    func testLoadUsers_Success() async throws {
        mockService.usersToReturn = [User(id: 1, name: "John", email: "john@test.com")]
        
        try await sut.loadUsers()
        
        XCTAssertEqual(sut.users.count, 1)
        XCTAssertFalse(sut.isLoading)
    }
}
```

### UI Tests
```swift
class UserListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testUserListDisplaysUsers() {
        let tableView = app.tables["UserTableView"]
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(tableView.cells.count > 0)
    }
}
```

## Best Practices

**MUST**:
- Use dependency injection via initializers (NOT singletons)
- Use [weak self] in closures to prevent retain cycles
- Clean up observers/delegates in deinit or viewDidDisappear
- Respect safe area for modern iOS devices (notch, Dynamic Island)
- Use Auto Layout (NOT frame-based layout)

**SHOULD**:
- Use diffable data sources for UITableView/UICollectionView
- Use async/await for modern iOS apps (iOS 13+)
- Use Coordinator pattern for navigation in complex apps
- Implement required init?(coder:) with fatalError (if not using storyboards)
- Use private for internal view properties

**AVOID**:
- Retain cycles in closures (always use [weak self])
- Force unwrapping (use guard let or if let)
- Business logic in view controllers (move to ViewModels)
- Singletons (makes testing difficult)
- Massive view controllers (split into smaller VCs or extract logic)

## Common Patterns

### Dependency Injection
```swift
// ✅ GOOD: Constructor injection
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

// ❌ BAD: Singleton
class UserViewController: UIViewController {
    private let viewModel = UserViewModel.shared  // Hard to test, global state
}
```

### Memory Management
```swift
// ✅ GOOD: [weak self] prevents retain cycle
viewModel.onUsersChanged = { [weak self] users in
    guard let self = self else { return }
    self.updateUI(with: users)
}

// ❌ BAD: Retain cycle
viewModel.onUsersChanged = { users in
    self.updateUI(with: users)  // ViewController -> closure -> self -> ViewController
}

// ✅ GOOD: Unsubscribe in deinit
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

### Type-Safe Identifiers
```swift
// ✅ GOOD: Protocol-based reuse identifiers
protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UserCell: ReusableView {}

// Usage
tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier)

// ❌ BAD: String literals
tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")  // Typo-prone
```

### Async/Await Error Handling
```swift
// ✅ GOOD: Specific error handling
func loadData() async {
    do {
        let users = try await service.fetchUsers()
        updateUI(with: users)
    } catch NetworkError.notConnected {
        showAlert(title: "No Connection", message: "Check your internet")
    } catch NetworkError.unauthorized {
        showLogin()
    } catch {
        showAlert(title: "Error", message: "Failed to load")
    }
}
```

### Safe Area
```swift
// ✅ GOOD: Respect safe area
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
])

// ❌ BAD: Hardcoded offsets (breaks on notch devices)
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)  // Wrong!
])
```
