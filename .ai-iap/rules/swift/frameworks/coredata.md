# Core Data Framework

## Overview
Core Data is Apple's object graph and persistence framework for iOS, macOS, and other Apple platforms.

## Stack Setup

### Core Data Stack
```swift
// ✅ Good - Core Data stack
class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
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
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
```

## Entity Management

### Create Entity
```swift
// ✅ Good - create entity
func createUser(name: String, email: String) -> User? {
    let context = CoreDataStack.shared.context
    let user = User(context: context)
    user.id = UUID()
    user.name = name
    user.email = email
    user.createdAt = Date()
    
    do {
        try context.save()
        return user
    } catch {
        print("Failed to create user: \(error)")
        return nil
    }
}
```

### Fetch Entities
```swift
// ✅ Good - fetch with predicate
func fetchUsers(matching query: String) -> [User] {
    let context = CoreDataStack.shared.context
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    
    if !query.isEmpty {
        fetchRequest.predicate = NSPredicate(
            format: "name CONTAINS[cd] %@ OR email CONTAINS[cd] %@",
            query,
            query
        )
    }
    
    fetchRequest.sortDescriptors = [
        NSSortDescriptor(key: "createdAt", ascending: false)
    ]
    
    do {
        return try context.fetch(fetchRequest)
    } catch {
        print("Failed to fetch users: \(error)")
        return []
    }
}
```

### Update Entity
```swift
// ✅ Good - update entity
func updateUser(_ user: User, name: String, email: String) -> Bool {
    let context = CoreDataStack.shared.context
    user.name = name
    user.email = email
    user.updatedAt = Date()
    
    do {
        try context.save()
        return true
    } catch {
        print("Failed to update user: \(error)")
        return false
    }
}
```

### Delete Entity
```swift
// ✅ Good - delete entity
func deleteUser(_ user: User) -> Bool {
    let context = CoreDataStack.shared.context
    context.delete(user)
    
    do {
        try context.save()
        return true
    } catch {
        print("Failed to delete user: \(error)")
        return false
    }
}
```

## Relationships

### One-to-Many
```swift
// User has many Posts
// ✅ Good - fetch with relationship
func fetchUserWithPosts(id: UUID) -> User? {
    let context = CoreDataStack.shared.context
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    fetchRequest.relationshipKeyPathsForPrefetching = ["posts"]
    
    do {
        return try context.fetch(fetchRequest).first
    } catch {
        print("Failed to fetch user: \(error)")
        return nil
    }
}
```

## Batch Operations

### Batch Update
```swift
// ✅ Good - batch update
func markAllPostsAsRead() {
    let context = CoreDataStack.shared.context
    let batchUpdate = NSBatchUpdateRequest(entityName: "Post")
    batchUpdate.propertiesToUpdate = ["isRead": true]
    batchUpdate.resultType = .updatedObjectIDsResultType
    
    do {
        let result = try context.execute(batchUpdate) as? NSBatchUpdateResult
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSUpdatedObjectsKey: objectIDs],
                into: [context]
            )
        }
    } catch {
        print("Failed to batch update: \(error)")
    }
}
```

### Batch Delete
```swift
// ✅ Good - batch delete
func deleteOldPosts(olderThan days: Int) {
    let context = CoreDataStack.shared.context
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Post.fetchRequest()
    let date = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    fetchRequest.predicate = NSPredicate(format: "createdAt < %@", date as CVarArg)
    
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    batchDelete.resultType = .resultTypeObjectIDs
    
    do {
        let result = try context.execute(batchDelete) as? NSBatchDeleteResult
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [context]
            )
        }
    } catch {
        print("Failed to batch delete: \(error)")
    }
}
```

## Fetched Results Controller (UIKit)

### Table View Integration
```swift
// ✅ Good - NSFetchedResultsController
class UserListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private lazy var fetchedResultsController: NSFetchedResultsController<User> = {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
```

## SwiftUI Integration

### @FetchRequest
```swift
// ✅ Good - SwiftUI with Core Data
struct UserListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.createdAt, ascending: false)],
        animation: .default
    )
    private var users: FetchedResults<User>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            ForEach(users) { user in
                NavigationLink(value: user) {
                    VStack(alignment: .leading) {
                        Text(user.name ?? "")
                            .font(.headline)
                        Text(user.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteUsers)
        }
        .navigationDestination(for: User.self) { user in
            UserDetailView(user: user)
        }
    }
    
    private func deleteUsers(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting: \(error)")
            }
        }
    }
}
```

## Background Context

### Concurrent Operations
```swift
// ✅ Good - background context
func importLargeDataset(_ data: [UserData]) async {
    await CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
        for userData in data {
            let user = User(context: context)
            user.id = UUID()
            user.name = userData.name
            user.email = userData.email
            user.createdAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
```

## Migrations

### Lightweight Migration
```swift
// ✅ Good - enable lightweight migration
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    
    let storeDescription = container.persistentStoreDescriptions.first
    storeDescription?.shouldMigrateStoreAutomatically = true
    storeDescription?.shouldInferMappingModelAutomatically = true
    
    container.loadPersistentStores { description, error in
        if let error = error {
            fatalError("Unable to load persistent stores: \(error)")
        }
    }
    
    return container
}()
```

## Best Practices

### 1. Use Property Wrappers (SwiftUI)
```swift
// ✅ Good - fetch request property wrapper
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
    predicate: NSPredicate(format: "isActive == true")
)
private var activeUsers: FetchedResults<User>
```

### 2. Save on Background Context
```swift
// ✅ Good - save heavy operations on background
Task {
    await context.perform {
        // Heavy work here
        try? context.save()
    }
}
```

### 3. Use Unique Constraints
```swift
// ✅ Good - define unique constraint in model
// In .xcdatamodeld: Set constraint on "id" field
```

### 4. Fetch Limits
```swift
// ✅ Good - limit fetch results
fetchRequest.fetchLimit = 50
fetchRequest.fetchBatchSize = 20
```

### 5. Delete Rules
```swift
// ✅ Good - set delete rules in relationships
// Cascade: Delete related objects
// Nullify: Set relationship to nil
// Deny: Prevent deletion if relationship exists
```

