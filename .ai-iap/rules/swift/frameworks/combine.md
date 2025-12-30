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

### Publishers

```swift
// Just (single value)
let just = Just(42)

// PassthroughSubject (manual emissions)
let subject = PassthroughSubject<String, Never>()
subject.send("Hello")

// CurrentValueSubject (stateful)
let state = CurrentValueSubject<Int, Never>(0)
print(state.value)

// @Published (property wrapper)
class ViewModel: ObservableObject {
    @Published var username = ""
    @Published var isLoading = false
}
```

### Subscription

```swift
class ViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        dataService.fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error: \(error)")
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

### Operators

```swift
publisher
    .map { $0.uppercased() }
    .filter { $0.count > 5 }
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { value in print(value) }
    .store(in: &cancellables)
```

### Combining Publishers

```swift
// Zip: wait for all
Publishers.Zip(publisher1, publisher2)
    .sink { value1, value2 in /* Both ready */ }
    .store(in: &cancellables)

// CombineLatest: emit on any change
Publishers.CombineLatest(publisher1, publisher2)
    .sink { value1, value2 in /* Latest from each */ }
    .store(in: &cancellables)

// Merge: combine same types
Publishers.Merge(publisher1, publisher2)
    .sink { value in /* From either */ }
    .store(in: &cancellables)
```

### Future (Async)

```swift
func fetchUser(id: Int) -> AnyPublisher<User, Error> {
    Future { promise in
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                promise(.failure(error))
            } else if let data = data {
                let user = try? JSONDecoder().decode(User.self, from: data)
                promise(.success(user!))
            }
        }.resume()
    }
    .eraseToAnyPublisher()
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
