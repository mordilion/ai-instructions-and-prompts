# iOS Development with UIKit

## Overview
iOS development with UIKit provides a mature, imperative UI framework for building iOS applications.

## View Controllers

### Lifecycle Management
```swift
// ✅ Good - proper lifecycle methods
class UserViewController: UIViewController {
    
    private let viewModel: UserViewModel
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        // Add subviews
    }
    
    private func setupConstraints() {
        // Layout constraints
    }
    
    private func setupBindings() {
        // Bind to view model
    }
}
```

### Keep View Controllers Lightweight
```swift
// ✅ Good - extracted responsibilities
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    private lazy var tableViewDataSource = UserTableViewDataSource()
    private lazy var tableViewDelegate = UserTableViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = tableViewDataSource
        tableView.delegate = tableViewDelegate
    }
}

// Separate data source
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

### Programmatic Constraints
```swift
// ✅ Good - clear constraint setup
private func setupConstraints() {
    label.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
}

// ✅ Good - constraint extension
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

### Modern Data Sources
```swift
// ✅ Good - diffable data source
class UserListViewController: UIViewController {
    
    private enum Section {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, User>!
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, User>(
            tableView: tableView
        ) { tableView, indexPath, user in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: UserCell.reuseIdentifier,
                for: indexPath
            ) as! UserCell
            cell.configure(with: user)
            return cell
        }
    }
    
    private func applySnapshot(users: [User], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
```

### Custom Cells
```swift
// ✅ Good - reusable cell
class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        // Load avatar image
    }
    
    private func setupUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(avatarImageView)
    }
    
    private func setupConstraints() {
        // Layout code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        emailLabel.text = nil
        avatarImageView.image = nil
    }
}
```

## Delegation Pattern

### Protocol Delegates
```swift
// ✅ Good - protocol-based delegation
protocol UserSelectionDelegate: AnyObject {
    func userViewController(_ controller: UserViewController, didSelect user: User)
}

class UserViewController: UIViewController {
    weak var delegate: UserSelectionDelegate?
    
    private func handleUserSelection(_ user: User) {
        delegate?.userViewController(self, didSelect: user)
    }
}

// Usage
class ParentViewController: UIViewController, UserSelectionDelegate {
    func userViewController(_ controller: UserViewController, didSelect user: User) {
        // Handle selection
    }
}
```

## Navigation

### Coordinator Pattern
```swift
// ✅ Good - coordinator for navigation
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
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showUserDetail(user: User) {
        let detailViewModel = UserDetailViewModel(user: user)
        let detailViewController = UserDetailViewController(viewModel: detailViewModel)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
```

## Networking

### URLSession
```swift
// ✅ Good - protocol-based networking
protocol NetworkService {
    func fetch<T: Decodable>(
        _ endpoint: String
    ) async throws -> T
}

class URLSessionNetworkService: NetworkService {
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}
```

## Data Persistence

### UserDefaults
```swift
// ✅ Good - type-safe UserDefaults wrapper
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct Settings {
    @UserDefault(key: "isDarkMode", defaultValue: false)
    static var isDarkMode: Bool
    
    @UserDefault(key: "notificationsEnabled", defaultValue: true)
    static var notificationsEnabled: Bool
}
```

### File System
```swift
// ✅ Good - file management
class FileManager {
    static let shared = FileManager()
    
    private let fileManager = Foundation.FileManager.default
    
    func save<T: Codable>(_ object: T, to filename: String) throws {
        let url = try getDocumentsDirectory().appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    func load<T: Codable>(_ type: T.Type, from filename: String) throws -> T {
        let url = try getDocumentsDirectory().appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func getDocumentsDirectory() throws -> URL {
        try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
}
```

## Testing

### Unit Tests
```swift
// ✅ Good - view model tests
class UserViewModelTests: XCTestCase {
    
    var sut: UserViewModel!
    var mockService: MockUserService!
    
    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        sut = UserViewModel(service: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    func testLoadUsers_Success() async throws {
        // Given
        let expectedUsers = [User(id: 1, name: "John", email: "john@example.com")]
        mockService.usersToReturn = expectedUsers
        
        // When
        try await sut.loadUsers()
        
        // Then
        XCTAssertEqual(sut.users, expectedUsers)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testLoadUsers_Failure() async {
        // Given
        mockService.shouldFail = true
        
        // When
        do {
            try await sut.loadUsers()
            XCTFail("Expected error to be thrown")
        } catch {
            // Then
            XCTAssertTrue(sut.users.isEmpty)
            XCTAssertNotNil(sut.error)
        }
    }
}

class MockUserService: UserServiceProtocol {
    var usersToReturn: [User] = []
    var shouldFail = false
    
    func fetchUsers() async throws -> [User] {
        if shouldFail {
            throw NetworkError.invalidResponse
        }
        return usersToReturn
    }
}
```

### UI Tests
```swift
// ✅ Good - UI tests
class UserListUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testUserListDisplaysUsers() {
        // Given
        app.launchArguments = ["UI-Testing"]
        
        // When
        let tableView = app.tables["UserTableView"]
        
        // Then
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(tableView.cells.count > 0)
    }
    
    func testSelectingUserNavigatesToDetail() {
        // When
        app.tables.cells.element(boundBy: 0).tap()
        
        // Then
        XCTAssertTrue(app.navigationBars["User Detail"].exists)
    }
}
```

## Best Practices

### 1. Use Dependency Injection
```swift
// ✅ Good - inject dependencies
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
}
```

### 2. Weak Self in Closures
```swift
// ✅ Good - avoid retain cycles
viewModel.onUsersChanged = { [weak self] users in
    guard let self = self else { return }
    self.updateUI(with: users)
}
```

### 3. Use Type-Safe Identifiers
```swift
// ✅ Good - avoid stringly-typed code
extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(
        for indexPath: IndexPath
    ) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(
            withIdentifier: T.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
```

### 4. Handle Errors Gracefully
```swift
// ✅ Good - user-friendly error handling
func loadData() async {
    do {
        let users = try await service.fetchUsers()
        updateUI(with: users)
    } catch NetworkError.notConnected {
        showAlert(title: "No Connection", message: "Please check your internet connection")
    } catch {
        showAlert(title: "Error", message: "Failed to load data")
    }
}
```

### 5. Use Safe Area Layout Guide
```swift
// ✅ Good - respect safe areas
NSLayoutConstraint.activate([
    view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
])
```

