# iOS Development with UIKit

> **Scope**: iOS apps using UIKit (Apple's imperative UI framework, 2008-present)
> **Applies to**: Swift files using UIKit
> **Extends**: swift/architecture.md, swift/code-style.md
> **Use When**: Existing apps, complex animations, iOS 12 and below

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use dependency injection via initializers (NOT singletons)
> **ALWAYS**: Use `[weak self]` in closures (prevent retain cycles)
> **ALWAYS**: Clean up observers/delegates in deinit
> **ALWAYS**: Respect safe area for modern iOS (notch, Dynamic Island)
> **ALWAYS**: Use Auto Layout (NOT frame-based)
> 
> **NEVER**: Force unwrap without safety check
> **NEVER**: Use singletons (makes testing difficult)
> **NEVER**: Put business logic in view controllers
> **NEVER**: Create retain cycles in closures
> **NEVER**: Ignore safe area layout guides

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| **Diffable Data Source** | iOS 13+, modern apps | Type-safe, automatic animations |
| **Traditional Data Source** | iOS 12 and below | Manual reloadData() |
| **Coordinator** | Multi-screen navigation | Decoupled routing |
| **Delegation** | Callbacks, events | Protocol-based communication |

## Core Patterns

### View Controllers

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

### Auto Layout

```swift
private func setupConstraints() {
    label.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
}
```

### Diffable Data Source (iOS 13+)

```kotlin
class UserListViewController: UIViewController {
    private enum Section { case main }
    private var dataSource: UITableViewDiffableDataSource<Section, User>!
    private let tableView = UITableView()
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, User>(tableView: tableView) { 
            tableView, indexPath, user in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UserCell
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

### Delegation Pattern

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

### Coordinator Pattern

```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

class UserCoordinator: Coordinator {
    let navigationController: UINavigationController
    
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

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Retain Cycles** | `self.updateUI()` in closure | `[weak self]` | Memory leak |
| **Force Unwrapping** | `user!` | `guard let user = ...` | Crash risk |
| **Singletons** | `UserService.shared` | Constructor injection | Hard to test |
| **Massive ViewControllers** | 1000+ lines | Extract logic to services | Maintainability |
| **Ignore Safe Area** | `view.topAnchor` | `view.safeAreaLayoutGuide.topAnchor` | Notch overlap |

### Anti-Pattern: Retain Cycle (MEMORY LEAK)

```swift
// ❌ WRONG: Retain cycle
viewModel.onUsersChanged = { users in
    self.updateUI(with: users)  // ViewController → closure → self → ViewController
}

// ✅ CORRECT: [weak self] prevents retain cycle
viewModel.onUsersChanged = { [weak self] users in
    guard let self = self else { return }
    self.updateUI(with: users)
}
```

### Anti-Pattern: Singleton (TESTING DISASTER)

```swift
// ❌ WRONG: Singleton (hard to test, global state)
class UserViewController: UIViewController {
    private let viewModel = UserViewModel.shared
}

// ✅ CORRECT: Constructor injection
class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
}
```

## AI Self-Check (Verify BEFORE generating UIKit code)

- [ ] Dependency injection via initializers?
- [ ] [weak self] in closures?
- [ ] Auto Layout (not frame-based)?
- [ ] Respecting safe area layout guides?
- [ ] Delegation pattern for callbacks?
- [ ] No force unwrapping without safety?
- [ ] ViewControllers under 300 lines?
- [ ] Cleanup in deinit?
- [ ] async/await for networking (iOS 13+)?
- [ ] No singletons?

## Key Components

| Component | Purpose | Keywords |
|-----------|---------|----------|
| **ViewControllers** | Screen management | Lifecycle, navigation |
| **Auto Layout** | Adaptive UI | Constraints, safe area |
| **Diffable Data Source** | TableView/CollectionView | Type-safe, animations |
| **Delegation** | Callbacks | Protocol, weak reference |
| **Coordinator** | Navigation | Decoupled routing |
| **URLSession** | Networking | async/await, Codable |
| **UserDefaults** | Simple persistence | @propertyWrapper |

## Best Practices

**MUST**:
- Constructor injection (not singletons)
- [weak self] in closures
- Clean up observers in deinit
- Safe area respect
- Auto Layout

**SHOULD**:
- Diffable data sources (iOS 13+)
- async/await (iOS 13+)
- Coordinator pattern
- Keep VCs under 300 lines
- Use private for internals

**AVOID**:
- Retain cycles
- Force unwrapping
- Business logic in VCs
- Singletons
- Massive view controllers
