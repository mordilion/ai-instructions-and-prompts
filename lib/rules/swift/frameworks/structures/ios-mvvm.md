# iOS MVVM Structure

> **Scope**: MVVM structure for iOS  
> **Applies to**: iOS projects with MVVM  
> **Extends**: swift/frameworks/ios.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: ViewModel for UI logic
> **ALWAYS**: Combine/async-await for observability
> **ALWAYS**: Protocol for ViewModels
> **ALWAYS**: Services for data access
> **ALWAYS**: Dependency injection via constructor
> 
> **NEVER**: Business logic in ViewControllers
> **NEVER**: ViewModels reference ViewControllers
> **NEVER**: Static state in ViewModels
> **NEVER**: Direct network calls in ViewModels
> **NEVER**: Skip protocol abstraction

## Directory Structure

```
Sources/
├── Features/
│   ├── User/
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── ViewModels/
│   │   │   ├── UserListViewModel.swift
│   │   │   └── UserDetailViewModel.swift
│   │   ├── Views/
│   │   │   ├── UserListViewController.swift
│   │   │   ├── UserDetailViewController.swift
│   │   │   └── Cells/
│   │   │       └── UserCell.swift
│   │   └── Services/
│   │       └── UserService.swift
│   └── Auth/
│       ├── Models/
│       ├── ViewModels/
│       ├── Views/
│       └── Services/
├── Common/
│   ├── Extensions/
│   ├── Utilities/
│   └── Coordinators/
└── Resources/
    ├── Assets.xcassets
    └── Storyboards/
```

## Implementation

### Model
```swift
struct User {
    let id: UUID
    let name: String
    let email: String
}
```

### ViewModel
```swift
class UserListViewModel {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service: UserService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: UserService = UserService()) {
        self.service = service
    }
    
    func loadUsers() {
        isLoading = true
        service.fetchUsers()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                }
            )
            .store(in: &cancellables)
    }
}
```

### View Controller
```swift
class UserListViewController: UIViewController {
    private let viewModel: UserListViewModel
    private let tableView = UITableView()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadUsers()
    }
    
    private func setupBindings() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}
```

## Benefits
- Clear separation of concerns
- Testable ViewModels
- Reactive data binding

## When to Use
- Standard iOS apps
- Apps with moderate complexity

## AI Self-Check

- [ ] ViewModel for UI logic?
- [ ] Combine/async-await for observability?
- [ ] Protocol for ViewModels?
- [ ] Services for data access?
- [ ] Dependency injection via constructor?
- [ ] No business logic in ViewControllers?
- [ ] ViewModels don't reference ViewControllers?
- [ ] No static state in ViewModels?
- [ ] No direct network calls in ViewModels?
- [ ] Protocol abstraction present?

