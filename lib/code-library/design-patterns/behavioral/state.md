---
title: State Pattern
category: Behavioral Design Pattern
difficulty: intermediate
purpose: Allow an object to alter its behavior when its internal state changes, appearing to change its class
when_to_use:
  - Workflow engines and state machines
  - Order processing (Draft, Pending, Shipped, Delivered)
  - Document states (Draft, Review, Published)
  - Connection states (Connecting, Connected, Disconnected)
  - UI states (Idle, Loading, Success, Error)
  - Game character states
languages:
  typescript:
    - name: Class State (Built-in)
      library: javascript-core
      recommended: true
  python:
    - name: ABC State (Built-in)
      library: python-core
      recommended: true
  java:
    - name: Interface State (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Interface State (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Interface State (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Sealed Class State (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Protocol State (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Abstract State (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Finite State Machine (FSM)
  - State transitions
  - State-specific behavior
  - Context maintains current state
best_practices:
  do:
    - Keep states focused and cohesive
    - Use enums or sealed classes for state types
    - Handle invalid transitions gracefully
    - Consider state history/undo
    - Document state diagram
  dont:
    - Put business logic in context
    - Create complex state hierarchies
    - Allow invalid state transitions
    - Forget to handle all transitions
related_functions:
  - None
tags: [state, behavioral-pattern, state-machine, fsm, workflow]
updated: 2026-01-20
---

## TypeScript

### Order State Machine
```typescript
// State interface
interface OrderState {
  confirm(): void;
  ship(): void;
  deliver(): void;
  cancel(): void;
  getStatus(): string;
}

// Context
class Order {
  private state: OrderState;

  constructor(
    public readonly id: string,
    public readonly items: string[]
  ) {
    this.state = new DraftState(this);
  }

  setState(state: OrderState): void {
    this.state = state;
  }

  confirm(): void {
    this.state.confirm();
  }

  ship(): void {
    this.state.ship();
  }

  deliver(): void {
    this.state.deliver();
  }

  cancel(): void {
    this.state.cancel();
  }

  getStatus(): string {
    return this.state.getStatus();
  }
}

// Concrete states
class DraftState implements OrderState {
  constructor(private order: Order) {}

  confirm(): void {
    console.log('Order confirmed');
    this.order.setState(new ConfirmedState(this.order));
  }

  ship(): void {
    console.log('Cannot ship draft order');
  }

  deliver(): void {
    console.log('Cannot deliver draft order');
  }

  cancel(): void {
    console.log('Order cancelled');
    this.order.setState(new CancelledState(this.order));
  }

  getStatus(): string {
    return 'Draft';
  }
}

class ConfirmedState implements OrderState {
  constructor(private order: Order) {}

  confirm(): void {
    console.log('Order already confirmed');
  }

  ship(): void {
    console.log('Order shipped');
    this.order.setState(new ShippedState(this.order));
  }

  deliver(): void {
    console.log('Cannot deliver unshipped order');
  }

  cancel(): void {
    console.log('Order cancelled');
    this.order.setState(new CancelledState(this.order));
  }

  getStatus(): string {
    return 'Confirmed';
  }
}

class ShippedState implements OrderState {
  constructor(private order: Order) {}

  confirm(): void {
    console.log('Order already confirmed and shipped');
  }

  ship(): void {
    console.log('Order already shipped');
  }

  deliver(): void {
    console.log('Order delivered');
    this.order.setState(new DeliveredState(this.order));
  }

  cancel(): void {
    console.log('Cannot cancel shipped order');
  }

  getStatus(): string {
    return 'Shipped';
  }
}

class DeliveredState implements OrderState {
  constructor(private order: Order) {}

  confirm(): void {
    console.log('Order already delivered');
  }

  ship(): void {
    console.log('Order already delivered');
  }

  deliver(): void {
    console.log('Order already delivered');
  }

  cancel(): void {
    console.log('Cannot cancel delivered order');
  }

  getStatus(): string {
    return 'Delivered';
  }
}

class CancelledState implements OrderState {
  constructor(private order: Order) {}

  confirm(): void {
    console.log('Cannot confirm cancelled order');
  }

  ship(): void {
    console.log('Cannot ship cancelled order');
  }

  deliver(): void {
    console.log('Cannot deliver cancelled order');
  }

  cancel(): void {
    console.log('Order already cancelled');
  }

  getStatus(): string {
    return 'Cancelled';
  }
}

// Usage
const order = new Order('ORD-123', ['Item 1', 'Item 2']);

console.log(`Status: ${order.getStatus()}`); // Draft
order.confirm();
console.log(`Status: ${order.getStatus()}`); // Confirmed
order.ship();
console.log(`Status: ${order.getStatus()}`); // Shipped
order.deliver();
console.log(`Status: ${order.getStatus()}`); // Delivered
```

### Document State Machine
```typescript
interface DocumentState {
  edit(): void;
  submit(): void;
  approve(): void;
  publish(): void;
  reject(): void;
}

class Document {
  private state: DocumentState;

  constructor(public content: string) {
    this.state = new DraftDocState(this);
  }

  setState(state: DocumentState): void {
    this.state = state;
  }

  edit(): void {
    this.state.edit();
  }

  submit(): void {
    this.state.submit();
  }

  approve(): void {
    this.state.approve();
  }

  publish(): void {
    this.state.publish();
  }

  reject(): void {
    this.state.reject();
  }
}

class DraftDocState implements DocumentState {
  constructor(private doc: Document) {}

  edit(): void {
    console.log('Editing draft...');
  }

  submit(): void {
    console.log('Submitting for review...');
    this.doc.setState(new InReviewState(this.doc));
  }

  approve(): void {
    console.log('Cannot approve draft');
  }

  publish(): void {
    console.log('Cannot publish draft');
  }

  reject(): void {
    console.log('Cannot reject draft');
  }
}

class InReviewState implements DocumentState {
  constructor(private doc: Document) {}

  edit(): void {
    console.log('Cannot edit during review');
  }

  submit(): void {
    console.log('Already in review');
  }

  approve(): void {
    console.log('Document approved');
    this.doc.setState(new ApprovedState(this.doc));
  }

  publish(): void {
    console.log('Cannot publish - needs approval');
  }

  reject(): void {
    console.log('Document rejected');
    this.doc.setState(new DraftDocState(this.doc));
  }
}

class ApprovedState implements DocumentState {
  constructor(private doc: Document) {}

  edit(): void {
    console.log('Cannot edit approved document');
  }

  submit(): void {
    console.log('Already approved');
  }

  approve(): void {
    console.log('Already approved');
  }

  publish(): void {
    console.log('Publishing document...');
    this.doc.setState(new PublishedState(this.doc));
  }

  reject(): void {
    console.log('Sending back to draft');
    this.doc.setState(new DraftDocState(this.doc));
  }
}

class PublishedState implements DocumentState {
  constructor(private doc: Document) {}

  edit(): void {
    console.log('Cannot edit published document');
  }

  submit(): void {
    console.log('Already published');
  }

  approve(): void {
    console.log('Already published');
  }

  publish(): void {
    console.log('Already published');
  }

  reject(): void {
    console.log('Cannot reject published document');
  }
}
```

---

## Python

### Order State Machine
```python
from abc import ABC, abstractmethod

# State interface
class OrderState(ABC):
    @abstractmethod
    def confirm(self) -> None:
        pass

    @abstractmethod
    def ship(self) -> None:
        pass

    @abstractmethod
    def deliver(self) -> None:
        pass

    @abstractmethod
    def cancel(self) -> None:
        pass

    @abstractmethod
    def get_status(self) -> str:
        pass

# Context
class Order:
    def __init__(self, order_id: str, items: list[str]):
        self.id = order_id
        self.items = items
        self._state: OrderState = DraftState(self)

    def set_state(self, state: OrderState) -> None:
        self._state = state

    def confirm(self) -> None:
        self._state.confirm()

    def ship(self) -> None:
        self._state.ship()

    def deliver(self) -> None:
        self._state.deliver()

    def cancel(self) -> None:
        self._state.cancel()

    def get_status(self) -> str:
        return self._state.get_status()

# Concrete states
class DraftState(OrderState):
    def __init__(self, order: Order):
        self._order = order

    def confirm(self) -> None:
        print("Order confirmed")
        self._order.set_state(ConfirmedState(self._order))

    def ship(self) -> None:
        print("Cannot ship draft order")

    def deliver(self) -> None:
        print("Cannot deliver draft order")

    def cancel(self) -> None:
        print("Order cancelled")
        self._order.set_state(CancelledState(self._order))

    def get_status(self) -> str:
        return "Draft"

class ConfirmedState(OrderState):
    def __init__(self, order: Order):
        self._order = order

    def confirm(self) -> None:
        print("Order already confirmed")

    def ship(self) -> None:
        print("Order shipped")
        self._order.set_state(ShippedState(self._order))

    def deliver(self) -> None:
        print("Cannot deliver unshipped order")

    def cancel(self) -> None:
        print("Order cancelled")
        self._order.set_state(CancelledState(self._order))

    def get_status(self) -> str:
        return "Confirmed"

class ShippedState(OrderState):
    def __init__(self, order: Order):
        self._order = order

    def confirm(self) -> None:
        print("Order already confirmed and shipped")

    def ship(self) -> None:
        print("Order already shipped")

    def deliver(self) -> None:
        print("Order delivered")
        self._order.set_state(DeliveredState(self._order))

    def cancel(self) -> None:
        print("Cannot cancel shipped order")

    def get_status(self) -> str:
        return "Shipped"

class DeliveredState(OrderState):
    def __init__(self, order: Order):
        self._order = order

    def confirm(self) -> None:
        print("Order already delivered")

    def ship(self) -> None:
        print("Order already delivered")

    def deliver(self) -> None:
        print("Order already delivered")

    def cancel(self) -> None:
        print("Cannot cancel delivered order")

    def get_status(self) -> str:
        return "Delivered"

class CancelledState(OrderState):
    def __init__(self, order: Order):
        self._order = order

    def confirm(self) -> None:
        print("Cannot confirm cancelled order")

    def ship(self) -> None:
        print("Cannot ship cancelled order")

    def deliver(self) -> None:
        print("Cannot deliver cancelled order")

    def cancel(self) -> None:
        print("Order already cancelled")

    def get_status(self) -> str:
        return "Cancelled"

# Usage
order = Order("ORD-123", ["Item 1", "Item 2"])

print(f"Status: {order.get_status()}")  # Draft
order.confirm()
print(f"Status: {order.get_status()}")  # Confirmed
order.ship()
print(f"Status: {order.get_status()}")  # Shipped
order.deliver()
print(f"Status: {order.get_status()}")  # Delivered
```

---

## Java

### Order State Machine
```java
// State interface
interface OrderState {
    void confirm();
    void ship();
    void deliver();
    void cancel();
    String getStatus();
}

// Context
class Order {
    private OrderState state;
    private final String id;
    private final List<String> items;

    public Order(String id, List<String> items) {
        this.id = id;
        this.items = items;
        this.state = new DraftState(this);
    }

    public void setState(OrderState state) {
        this.state = state;
    }

    public void confirm() {
        state.confirm();
    }

    public void ship() {
        state.ship();
    }

    public void deliver() {
        state.deliver();
    }

    public void cancel() {
        state.cancel();
    }

    public String getStatus() {
        return state.getStatus();
    }
}

// Concrete states
class DraftState implements OrderState {
    private final Order order;

    public DraftState(Order order) {
        this.order = order;
    }

    @Override
    public void confirm() {
        System.out.println("Order confirmed");
        order.setState(new ConfirmedState(order));
    }

    @Override
    public void ship() {
        System.out.println("Cannot ship draft order");
    }

    @Override
    public void deliver() {
        System.out.println("Cannot deliver draft order");
    }

    @Override
    public void cancel() {
        System.out.println("Order cancelled");
        order.setState(new CancelledState(order));
    }

    @Override
    public String getStatus() {
        return "Draft";
    }
}

class ConfirmedState implements OrderState {
    private final Order order;

    public ConfirmedState(Order order) {
        this.order = order;
    }

    @Override
    public void confirm() {
        System.out.println("Order already confirmed");
    }

    @Override
    public void ship() {
        System.out.println("Order shipped");
        order.setState(new ShippedState(order));
    }

    @Override
    public void deliver() {
        System.out.println("Cannot deliver unshipped order");
    }

    @Override
    public void cancel() {
        System.out.println("Order cancelled");
        order.setState(new CancelledState(order));
    }

    @Override
    public String getStatus() {
        return "Confirmed";
    }
}

// Usage
Order order = new Order("ORD-123", List.of("Item 1", "Item 2"));

System.out.println("Status: " + order.getStatus()); // Draft
order.confirm();
System.out.println("Status: " + order.getStatus()); // Confirmed
order.ship();
System.out.println("Status: " + order.getStatus()); // Shipped
```

---

## C#

### Order State Machine
```csharp
// State interface
public interface IOrderState
{
    void Confirm();
    void Ship();
    void Deliver();
    void Cancel();
    string GetStatus();
}

// Context
public class Order
{
    private IOrderState _state;
    public string Id { get; }
    public List<string> Items { get; }

    public Order(string id, List<string> items)
    {
        Id = id;
        Items = items;
        _state = new DraftState(this);
    }

    public void SetState(IOrderState state)
    {
        _state = state;
    }

    public void Confirm() => _state.Confirm();
    public void Ship() => _state.Ship();
    public void Deliver() => _state.Deliver();
    public void Cancel() => _state.Cancel();
    public string GetStatus() => _state.GetStatus();
}

// Concrete states
public class DraftState : IOrderState
{
    private readonly Order _order;

    public DraftState(Order order)
    {
        _order = order;
    }

    public void Confirm()
    {
        Console.WriteLine("Order confirmed");
        _order.SetState(new ConfirmedState(_order));
    }

    public void Ship()
    {
        Console.WriteLine("Cannot ship draft order");
    }

    public void Deliver()
    {
        Console.WriteLine("Cannot deliver draft order");
    }

    public void Cancel()
    {
        Console.WriteLine("Order cancelled");
        _order.SetState(new CancelledState(_order));
    }

    public string GetStatus() => "Draft";
}

public class ConfirmedState : IOrderState
{
    private readonly Order _order;

    public ConfirmedState(Order order)
    {
        _order = order;
    }

    public void Confirm()
    {
        Console.WriteLine("Order already confirmed");
    }

    public void Ship()
    {
        Console.WriteLine("Order shipped");
        _order.SetState(new ShippedState(_order));
    }

    public void Deliver()
    {
        Console.WriteLine("Cannot deliver unshipped order");
    }

    public void Cancel()
    {
        Console.WriteLine("Order cancelled");
        _order.SetState(new CancelledState(_order));
    }

    public string GetStatus() => "Confirmed";
}

// Usage
var order = new Order("ORD-123", new List<string> { "Item 1", "Item 2" });

Console.WriteLine($"Status: {order.GetStatus()}"); // Draft
order.Confirm();
Console.WriteLine($"Status: {order.GetStatus()}"); // Confirmed
order.Ship();
Console.WriteLine($"Status: {order.GetStatus()}"); // Shipped
```

---

## PHP

### Order State Machine
```php
// State interface
interface OrderState
{
    public function confirm(): void;
    public function ship(): void;
    public function deliver(): void;
    public function cancel(): void;
    public function getStatus(): string;
}

// Context
class Order
{
    private OrderState $state;

    public function __construct(
        public readonly string $id,
        public readonly array $items
    ) {
        $this->state = new DraftState($this);
    }

    public function setState(OrderState $state): void
    {
        $this->state = $state;
    }

    public function confirm(): void
    {
        $this->state->confirm();
    }

    public function ship(): void
    {
        $this->state->ship();
    }

    public function deliver(): void
    {
        $this->state->deliver();
    }

    public function cancel(): void
    {
        $this->state->cancel();
    }

    public function getStatus(): string
    {
        return $this->state->getStatus();
    }
}

// Concrete states
class DraftState implements OrderState
{
    public function __construct(private Order $order) {}

    public function confirm(): void
    {
        echo "Order confirmed\n";
        $this->order->setState(new ConfirmedState($this->order));
    }

    public function ship(): void
    {
        echo "Cannot ship draft order\n";
    }

    public function deliver(): void
    {
        echo "Cannot deliver draft order\n";
    }

    public function cancel(): void
    {
        echo "Order cancelled\n";
        $this->order->setState(new CancelledState($this->order));
    }

    public function getStatus(): string
    {
        return 'Draft';
    }
}

class ConfirmedState implements OrderState
{
    public function __construct(private Order $order) {}

    public function confirm(): void
    {
        echo "Order already confirmed\n";
    }

    public function ship(): void
    {
        echo "Order shipped\n";
        $this->order->setState(new ShippedState($this->order));
    }

    public function deliver(): void
    {
        echo "Cannot deliver unshipped order\n";
    }

    public function cancel(): void
    {
        echo "Order cancelled\n";
        $this->order->setState(new CancelledState($this->order));
    }

    public function getStatus(): string
    {
        return 'Confirmed';
    }
}

// Usage
$order = new Order('ORD-123', ['Item 1', 'Item 2']);

echo "Status: {$order->getStatus()}\n"; // Draft
$order->confirm();
echo "Status: {$order->getStatus()}\n"; // Confirmed
$order->ship();
echo "Status: {$order->getStatus()}\n"; // Shipped
```

---

## Kotlin

### Order State Machine with Sealed Classes
```kotlin
// Sealed class for states (type-safe)
sealed class OrderState {
    abstract fun confirm(order: Order)
    abstract fun ship(order: Order)
    abstract fun deliver(order: Order)
    abstract fun cancel(order: Order)
    abstract fun getStatus(): String

    object Draft : OrderState() {
        override fun confirm(order: Order) {
            println("Order confirmed")
            order.setState(Confirmed)
        }

        override fun ship(order: Order) {
            println("Cannot ship draft order")
        }

        override fun deliver(order: Order) {
            println("Cannot deliver draft order")
        }

        override fun cancel(order: Order) {
            println("Order cancelled")
            order.setState(Cancelled)
        }

        override fun getStatus() = "Draft"
    }

    object Confirmed : OrderState() {
        override fun confirm(order: Order) {
            println("Order already confirmed")
        }

        override fun ship(order: Order) {
            println("Order shipped")
            order.setState(Shipped)
        }

        override fun deliver(order: Order) {
            println("Cannot deliver unshipped order")
        }

        override fun cancel(order: Order) {
            println("Order cancelled")
            order.setState(Cancelled)
        }

        override fun getStatus() = "Confirmed"
    }

    object Shipped : OrderState() {
        override fun confirm(order: Order) {
            println("Order already confirmed and shipped")
        }

        override fun ship(order: Order) {
            println("Order already shipped")
        }

        override fun deliver(order: Order) {
            println("Order delivered")
            order.setState(Delivered)
        }

        override fun cancel(order: Order) {
            println("Cannot cancel shipped order")
        }

        override fun getStatus() = "Shipped"
    }

    object Delivered : OrderState() {
        override fun confirm(order: Order) {
            println("Order already delivered")
        }

        override fun ship(order: Order) {
            println("Order already delivered")
        }

        override fun deliver(order: Order) {
            println("Order already delivered")
        }

        override fun cancel(order: Order) {
            println("Cannot cancel delivered order")
        }

        override fun getStatus() = "Delivered"
    }

    object Cancelled : OrderState() {
        override fun confirm(order: Order) {
            println("Cannot confirm cancelled order")
        }

        override fun ship(order: Order) {
            println("Cannot ship cancelled order")
        }

        override fun deliver(order: Order) {
            println("Cannot deliver cancelled order")
        }

        override fun cancel(order: Order) {
            println("Order already cancelled")
        }

        override fun getStatus() = "Cancelled"
    }
}

// Context
class Order(val id: String, val items: List<String>) {
    private var state: OrderState = OrderState.Draft

    fun setState(state: OrderState) {
        this.state = state
    }

    fun confirm() = state.confirm(this)
    fun ship() = state.ship(this)
    fun deliver() = state.deliver(this)
    fun cancel() = state.cancel(this)
    fun getStatus() = state.getStatus()
}

// Usage
val order = Order("ORD-123", listOf("Item 1", "Item 2"))

println("Status: ${order.getStatus()}") // Draft
order.confirm()
println("Status: ${order.getStatus()}") // Confirmed
order.ship()
println("Status: ${order.getStatus()}") // Shipped
```

---

## Swift

### Order State Machine
```swift
// State protocol
protocol OrderState {
    func confirm(order: Order)
    func ship(order: Order)
    func deliver(order: Order)
    func cancel(order: Order)
    func getStatus() -> String
}

// Context
class Order {
    let id: String
    let items: [String]
    private var state: OrderState

    init(id: String, items: [String]) {
        self.id = id
        self.items = items
        self.state = DraftState()
    }

    func setState(_ state: OrderState) {
        self.state = state
    }

    func confirm() {
        state.confirm(order: self)
    }

    func ship() {
        state.ship(order: self)
    }

    func deliver() {
        state.deliver(order: self)
    }

    func cancel() {
        state.cancel(order: self)
    }

    func getStatus() -> String {
        return state.getStatus()
    }
}

// Concrete states
class DraftState: OrderState {
    func confirm(order: Order) {
        print("Order confirmed")
        order.setState(ConfirmedState())
    }

    func ship(order: Order) {
        print("Cannot ship draft order")
    }

    func deliver(order: Order) {
        print("Cannot deliver draft order")
    }

    func cancel(order: Order) {
        print("Order cancelled")
        order.setState(CancelledState())
    }

    func getStatus() -> String {
        return "Draft"
    }
}

class ConfirmedState: OrderState {
    func confirm(order: Order) {
        print("Order already confirmed")
    }

    func ship(order: Order) {
        print("Order shipped")
        order.setState(ShippedState())
    }

    func deliver(order: Order) {
        print("Cannot deliver unshipped order")
    }

    func cancel(order: Order) {
        print("Order cancelled")
        order.setState(CancelledState())
    }

    func getStatus() -> String {
        return "Confirmed"
    }
}

// Usage
let order = Order(id: "ORD-123", items: ["Item 1", "Item 2"])

print("Status: \(order.getStatus())") // Draft
order.confirm()
print("Status: \(order.getStatus())") // Confirmed
order.ship()
print("Status: \(order.getStatus())") // Shipped
```

---

## Dart

### Order State Machine
```dart
// State interface
abstract class OrderState {
  void confirm(Order order);
  void ship(Order order);
  void deliver(Order order);
  void cancel(Order order);
  String getStatus();
}

// Context
class Order {
  final String id;
  final List<String> items;
  OrderState _state;

  Order(this.id, this.items) : _state = DraftState();

  void setState(OrderState state) {
    _state = state;
  }

  void confirm() => _state.confirm(this);
  void ship() => _state.ship(this);
  void deliver() => _state.deliver(this);
  void cancel() => _state.cancel(this);
  String getStatus() => _state.getStatus();
}

// Concrete states
class DraftState implements OrderState {
  @override
  void confirm(Order order) {
    print('Order confirmed');
    order.setState(ConfirmedState());
  }

  @override
  void ship(Order order) {
    print('Cannot ship draft order');
  }

  @override
  void deliver(Order order) {
    print('Cannot deliver draft order');
  }

  @override
  void cancel(Order order) {
    print('Order cancelled');
    order.setState(CancelledState());
  }

  @override
  String getStatus() => 'Draft';
}

class ConfirmedState implements OrderState {
  @override
  void confirm(Order order) {
    print('Order already confirmed');
  }

  @override
  void ship(Order order) {
    print('Order shipped');
    order.setState(ShippedState());
  }

  @override
  void deliver(Order order) {
    print('Cannot deliver unshipped order');
  }

  @override
  void cancel(Order order) {
    print('Order cancelled');
    order.setState(CancelledState());
  }

  @override
  String getStatus() => 'Confirmed';
}

class ShippedState implements OrderState {
  @override
  void confirm(Order order) {
    print('Order already confirmed and shipped');
  }

  @override
  void ship(Order order) {
    print('Order already shipped');
  }

  @override
  void deliver(Order order) {
    print('Order delivered');
    order.setState(DeliveredState());
  }

  @override
  void cancel(Order order) {
    print('Cannot cancel shipped order');
  }

  @override
  String getStatus() => 'Shipped';
}

class DeliveredState implements OrderState {
  @override
  void confirm(Order order) => print('Order already delivered');
  @override
  void ship(Order order) => print('Order already delivered');
  @override
  void deliver(Order order) => print('Order already delivered');
  @override
  void cancel(Order order) => print('Cannot cancel delivered order');
  @override
  String getStatus() => 'Delivered';
}

class CancelledState implements OrderState {
  @override
  void confirm(Order order) => print('Cannot confirm cancelled order');
  @override
  void ship(Order order) => print('Cannot ship cancelled order');
  @override
  void deliver(Order order) => print('Cannot deliver cancelled order');
  @override
  void cancel(Order order) => print('Order already cancelled');
  @override
  String getStatus() => 'Cancelled';
}

// Usage
void main() {
  final order = Order('ORD-123', ['Item 1', 'Item 2']);

  print('Status: ${order.getStatus()}'); // Draft
  order.confirm();
  print('Status: ${order.getStatus()}'); // Confirmed
  order.ship();
  print('Status: ${order.getStatus()}'); // Shipped
  order.deliver();
  print('Status: ${order.getStatus()}'); // Delivered
}
```
