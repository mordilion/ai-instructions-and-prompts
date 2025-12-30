# iOS Development with UIKit

> **Scope**: iOS apps using UIKit  
> **Applies to**: Swift files using UIKit
> **Extends**: swift/architecture.md, swift/code-style.md
> **Use When**: Existing apps, complex animations, iOS 12 and below

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use DI via initializers (NOT singletons)
> **ALWAYS**: Use `[weak self]` in closures
> **ALWAYS**: Clean up observers/delegates in deinit
> **ALWAYS**: Respect safe area
> **ALWAYS**: Use Auto Layout
> 
> **NEVER**: Force unwrap without safety check
> **NEVER**: Use singletons
> **NEVER**: Put business logic in view controllers
> **NEVER**: Create retain cycles
> **NEVER**: Ignore safe area

## Core Patterns

### View Controller

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
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] data in
            self?.updateUI(with: data)
        }
    }
}
```

### Diffable Data Source (iOS 13+)

```swift
class UserListViewController: UIViewController {
    enum Section { case main }
    
    private var dataSource: UITableViewDiffableDataSource<Section, User>!
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, user in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
            cell.textLabel?.text = user.name
            return cell
        }
    }
    
    func updateData(_ users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
```

### Auto Layout

```swift
private func setupConstraints() {
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
}
```

### Delegation

```swift
protocol UserViewDelegate: AnyObject {
    func didSelectUser(_ user: User)
}

class UserView: UIView {
    weak var delegate: UserViewDelegate?
    
    private func handleTap() {
        delegate?.didSelectUser(selectedUser)
    }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Singleton** | `UserService.shared` | Constructor injection |
| **Strong Self** | `self.update()` | `[weak self]` |
| **Force Unwrap** | `user!` | `guard let user` |
| **Frame Layout** | `view.frame = CGRect()` | Auto Layout |

## AI Self-Check

- [ ] DI via initializers?
- [ ] [weak self] in closures?
- [ ] Observer cleanup in deinit?
- [ ] Safe area respected?
- [ ] Auto Layout used?
- [ ] No singletons?
- [ ] No force unwraps?
- [ ] Business logic in ViewModels?
- [ ] No retain cycles?

## Key Features

| Feature | Purpose |
|---------|---------|
| Diffable Data Source | Modern lists |
| Auto Layout | Responsive UI |
| Delegation | Event handling |
| DI | Testability |
| Safe Area | Modern devices |

## Best Practices

**MUST**: DI, [weak self], Auto Layout, safe area, observer cleanup
**SHOULD**: Diffable data source, coordinator pattern, delegation
**AVOID**: Singletons, retain cycles, force unwraps, frame layout
