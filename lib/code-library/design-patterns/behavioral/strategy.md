---
title: Strategy Pattern
category: Behavioral Design Pattern
difficulty: beginner
purpose: Define a family of algorithms, encapsulate each one, and make them interchangeable at runtime
when_to_use:
  - Multiple payment methods (Credit Card, PayPal, Crypto)
  - Different sorting algorithms
  - Compression strategies (ZIP, GZIP, RAR)
  - Validation strategies
  - Pricing calculations (Regular, Premium, Seasonal)
  - Authentication methods (OAuth, JWT, Basic)
languages:
  typescript:
    - name: Interface Strategy (Built-in)
      library: javascript-core
      recommended: true
    - name: Function Strategy (Built-in)
      library: javascript-core
  python:
    - name: ABC Strategy (Built-in)
      library: python-core
      recommended: true
    - name: Protocol Strategy (Built-in)
      library: python-core
    - name: Callable Strategy (Built-in)
      library: python-core
  java:
    - name: Interface Strategy (Built-in)
      library: java-core
      recommended: true
    - name: Functional Interface (Built-in)
      library: java-core
  csharp:
    - name: Interface Strategy (Built-in)
      library: dotnet-core
      recommended: true
    - name: Delegate Strategy (Built-in)
      library: dotnet-core
  php:
    - name: Interface Strategy (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Interface Strategy (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Function Type Strategy (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Protocol Strategy (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Closure Strategy (Built-in)
      library: swift-stdlib
  dart:
    - name: Interface Strategy (Built-in)
      library: dart-core
      recommended: true
    - name: Function Strategy (Built-in)
      library: dart-core
common_patterns:
  - Context holds reference to strategy
  - Strategies are swappable at runtime
  - Dependency injection for strategies
  - Registry pattern for strategy selection
best_practices:
  do:
    - Use dependency injection to provide strategies
    - Make strategies stateless when possible
    - Use simple functions for trivial strategies
    - Consider factory pattern for strategy creation
    - Document when to use each strategy
  dont:
    - Create strategy for single implementation
    - Put complex state in strategies
    - Tightly couple context to specific strategies
    - Use when simple if/else is clearer
related_functions:
  - auth-authorization.md
  - input-validation.md
tags: [strategy, behavioral-pattern, polymorphism, dependency-injection]
updated: 2026-01-20
---

## TypeScript

### Interface Strategy
```typescript
// Strategy interface
interface PaymentStrategy {
  pay(amount: number): Promise<string>;
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy {
  constructor(
    private cardNumber: string,
    private cvv: string
  ) {}

  async pay(amount: number): Promise<string> {
    return `Paid $${amount} with credit card ending in ${this.cardNumber.slice(-4)}`;
  }
}

class PayPalPayment implements PaymentStrategy {
  constructor(private email: string) {}

  async pay(amount: number): Promise<string> {
    return `Paid $${amount} via PayPal (${this.email})`;
  }
}

class CryptoPayment implements PaymentStrategy {
  constructor(private walletAddress: string) {}

  async pay(amount: number): Promise<string> {
    return `Paid $${amount} via crypto to ${this.walletAddress.slice(0, 10)}...`;
  }
}

// Context
class PaymentProcessor {
  constructor(private strategy: PaymentStrategy) {}

  setStrategy(strategy: PaymentStrategy): void {
    this.strategy = strategy;
  }

  async processPayment(amount: number): Promise<string> {
    return await this.strategy.pay(amount);
  }
}

// Usage
const processor = new PaymentProcessor(
  new CreditCardPayment('4111111111111111', '123')
);
await processor.processPayment(100);

processor.setStrategy(new PayPalPayment('user@example.com'));
await processor.processPayment(50);
```

### Function Strategy (Lightweight)
```typescript
type PaymentStrategy = (amount: number) => Promise<string>;

const creditCardPayment: PaymentStrategy = async (amount) => {
  return `Paid $${amount} with credit card`;
};

const payPalPayment: PaymentStrategy = async (amount) => {
  return `Paid $${amount} via PayPal`;
};

class PaymentProcessor {
  constructor(private strategy: PaymentStrategy) {}

  setStrategy(strategy: PaymentStrategy): void {
    this.strategy = strategy;
  }

  async processPayment(amount: number): Promise<string> {
    return await this.strategy(amount);
  }
}

// Usage
const processor = new PaymentProcessor(creditCardPayment);
await processor.processPayment(100);
```

---

## Python

### ABC Strategy
```python
from abc import ABC, abstractmethod

# Strategy interface
class PaymentStrategy(ABC):
    @abstractmethod
    async def pay(self, amount: float) -> str:
        pass

# Concrete strategies
class CreditCardPayment(PaymentStrategy):
    def __init__(self, card_number: str, cvv: str):
        self.card_number = card_number
        self.cvv = cvv

    async def pay(self, amount: float) -> str:
        return f"Paid ${amount} with credit card ending in {self.card_number[-4:]}"

class PayPalPayment(PaymentStrategy):
    def __init__(self, email: str):
        self.email = email

    async def pay(self, amount: float) -> str:
        return f"Paid ${amount} via PayPal ({self.email})"

class CryptoPayment(PaymentStrategy):
    def __init__(self, wallet_address: str):
        self.wallet_address = wallet_address

    async def pay(self, amount: float) -> str:
        return f"Paid ${amount} via crypto to {self.wallet_address[:10]}..."

# Context
class PaymentProcessor:
    def __init__(self, strategy: PaymentStrategy):
        self._strategy = strategy

    def set_strategy(self, strategy: PaymentStrategy) -> None:
        self._strategy = strategy

    async def process_payment(self, amount: float) -> str:
        return await self._strategy.pay(amount)

# Usage
processor = PaymentProcessor(CreditCardPayment("4111111111111111", "123"))
result = await processor.process_payment(100)

processor.set_strategy(PayPalPayment("user@example.com"))
result = await processor.process_payment(50)
```

### Callable Strategy (Lightweight)
```python
from typing import Callable, Awaitable

PaymentStrategy = Callable[[float], Awaitable[str]]

async def credit_card_payment(amount: float) -> str:
    return f"Paid ${amount} with credit card"

async def paypal_payment(amount: float) -> str:
    return f"Paid ${amount} via PayPal"

class PaymentProcessor:
    def __init__(self, strategy: PaymentStrategy):
        self._strategy = strategy

    def set_strategy(self, strategy: PaymentStrategy) -> None:
        self._strategy = strategy

    async def process_payment(self, amount: float) -> str:
        return await self._strategy(amount)

# Usage
processor = PaymentProcessor(credit_card_payment)
result = await processor.process_payment(100)
```

---

## Java

### Interface Strategy
```java
// Strategy interface
interface PaymentStrategy {
    String pay(double amount);
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy {
    private final String cardNumber;
    private final String cvv;

    public CreditCardPayment(String cardNumber, String cvv) {
        this.cardNumber = cardNumber;
        this.cvv = cvv;
    }

    @Override
    public String pay(double amount) {
        return String.format("Paid $%.2f with credit card ending in %s", 
            amount, cardNumber.substring(cardNumber.length() - 4));
    }
}

class PayPalPayment implements PaymentStrategy {
    private final String email;

    public PayPalPayment(String email) {
        this.email = email;
    }

    @Override
    public String pay(double amount) {
        return String.format("Paid $%.2f via PayPal (%s)", amount, email);
    }
}

class CryptoPayment implements PaymentStrategy {
    private final String walletAddress;

    public CryptoPayment(String walletAddress) {
        this.walletAddress = walletAddress;
    }

    @Override
    public String pay(double amount) {
        return String.format("Paid $%.2f via crypto to %s...", 
            amount, walletAddress.substring(0, 10));
    }
}

// Context
class PaymentProcessor {
    private PaymentStrategy strategy;

    public PaymentProcessor(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void setStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public String processPayment(double amount) {
        return strategy.pay(amount);
    }
}

// Usage
PaymentProcessor processor = new PaymentProcessor(
    new CreditCardPayment("4111111111111111", "123")
);
String result = processor.processPayment(100);

processor.setStrategy(new PayPalPayment("user@example.com"));
result = processor.processPayment(50);
```

### Functional Interface (Java 8+)
```java
@FunctionalInterface
interface PaymentStrategy {
    String pay(double amount);
}

class PaymentProcessor {
    private PaymentStrategy strategy;

    public PaymentProcessor(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public void setStrategy(PaymentStrategy strategy) {
        this.strategy = strategy;
    }

    public String processPayment(double amount) {
        return strategy.pay(amount);
    }
}

// Usage with lambdas
PaymentProcessor processor = new PaymentProcessor(
    amount -> String.format("Paid $%.2f with credit card", amount)
);
String result = processor.processPayment(100);

processor.setStrategy(
    amount -> String.format("Paid $%.2f via PayPal", amount)
);
```

---

## C#

### Interface Strategy
```csharp
// Strategy interface
public interface IPaymentStrategy
{
    Task<string> PayAsync(decimal amount);
}

// Concrete strategies
public class CreditCardPayment : IPaymentStrategy
{
    private readonly string _cardNumber;
    private readonly string _cvv;

    public CreditCardPayment(string cardNumber, string cvv)
    {
        _cardNumber = cardNumber;
        _cvv = cvv;
    }

    public async Task<string> PayAsync(decimal amount)
    {
        await Task.CompletedTask;
        return $"Paid ${amount} with credit card ending in {_cardNumber[^4..]}";
    }
}

public class PayPalPayment : IPaymentStrategy
{
    private readonly string _email;

    public PayPalPayment(string email)
    {
        _email = email;
    }

    public async Task<string> PayAsync(decimal amount)
    {
        await Task.CompletedTask;
        return $"Paid ${amount} via PayPal ({_email})";
    }
}

public class CryptoPayment : IPaymentStrategy
{
    private readonly string _walletAddress;

    public CryptoPayment(string walletAddress)
    {
        _walletAddress = walletAddress;
    }

    public async Task<string> PayAsync(decimal amount)
    {
        await Task.CompletedTask;
        return $"Paid ${amount} via crypto to {_walletAddress[..10]}...";
    }
}

// Context
public class PaymentProcessor
{
    private IPaymentStrategy _strategy;

    public PaymentProcessor(IPaymentStrategy strategy)
    {
        _strategy = strategy;
    }

    public void SetStrategy(IPaymentStrategy strategy)
    {
        _strategy = strategy;
    }

    public async Task<string> ProcessPaymentAsync(decimal amount)
    {
        return await _strategy.PayAsync(amount);
    }
}

// Usage
var processor = new PaymentProcessor(
    new CreditCardPayment("4111111111111111", "123")
);
var result = await processor.ProcessPaymentAsync(100);

processor.SetStrategy(new PayPalPayment("user@example.com"));
result = await processor.ProcessPaymentAsync(50);
```

### Delegate Strategy
```csharp
public delegate Task<string> PaymentStrategy(decimal amount);

public class PaymentProcessor
{
    private PaymentStrategy _strategy;

    public PaymentProcessor(PaymentStrategy strategy)
    {
        _strategy = strategy;
    }

    public void SetStrategy(PaymentStrategy strategy)
    {
        _strategy = strategy;
    }

    public async Task<string> ProcessPaymentAsync(decimal amount)
    {
        return await _strategy(amount);
    }
}

// Usage with lambdas
var processor = new PaymentProcessor(
    async amount => await Task.FromResult($"Paid ${amount} with credit card")
);
var result = await processor.ProcessPaymentAsync(100);
```

---

## PHP

### Interface Strategy
```php
// Strategy interface
interface PaymentStrategy
{
    public function pay(float $amount): string;
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy
{
    public function __construct(
        private string $cardNumber,
        private string $cvv
    ) {}

    public function pay(float $amount): string
    {
        $lastFour = substr($this->cardNumber, -4);
        return "Paid $$amount with credit card ending in $lastFour";
    }
}

class PayPalPayment implements PaymentStrategy
{
    public function __construct(private string $email) {}

    public function pay(float $amount): string
    {
        return "Paid $$amount via PayPal ({$this->email})";
    }
}

class CryptoPayment implements PaymentStrategy
{
    public function __construct(private string $walletAddress) {}

    public function pay(float $amount): string
    {
        $prefix = substr($this->walletAddress, 0, 10);
        return "Paid $$amount via crypto to $prefix...";
    }
}

// Context
class PaymentProcessor
{
    public function __construct(private PaymentStrategy $strategy) {}

    public function setStrategy(PaymentStrategy $strategy): void
    {
        $this->strategy = $strategy;
    }

    public function processPayment(float $amount): string
    {
        return $this->strategy->pay($amount);
    }
}

// Usage
$processor = new PaymentProcessor(
    new CreditCardPayment('4111111111111111', '123')
);
$result = $processor->processPayment(100);

$processor->setStrategy(new PayPalPayment('user@example.com'));
$result = $processor->processPayment(50);
```

---

## Kotlin

### Interface Strategy
```kotlin
// Strategy interface
interface PaymentStrategy {
    suspend fun pay(amount: Double): String
}

// Concrete strategies
class CreditCardPayment(
    private val cardNumber: String,
    private val cvv: String
) : PaymentStrategy {
    override suspend fun pay(amount: Double): String {
        return "Paid $$amount with credit card ending in ${cardNumber.takeLast(4)}"
    }
}

class PayPalPayment(private val email: String) : PaymentStrategy {
    override suspend fun pay(amount: Double): String {
        return "Paid $$amount via PayPal ($email)"
    }
}

class CryptoPayment(private val walletAddress: String) : PaymentStrategy {
    override suspend fun pay(amount: Double): String {
        return "Paid $$amount via crypto to ${walletAddress.take(10)}..."
    }
}

// Context
class PaymentProcessor(private var strategy: PaymentStrategy) {
    fun setStrategy(strategy: PaymentStrategy) {
        this.strategy = strategy
    }

    suspend fun processPayment(amount: Double): String {
        return strategy.pay(amount)
    }
}

// Usage
val processor = PaymentProcessor(CreditCardPayment("4111111111111111", "123"))
val result = processor.processPayment(100.0)

processor.setStrategy(PayPalPayment("user@example.com"))
val result2 = processor.processPayment(50.0)
```

### Function Type Strategy
```kotlin
typealias PaymentStrategy = suspend (Double) -> String

class PaymentProcessor(private var strategy: PaymentStrategy) {
    fun setStrategy(strategy: PaymentStrategy) {
        this.strategy = strategy
    }

    suspend fun processPayment(amount: Double): String {
        return strategy(amount)
    }
}

// Usage with lambdas
val processor = PaymentProcessor { amount ->
    "Paid $$amount with credit card"
}
val result = processor.processPayment(100.0)
```

---

## Swift

### Protocol Strategy
```swift
// Strategy protocol
protocol PaymentStrategy {
    func pay(amount: Double) async -> String
}

// Concrete strategies
struct CreditCardPayment: PaymentStrategy {
    let cardNumber: String
    let cvv: String
    
    func pay(amount: Double) async -> String {
        let lastFour = String(cardNumber.suffix(4))
        return "Paid $\(amount) with credit card ending in \(lastFour)"
    }
}

struct PayPalPayment: PaymentStrategy {
    let email: String
    
    func pay(amount: Double) async -> String {
        return "Paid $\(amount) via PayPal (\(email))"
    }
}

struct CryptoPayment: PaymentStrategy {
    let walletAddress: String
    
    func pay(amount: Double) async -> String {
        let prefix = String(walletAddress.prefix(10))
        return "Paid $\(amount) via crypto to \(prefix)..."
    }
}

// Context
class PaymentProcessor {
    private var strategy: PaymentStrategy
    
    init(strategy: PaymentStrategy) {
        self.strategy = strategy
    }
    
    func setStrategy(_ strategy: PaymentStrategy) {
        self.strategy = strategy
    }
    
    func processPayment(amount: Double) async -> String {
        return await strategy.pay(amount: amount)
    }
}

// Usage
let processor = PaymentProcessor(strategy: CreditCardPayment(
    cardNumber: "4111111111111111",
    cvv: "123"
))
let result = await processor.processPayment(amount: 100)

processor.setStrategy(PayPalPayment(email: "user@example.com"))
let result2 = await processor.processPayment(amount: 50)
```

### Closure Strategy
```swift
typealias PaymentStrategy = (Double) async -> String

class PaymentProcessor {
    private var strategy: PaymentStrategy
    
    init(strategy: @escaping PaymentStrategy) {
        self.strategy = strategy
    }
    
    func setStrategy(_ strategy: @escaping PaymentStrategy) {
        self.strategy = strategy
    }
    
    func processPayment(amount: Double) async -> String {
        return await strategy(amount)
    }
}

// Usage with closures
let processor = PaymentProcessor { amount in
    "Paid $\(amount) with credit card"
}
let result = await processor.processPayment(amount: 100)
```

---

## Dart

### Interface Strategy
```dart
// Strategy interface
abstract class PaymentStrategy {
  Future<String> pay(double amount);
}

// Concrete strategies
class CreditCardPayment implements PaymentStrategy {
  final String cardNumber;
  final String cvv;

  CreditCardPayment(this.cardNumber, this.cvv);

  @override
  Future<String> pay(double amount) async {
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return 'Paid \$$amount with credit card ending in $lastFour';
  }
}

class PayPalPayment implements PaymentStrategy {
  final String email;

  PayPalPayment(this.email);

  @override
  Future<String> pay(double amount) async {
    return 'Paid \$$amount via PayPal ($email)';
  }
}

class CryptoPayment implements PaymentStrategy {
  final String walletAddress;

  CryptoPayment(this.walletAddress);

  @override
  Future<String> pay(double amount) async {
    final prefix = walletAddress.substring(0, 10);
    return 'Paid \$$amount via crypto to $prefix...';
  }
}

// Context
class PaymentProcessor {
  PaymentStrategy _strategy;

  PaymentProcessor(this._strategy);

  void setStrategy(PaymentStrategy strategy) {
    _strategy = strategy;
  }

  Future<String> processPayment(double amount) async {
    return await _strategy.pay(amount);
  }
}

// Usage
final processor = PaymentProcessor(
  CreditCardPayment('4111111111111111', '123')
);
final result = await processor.processPayment(100);

processor.setStrategy(PayPalPayment('user@example.com'));
final result2 = await processor.processPayment(50);
```

### Function Strategy
```dart
typedef PaymentStrategy = Future<String> Function(double amount);

class PaymentProcessor {
  PaymentStrategy _strategy;

  PaymentProcessor(this._strategy);

  void setStrategy(PaymentStrategy strategy) {
    _strategy = strategy;
  }

  Future<String> processPayment(double amount) async {
    return await _strategy(amount);
  }
}

// Usage with functions
final processor = PaymentProcessor((amount) async {
  return 'Paid \$$amount with credit card';
});
final result = await processor.processPayment(100);
```
