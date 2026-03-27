---
title: Abstract Factory Pattern
category: Creational Design Pattern
difficulty: intermediate
purpose: Provide an interface for creating families of related objects without specifying their concrete classes
when_to_use:
  - Multi-cloud providers (AWS, Azure, GCP)
  - Cross-platform UI (Windows, Mac, Linux)
  - Database drivers (MySQL, PostgreSQL, MongoDB)
  - Theme systems (Dark, Light, High Contrast)
  - Document formats (PDF, DOCX, HTML)
  - Platform-specific components
languages:
  typescript:
    - name: Interface Factory (Built-in)
      library: javascript-core
      recommended: true
  python:
    - name: ABC Factory (Built-in)
      library: python-core
      recommended: true
  java:
    - name: Interface Factory (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Interface Factory (Built-in)
      library: dotnet-core
      recommended: true
  php:
    - name: Interface Factory (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Interface Factory (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: Protocol Factory (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Abstract Factory (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Product families (related objects)
  - Platform abstraction
  - Configuration-based factory selection
  - Dependency injection with factories
best_practices:
  do:
    - Create families of related products
    - Use for platform/provider abstraction
    - Return interfaces/abstract types
    - Consider dependency injection
    - Keep factories stateless
  dont:
    - Use for single products (use Factory Method)
    - Mix unrelated products in factory
    - Add business logic to factories
    - Create factories with mutable state
related_functions:
  - None
tags: [abstract-factory, creational-pattern, families, platform-abstraction]
updated: 2026-01-20
---

## TypeScript

### Cloud Provider Example
```typescript
// Abstract products
interface Storage {
  upload(file: string): void;
  download(file: string): void;
}

interface Database {
  query(sql: string): any[];
  insert(data: any): void;
}

interface Queue {
  publish(message: string): void;
  consume(): string;
}

// Abstract factory
interface CloudFactory {
  createStorage(): Storage;
  createDatabase(): Database;
  createQueue(): Queue;
}

// Concrete products - AWS
class S3Storage implements Storage {
  upload(file: string): void {
    console.log(`Uploading ${file} to S3`);
  }

  download(file: string): void {
    console.log(`Downloading ${file} from S3`);
  }
}

class DynamoDB implements Database {
  query(sql: string): any[] {
    console.log(`Querying DynamoDB: ${sql}`);
    return [];
  }

  insert(data: any): void {
    console.log(`Inserting into DynamoDB:`, data);
  }
}

class SQS implements Queue {
  publish(message: string): void {
    console.log(`Publishing to SQS: ${message}`);
  }

  consume(): string {
    console.log(`Consuming from SQS`);
    return 'message';
  }
}

// Concrete products - Azure
class BlobStorage implements Storage {
  upload(file: string): void {
    console.log(`Uploading ${file} to Azure Blob`);
  }

  download(file: string): void {
    console.log(`Downloading ${file} from Azure Blob`);
  }
}

class CosmosDB implements Database {
  query(sql: string): any[] {
    console.log(`Querying CosmosDB: ${sql}`);
    return [];
  }

  insert(data: any): void {
    console.log(`Inserting into CosmosDB:`, data);
  }
}

class ServiceBus implements Queue {
  publish(message: string): void {
    console.log(`Publishing to Service Bus: ${message}`);
  }

  consume(): string {
    console.log(`Consuming from Service Bus`);
    return 'message';
  }
}

// Concrete factories
class AWSFactory implements CloudFactory {
  createStorage(): Storage {
    return new S3Storage();
  }

  createDatabase(): Database {
    return new DynamoDB();
  }

  createQueue(): Queue {
    return new SQS();
  }
}

class AzureFactory implements CloudFactory {
  createStorage(): Storage {
    return new BlobStorage();
  }

  createDatabase(): Database {
    return new CosmosDB();
  }

  createQueue(): Queue {
    return new ServiceBus();
  }
}

// Client code
class Application {
  private storage: Storage;
  private database: Database;
  private queue: Queue;

  constructor(factory: CloudFactory) {
    this.storage = factory.createStorage();
    this.database = factory.createDatabase();
    this.queue = factory.createQueue();
  }

  run(): void {
    this.storage.upload('data.txt');
    this.database.insert({ id: 1, name: 'Test' });
    this.queue.publish('Hello World');
  }
}

// Usage
const awsApp = new Application(new AWSFactory());
awsApp.run();

console.log('\n---\n');

const azureApp = new Application(new AzureFactory());
azureApp.run();
```

### UI Theme Example
```typescript
interface Button {
  render(): void;
  click(): void;
}

interface Checkbox {
  render(): void;
  toggle(): void;
}

interface ThemeFactory {
  createButton(text: string): Button;
  createCheckbox(label: string): Checkbox;
}

// Dark theme
class DarkButton implements Button {
  constructor(private text: string) {}

  render(): void {
    console.log(`[Dark Button: ${this.text}]`);
  }

  click(): void {
    console.log(`Dark button "${this.text}" clicked`);
  }
}

class DarkCheckbox implements Checkbox {
  constructor(private label: string) {}

  render(): void {
    console.log(`[☐ Dark Checkbox: ${this.label}]`);
  }

  toggle(): void {
    console.log(`Dark checkbox "${this.label}" toggled`);
  }
}

// Light theme
class LightButton implements Button {
  constructor(private text: string) {}

  render(): void {
    console.log(`[Light Button: ${this.text}]`);
  }

  click(): void {
    console.log(`Light button "${this.text}" clicked`);
  }
}

class LightCheckbox implements Checkbox {
  constructor(private label: string) {}

  render(): void {
    console.log(`[□ Light Checkbox: ${this.label}]`);
  }

  toggle(): void {
    console.log(`Light checkbox "${this.label}" toggled`);
  }
}

// Factories
class DarkThemeFactory implements ThemeFactory {
  createButton(text: string): Button {
    return new DarkButton(text);
  }

  createCheckbox(label: string): Checkbox {
    return new DarkCheckbox(label);
  }
}

class LightThemeFactory implements ThemeFactory {
  createButton(text: string): Button {
    return new LightButton(text);
  }

  createCheckbox(label: string): Checkbox {
    return new LightCheckbox(label);
  }
}

// Usage
function renderUI(factory: ThemeFactory) {
  const submitBtn = factory.createButton('Submit');
  const agreeCheckbox = factory.createCheckbox('I agree');

  submitBtn.render();
  agreeCheckbox.render();
}

renderUI(new DarkThemeFactory());
console.log();
renderUI(new LightThemeFactory());
```

---

## Python

### Cloud Provider Example
```python
from abc import ABC, abstractmethod

# Abstract products
class Storage(ABC):
    @abstractmethod
    def upload(self, file: str) -> None:
        pass

    @abstractmethod
    def download(self, file: str) -> None:
        pass

class Database(ABC):
    @abstractmethod
    def query(self, sql: str) -> list:
        pass

    @abstractmethod
    def insert(self, data: dict) -> None:
        pass

class Queue(ABC):
    @abstractmethod
    def publish(self, message: str) -> None:
        pass

    @abstractmethod
    def consume(self) -> str:
        pass

# Abstract factory
class CloudFactory(ABC):
    @abstractmethod
    def create_storage(self) -> Storage:
        pass

    @abstractmethod
    def create_database(self) -> Database:
        pass

    @abstractmethod
    def create_queue(self) -> Queue:
        pass

# Concrete products - AWS
class S3Storage(Storage):
    def upload(self, file: str) -> None:
        print(f"Uploading {file} to S3")

    def download(self, file: str) -> None:
        print(f"Downloading {file} from S3")

class DynamoDB(Database):
    def query(self, sql: str) -> list:
        print(f"Querying DynamoDB: {sql}")
        return []

    def insert(self, data: dict) -> None:
        print(f"Inserting into DynamoDB: {data}")

class SQS(Queue):
    def publish(self, message: str) -> None:
        print(f"Publishing to SQS: {message}")

    def consume(self) -> str:
        print("Consuming from SQS")
        return "message"

# Concrete products - Azure
class BlobStorage(Storage):
    def upload(self, file: str) -> None:
        print(f"Uploading {file} to Azure Blob")

    def download(self, file: str) -> None:
        print(f"Downloading {file} from Azure Blob")

class CosmosDB(Database):
    def query(self, sql: str) -> list:
        print(f"Querying CosmosDB: {sql}")
        return []

    def insert(self, data: dict) -> None:
        print(f"Inserting into CosmosDB: {data}")

class ServiceBus(Queue):
    def publish(self, message: str) -> None:
        print(f"Publishing to Service Bus: {message}")

    def consume(self) -> str:
        print("Consuming from Service Bus")
        return "message"

# Concrete factories
class AWSFactory(CloudFactory):
    def create_storage(self) -> Storage:
        return S3Storage()

    def create_database(self) -> Database:
        return DynamoDB()

    def create_queue(self) -> Queue:
        return SQS()

class AzureFactory(CloudFactory):
    def create_storage(self) -> Storage:
        return BlobStorage()

    def create_database(self) -> Database:
        return CosmosDB()

    def create_queue(self) -> Queue:
        return ServiceBus()

# Client code
class Application:
    def __init__(self, factory: CloudFactory):
        self._storage = factory.create_storage()
        self._database = factory.create_database()
        self._queue = factory.create_queue()

    def run(self) -> None:
        self._storage.upload("data.txt")
        self._database.insert({"id": 1, "name": "Test"})
        self._queue.publish("Hello World")

# Usage
aws_app = Application(AWSFactory())
aws_app.run()

print("\n---\n")

azure_app = Application(AzureFactory())
azure_app.run()
```

---

## Java

### Cloud Provider Example
```java
// Abstract products
interface Storage {
    void upload(String file);
    void download(String file);
}

interface Database {
    List<Object> query(String sql);
    void insert(Map<String, Object> data);
}

interface Queue {
    void publish(String message);
    String consume();
}

// Abstract factory
interface CloudFactory {
    Storage createStorage();
    Database createDatabase();
    Queue createQueue();
}

// Concrete products - AWS
class S3Storage implements Storage {
    @Override
    public void upload(String file) {
        System.out.println("Uploading " + file + " to S3");
    }

    @Override
    public void download(String file) {
        System.out.println("Downloading " + file + " from S3");
    }
}

class DynamoDB implements Database {
    @Override
    public List<Object> query(String sql) {
        System.out.println("Querying DynamoDB: " + sql);
        return new ArrayList<>();
    }

    @Override
    public void insert(Map<String, Object> data) {
        System.out.println("Inserting into DynamoDB: " + data);
    }
}

class SQS implements Queue {
    @Override
    public void publish(String message) {
        System.out.println("Publishing to SQS: " + message);
    }

    @Override
    public String consume() {
        System.out.println("Consuming from SQS");
        return "message";
    }
}

// Concrete factory - AWS
class AWSFactory implements CloudFactory {
    @Override
    public Storage createStorage() {
        return new S3Storage();
    }

    @Override
    public Database createDatabase() {
        return new DynamoDB();
    }

    @Override
    public Queue createQueue() {
        return new SQS();
    }
}

// Client code
class Application {
    private final Storage storage;
    private final Database database;
    private final Queue queue;

    public Application(CloudFactory factory) {
        this.storage = factory.createStorage();
        this.database = factory.createDatabase();
        this.queue = factory.createQueue();
    }

    public void run() {
        storage.upload("data.txt");
        database.insert(Map.of("id", 1, "name", "Test"));
        queue.publish("Hello World");
    }
}

// Usage
Application awsApp = new Application(new AWSFactory());
awsApp.run();
```

---

## C#

### Cloud Provider Example
```csharp
// Abstract products
public interface IStorage
{
    void Upload(string file);
    void Download(string file);
}

public interface IDatabase
{
    List<object> Query(string sql);
    void Insert(Dictionary<string, object> data);
}

public interface IQueue
{
    void Publish(string message);
    string Consume();
}

// Abstract factory
public interface ICloudFactory
{
    IStorage CreateStorage();
    IDatabase CreateDatabase();
    IQueue CreateQueue();
}

// Concrete products - AWS
public class S3Storage : IStorage
{
    public void Upload(string file)
    {
        Console.WriteLine($"Uploading {file} to S3");
    }

    public void Download(string file)
    {
        Console.WriteLine($"Downloading {file} from S3");
    }
}

public class DynamoDB : IDatabase
{
    public List<object> Query(string sql)
    {
        Console.WriteLine($"Querying DynamoDB: {sql}");
        return new List<object>();
    }

    public void Insert(Dictionary<string, object> data)
    {
        Console.WriteLine($"Inserting into DynamoDB: {string.Join(", ", data)}");
    }
}

public class SQS : IQueue
{
    public void Publish(string message)
    {
        Console.WriteLine($"Publishing to SQS: {message}");
    }

    public string Consume()
    {
        Console.WriteLine("Consuming from SQS");
        return "message";
    }
}

// Concrete factory - AWS
public class AWSFactory : ICloudFactory
{
    public IStorage CreateStorage() => new S3Storage();
    public IDatabase CreateDatabase() => new DynamoDB();
    public IQueue CreateQueue() => new SQS();
}

// Client code
public class Application
{
    private readonly IStorage _storage;
    private readonly IDatabase _database;
    private readonly IQueue _queue;

    public Application(ICloudFactory factory)
    {
        _storage = factory.CreateStorage();
        _database = factory.CreateDatabase();
        _queue = factory.CreateQueue();
    }

    public void Run()
    {
        _storage.Upload("data.txt");
        _database.Insert(new Dictionary<string, object> { ["id"] = 1, ["name"] = "Test" });
        _queue.Publish("Hello World");
    }
}

// Usage
var awsApp = new Application(new AWSFactory());
awsApp.Run();
```

---

## PHP

### Cloud Provider Example
```php
// Abstract products
interface Storage
{
    public function upload(string $file): void;
    public function download(string $file): void;
}

interface Database
{
    public function query(string $sql): array;
    public function insert(array $data): void;
}

interface Queue
{
    public function publish(string $message): void;
    public function consume(): string;
}

// Abstract factory
interface CloudFactory
{
    public function createStorage(): Storage;
    public function createDatabase(): Database;
    public function createQueue(): Queue;
}

// Concrete products - AWS
class S3Storage implements Storage
{
    public function upload(string $file): void
    {
        echo "Uploading $file to S3\n";
    }

    public function download(string $file): void
    {
        echo "Downloading $file from S3\n";
    }
}

class DynamoDB implements Database
{
    public function query(string $sql): array
    {
        echo "Querying DynamoDB: $sql\n";
        return [];
    }

    public function insert(array $data): void
    {
        echo "Inserting into DynamoDB: " . json_encode($data) . "\n";
    }
}

class SQS implements Queue
{
    public function publish(string $message): void
    {
        echo "Publishing to SQS: $message\n";
    }

    public function consume(): string
    {
        echo "Consuming from SQS\n";
        return 'message';
    }
}

// Concrete factory - AWS
class AWSFactory implements CloudFactory
{
    public function createStorage(): Storage
    {
        return new S3Storage();
    }

    public function createDatabase(): Database
    {
        return new DynamoDB();
    }

    public function createQueue(): Queue
    {
        return new SQS();
    }
}

// Client code
class Application
{
    private Storage $storage;
    private Database $database;
    private Queue $queue;

    public function __construct(CloudFactory $factory)
    {
        $this->storage = $factory->createStorage();
        $this->database = $factory->createDatabase();
        $this->queue = $factory->createQueue();
    }

    public function run(): void
    {
        $this->storage->upload('data.txt');
        $this->database->insert(['id' => 1, 'name' => 'Test']);
        $this->queue->publish('Hello World');
    }
}

// Usage
$awsApp = new Application(new AWSFactory());
$awsApp->run();
```

---

## Kotlin

### Cloud Provider Example
```kotlin
// Abstract products
interface Storage {
    fun upload(file: String)
    fun download(file: String)
}

interface Database {
    fun query(sql: String): List<Any>
    fun insert(data: Map<String, Any>)
}

interface Queue {
    fun publish(message: String)
    fun consume(): String
}

// Abstract factory
interface CloudFactory {
    fun createStorage(): Storage
    fun createDatabase(): Database
    fun createQueue(): Queue
}

// Concrete products - AWS
class S3Storage : Storage {
    override fun upload(file: String) {
        println("Uploading $file to S3")
    }

    override fun download(file: String) {
        println("Downloading $file from S3")
    }
}

class DynamoDB : Database {
    override fun query(sql: String): List<Any> {
        println("Querying DynamoDB: $sql")
        return emptyList()
    }

    override fun insert(data: Map<String, Any>) {
        println("Inserting into DynamoDB: $data")
    }
}

class SQS : Queue {
    override fun publish(message: String) {
        println("Publishing to SQS: $message")
    }

    override fun consume(): String {
        println("Consuming from SQS")
        return "message"
    }
}

// Concrete factory - AWS
class AWSFactory : CloudFactory {
    override fun createStorage() = S3Storage()
    override fun createDatabase() = DynamoDB()
    override fun createQueue() = SQS()
}

// Client code
class Application(factory: CloudFactory) {
    private val storage = factory.createStorage()
    private val database = factory.createDatabase()
    private val queue = factory.createQueue()

    fun run() {
        storage.upload("data.txt")
        database.insert(mapOf("id" to 1, "name" to "Test"))
        queue.publish("Hello World")
    }
}

// Usage
val awsApp = Application(AWSFactory())
awsApp.run()
```

---

## Swift

### Cloud Provider Example
```swift
// Abstract products
protocol Storage {
    func upload(file: String)
    func download(file: String)
}

protocol Database {
    func query(sql: String) -> [Any]
    func insert(data: [String: Any])
}

protocol Queue {
    func publish(message: String)
    func consume() -> String
}

// Abstract factory
protocol CloudFactory {
    func createStorage() -> Storage
    func createDatabase() -> Database
    func createQueue() -> Queue
}

// Concrete products - AWS
class S3Storage: Storage {
    func upload(file: String) {
        print("Uploading \(file) to S3")
    }

    func download(file: String) {
        print("Downloading \(file) from S3")
    }
}

class DynamoDB: Database {
    func query(sql: String) -> [Any] {
        print("Querying DynamoDB: \(sql)")
        return []
    }

    func insert(data: [String: Any]) {
        print("Inserting into DynamoDB: \(data)")
    }
}

class SQS: Queue {
    func publish(message: String) {
        print("Publishing to SQS: \(message)")
    }

    func consume() -> String {
        print("Consuming from SQS")
        return "message"
    }
}

// Concrete factory - AWS
class AWSFactory: CloudFactory {
    func createStorage() -> Storage {
        return S3Storage()
    }

    func createDatabase() -> Database {
        return DynamoDB()
    }

    func createQueue() -> Queue {
        return SQS()
    }
}

// Client code
class Application {
    private let storage: Storage
    private let database: Database
    private let queue: Queue

    init(factory: CloudFactory) {
        storage = factory.createStorage()
        database = factory.createDatabase()
        queue = factory.createQueue()
    }

    func run() {
        storage.upload(file: "data.txt")
        database.insert(data: ["id": 1, "name": "Test"])
        queue.publish(message: "Hello World")
    }
}

// Usage
let awsApp = Application(factory: AWSFactory())
awsApp.run()
```

---

## Dart

### Cloud Provider Example
```dart
// Abstract products
abstract class Storage {
  void upload(String file);
  void download(String file);
}

abstract class Database {
  List<Object> query(String sql);
  void insert(Map<String, Object> data);
}

abstract class Queue {
  void publish(String message);
  String consume();
}

// Abstract factory
abstract class CloudFactory {
  Storage createStorage();
  Database createDatabase();
  Queue createQueue();
}

// Concrete products - AWS
class S3Storage implements Storage {
  @override
  void upload(String file) {
    print('Uploading $file to S3');
  }

  @override
  void download(String file) {
    print('Downloading $file from S3');
  }
}

class DynamoDB implements Database {
  @override
  List<Object> query(String sql) {
    print('Querying DynamoDB: $sql');
    return [];
  }

  @override
  void insert(Map<String, Object> data) {
    print('Inserting into DynamoDB: $data');
  }
}

class SQS implements Queue {
  @override
  void publish(String message) {
    print('Publishing to SQS: $message');
  }

  @override
  String consume() {
    print('Consuming from SQS');
    return 'message';
  }
}

// Concrete factory - AWS
class AWSFactory implements CloudFactory {
  @override
  Storage createStorage() => S3Storage();

  @override
  Database createDatabase() => DynamoDB();

  @override
  Queue createQueue() => SQS();
}

// Client code
class Application {
  final Storage _storage;
  final Database _database;
  final Queue _queue;

  Application(CloudFactory factory)
      : _storage = factory.createStorage(),
        _database = factory.createDatabase(),
        _queue = factory.createQueue();

  void run() {
    _storage.upload('data.txt');
    _database.insert({'id': 1, 'name': 'Test'});
    _queue.publish('Hello World');
  }
}

// Usage
void main() {
  final awsApp = Application(AWSFactory());
  awsApp.run();
}
```
