---
title: Factory Method Pattern
category: Creational Design Pattern
difficulty: beginner
purpose: Define an interface for creating objects but let subclasses decide which class to instantiate
when_to_use:
  - Creating different types of database connections
  - Payment processing with multiple providers
  - Notification systems (Email, SMS, Push)
  - Document parsers (JSON, XML, CSV)
  - Logger implementations
  - Authentication strategies
languages:
  typescript:
    - name: Abstract Class Factory (Built-in)
      library: javascript-core
      recommended: true
    - name: Interface Factory (Built-in)
      library: javascript-core
  python:
    - name: ABC Abstract Method (Built-in)
      library: python-core
      recommended: true
    - name: Protocol Factory (Built-in)
      library: python-core
  java:
    - name: Abstract Class Factory (Built-in)
      library: java-core
      recommended: true
    - name: Interface Factory (Built-in)
      library: java-core
  csharp:
    - name: Abstract Class Factory (Built-in)
      library: dotnet-core
      recommended: true
    - name: Interface Factory (Built-in)
      library: dotnet-core
  php:
    - name: Abstract Class Factory (Built-in)
      library: php-core
      recommended: true
    - name: Interface Factory (Built-in)
      library: php-core
  kotlin:
    - name: Abstract Class Factory (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Sealed Class Factory (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Protocol Factory (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Abstract Class Factory (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Factory method returns interface/abstract type
  - Subclasses override factory method to create specific instances
  - Often combined with Strategy pattern
  - Can use registry pattern for dynamic factories
best_practices:
  do:
    - Return abstract types from factory methods
    - Use dependency injection to inject factories
    - Keep factory logic simple and focused
    - Consider using Simple Factory for basic cases
    - Use factory method when creation logic varies by subclass
  dont:
    - Create factory for single implementation
    - Put complex business logic in factory methods
    - Couple factory to concrete implementation details
    - Overuse - sometimes direct instantiation is clearer
related_functions:
  - database-query.md
  - http-requests.md
tags: [factory-method, creational-pattern, polymorphism, dependency-injection]
updated: 2026-01-20
---

## TypeScript

### Abstract Class Factory
```typescript
// Product interface
interface Notification {
  send(recipient: string, message: string): Promise<void>;
}

// Concrete products
class EmailNotification implements Notification {
  async send(recipient: string, message: string): Promise<void> {
    console.log(`Sending email to ${recipient}: ${message}`);
  }
}

class SMSNotification implements Notification {
  async send(recipient: string, message: string): Promise<void> {
    console.log(`Sending SMS to ${recipient}: ${message}`);
  }
}

class PushNotification implements Notification {
  async send(recipient: string, message: string): Promise<void> {
    console.log(`Sending push to ${recipient}: ${message}`);
  }
}

// Factory
abstract class NotificationFactory {
  abstract createNotification(): Notification;

  async notify(recipient: string, message: string): Promise<void> {
    const notification = this.createNotification();
    await notification.send(recipient, message);
  }
}

class EmailNotificationFactory extends NotificationFactory {
  createNotification(): Notification {
    return new EmailNotification();
  }
}

class SMSNotificationFactory extends NotificationFactory {
  createNotification(): Notification {
    return new SMSNotification();
  }
}

// Usage
const factory: NotificationFactory = new EmailNotificationFactory();
await factory.notify('user@example.com', 'Hello!');
```

### Simple Factory (Alternative)
```typescript
enum NotificationType {
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push'
}

class NotificationFactory {
  static create(type: NotificationType): Notification {
    switch (type) {
      case NotificationType.EMAIL:
        return new EmailNotification();
      case NotificationType.SMS:
        return new SMSNotification();
      case NotificationType.PUSH:
        return new PushNotification();
      default:
        throw new Error(`Unknown notification type: ${type}`);
    }
  }
}

// Usage
const notification = NotificationFactory.create(NotificationType.EMAIL);
await notification.send('user@example.com', 'Hello!');
```

---

## Python

### ABC Abstract Method
```python
from abc import ABC, abstractmethod

# Product interface
class Notification(ABC):
    @abstractmethod
    async def send(self, recipient: str, message: str) -> None:
        pass

# Concrete products
class EmailNotification(Notification):
    async def send(self, recipient: str, message: str) -> None:
        print(f"Sending email to {recipient}: {message}")

class SMSNotification(Notification):
    async def send(self, recipient: str, message: str) -> None:
        print(f"Sending SMS to {recipient}: {message}")

class PushNotification(Notification):
    async def send(self, recipient: str, message: str) -> None:
        print(f"Sending push to {recipient}: {message}")

# Factory
class NotificationFactory(ABC):
    @abstractmethod
    def create_notification(self) -> Notification:
        pass

    async def notify(self, recipient: str, message: str) -> None:
        notification = self.create_notification()
        await notification.send(recipient, message)

class EmailNotificationFactory(NotificationFactory):
    def create_notification(self) -> Notification:
        return EmailNotification()

class SMSNotificationFactory(NotificationFactory):
    def create_notification(self) -> Notification:
        return SMSNotification()

# Usage
factory: NotificationFactory = EmailNotificationFactory()
await factory.notify("user@example.com", "Hello!")
```

### Simple Factory (Alternative)
```python
from enum import Enum

class NotificationType(Enum):
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"

class NotificationFactory:
    @staticmethod
    def create(notification_type: NotificationType) -> Notification:
        match notification_type:
            case NotificationType.EMAIL:
                return EmailNotification()
            case NotificationType.SMS:
                return SMSNotification()
            case NotificationType.PUSH:
                return PushNotification()
            case _:
                raise ValueError(f"Unknown type: {notification_type}")

# Usage
notification = NotificationFactory.create(NotificationType.EMAIL)
await notification.send("user@example.com", "Hello!")
```

---

## Java

### Abstract Class Factory
```java
// Product interface
interface Notification {
    void send(String recipient, String message);
}

// Concrete products
class EmailNotification implements Notification {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending email to " + recipient + ": " + message);
    }
}

class SMSNotification implements Notification {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending SMS to " + recipient + ": " + message);
    }
}

class PushNotification implements Notification {
    @Override
    public void send(String recipient, String message) {
        System.out.println("Sending push to " + recipient + ": " + message);
    }
}

// Factory
abstract class NotificationFactory {
    protected abstract Notification createNotification();

    public void notify(String recipient, String message) {
        Notification notification = createNotification();
        notification.send(recipient, message);
    }
}

class EmailNotificationFactory extends NotificationFactory {
    @Override
    protected Notification createNotification() {
        return new EmailNotification();
    }
}

class SMSNotificationFactory extends NotificationFactory {
    @Override
    protected Notification createNotification() {
        return new SMSNotification();
    }
}

// Usage
NotificationFactory factory = new EmailNotificationFactory();
factory.notify("user@example.com", "Hello!");
```

### Simple Factory with Enum
```java
enum NotificationType {
    EMAIL, SMS, PUSH
}

class NotificationFactory {
    public static Notification create(NotificationType type) {
        return switch (type) {
            case EMAIL -> new EmailNotification();
            case SMS -> new SMSNotification();
            case PUSH -> new PushNotification();
        };
    }
}

// Usage
Notification notification = NotificationFactory.create(NotificationType.EMAIL);
notification.send("user@example.com", "Hello!");
```

---

## C#

### Abstract Class Factory
```csharp
// Product interface
public interface INotification
{
    Task SendAsync(string recipient, string message);
}

// Concrete products
public class EmailNotification : INotification
{
    public async Task SendAsync(string recipient, string message)
    {
        Console.WriteLine($"Sending email to {recipient}: {message}");
        await Task.CompletedTask;
    }
}

public class SmsNotification : INotification
{
    public async Task SendAsync(string recipient, string message)
    {
        Console.WriteLine($"Sending SMS to {recipient}: {message}");
        await Task.CompletedTask;
    }
}

public class PushNotification : INotification
{
    public async Task SendAsync(string recipient, string message)
    {
        Console.WriteLine($"Sending push to {recipient}: {message}");
        await Task.CompletedTask;
    }
}

// Factory
public abstract class NotificationFactory
{
    protected abstract INotification CreateNotification();

    public async Task NotifyAsync(string recipient, string message)
    {
        var notification = CreateNotification();
        await notification.SendAsync(recipient, message);
    }
}

public class EmailNotificationFactory : NotificationFactory
{
    protected override INotification CreateNotification()
    {
        return new EmailNotification();
    }
}

public class SmsNotificationFactory : NotificationFactory
{
    protected override INotification CreateNotification()
    {
        return new SmsNotification();
    }
}

// Usage
NotificationFactory factory = new EmailNotificationFactory();
await factory.NotifyAsync("user@example.com", "Hello!");
```

### Simple Factory with Switch Expression
```csharp
public enum NotificationType
{
    Email,
    Sms,
    Push
}

public static class NotificationFactory
{
    public static INotification Create(NotificationType type) => type switch
    {
        NotificationType.Email => new EmailNotification(),
        NotificationType.Sms => new SmsNotification(),
        NotificationType.Push => new PushNotification(),
        _ => throw new ArgumentException($"Unknown type: {type}")
    };
}

// Usage
var notification = NotificationFactory.Create(NotificationType.Email);
await notification.SendAsync("user@example.com", "Hello!");
```

---

## PHP

### Abstract Class Factory
```php
// Product interface
interface Notification
{
    public function send(string $recipient, string $message): void;
}

// Concrete products
class EmailNotification implements Notification
{
    public function send(string $recipient, string $message): void
    {
        echo "Sending email to $recipient: $message\n";
    }
}

class SMSNotification implements Notification
{
    public function send(string $recipient, string $message): void
    {
        echo "Sending SMS to $recipient: $message\n";
    }
}

class PushNotification implements Notification
{
    public function send(string $recipient, string $message): void
    {
        echo "Sending push to $recipient: $message\n";
    }
}

// Factory
abstract class NotificationFactory
{
    abstract protected function createNotification(): Notification;

    public function notify(string $recipient, string $message): void
    {
        $notification = $this->createNotification();
        $notification->send($recipient, $message);
    }
}

class EmailNotificationFactory extends NotificationFactory
{
    protected function createNotification(): Notification
    {
        return new EmailNotification();
    }
}

class SMSNotificationFactory extends NotificationFactory
{
    protected function createNotification(): Notification
    {
        return new SMSNotification();
    }
}

// Usage
$factory = new EmailNotificationFactory();
$factory->notify('user@example.com', 'Hello!');
```

### Simple Factory with Match Expression
```php
enum NotificationType: string
{
    case EMAIL = 'email';
    case SMS = 'sms';
    case PUSH = 'push';
}

class NotificationFactory
{
    public static function create(NotificationType $type): Notification
    {
        return match ($type) {
            NotificationType::EMAIL => new EmailNotification(),
            NotificationType::SMS => new SMSNotification(),
            NotificationType::PUSH => new PushNotification(),
        };
    }
}

// Usage
$notification = NotificationFactory::create(NotificationType::EMAIL);
$notification->send('user@example.com', 'Hello!');
```

---

## Kotlin

### Abstract Class Factory
```kotlin
// Product interface
interface Notification {
    suspend fun send(recipient: String, message: String)
}

// Concrete products
class EmailNotification : Notification {
    override suspend fun send(recipient: String, message: String) {
        println("Sending email to $recipient: $message")
    }
}

class SMSNotification : Notification {
    override suspend fun send(recipient: String, message: String) {
        println("Sending SMS to $recipient: $message")
    }
}

class PushNotification : Notification {
    override suspend fun send(recipient: String, message: String) {
        println("Sending push to $recipient: $message")
    }
}

// Factory
abstract class NotificationFactory {
    protected abstract fun createNotification(): Notification

    suspend fun notify(recipient: String, message: String) {
        val notification = createNotification()
        notification.send(recipient, message)
    }
}

class EmailNotificationFactory : NotificationFactory() {
    override fun createNotification(): Notification {
        return EmailNotification()
    }
}

class SMSNotificationFactory : NotificationFactory() {
    override fun createNotification(): Notification {
        return SMSNotification()
    }
}

// Usage
val factory: NotificationFactory = EmailNotificationFactory()
factory.notify("user@example.com", "Hello!")
```

### Sealed Class Factory (Type-safe)
```kotlin
sealed class NotificationType {
    object Email : NotificationType()
    object SMS : NotificationType()
    object Push : NotificationType()
}

object NotificationFactory {
    fun create(type: NotificationType): Notification = when (type) {
        is NotificationType.Email -> EmailNotification()
        is NotificationType.SMS -> SMSNotification()
        is NotificationType.Push -> PushNotification()
    }
}

// Usage
val notification = NotificationFactory.create(NotificationType.Email)
notification.send("user@example.com", "Hello!")
```

---

## Swift

### Protocol Factory
```swift
// Product protocol
protocol Notification {
    func send(recipient: String, message: String) async
}

// Concrete products
struct EmailNotification: Notification {
    func send(recipient: String, message: String) async {
        print("Sending email to \(recipient): \(message)")
    }
}

struct SMSNotification: Notification {
    func send(recipient: String, message: String) async {
        print("Sending SMS to \(recipient): \(message)")
    }
}

struct PushNotification: Notification {
    func send(recipient: String, message: String) async {
        print("Sending push to \(recipient): \(message)")
    }
}

// Factory
protocol NotificationFactory {
    func createNotification() -> Notification
    func notify(recipient: String, message: String) async
}

extension NotificationFactory {
    func notify(recipient: String, message: String) async {
        let notification = createNotification()
        await notification.send(recipient: recipient, message: message)
    }
}

struct EmailNotificationFactory: NotificationFactory {
    func createNotification() -> Notification {
        return EmailNotification()
    }
}

struct SMSNotificationFactory: NotificationFactory {
    func createNotification() -> Notification {
        return SMSNotification()
    }
}

// Usage
let factory: NotificationFactory = EmailNotificationFactory()
await factory.notify(recipient: "user@example.com", message: "Hello!")
```

### Enum-based Factory
```swift
enum NotificationType {
    case email
    case sms
    case push
}

struct NotificationFactory {
    static func create(_ type: NotificationType) -> Notification {
        switch type {
        case .email:
            return EmailNotification()
        case .sms:
            return SMSNotification()
        case .push:
            return PushNotification()
        }
    }
}

// Usage
let notification = NotificationFactory.create(.email)
await notification.send(recipient: "user@example.com", message: "Hello!")
```

---

## Dart

### Abstract Class Factory
```dart
// Product interface
abstract class Notification {
  Future<void> send(String recipient, String message);
}

// Concrete products
class EmailNotification implements Notification {
  @override
  Future<void> send(String recipient, String message) async {
    print('Sending email to $recipient: $message');
  }
}

class SMSNotification implements Notification {
  @override
  Future<void> send(String recipient, String message) async {
    print('Sending SMS to $recipient: $message');
  }
}

class PushNotification implements Notification {
  @override
  Future<void> send(String recipient, String message) async {
    print('Sending push to $recipient: $message');
  }
}

// Factory
abstract class NotificationFactory {
  Notification createNotification();

  Future<void> notify(String recipient, String message) async {
    final notification = createNotification();
    await notification.send(recipient, message);
  }
}

class EmailNotificationFactory extends NotificationFactory {
  @override
  Notification createNotification() {
    return EmailNotification();
  }
}

class SMSNotificationFactory extends NotificationFactory {
  @override
  Notification createNotification() {
    return SMSNotification();
  }
}

// Usage
final factory = EmailNotificationFactory();
await factory.notify('user@example.com', 'Hello!');
```

### Enum-based Factory
```dart
enum NotificationType { email, sms, push }

class NotificationFactory {
  static Notification create(NotificationType type) {
    switch (type) {
      case NotificationType.email:
        return EmailNotification();
      case NotificationType.sms:
        return SMSNotification();
      case NotificationType.push:
        return PushNotification();
    }
  }
}

// Usage
final notification = NotificationFactory.create(NotificationType.email);
await notification.send('user@example.com', 'Hello!');
```
