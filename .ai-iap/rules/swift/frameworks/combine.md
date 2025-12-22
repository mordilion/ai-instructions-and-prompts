# Combine Framework

## Overview
Combine: Apple's framework for processing values over time.

## Publishers

### Basic Publishers
```swift
// Just
let just = Just(42)

// Future
let future = Future<String, Never> { promise in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        promise(.success("Hello"))
    }
}

// Subject
let passthroughSubject = PassthroughSubject<String, Never>()
let currentValueSubject = CurrentValueSubject<Int, Never>(0)
```

## Operators

### Transformation
```swift
[1, 2, 3].publisher
    .map { $0 * 2 }
    .sink { print($0) }

// flatMap
userIDs.publisher
    .flatMap { id in fetchUser(id: id) }
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })

// compactMap
[1, nil, 3].publisher
    .compactMap { $0 }
    .sink { print($0) }
```

### Filtering
```swift
numbers.publisher
    .filter { $0 % 2 == 0 }
    .removeDuplicates()
    .sink { print($0) }
```

### Combining
```swift
publisher1.zip(publisher2)
    .sink { number, letter in print("\(number)\(letter)") }

temperature.combineLatest(humidity)
    .sink { temp, hum in print("Temp: \(temp)°, Humidity: \(hum)%") }
```

### Error Handling
```swift
func fetchData() -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .retry(3)
        .catch { _ in Just(Data()) }
        .eraseToAnyPublisher()
}
```

## Subscribers

```swift
// sink
let cancellable = publisher
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished: print("Done")
            case .failure(let error): print("Error: \(error)")
            }
        },
        receiveValue: { print($0) }
    )

// assign
class ViewModel: ObservableObject {
    @Published var users: [User] = []
    private var cancellables = Set<AnyCancellable>()
    
    func loadUsers() {
        fetchUsers()
            .assign(to: \.users, on: self)
            .store(in: &cancellables)
    }
}
```

## Subjects

### PassthroughSubject
```swift
class EventManager {
    let eventPublisher = PassthroughSubject<Event, Never>()
    
    func sendEvent(_ event: Event) {
        eventPublisher.send(event)
    }
}
```

### CurrentValueSubject
```swift
class UserViewModel: ObservableObject {
    let state = CurrentValueSubject<ViewState, Never>(.idle)
    
    func loadData() {
        state.send(.loading)
        fetchData()
            .sink(
                receiveCompletion: { [weak self] in
                    if case .failure = $0 { self?.state.send(.error) }
                },
                receiveValue: { [weak self] in self?.state.send(.loaded($0)) }
            )
    }
}
```

## Memory Management

```swift
class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.userPublisher
            .sink { [weak self] in self?.updateUI(with: $0) }
            .store(in: &cancellables)
    }
}
```

## Schedulers

```swift
fetchData()
    .subscribe(on: DispatchQueue.global())
    .receive(on: DispatchQueue.main)
    .sink { updateUI(with: $0) }

// Debounce & Throttle
searchField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { performSearch($0) }

button.tapPublisher
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
    .sink { handleTap() }
```

## Networking

```swift
func fetchUsers() -> AnyPublisher<[User], Error> {
    URLSession.shared.dataTaskPublisher(for: URL(string: "https://api.example.com/users")!)
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

## SwiftUI Integration

```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    func loadUsers() {
        isLoading = true
        fetchUsers()
            .sink(
                receiveCompletion: { [weak self] in
                    self?.isLoading = false
                    if case .failure(let error) = $0 {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] in self?.users = $0 }
            )
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Time: \(currentTime)")
            .onReceive(timer) { _ in updateTime() }
    }
}
```

## Testing

```swift
class ViewModelTests: XCTestCase {
    var sut: ViewModel!
    var cancellables: Set<AnyCancellable>!
    
    func testLoadUsers() {
        let expectation = XCTestExpectation()
        var receivedUsers: [User] = []
        
        sut.$users
            .dropFirst()
            .sink {
                receivedUsers = $0
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadUsers()
        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(receivedUsers.isEmpty)
    }
}
```

## Best Practices

**MUST**:
- Store cancellables in `Set<AnyCancellable>` or use `.store(in:)`
- Use `[weak self]` in sink closures to prevent retain cycles
- Handle completion (`.finished` and `.failure`) explicitly
- Use `.receive(on: DispatchQueue.main)` for UI updates
- Cancel subscriptions when done (automatic with stored cancellables)

**SHOULD**:
- Use `eraseToAnyPublisher()` for public APIs (hide implementation)
- Use `@Published` for observable properties in ObservableObject
- Use operators (map, filter, etc.) over manual subscription logic
- Use `PassthroughSubject` for events, `CurrentValueSubject` for state
- Use `.assign(to:)` for simple property updates

**AVOID**:
- Not storing cancellables (subscriptions immediately cancelled)
- Retain cycles in closures (use `[weak self]`)
- Complex logic in operators (move to separate functions)
- Ignoring errors (handle with `.catch` or completion)
- Using Combine for simple one-time async calls (use async/await)

## Common Patterns

### Type Erasure (Public APIs)
```swift
// ✅ GOOD: Hide implementation details
func fetchData() -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .eraseToAnyPublisher()  // Type erasure
}

// ❌ BAD: Exposing implementation
func fetchData() -> URLSession.DataTaskPublisher {
    URLSession.shared.dataTaskPublisher(for: url)  // Leaks implementation
}
```

### Memory Management
```swift
// ✅ GOOD: [weak self] + stored cancellable
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        publisher
            .sink(receiveValue: { [weak self] value in
                self?.updateUI(value)
            })
            .store(in: &cancellables)  // Stored = cleaned up with ViewModel
    }
}

// ❌ BAD: Retain cycle + not stored
class ViewModel: ObservableObject {
    func loadData() {
        publisher
            .sink(receiveValue: { value in
                self.updateUI(value)  // Retain cycle!
            })
        // Not stored = immediately cancelled!
    }
}
```

### Completion Handling
```swift
// ✅ GOOD: Explicit completion handling
publisher.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Stream completed successfully")
        case .failure(let error):
            print("Error: \(error)")
            // Handle error (show alert, retry, etc.)
        }
    },
    receiveValue: { value in
        print("Received: \(value)")
    }
)
.store(in: &cancellables)

// ❌ BAD: Ignoring completion
publisher
    .sink { value in print(value) }  // What if it fails?
    .store(in: &cancellables)
```

### Operator Chaining
```swift
// ✅ GOOD: Clean operator chain
searchField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)  // Wait for typing pause
    .removeDuplicates()  // Skip duplicates
    .filter { !$0.isEmpty }  // Ignore empty
    .flatMap { query in
        searchService.search(query)  // Async search
            .catch { _ in Just([]) }  // Handle errors gracefully
    }
    .receive(on: DispatchQueue.main)  // UI updates on main thread
    .sink { [weak self] results in
        self?.displayResults(results)
    }
    .store(in: &cancellables)
```
