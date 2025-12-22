# Combine Framework

## Overview
Combine is Apple's framework for processing values over time using declarative Swift code.

## Publishers

### Basic Publishers
```swift
// ✅ Good - create publishers
import Combine

// Just - single value
let justPublisher = Just(42)

// Future - async value
let futurePublisher = Future<String, Never> { promise in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        promise(.success("Hello"))
    }
}

// Subject - send values manually
let passthroughSubject = PassthroughSubject<String, Never>()
let currentValueSubject = CurrentValueSubject<Int, Never>(0)
```

### Custom Publishers
```swift
// ✅ Good - custom publisher
struct UserPublisher: Publisher {
    typealias Output = User
    typealias Failure = NetworkError
    
    private let userID: Int
    
    init(userID: Int) {
        self.userID = userID
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = UserSubscription(subscriber: subscriber, userID: userID)
        subscriber.receive(subscription: subscription)
    }
}
```

## Operators

### Transformation
```swift
// ✅ Good - map, flatMap, compactMap
let numbers = [1, 2, 3, 4, 5].publisher

numbers
    .map { $0 * 2 }
    .sink { print($0) }  // 2, 4, 6, 8, 10

// ✅ Good - flatMap for nested publishers
let userIDs = [1, 2, 3].publisher

userIDs
    .flatMap { id in
        fetchUser(id: id)
    }
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { user in print(user) }
    )

// ✅ Good - compactMap to filter nils
let optionalNumbers = [1, nil, 3, nil, 5].publisher

optionalNumbers
    .compactMap { $0 }
    .sink { print($0) }  // 1, 3, 5
```

### Filtering
```swift
// ✅ Good - filter, removeDuplicates
numbers
    .filter { $0 % 2 == 0 }
    .sink { print($0) }  // Even numbers only

let values = [1, 1, 2, 2, 3, 3].publisher
values
    .removeDuplicates()
    .sink { print($0) }  // 1, 2, 3
```

### Combining
```swift
// ✅ Good - zip, combineLatest
let publisher1 = [1, 2, 3].publisher
let publisher2 = ["A", "B", "C"].publisher

publisher1.zip(publisher2)
    .sink { number, letter in
        print("\(number)\(letter)")  // 1A, 2B, 3C
    }

// ✅ Good - combineLatest
let temperature = PassthroughSubject<Double, Never>()
let humidity = PassthroughSubject<Double, Never>()

temperature.combineLatest(humidity)
    .sink { temp, hum in
        print("Temp: \(temp)°, Humidity: \(hum)%")
    }
```

### Error Handling
```swift
// ✅ Good - catch, retry
func fetchData() -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .retry(3)
        .catch { error -> Just<Data> in
            print("Error: \(error)")
            return Just(Data())
        }
        .eraseToAnyPublisher()
}
```

## Subscribers

### Built-in Subscribers
```swift
// ✅ Good - sink
let cancellable = publisher
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Finished")
            case .failure(let error):
                print("Error: \(error)")
            }
        },
        receiveValue: { value in
            print("Value: \(value)")
        }
    )

// ✅ Good - assign
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
// ✅ Good - event stream
class EventManager {
    let eventPublisher = PassthroughSubject<Event, Never>()
    
    func sendEvent(_ event: Event) {
        eventPublisher.send(event)
    }
}

let manager = EventManager()
let cancellable = manager.eventPublisher
    .sink { event in
        print("Received event: \(event)")
    }
```

### CurrentValueSubject
```swift
// ✅ Good - state management
class UserViewModel: ObservableObject {
    let state = CurrentValueSubject<ViewState, Never>(.idle)
    
    func loadData() {
        state.send(.loading)
        
        fetchData()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state.send(.error)
                    }
                },
                receiveValue: { [weak self] data in
                    self?.state.send(.loaded(data))
                }
            )
    }
}
```

## Memory Management

### Store Cancellables
```swift
// ✅ Good - store cancellables
class ViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.userPublisher
            .sink { [weak self] user in
                self?.updateUI(with: user)
            }
            .store(in: &cancellables)
    }
}
```

### AnyCancellable
```swift
// ✅ Good - manual cancellation
var cancellable: AnyCancellable?

func startListening() {
    cancellable = publisher.sink { value in
        print(value)
    }
}

func stopListening() {
    cancellable?.cancel()
    cancellable = nil
}
```

## Schedulers

### Dispatch Queue Scheduler
```swift
// ✅ Good - specify scheduler
fetchData()
    .subscribe(on: DispatchQueue.global())  // Work on background
    .receive(on: DispatchQueue.main)        // Receive on main
    .sink { data in
        updateUI(with: data)
    }
```

### Debounce & Throttle
```swift
// ✅ Good - search debouncing
searchTextField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { query in
        performSearch(query)
    }

// ✅ Good - button throttling
button.tapPublisher
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
    .sink { _ in
        handleButtonTap()
    }
```

## Networking with Combine

### URLSession Publisher
```swift
// ✅ Good - network request
func fetchUsers() -> AnyPublisher<[User], Error> {
    let url = URL(string: "https://api.example.com/users")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

// Usage
fetchUsers()
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error: \(error)")
            }
        },
        receiveValue: { users in
            print("Received \(users.count) users")
        }
    )
    .store(in: &cancellables)
```

## SwiftUI Integration

### @Published Property
```swift
// ✅ Good - observable object
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadUsers() {
        isLoading = true
        
        fetchUsers()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
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

### onReceive Modifier
```swift
// ✅ Good - observe publisher in SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Time: \(currentTime)")
            .onReceive(timer) { _ in
                updateTime()
            }
    }
}
```

## Testing

### Test Scheduler
```swift
// ✅ Good - test with TestScheduler
import XCTest
@testable import MyApp

class ViewModelTests: XCTestCase {
    var sut: ViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        sut = ViewModel()
        cancellables = []
    }
    
    func testLoadUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Load users")
        var receivedUsers: [User] = []
        
        // When
        sut.$users
            .dropFirst()  // Skip initial value
            .sink { users in
                receivedUsers = users
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadUsers()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertFalse(receivedUsers.isEmpty)
    }
}
```

## Best Practices

### 1. Use eraseToAnyPublisher
```swift
// ✅ Good - type erasure for clean APIs
func fetchData() -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .eraseToAnyPublisher()
}
```

### 2. Avoid Retain Cycles
```swift
// ✅ Good - use [weak self]
publisher
    .sink { [weak self] value in
        self?.handle(value)
    }
    .store(in: &cancellables)
```

### 3. Handle Completion
```swift
// ✅ Good - always handle completion
publisher
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Done")
            case .failure(let error):
                print("Error: \(error)")
            }
        },
        receiveValue: { value in
            print(value)
        }
    )
```

### 4. Use Operators Wisely
```swift
// ✅ Good - chain operators efficiently
publisher
    .filter { $0 > 0 }
    .map { $0 * 2 }
    .removeDuplicates()
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { value in
        print(value)
    }
```

### 5. Store Cancellables Properly
```swift
// ✅ Good - use Set<AnyCancellable>
private var cancellables = Set<AnyCancellable>()

func setupBindings() {
    publisher1.sink { }.store(in: &cancellables)
    publisher2.sink { }.store(in: &cancellables)
}
```

