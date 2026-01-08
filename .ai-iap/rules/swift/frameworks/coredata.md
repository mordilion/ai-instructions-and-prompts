# Core Data Framework

> **Scope**: Apple's object graph and persistence framework  
> **Applies to**: Swift files using Core Data
> **Extends**: swift/architecture.md, swift/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use NSPersistentContainer
> **ALWAYS**: Save context after modifications
> **ALWAYS**: Use background context for heavy ops
> **ALWAYS**: Use NSFetchRequest with predicates
> **ALWAYS**: Handle fetch errors
> 
> **NEVER**: Heavy ops on main context
> **NEVER**: Pass NSManagedObject between threads
> **NEVER**: Force unwrap Core Data ops
> **NEVER**: Skip hasChanges check

## Core Patterns

```swift
// Stack Setup
class CoreDataStack {
    static let shared = CoreDataStack()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in if let error = error { fatalError() } }
        return container
    }()
    func save() { if context.hasChanges { try? context.save() } }
}

// CRUD
func createUser(name: String) -> User? {
    let user = User(context: CoreDataStack.shared.context)
    user.name = name
    try? CoreDataStack.shared.context.save()
    return user
}

func fetchUsers() -> [User] {
    let request: NSFetchRequest<User> = User.fetchRequest()
    return (try? CoreDataStack.shared.context.fetch(request)) ?? []
}

// Background Context
func importData(_ items: [DataItem]) {
    CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
        items.forEach { User(context: context).name = $0.name }
        try? context.save()
    }
}

// NSFetchedResultsController
lazy var frc: NSFetchedResultsController<User> = {
    let req: NSFetchRequest<User> = User.fetchRequest()
    req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    let frc = NSFetchedResultsController(fetchRequest: req, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
    return frc
}()
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Heavy Main Context** | Import 1000s on main | Background context |
| **Cross-Thread Objects** | Pass object | Pass objectID |
| **Force Unwrap** | `try! context.save()` | `try? context.save()` |
| **No hasChanges** | Always save | Check `hasChanges` |

### Anti-Pattern: Heavy Main Context

```swift
// ❌ WRONG
func importUsers(_ data: [UserData]) {
    let context = CoreDataStack.shared.context  // Main!
    for item in data { /* Heavy work blocks UI */ }
}

// ✅ CORRECT
func importUsers(_ data: [UserData]) {
    CoreDataStack.shared.persistentContainer.performBackgroundTask { context in
        for item in data { /* Background thread */ }
        try? context.save()
    }
}
```

### Anti-Pattern: Cross-Thread

```swift
// ❌ WRONG
let objectID = user.objectID
DispatchQueue.global().async {
    user.name = "Updated"  // Crash!
}

// ✅ CORRECT
let objectID = user.objectID
DispatchQueue.global().async {
    let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
    if let user = try? context.existingObject(with: objectID) as? User {
        user.name = "Updated"
        try? context.save()
    }
}
```

## AI Self-Check

- [ ] NSPersistentContainer?
- [ ] Saving after modifications?
- [ ] Background context for heavy ops?
- [ ] NSFetchRequest with predicates?
- [ ] Handling errors?
- [ ] Not passing objects between threads?
- [ ] Checking hasChanges?
- [ ] Using generated classes?
- [ ] No force unwrapping?

## Key Features

| Feature | Purpose |
|---------|---------|
| NSPersistentContainer | Setup |
| NSFetchRequest | Querying |
| Background Context | Heavy ops |
| NSFetchedResultsController | TableView |
| Batch Operations | Bulk changes |

## Best Practices

**MUST**: NSPersistentContainer, background context for heavy ops, hasChanges check
**SHOULD**: NSFetchedResultsController, batch operations, objectID for cross-thread
**AVOID**: Heavy main context ops, cross-thread objects, force unwrapping
