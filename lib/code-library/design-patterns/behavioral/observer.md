---
title: Observer Pattern
category: Behavioral Design Pattern
difficulty: intermediate
purpose: Define a one-to-many dependency where observers are notified when subject state changes
when_to_use:
  - Event handling systems
  - Pub/sub messaging
  - Model-View updates (MVC, MVVM)
  - Real-time data updates
  - Notification systems
  - State change propagation
languages:
  typescript:
    - name: Custom Observer (Built-in)
      library: javascript-core
      recommended: true
    - name: EventEmitter (Node.js)
      library: node:events
    - name: RxJS Observables
      library: rxjs
  python:
    - name: Custom Observer (Built-in)
      library: python-core
      recommended: true
    - name: Built-in Signals (Python 3.8+)
      library: python-core
    - name: PyPubSub
      library: pypubsub
  java:
    - name: Observer/Observable (Built-in, deprecated)
      library: java-core
    - name: PropertyChangeListener (Built-in)
      library: java-core
      recommended: true
    - name: RxJava
      library: io.reactivex.rxjava3:rxjava
  csharp:
    - name: Event/EventHandler (Built-in)
      library: dotnet-core
      recommended: true
    - name: IObserver/IObservable (Built-in)
      library: dotnet-core
    - name: Reactive Extensions (Rx.NET)
      library: System.Reactive
  php:
    - name: SplObserver/SplSubject (Built-in)
      library: php-core
      recommended: true
    - name: Custom Observer (Built-in)
      library: php-core
    - name: Laravel Events
      library: laravel/framework
  kotlin:
    - name: Custom Observer (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Flow (Built-in)
      library: kotlinx-coroutines-core
    - name: LiveData (Android)
      library: androidx.lifecycle:lifecycle-livedata
  swift:
    - name: NotificationCenter (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Combine Publishers
      library: swift-stdlib
    - name: Custom Observer (Built-in)
      library: swift-stdlib
  dart:
    - name: Stream/StreamController (Built-in)
      library: dart-core
      recommended: true
    - name: ChangeNotifier (Flutter)
      library: flutter
    - name: Custom Observer (Built-in)
      library: dart-core
common_patterns:
  - Push vs Pull model
  - Event registration and deregistration
  - Weak references to prevent memory leaks
  - Async notification
  - Event filtering
best_practices:
  do:
    - Use weak references for observers to prevent memory leaks
    - Unsubscribe observers when no longer needed
    - Handle errors in observer notifications gracefully
    - Consider async notifications for long-running handlers
    - Document notification order if it matters
    - Use modern reactive libraries (RxJS, Combine, Flow) for complex cases
  dont:
    - Create circular observer dependencies
    - Modify subject state in observer handlers
    - Throw exceptions from observer handlers
    - Use observer for tight coupling - prefer direct calls
    - Forget to unregister observers (memory leaks)
related_functions:
  - async-operations.md
  - logging.md
  - webhooks.md
tags: [observer, behavioral-pattern, event-handling, pub-sub, reactive]
updated: 2026-01-20
---

## TypeScript

### Custom Observer
```typescript
interface Observer<T> {
  update(data: T): void;
}

interface Subject<T> {
  attach(observer: Observer<T>): void;
  detach(observer: Observer<T>): void;
  notify(data: T): void;
}

class StockPrice implements Subject<number> {
  private observers: Set<Observer<number>> = new Set();
  private price: number = 0;

  attach(observer: Observer<number>): void {
    this.observers.add(observer);
  }

  detach(observer: Observer<number>): void {
    this.observers.delete(observer);
  }

  notify(data: number): void {
    this.observers.forEach(observer => observer.update(data));
  }

  setPrice(newPrice: number): void {
    this.price = newPrice;
    this.notify(this.price);
  }
}

class PriceDisplay implements Observer<number> {
  update(price: number): void {
    console.log(`Price updated: $${price}`);
  }
}

// Usage
const stock = new StockPrice();
const display = new PriceDisplay();
stock.attach(display);
stock.setPrice(150.25);
```

### EventEmitter (Node.js)
```typescript
import { EventEmitter } from 'events';

class StockPrice extends EventEmitter {
  private price: number = 0;

  setPrice(newPrice: number): void {
    this.price = newPrice;
    this.emit('priceChanged', this.price);
  }

  getPrice(): number {
    return this.price;
  }
}

// Usage
const stock = new StockPrice();
stock.on('priceChanged', (price: number) => {
  console.log(`Price updated: $${price}`);
});
stock.setPrice(150.25);
```

### RxJS Observable
```typescript
import { Subject } from 'rxjs';

class StockPrice {
  private priceSubject = new Subject<number>();
  public price$ = this.priceSubject.asObservable();
  private price: number = 0;

  setPrice(newPrice: number): void {
    this.price = newPrice;
    this.priceSubject.next(this.price);
  }
}

// Usage
const stock = new StockPrice();
stock.price$.subscribe(price => {
  console.log(`Price updated: $${price}`);
});
stock.setPrice(150.25);
```

---

## Python

### Custom Observer
```python
from abc import ABC, abstractmethod
from typing import Set

class Observer(ABC):
    @abstractmethod
    def update(self, data: float) -> None:
        pass

class Subject(ABC):
    @abstractmethod
    def attach(self, observer: Observer) -> None:
        pass

    @abstractmethod
    def detach(self, observer: Observer) -> None:
        pass

    @abstractmethod
    def notify(self, data: float) -> None:
        pass

class StockPrice(Subject):
    def __init__(self):
        self._observers: Set[Observer] = set()
        self._price: float = 0.0

    def attach(self, observer: Observer) -> None:
        self._observers.add(observer)

    def detach(self, observer: Observer) -> None:
        self._observers.discard(observer)

    def notify(self, data: float) -> None:
        for observer in self._observers:
            observer.update(data)

    def set_price(self, new_price: float) -> None:
        self._price = new_price
        self.notify(self._price)

class PriceDisplay(Observer):
    def update(self, price: float) -> None:
        print(f"Price updated: ${price}")

# Usage
stock = StockPrice()
display = PriceDisplay()
stock.attach(display)
stock.set_price(150.25)
```

### Using weakref to Prevent Memory Leaks
```python
import weakref
from typing import Set

class StockPrice:
    def __init__(self):
        self._observers: Set[weakref.ref] = set()
        self._price: float = 0.0

    def attach(self, observer) -> None:
        self._observers.add(weakref.ref(observer))

    def notify(self, data: float) -> None:
        dead_refs = set()
        for observer_ref in self._observers:
            observer = observer_ref()
            if observer is not None:
                observer.update(data)
            else:
                dead_refs.add(observer_ref)
        self._observers -= dead_refs

    def set_price(self, new_price: float) -> None:
        self._price = new_price
        self.notify(self._price)
```

---

## Java

### PropertyChangeListener (Recommended)
```java
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;

class StockPrice {
    private final PropertyChangeSupport support;
    private double price;

    public StockPrice() {
        this.support = new PropertyChangeSupport(this);
        this.price = 0.0;
    }

    public void addPropertyChangeListener(PropertyChangeListener listener) {
        support.addPropertyChangeListener(listener);
    }

    public void removePropertyChangeListener(PropertyChangeListener listener) {
        support.removePropertyChangeListener(listener);
    }

    public void setPrice(double newPrice) {
        double oldPrice = this.price;
        this.price = newPrice;
        support.firePropertyChange("price", oldPrice, newPrice);
    }

    public double getPrice() {
        return price;
    }
}

// Usage
StockPrice stock = new StockPrice();
stock.addPropertyChangeListener(evt -> {
    System.out.println("Price updated: $" + evt.getNewValue());
});
stock.setPrice(150.25);
```

### Custom Observer
```java
import java.util.HashSet;
import java.util.Set;

interface Observer {
    void update(double data);
}

interface Subject {
    void attach(Observer observer);
    void detach(Observer observer);
    void notifyObservers(double data);
}

class StockPrice implements Subject {
    private final Set<Observer> observers = new HashSet<>();
    private double price = 0.0;

    @Override
    public void attach(Observer observer) {
        observers.add(observer);
    }

    @Override
    public void detach(Observer observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyObservers(double data) {
        for (Observer observer : observers) {
            observer.update(data);
        }
    }

    public void setPrice(double newPrice) {
        this.price = newPrice;
        notifyObservers(this.price);
    }
}

class PriceDisplay implements Observer {
    @Override
    public void update(double price) {
        System.out.println("Price updated: $" + price);
    }
}
```

---

## C#

### Event/EventHandler (Recommended)
```csharp
public class PriceChangedEventArgs : EventArgs
{
    public double NewPrice { get; }
    public double OldPrice { get; }

    public PriceChangedEventArgs(double oldPrice, double newPrice)
    {
        OldPrice = oldPrice;
        NewPrice = newPrice;
    }
}

public class StockPrice
{
    private double _price;

    public event EventHandler<PriceChangedEventArgs>? PriceChanged;

    public double Price
    {
        get => _price;
        set
        {
            if (_price != value)
            {
                double oldPrice = _price;
                _price = value;
                OnPriceChanged(new PriceChangedEventArgs(oldPrice, _price));
            }
        }
    }

    protected virtual void OnPriceChanged(PriceChangedEventArgs e)
    {
        PriceChanged?.Invoke(this, e);
    }
}

// Usage
var stock = new StockPrice();
stock.PriceChanged += (sender, e) =>
{
    Console.WriteLine($"Price updated: ${e.NewPrice}");
};
stock.Price = 150.25;
```

### IObserver/IObservable
```csharp
using System;
using System.Collections.Generic;

public class StockPrice : IObservable<double>
{
    private readonly List<IObserver<double>> _observers = new();
    private double _price;

    public IDisposable Subscribe(IObserver<double> observer)
    {
        if (!_observers.Contains(observer))
            _observers.Add(observer);
        
        return new Unsubscriber(_observers, observer);
    }

    public void SetPrice(double newPrice)
    {
        _price = newPrice;
        foreach (var observer in _observers)
        {
            observer.OnNext(_price);
        }
    }

    private class Unsubscriber : IDisposable
    {
        private readonly List<IObserver<double>> _observers;
        private readonly IObserver<double> _observer;

        public Unsubscriber(List<IObserver<double>> observers, IObserver<double> observer)
        {
            _observers = observers;
            _observer = observer;
        }

        public void Dispose()
        {
            if (_observer != null && _observers.Contains(_observer))
                _observers.Remove(_observer);
        }
    }
}

// Usage
var stock = new StockPrice();
var subscription = stock.Subscribe(new PriceObserver());
stock.SetPrice(150.25);
```

---

## PHP

### SplObserver/SplSubject (Recommended)
```php
class StockPrice implements SplSubject
{
    private SplObjectStorage $observers;
    private float $price = 0.0;

    public function __construct()
    {
        $this->observers = new SplObjectStorage();
    }

    public function attach(SplObserver $observer): void
    {
        $this->observers->attach($observer);
    }

    public function detach(SplObserver $observer): void
    {
        $this->observers->detach($observer);
    }

    public function notify(): void
    {
        foreach ($this->observers as $observer) {
            $observer->update($this);
        }
    }

    public function setPrice(float $newPrice): void
    {
        $this->price = $newPrice;
        $this->notify();
    }

    public function getPrice(): float
    {
        return $this->price;
    }
}

class PriceDisplay implements SplObserver
{
    public function update(SplSubject $subject): void
    {
        if ($subject instanceof StockPrice) {
            echo "Price updated: $" . $subject->getPrice() . "\n";
        }
    }
}

// Usage
$stock = new StockPrice();
$display = new PriceDisplay();
$stock->attach($display);
$stock->setPrice(150.25);
```

### Laravel Events
```php
// Event class
namespace App\Events;

use Illuminate\Foundation\Events\Dispatchable;

class PriceChanged
{
    use Dispatchable;

    public function __construct(public float $price) {}
}

// Listener class
namespace App\Listeners;

use App\Events\PriceChanged;

class LogPriceChange
{
    public function handle(PriceChanged $event): void
    {
        logger()->info("Price updated: $" . $event->price);
    }
}

// Usage
use App\Events\PriceChanged;

event(new PriceChanged(150.25));
```

---

## Kotlin

### Custom Observer
```kotlin
interface Observer<T> {
    fun update(data: T)
}

interface Subject<T> {
    fun attach(observer: Observer<T>)
    fun detach(observer: Observer<T>)
    fun notify(data: T)
}

class StockPrice : Subject<Double> {
    private val observers = mutableSetOf<Observer<Double>>()
    private var price: Double = 0.0

    override fun attach(observer: Observer<Double>) {
        observers.add(observer)
    }

    override fun detach(observer: Observer<Double>) {
        observers.remove(observer)
    }

    override fun notify(data: Double) {
        observers.forEach { it.update(data) }
    }

    fun setPrice(newPrice: Double) {
        price = newPrice
        notify(price)
    }
}

class PriceDisplay : Observer<Double> {
    override fun update(price: Double) {
        println("Price updated: $$price")
    }
}

// Usage
val stock = StockPrice()
val display = PriceDisplay()
stock.attach(display)
stock.setPrice(150.25)
```

### Kotlin Flow (Reactive)
```kotlin
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class StockPrice {
    private val _price = MutableStateFlow(0.0)
    val price: StateFlow<Double> = _price.asStateFlow()

    fun setPrice(newPrice: Double) {
        _price.value = newPrice
    }
}

// Usage
import kotlinx.coroutines.launch

val stock = StockPrice()
launch {
    stock.price.collect { price ->
        println("Price updated: $$price")
    }
}
stock.setPrice(150.25)
```

---

## Swift

### NotificationCenter (Recommended)
```swift
extension Notification.Name {
    static let priceChanged = Notification.Name("priceChanged")
}

class StockPrice {
    private var price: Double = 0.0
    
    func setPrice(_ newPrice: Double) {
        price = newPrice
        NotificationCenter.default.post(
            name: .priceChanged,
            object: self,
            userInfo: ["price": newPrice]
        )
    }
}

// Usage
let stock = StockPrice()
let observer = NotificationCenter.default.addObserver(
    forName: .priceChanged,
    object: stock,
    queue: .main
) { notification in
    if let price = notification.userInfo?["price"] as? Double {
        print("Price updated: $\(price)")
    }
}
stock.setPrice(150.25)

// Don't forget to remove observer
NotificationCenter.default.removeObserver(observer)
```

### Combine Publisher
```swift
import Combine

class StockPrice {
    @Published private(set) var price: Double = 0.0
    
    func setPrice(_ newPrice: Double) {
        price = newPrice
    }
}

// Usage
let stock = StockPrice()
let cancellable = stock.$price.sink { price in
    print("Price updated: $\(price)")
}
stock.setPrice(150.25)
```

---

## Dart

### Stream/StreamController (Recommended)
```dart
import 'dart:async';

class StockPrice {
  final _priceController = StreamController<double>.broadcast();
  Stream<double> get priceStream => _priceController.stream;

  double _price = 0.0;

  void setPrice(double newPrice) {
    _price = newPrice;
    _priceController.add(_price);
  }

  void dispose() {
    _priceController.close();
  }
}

// Usage
final stock = StockPrice();
final subscription = stock.priceStream.listen((price) {
  print('Price updated: \$$price');
});
stock.setPrice(150.25);

// Clean up
subscription.cancel();
stock.dispose();
```

### ChangeNotifier (Flutter)
```dart
import 'package:flutter/foundation.dart';

class StockPrice extends ChangeNotifier {
  double _price = 0.0;
  double get price => _price;

  void setPrice(double newPrice) {
    _price = newPrice;
    notifyListeners();
  }
}

// Usage in Flutter widget
class PriceWidget extends StatelessWidget {
  final StockPrice stock;

  const PriceWidget({required this.stock});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stock,
      builder: (context, child) {
        return Text('Price: \$${stock.price}');
      },
    );
  }
}
```
