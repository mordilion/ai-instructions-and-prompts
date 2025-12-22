# Core Data Framework

## Overview
Core Data: Apple's object graph and persistence framework.

## Stack Setup

```swift
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

## Entity Management

### CRUD Operations
```swift
func createUser(name: String, email: String) -> User? {
    let context = CoreDataStack.shared.context
    let user = User(context: context)
    user.id = UUID()
    user.name = name
    user.email = email
    try? context.save()
    return user
}

func fetchUsers(matching query: String) -> [User] {
    let context = CoreDataStack.shared.context
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    
    if !query.isEmpty {
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
    }
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    
    return (try? context.fetch(fetchRequest)) ?? []
}

func updateUser(_ user: User, name: String, email: String) -> Bool {
    user.name = name
    user.email = email
    return (try? user.managedObjectContext?.save()) != nil
}

func deleteUser(_ user: User) -> Bool {
    guard let context = user.managedObjectContext else { return false }
    context.delete(user)
    return (try? context.save()) != nil
}
```

## Batch Operations

```swift
func markAllPostsAsRead() {
    let batchUpdate = NSBatchUpdateRequest(entityName: "Post")
    batchUpdate.propertiesToUpdate = ["isRead": true]
    batchUpdate.resultType = .updatedObjectIDsResultType
    
    if let result = try? context.execute(batchUpdate) as? NSBatchUpdateResult,
       let objectIDs = result.result as? [NSManagedObjectID] {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSUpdatedObjectsKey: objectIDs],
            into: [context]
        )
    }
}
```

## Fetched Results Controller

```swift
class UserListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? fetchedResultsController.performFetch()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                   didChange anObject: Any,
                   at indexPath: IndexPath?,
                   for type: NSFetchedResultsChangeType,
                   newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }
}
```

## SwiftUI Integration

```swift
struct UserListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.createdAt, ascending: false)]
    )
    private var users: FetchedResults<User>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            ForEach(users) { user in
                VStack(alignment: .leading) {
                    Text(user.name ?? "")
                    Text(user.email ?? "").font(.subheadline)
                }
            }
            .onDelete(perform: deleteUsers)
        }
    }
    
    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}
```

## Background Context

```swift
func importLargeDataset(_ data: [UserData]) async {
    await CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
        for userData in data {
            let user = User(context: context)
            user.id = UUID()
            user.name = userData.name
            user.email = userData.email
        }
        try? context.save()
    }
}
```

## Migrations

```swift
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    
    let storeDescription = container.persistentStoreDescriptions.first
    storeDescription?.shouldMigrateStoreAutomatically = true
    storeDescription?.shouldInferMappingModelAutomatically = true
    
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Unable to load: \(error)")
        }
    }
    return container
}()
```

## Best Practices

**MUST**:
- Use `NSManagedObjectContext.perform` or `performAndWait` for thread safety
- Save context after changes (Core Data doesn't auto-save)
- Use fetch request limits for large datasets (pagination)
- Use predicates for filtering (NOT fetching all then filtering in code)
- Configure merge policy for conflict resolution

**SHOULD**:
- Use background context for heavy operations (import, batch updates)
- Use `@FetchRequest` in SwiftUI for automatic updates
- Use batch operations for multiple inserts/updates
- Enable automatic migration for development
- Use fetch batch size for memory efficiency

**AVOID**:
- Accessing Core Data from multiple threads without proper context
- Forgetting to save context (changes lost)
- Fetching all objects then filtering in memory (slow)
- Using main context for heavy operations (UI freezes)
- Ignoring Core Data threading rules (crashes)

## Common Patterns

### Property Wrappers (SwiftUI)
```swift
// ✅ GOOD: @FetchRequest with filtering
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
    predicate: NSPredicate(format: "isActive == true")
)
private var activeUsers: FetchedResults<User>

var body: some View {
    List(activeUsers) { user in
        Text(user.name)  // Automatically updates when data changes
    }
}

// ❌ BAD: Fetching all then filtering
@FetchRequest(sortDescriptors: [])
private var allUsers: FetchedResults<User>

var body: some View {
    List(allUsers.filter { $0.isActive }) { user in  // Inefficient!
        Text(user.name)
    }
}
```

### Background Context (Thread Safety)
```swift
// ✅ GOOD: Background context for heavy work
func importUsers(_ usersData: [UserData]) async {
    await persistentContainer.performBackgroundTask { context in
        for userData in usersData {
            let user = User(context: context)
            user.name = userData.name
            user.email = userData.email
        }
        try? context.save()  // Save on background thread
    }
}

// ❌ BAD: Heavy work on main context
func importUsers(_ usersData: [UserData]) {
    for userData in usersData {
        let user = User(context: viewContext)  // Blocks UI!
        user.name = userData.name
    }
    try? viewContext.save()
}
```

### Fetch Limits (Performance)
```swift
// ✅ GOOD: Paginated fetch with limits
func fetchUsers(page: Int, pageSize: Int = 50) -> [User] {
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.fetchLimit = pageSize
    fetchRequest.fetchOffset = page * pageSize
    fetchRequest.fetchBatchSize = 20  // Load in batches
    
    return (try? context.fetch(fetchRequest)) ?? []
}

// ❌ BAD: Fetching all objects
func fetchUsers() -> [User] {
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    return (try? context.fetch(fetchRequest)) ?? []  // Could be thousands!
}
```
