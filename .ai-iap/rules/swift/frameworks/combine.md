# Combine Framework

> **Scope**: Apple's reactive framework  
> **Applies to**: Swift files using Combine
> **Extends**: swift/architecture.md, swift/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Store cancellables properly
> **ALWAYS**: Use `.eraseToAnyPublisher()` for public APIs
> **ALWAYS**: Handle completion and errors with `sink`
> **ALWAYS**: Use `.receive(on: DispatchQueue.main)` for UI
> **ALWAYS**: Use weak self in closures
> 
> **NEVER**: Ignore cancellables
> **NEVER**: Update UI on background threads
> **NEVER**: Use `.sink` without storing
> **NEVER**: Force unwrap publisher values
> **NEVER**: Create retain cycles

## Core Patterns

```swift
// Publishers
let just = Just(42)
let subject = PassthroughSubject<String, Never>()
let state = CurrentValueSubject<Int, Never>(0)

class ViewModel: ObservableObject {
    @Published var username = ""
}

// Subscription (CRITICAL: Store cancellables!)
class ViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        dataService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] users in self?.users = users })
            .store(in: &cancellables)
    }
}

// Operators
publisher
    .map { $0.uppercased() }
    .filter { $0.count > 5 }
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { print($0) }
    .store(in: &cancellables)

// Combining
Publishers.Zip(pub1, pub2).sink { v1, v2 in }.store(in: &c)
Publishers.CombineLatest(pub1, pub2).sink { v1, v2 in }.store(in: &c)
Publishers.Merge(pub1, pub2).sink { v in }.store(in: &c)

// Future (Async)
func fetchUser() -> AnyPublisher<User, Error> {
    Future { promise in
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { promise(.failure(error)) }
            else if let data = data { promise(.success(try! JSONDecoder().decode(User.self, from: data))) }
        }.resume()
    }.eraseToAnyPublisher()
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **No Storage** | `sink { }` | `store(in: &cancellables)` |
| **Background UI** | No receive(on:) | `.receive(on: .main)` |
| **Strong Self** | `self.update()` | `[weak self]` |
| **No Completion** | `.sink { value in }` | Handle completion too |

## AI Self-Check

- [ ] Storing cancellables?
- [ ] eraseToAnyPublisher() for APIs?
- [ ] Handling completion/errors?
- [ ] receive(on: .main) for UI?
- [ ] [weak self] in closures?
- [ ] No ignored cancellables?
- [ ] No background UI updates?
- [ ] No retain cycles?

## Key Patterns

| Pattern | Purpose |
|---------|---------|
| PassthroughSubject | Events |
| CurrentValueSubject | State |
| @Published | Property observation |
| Future | Async operations |
| Operators | Transformation |

## Best Practices

**MUST**: Store cancellables, receive(on:) for UI, [weak self], handle errors
**SHOULD**: eraseToAnyPublisher(), operators, combine publishers
**AVOID**: Ignore cancellables, background UI updates, retain cycles
