---
title: Adapter Pattern
category: Structural Design Pattern
difficulty: beginner
purpose: Convert the interface of a class into another interface clients expect, allowing incompatible interfaces to work together
when_to_use:
  - Integrating third-party libraries with different interfaces
  - Legacy system integration
  - API version compatibility layers
  - Payment gateway abstraction
  - Database driver adapters
  - Cloud service abstraction (AWS, Azure, GCP)
languages:
  typescript:
    - name: Class Adapter (Built-in)
      library: javascript-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: javascript-core
  python:
    - name: Class Adapter (Built-in)
      library: python-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: python-core
  java:
    - name: Class Adapter (Built-in)
      library: java-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: java-core
  csharp:
    - name: Class Adapter (Built-in)
      library: dotnet-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: dotnet-core
  php:
    - name: Class Adapter (Built-in)
      library: php-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: php-core
  kotlin:
    - name: Class Adapter (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Delegation Adapter (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Protocol Adapter (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Extension Adapter (Built-in)
      library: swift-stdlib
  dart:
    - name: Class Adapter (Built-in)
      library: dart-core
      recommended: true
    - name: Object Adapter (Built-in)
      library: dart-core
common_patterns:
  - Class adapter (inheritance-based)
  - Object adapter (composition-based)
  - Two-way adapter (bidirectional)
  - Pluggable adapter (configurable)
best_practices:
  do:
    - Prefer object adapter over class adapter (composition over inheritance)
    - Use adapters to isolate third-party dependencies
    - Create adapters for each external service/library
    - Document the interface mapping clearly
    - Consider using facade pattern for complex adaptations
  dont:
    - Add business logic to adapters
    - Create adapters for interfaces you control
    - Use adapters when you can modify the adaptee directly
    - Create unnecessary layers of adapters
related_functions:
  - http-requests.md
  - database-query.md
tags: [adapter, structural-pattern, interface, compatibility, wrapper]
updated: 2026-01-20
---

## TypeScript

### Object Adapter (Recommended - Composition)
```typescript
// Target interface (what client expects)
interface PaymentProcessor {
  processPayment(amount: number, currency: string): Promise<string>;
  refund(transactionId: string): Promise<void>;
}

// Adaptee (third-party service with different interface)
class StripePaymentService {
  async charge(amountInCents: number, currencyCode: string): Promise<{ id: string }> {
    console.log(`Stripe: Charging ${amountInCents} cents in ${currencyCode}`);
    return { id: 'stripe_tx_123' };
  }

  async createRefund(chargeId: string): Promise<void> {
    console.log(`Stripe: Refunding charge ${chargeId}`);
  }
}

// Adapter
class StripeAdapter implements PaymentProcessor {
  constructor(private stripeService: StripePaymentService) {}

  async processPayment(amount: number, currency: string): Promise<string> {
    const amountInCents = Math.round(amount * 100);
    const result = await this.stripeService.charge(amountInCents, currency);
    return result.id;
  }

  async refund(transactionId: string): Promise<void> {
    await this.stripeService.createRefund(transactionId);
  }
}

// Usage
const stripeService = new StripePaymentService();
const paymentProcessor: PaymentProcessor = new StripeAdapter(stripeService);
await paymentProcessor.processPayment(99.99, 'USD');
```

### Class Adapter (Inheritance)
```typescript
// Target interface
interface MediaPlayer {
  play(filename: string): void;
}

// Adaptee
class MP3Player {
  playMP3(file: string): void {
    console.log(`Playing MP3: ${file}`);
  }
}

// Adapter (using inheritance and interface)
class MediaAdapter extends MP3Player implements MediaPlayer {
  play(filename: string): void {
    if (filename.endsWith('.mp3')) {
      this.playMP3(filename);
    } else {
      console.log(`Unsupported format: ${filename}`);
    }
  }
}

// Usage
const player: MediaPlayer = new MediaAdapter();
player.play('song.mp3');
```

---

## Python

### Object Adapter (Recommended)
```python
from abc import ABC, abstractmethod

# Target interface
class PaymentProcessor(ABC):
    @abstractmethod
    async def process_payment(self, amount: float, currency: str) -> str:
        pass

    @abstractmethod
    async def refund(self, transaction_id: str) -> None:
        pass

# Adaptee
class StripePaymentService:
    async def charge(self, amount_in_cents: int, currency_code: str) -> dict:
        print(f"Stripe: Charging {amount_in_cents} cents in {currency_code}")
        return {"id": "stripe_tx_123"}

    async def create_refund(self, charge_id: str) -> None:
        print(f"Stripe: Refunding charge {charge_id}")

# Adapter
class StripeAdapter(PaymentProcessor):
    def __init__(self, stripe_service: StripePaymentService):
        self._stripe_service = stripe_service

    async def process_payment(self, amount: float, currency: str) -> str:
        amount_in_cents = round(amount * 100)
        result = await self._stripe_service.charge(amount_in_cents, currency)
        return result["id"]

    async def refund(self, transaction_id: str) -> None:
        await self._stripe_service.create_refund(transaction_id)

# Usage
stripe_service = StripePaymentService()
payment_processor: PaymentProcessor = StripeAdapter(stripe_service)
await payment_processor.process_payment(99.99, "USD")
```

### Class Adapter (Multiple Inheritance)
```python
# Target interface
class MediaPlayer(ABC):
    @abstractmethod
    def play(self, filename: str) -> None:
        pass

# Adaptee
class MP3Player:
    def play_mp3(self, file: str) -> None:
        print(f"Playing MP3: {file}")

# Adapter
class MediaAdapter(MP3Player, MediaPlayer):
    def play(self, filename: str) -> None:
        if filename.endswith('.mp3'):
            self.play_mp3(filename)
        else:
            print(f"Unsupported format: {filename}")

# Usage
player: MediaPlayer = MediaAdapter()
player.play("song.mp3")
```

---

## Java

### Object Adapter (Recommended)
```java
// Target interface
interface PaymentProcessor {
    String processPayment(double amount, String currency);
    void refund(String transactionId);
}

// Adaptee
class StripePaymentService {
    public ChargeResult charge(int amountInCents, String currencyCode) {
        System.out.println("Stripe: Charging " + amountInCents + " cents in " + currencyCode);
        return new ChargeResult("stripe_tx_123");
    }

    public void createRefund(String chargeId) {
        System.out.println("Stripe: Refunding charge " + chargeId);
    }

    static class ChargeResult {
        private final String id;
        public ChargeResult(String id) { this.id = id; }
        public String getId() { return id; }
    }
}

// Adapter
class StripeAdapter implements PaymentProcessor {
    private final StripePaymentService stripeService;

    public StripeAdapter(StripePaymentService stripeService) {
        this.stripeService = stripeService;
    }

    @Override
    public String processPayment(double amount, String currency) {
        int amountInCents = (int) Math.round(amount * 100);
        StripePaymentService.ChargeResult result = stripeService.charge(amountInCents, currency);
        return result.getId();
    }

    @Override
    public void refund(String transactionId) {
        stripeService.createRefund(transactionId);
    }
}

// Usage
StripePaymentService stripeService = new StripePaymentService();
PaymentProcessor paymentProcessor = new StripeAdapter(stripeService);
String txId = paymentProcessor.processPayment(99.99, "USD");
```

### Class Adapter (Inheritance)
```java
// Target interface
interface MediaPlayer {
    void play(String filename);
}

// Adaptee
class MP3Player {
    public void playMP3(String file) {
        System.out.println("Playing MP3: " + file);
    }
}

// Adapter
class MediaAdapter extends MP3Player implements MediaPlayer {
    @Override
    public void play(String filename) {
        if (filename.endsWith(".mp3")) {
            playMP3(filename);
        } else {
            System.out.println("Unsupported format: " + filename);
        }
    }
}

// Usage
MediaPlayer player = new MediaAdapter();
player.play("song.mp3");
```

---

## C#

### Object Adapter (Recommended)
```csharp
// Target interface
public interface IPaymentProcessor
{
    Task<string> ProcessPaymentAsync(decimal amount, string currency);
    Task RefundAsync(string transactionId);
}

// Adaptee
public class StripePaymentService
{
    public async Task<ChargeResult> ChargeAsync(int amountInCents, string currencyCode)
    {
        Console.WriteLine($"Stripe: Charging {amountInCents} cents in {currencyCode}");
        await Task.CompletedTask;
        return new ChargeResult { Id = "stripe_tx_123" };
    }

    public async Task CreateRefundAsync(string chargeId)
    {
        Console.WriteLine($"Stripe: Refunding charge {chargeId}");
        await Task.CompletedTask;
    }

    public class ChargeResult
    {
        public string Id { get; set; }
    }
}

// Adapter
public class StripeAdapter : IPaymentProcessor
{
    private readonly StripePaymentService _stripeService;

    public StripeAdapter(StripePaymentService stripeService)
    {
        _stripeService = stripeService;
    }

    public async Task<string> ProcessPaymentAsync(decimal amount, string currency)
    {
        int amountInCents = (int)Math.Round(amount * 100);
        var result = await _stripeService.ChargeAsync(amountInCents, currency);
        return result.Id;
    }

    public async Task RefundAsync(string transactionId)
    {
        await _stripeService.CreateRefundAsync(transactionId);
    }
}

// Usage
var stripeService = new StripePaymentService();
IPaymentProcessor paymentProcessor = new StripeAdapter(stripeService);
var txId = await paymentProcessor.ProcessPaymentAsync(99.99m, "USD");
```

---

## PHP

### Object Adapter (Recommended)
```php
// Target interface
interface PaymentProcessor
{
    public function processPayment(float $amount, string $currency): string;
    public function refund(string $transactionId): void;
}

// Adaptee
class StripePaymentService
{
    public function charge(int $amountInCents, string $currencyCode): array
    {
        echo "Stripe: Charging $amountInCents cents in $currencyCode\n";
        return ['id' => 'stripe_tx_123'];
    }

    public function createRefund(string $chargeId): void
    {
        echo "Stripe: Refunding charge $chargeId\n";
    }
}

// Adapter
class StripeAdapter implements PaymentProcessor
{
    public function __construct(private StripePaymentService $stripeService) {}

    public function processPayment(float $amount, string $currency): string
    {
        $amountInCents = (int) round($amount * 100);
        $result = $this->stripeService->charge($amountInCents, $currency);
        return $result['id'];
    }

    public function refund(string $transactionId): void
    {
        $this->stripeService->createRefund($transactionId);
    }
}

// Usage
$stripeService = new StripePaymentService();
$paymentProcessor = new StripeAdapter($stripeService);
$txId = $paymentProcessor->processPayment(99.99, 'USD');
```

### Class Adapter
```php
// Target interface
interface MediaPlayer
{
    public function play(string $filename): void;
}

// Adaptee
class MP3Player
{
    public function playMP3(string $file): void
    {
        echo "Playing MP3: $file\n";
    }
}

// Adapter
class MediaAdapter extends MP3Player implements MediaPlayer
{
    public function play(string $filename): void
    {
        if (str_ends_with($filename, '.mp3')) {
            $this->playMP3($filename);
        } else {
            echo "Unsupported format: $filename\n";
        }
    }
}

// Usage
$player = new MediaAdapter();
$player->play('song.mp3');
```

---

## Kotlin

### Object Adapter (Recommended)
```kotlin
// Target interface
interface PaymentProcessor {
    suspend fun processPayment(amount: Double, currency: String): String
    suspend fun refund(transactionId: String)
}

// Adaptee
class StripePaymentService {
    suspend fun charge(amountInCents: Int, currencyCode: String): ChargeResult {
        println("Stripe: Charging $amountInCents cents in $currencyCode")
        return ChargeResult("stripe_tx_123")
    }

    suspend fun createRefund(chargeId: String) {
        println("Stripe: Refunding charge $chargeId")
    }

    data class ChargeResult(val id: String)
}

// Adapter
class StripeAdapter(private val stripeService: StripePaymentService) : PaymentProcessor {
    override suspend fun processPayment(amount: Double, currency: String): String {
        val amountInCents = (amount * 100).toInt()
        val result = stripeService.charge(amountInCents, currency)
        return result.id
    }

    override suspend fun refund(transactionId: String) {
        stripeService.createRefund(transactionId)
    }
}

// Usage
val stripeService = StripePaymentService()
val paymentProcessor: PaymentProcessor = StripeAdapter(stripeService)
val txId = paymentProcessor.processPayment(99.99, "USD")
```

### Delegation Adapter
```kotlin
// Target interface
interface MediaPlayer {
    fun play(filename: String)
}

// Adaptee
class MP3Player {
    fun playMP3(file: String) {
        println("Playing MP3: $file")
    }
}

// Adapter using delegation
class MediaAdapter(private val mp3Player: MP3Player) : MediaPlayer {
    override fun play(filename: String) {
        when {
            filename.endsWith(".mp3") -> mp3Player.playMP3(filename)
            else -> println("Unsupported format: $filename")
        }
    }
}

// Usage
val mp3Player = MP3Player()
val player: MediaPlayer = MediaAdapter(mp3Player)
player.play("song.mp3")
```

---

## Swift

### Protocol Adapter (Recommended)
```swift
// Target protocol
protocol PaymentProcessor {
    func processPayment(amount: Double, currency: String) async -> String
    func refund(transactionId: String) async
}

// Adaptee
class StripePaymentService {
    struct ChargeResult {
        let id: String
    }
    
    func charge(amountInCents: Int, currencyCode: String) async -> ChargeResult {
        print("Stripe: Charging \(amountInCents) cents in \(currencyCode)")
        return ChargeResult(id: "stripe_tx_123")
    }
    
    func createRefund(chargeId: String) async {
        print("Stripe: Refunding charge \(chargeId)")
    }
}

// Adapter
class StripeAdapter: PaymentProcessor {
    private let stripeService: StripePaymentService
    
    init(stripeService: StripePaymentService) {
        self.stripeService = stripeService
    }
    
    func processPayment(amount: Double, currency: String) async -> String {
        let amountInCents = Int(round(amount * 100))
        let result = await stripeService.charge(amountInCents: amountInCents, currencyCode: currency)
        return result.id
    }
    
    func refund(transactionId: String) async {
        await stripeService.createRefund(chargeId: transactionId)
    }
}

// Usage
let stripeService = StripePaymentService()
let paymentProcessor: PaymentProcessor = StripeAdapter(stripeService: stripeService)
let txId = await paymentProcessor.processPayment(amount: 99.99, currency: "USD")
```

### Extension Adapter
```swift
// Adaptee
class LegacyImageLoader {
    func loadImageData(path: String) -> Data? {
        print("Loading image from: \(path)")
        return nil
    }
}

// Target protocol
protocol ImageProvider {
    func fetchImage(url: String) async -> Data?
}

// Adapter using extension
extension LegacyImageLoader: ImageProvider {
    func fetchImage(url: String) async -> Data? {
        return loadImageData(path: url)
    }
}

// Usage
let loader: ImageProvider = LegacyImageLoader()
let imageData = await loader.fetchImage(url: "/path/to/image.png")
```

---

## Dart

### Object Adapter (Recommended)
```dart
// Target interface
abstract class PaymentProcessor {
  Future<String> processPayment(double amount, String currency);
  Future<void> refund(String transactionId);
}

// Adaptee
class StripePaymentService {
  Future<ChargeResult> charge(int amountInCents, String currencyCode) async {
    print('Stripe: Charging $amountInCents cents in $currencyCode');
    return ChargeResult('stripe_tx_123');
  }

  Future<void> createRefund(String chargeId) async {
    print('Stripe: Refunding charge $chargeId');
  }
}

class ChargeResult {
  final String id;
  ChargeResult(this.id);
}

// Adapter
class StripeAdapter implements PaymentProcessor {
  final StripePaymentService _stripeService;

  StripeAdapter(this._stripeService);

  @override
  Future<String> processPayment(double amount, String currency) async {
    final amountInCents = (amount * 100).round();
    final result = await _stripeService.charge(amountInCents, currency);
    return result.id;
  }

  @override
  Future<void> refund(String transactionId) async {
    await _stripeService.createRefund(transactionId);
  }
}

// Usage
final stripeService = StripePaymentService();
final PaymentProcessor paymentProcessor = StripeAdapter(stripeService);
final txId = await paymentProcessor.processPayment(99.99, 'USD');
```

### Class Adapter (Mixin)
```dart
// Target interface
abstract class MediaPlayer {
  void play(String filename);
}

// Adaptee
class MP3Player {
  void playMP3(String file) {
    print('Playing MP3: $file');
  }
}

// Adapter using mixin
class MediaAdapter extends MP3Player implements MediaPlayer {
  @override
  void play(String filename) {
    if (filename.endsWith('.mp3')) {
      playMP3(filename);
    } else {
      print('Unsupported format: $filename');
    }
  }
}

// Usage
final MediaPlayer player = MediaAdapter();
player.play('song.mp3');
```
