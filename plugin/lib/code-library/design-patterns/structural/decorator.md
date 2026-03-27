---
title: Decorator Pattern
category: Structural Design Pattern
difficulty: intermediate
purpose: Attach additional responsibilities to an object dynamically without altering its structure
when_to_use:
  - Adding logging to functions/methods
  - Authentication/authorization wrappers
  - Caching layers
  - Input/output transformation
  - Rate limiting wrappers
  - Compression/encryption layers
languages:
  typescript:
    - name: Class Decorator (Built-in)
      library: javascript-core
      recommended: true
    - name: Function Decorator (Built-in)
      library: javascript-core
    - name: TypeScript Decorator (Built-in)
      library: typescript
  python:
    - name: Function Decorator (Built-in)
      library: python-core
      recommended: true
    - name: Class Decorator (Built-in)
      library: python-core
    - name: Decorator with functools
      library: python-core
  java:
    - name: Class Decorator (Built-in)
      library: java-core
      recommended: true
  csharp:
    - name: Class Decorator (Built-in)
      library: dotnet-core
      recommended: true
    - name: Extension Method Decorator (Built-in)
      library: dotnet-core
  php:
    - name: Class Decorator (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Class Decorator (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Delegation Decorator (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Protocol Decorator (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Property Wrapper (Built-in)
      library: swift-stdlib
  dart:
    - name: Class Decorator (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Wrapping existing objects with new behavior
  - Chaining multiple decorators
  - Transparent decoration (same interface)
  - Decorator stacks for complex behavior
best_practices:
  do:
    - Keep decorators focused on single responsibility
    - Make decorators composable and stackable
    - Maintain the same interface as the decorated object
    - Use decorators for cross-cutting concerns (logging, caching, auth)
    - Consider using decorators for middleware patterns
  dont:
    - Add complex business logic to decorators
    - Create deep decorator chains (hard to debug)
    - Modify the decorated object's state inappropriately
    - Use decorator when simple inheritance suffices
related_functions:
  - logging.md
  - caching.md
  - auth-authorization.md
  - rate-limiting.md
tags: [decorator, structural-pattern, wrapper, composition, middleware]
updated: 2026-01-20
---

## TypeScript

### Class Decorator
```typescript
// Component interface
interface DataSource {
  readData(): string;
  writeData(data: string): void;
}

// Concrete component
class FileDataSource implements DataSource {
  constructor(private filename: string) {}

  readData(): string {
    console.log(`Reading data from file: ${this.filename}`);
    return `file content from ${this.filename}`;
  }

  writeData(data: string): void {
    console.log(`Writing data to file: ${this.filename}`);
  }
}

// Base decorator
abstract class DataSourceDecorator implements DataSource {
  constructor(protected wrapped: DataSource) {}

  readData(): string {
    return this.wrapped.readData();
  }

  writeData(data: string): void {
    this.wrapped.writeData(data);
  }
}

// Concrete decorators
class EncryptionDecorator extends DataSourceDecorator {
  readData(): string {
    const data = super.readData();
    return this.decrypt(data);
  }

  writeData(data: string): void {
    const encrypted = this.encrypt(data);
    super.writeData(encrypted);
  }

  private encrypt(data: string): string {
    console.log('Encrypting data...');
    return `encrypted(${data})`;
  }

  private decrypt(data: string): string {
    console.log('Decrypting data...');
    return data.replace('encrypted(', '').replace(')', '');
  }
}

class CompressionDecorator extends DataSourceDecorator {
  readData(): string {
    const data = super.readData();
    return this.decompress(data);
  }

  writeData(data: string): void {
    const compressed = this.compress(data);
    super.writeData(compressed);
  }

  private compress(data: string): string {
    console.log('Compressing data...');
    return `compressed(${data})`;
  }

  private decompress(data: string): string {
    console.log('Decompressing data...');
    return data.replace('compressed(', '').replace(')', '');
  }
}

// Usage - stacking decorators
let source: DataSource = new FileDataSource('data.txt');
source = new EncryptionDecorator(source);
source = new CompressionDecorator(source);
source.writeData('Sensitive data');
const data = source.readData();
```

### Function Decorator
```typescript
function logExecution(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;

  descriptor.value = async function (...args: any[]) {
    console.log(`Calling ${propertyKey} with:`, args);
    const result = await originalMethod.apply(this, args);
    console.log(`${propertyKey} returned:`, result);
    return result;
  };

  return descriptor;
}

function cache(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  const cacheMap = new Map<string, any>();

  descriptor.value = async function (...args: any[]) {
    const key = JSON.stringify(args);
    if (cacheMap.has(key)) {
      console.log('Cache hit');
      return cacheMap.get(key);
    }
    const result = await originalMethod.apply(this, args);
    cacheMap.set(key, result);
    return result;
  };

  return descriptor;
}

class UserService {
  @logExecution
  @cache
  async getUser(id: string): Promise<{ id: string; name: string }> {
    console.log('Fetching user from database...');
    return { id, name: 'John Doe' };
  }
}

// Usage
const service = new UserService();
await service.getUser('123');
```

---

## Python

### Function Decorator (Recommended)
```python
from functools import wraps
from time import time
from typing import Callable, Any

def timer(func: Callable) -> Callable:
    @wraps(func)
    async def wrapper(*args, **kwargs):
        start = time()
        result = await func(*args, **kwargs)
        end = time()
        print(f"{func.__name__} took {end - start:.2f}s")
        return result
    return wrapper

def cache(func: Callable) -> Callable:
    cache_map = {}
    
    @wraps(func)
    async def wrapper(*args, **kwargs):
        key = (args, tuple(sorted(kwargs.items())))
        if key in cache_map:
            print("Cache hit")
            return cache_map[key]
        result = await func(*args, **kwargs)
        cache_map[key] = result
        return result
    return wrapper

def log_execution(func: Callable) -> Callable:
    @wraps(func)
    async def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__} with args={args}, kwargs={kwargs}")
        result = await func(*args, **kwargs)
        print(f"{func.__name__} returned: {result}")
        return result
    return wrapper

# Usage - stacking decorators
class UserService:
    @timer
    @cache
    @log_execution
    async def get_user(self, user_id: str) -> dict:
        print("Fetching user from database...")
        return {"id": user_id, "name": "John Doe"}

# Usage
service = UserService()
await service.get_user("123")
```

### Class Decorator
```python
from abc import ABC, abstractmethod

# Component interface
class DataSource(ABC):
    @abstractmethod
    def read_data(self) -> str:
        pass

    @abstractmethod
    def write_data(self, data: str) -> None:
        pass

# Concrete component
class FileDataSource(DataSource):
    def __init__(self, filename: str):
        self._filename = filename

    def read_data(self) -> str:
        print(f"Reading data from file: {self._filename}")
        return f"file content from {self._filename}"

    def write_data(self, data: str) -> None:
        print(f"Writing data to file: {self._filename}")

# Base decorator
class DataSourceDecorator(DataSource):
    def __init__(self, wrapped: DataSource):
        self._wrapped = wrapped

    def read_data(self) -> str:
        return self._wrapped.read_data()

    def write_data(self, data: str) -> None:
        self._wrapped.write_data(data)

# Concrete decorators
class EncryptionDecorator(DataSourceDecorator):
    def read_data(self) -> str:
        data = super().read_data()
        return self._decrypt(data)

    def write_data(self, data: str) -> None:
        encrypted = self._encrypt(data)
        super().write_data(encrypted)

    def _encrypt(self, data: str) -> str:
        print("Encrypting data...")
        return f"encrypted({data})"

    def _decrypt(self, data: str) -> str:
        print("Decrypting data...")
        return data.replace("encrypted(", "").replace(")", "")

class CompressionDecorator(DataSourceDecorator):
    def read_data(self) -> str:
        data = super().read_data()
        return self._decompress(data)

    def write_data(self, data: str) -> None:
        compressed = self._compress(data)
        super().write_data(compressed)

    def _compress(self, data: str) -> str:
        print("Compressing data...")
        return f"compressed({data})"

    def _decompress(self, data: str) -> str:
        print("Decompressing data...")
        return data.replace("compressed(", "").replace(")", "")

# Usage
source: DataSource = FileDataSource("data.txt")
source = EncryptionDecorator(source)
source = CompressionDecorator(source)
source.write_data("Sensitive data")
data = source.read_data()
```

---

## Java

### Class Decorator
```java
// Component interface
interface DataSource {
    String readData();
    void writeData(String data);
}

// Concrete component
class FileDataSource implements DataSource {
    private final String filename;

    public FileDataSource(String filename) {
        this.filename = filename;
    }

    @Override
    public String readData() {
        System.out.println("Reading data from file: " + filename);
        return "file content from " + filename;
    }

    @Override
    public void writeData(String data) {
        System.out.println("Writing data to file: " + filename);
    }
}

// Base decorator
abstract class DataSourceDecorator implements DataSource {
    protected final DataSource wrapped;

    public DataSourceDecorator(DataSource wrapped) {
        this.wrapped = wrapped;
    }

    @Override
    public String readData() {
        return wrapped.readData();
    }

    @Override
    public void writeData(String data) {
        wrapped.writeData(data);
    }
}

// Concrete decorators
class EncryptionDecorator extends DataSourceDecorator {
    public EncryptionDecorator(DataSource wrapped) {
        super(wrapped);
    }

    @Override
    public String readData() {
        String data = super.readData();
        return decrypt(data);
    }

    @Override
    public void writeData(String data) {
        String encrypted = encrypt(data);
        super.writeData(encrypted);
    }

    private String encrypt(String data) {
        System.out.println("Encrypting data...");
        return "encrypted(" + data + ")";
    }

    private String decrypt(String data) {
        System.out.println("Decrypting data...");
        return data.replace("encrypted(", "").replace(")", "");
    }
}

class CompressionDecorator extends DataSourceDecorator {
    public CompressionDecorator(DataSource wrapped) {
        super(wrapped);
    }

    @Override
    public String readData() {
        String data = super.readData();
        return decompress(data);
    }

    @Override
    public void writeData(String data) {
        String compressed = compress(data);
        super.writeData(compressed);
    }

    private String compress(String data) {
        System.out.println("Compressing data...");
        return "compressed(" + data + ")";
    }

    private String decompress(String data) {
        System.out.println("Decompressing data...");
        return data.replace("compressed(", "").replace(")", "");
    }
}

// Usage
DataSource source = new FileDataSource("data.txt");
source = new EncryptionDecorator(source);
source = new CompressionDecorator(source);
source.writeData("Sensitive data");
String data = source.readData();
```

---

## C#

### Class Decorator
```csharp
// Component interface
public interface IDataSource
{
    string ReadData();
    void WriteData(string data);
}

// Concrete component
public class FileDataSource : IDataSource
{
    private readonly string _filename;

    public FileDataSource(string filename)
    {
        _filename = filename;
    }

    public string ReadData()
    {
        Console.WriteLine($"Reading data from file: {_filename}");
        return $"file content from {_filename}";
    }

    public void WriteData(string data)
    {
        Console.WriteLine($"Writing data to file: {_filename}");
    }
}

// Base decorator
public abstract class DataSourceDecorator : IDataSource
{
    protected readonly IDataSource Wrapped;

    protected DataSourceDecorator(IDataSource wrapped)
    {
        Wrapped = wrapped;
    }

    public virtual string ReadData()
    {
        return Wrapped.ReadData();
    }

    public virtual void WriteData(string data)
    {
        Wrapped.WriteData(data);
    }
}

// Concrete decorators
public class EncryptionDecorator : DataSourceDecorator
{
    public EncryptionDecorator(IDataSource wrapped) : base(wrapped) { }

    public override string ReadData()
    {
        var data = base.ReadData();
        return Decrypt(data);
    }

    public override void WriteData(string data)
    {
        var encrypted = Encrypt(data);
        base.WriteData(encrypted);
    }

    private string Encrypt(string data)
    {
        Console.WriteLine("Encrypting data...");
        return $"encrypted({data})";
    }

    private string Decrypt(string data)
    {
        Console.WriteLine("Decrypting data...");
        return data.Replace("encrypted(", "").Replace(")", "");
    }
}

public class CompressionDecorator : DataSourceDecorator
{
    public CompressionDecorator(IDataSource wrapped) : base(wrapped) { }

    public override string ReadData()
    {
        var data = base.ReadData();
        return Decompress(data);
    }

    public override void WriteData(string data)
    {
        var compressed = Compress(data);
        base.WriteData(compressed);
    }

    private string Compress(string data)
    {
        Console.WriteLine("Compressing data...");
        return $"compressed({data})";
    }

    private string Decompress(string data)
    {
        Console.WriteLine("Decompressing data...");
        return data.Replace("compressed(", "").Replace(")", "");
    }
}

// Usage
IDataSource source = new FileDataSource("data.txt");
source = new EncryptionDecorator(source);
source = new CompressionDecorator(source);
source.WriteData("Sensitive data");
var data = source.ReadData();
```

---

## PHP

### Class Decorator
```php
// Component interface
interface DataSource
{
    public function readData(): string;
    public function writeData(string $data): void;
}

// Concrete component
class FileDataSource implements DataSource
{
    public function __construct(private string $filename) {}

    public function readData(): string
    {
        echo "Reading data from file: {$this->filename}\n";
        return "file content from {$this->filename}";
    }

    public function writeData(string $data): void
    {
        echo "Writing data to file: {$this->filename}\n";
    }
}

// Base decorator
abstract class DataSourceDecorator implements DataSource
{
    public function __construct(protected DataSource $wrapped) {}

    public function readData(): string
    {
        return $this->wrapped->readData();
    }

    public function writeData(string $data): void
    {
        $this->wrapped->writeData($data);
    }
}

// Concrete decorators
class EncryptionDecorator extends DataSourceDecorator
{
    public function readData(): string
    {
        $data = parent::readData();
        return $this->decrypt($data);
    }

    public function writeData(string $data): void
    {
        $encrypted = $this->encrypt($data);
        parent::writeData($encrypted);
    }

    private function encrypt(string $data): string
    {
        echo "Encrypting data...\n";
        return "encrypted($data)";
    }

    private function decrypt(string $data): string
    {
        echo "Decrypting data...\n";
        return str_replace(['encrypted(', ')'], '', $data);
    }
}

class CompressionDecorator extends DataSourceDecorator
{
    public function readData(): string
    {
        $data = parent::readData();
        return $this->decompress($data);
    }

    public function writeData(string $data): void
    {
        $compressed = $this->compress($data);
        parent::writeData($compressed);
    }

    private function compress(string $data): string
    {
        echo "Compressing data...\n";
        return "compressed($data)";
    }

    private function decompress(string $data): string
    {
        echo "Decompressing data...\n";
        return str_replace(['compressed(', ')'], '', $data);
    }
}

// Usage
$source = new FileDataSource('data.txt');
$source = new EncryptionDecorator($source);
$source = new CompressionDecorator($source);
$source->writeData('Sensitive data');
$data = $source->readData();
```

---

## Kotlin

### Delegation Decorator (Idiomatic)
```kotlin
// Component interface
interface DataSource {
    fun readData(): String
    fun writeData(data: String)
}

// Concrete component
class FileDataSource(private val filename: String) : DataSource {
    override fun readData(): String {
        println("Reading data from file: $filename")
        return "file content from $filename"
    }

    override fun writeData(data: String) {
        println("Writing data to file: $filename")
    }
}

// Concrete decorators using delegation
class EncryptionDecorator(private val wrapped: DataSource) : DataSource by wrapped {
    override fun readData(): String {
        val data = wrapped.readData()
        return decrypt(data)
    }

    override fun writeData(data: String) {
        val encrypted = encrypt(data)
        wrapped.writeData(encrypted)
    }

    private fun encrypt(data: String): String {
        println("Encrypting data...")
        return "encrypted($data)"
    }

    private fun decrypt(data: String): String {
        println("Decrypting data...")
        return data.replace("encrypted(", "").replace(")", "")
    }
}

class CompressionDecorator(private val wrapped: DataSource) : DataSource by wrapped {
    override fun readData(): String {
        val data = wrapped.readData()
        return decompress(data)
    }

    override fun writeData(data: String) {
        val compressed = compress(data)
        wrapped.writeData(compressed)
    }

    private fun compress(data: String): String {
        println("Compressing data...")
        return "compressed($data)"
    }

    private fun decompress(data: String): String {
        println("Decompressing data...")
        return data.replace("compressed(", "").replace(")", "")
    }
}

// Usage
var source: DataSource = FileDataSource("data.txt")
source = EncryptionDecorator(source)
source = CompressionDecorator(source)
source.writeData("Sensitive data")
val data = source.readData()
```

---

## Swift

### Protocol Decorator
```swift
// Component protocol
protocol DataSource {
    func readData() -> String
    func writeData(data: String)
}

// Concrete component
class FileDataSource: DataSource {
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    func readData() -> String {
        print("Reading data from file: \(filename)")
        return "file content from \(filename)"
    }
    
    func writeData(data: String) {
        print("Writing data to file: \(filename)")
    }
}

// Base decorator
class DataSourceDecorator: DataSource {
    let wrapped: DataSource
    
    init(wrapped: DataSource) {
        self.wrapped = wrapped
    }
    
    func readData() -> String {
        return wrapped.readData()
    }
    
    func writeData(data: String) {
        wrapped.writeData(data: data)
    }
}

// Concrete decorators
class EncryptionDecorator: DataSourceDecorator {
    override func readData() -> String {
        let data = super.readData()
        return decrypt(data)
    }
    
    override func writeData(data: String) {
        let encrypted = encrypt(data)
        super.writeData(data: encrypted)
    }
    
    private func encrypt(_ data: String) -> String {
        print("Encrypting data...")
        return "encrypted(\(data))"
    }
    
    private func decrypt(_ data: String) -> String {
        print("Decrypting data...")
        return data.replacingOccurrences(of: "encrypted(", with: "")
                   .replacingOccurrences(of: ")", with: "")
    }
}

class CompressionDecorator: DataSourceDecorator {
    override func readData() -> String {
        let data = super.readData()
        return decompress(data)
    }
    
    override func writeData(data: String) {
        let compressed = compress(data)
        super.writeData(data: compressed)
    }
    
    private func compress(_ data: String) -> String {
        print("Compressing data...")
        return "compressed(\(data))"
    }
    
    private func decompress(_ data: String) -> String {
        print("Decompressing data...")
        return data.replacingOccurrences(of: "compressed(", with: "")
                   .replacingOccurrences(of: ")", with: "")
    }
}

// Usage
var source: DataSource = FileDataSource(filename: "data.txt")
source = EncryptionDecorator(wrapped: source)
source = CompressionDecorator(wrapped: source)
source.writeData(data: "Sensitive data")
let data = source.readData()
```

---

## Dart

### Class Decorator
```dart
// Component interface
abstract class DataSource {
  String readData();
  void writeData(String data);
}

// Concrete component
class FileDataSource implements DataSource {
  final String filename;

  FileDataSource(this.filename);

  @override
  String readData() {
    print('Reading data from file: $filename');
    return 'file content from $filename';
  }

  @override
  void writeData(String data) {
    print('Writing data to file: $filename');
  }
}

// Base decorator
abstract class DataSourceDecorator implements DataSource {
  final DataSource wrapped;

  DataSourceDecorator(this.wrapped);

  @override
  String readData() {
    return wrapped.readData();
  }

  @override
  void writeData(String data) {
    wrapped.writeData(data);
  }
}

// Concrete decorators
class EncryptionDecorator extends DataSourceDecorator {
  EncryptionDecorator(DataSource wrapped) : super(wrapped);

  @override
  String readData() {
    final data = super.readData();
    return _decrypt(data);
  }

  @override
  void writeData(String data) {
    final encrypted = _encrypt(data);
    super.writeData(encrypted);
  }

  String _encrypt(String data) {
    print('Encrypting data...');
    return 'encrypted($data)';
  }

  String _decrypt(String data) {
    print('Decrypting data...');
    return data.replaceAll('encrypted(', '').replaceAll(')', '');
  }
}

class CompressionDecorator extends DataSourceDecorator {
  CompressionDecorator(DataSource wrapped) : super(wrapped);

  @override
  String readData() {
    final data = super.readData();
    return _decompress(data);
  }

  @override
  void writeData(String data) {
    final compressed = _compress(data);
    super.writeData(compressed);
  }

  String _compress(String data) {
    print('Compressing data...');
    return 'compressed($data)';
  }

  String _decompress(String data) {
    print('Decompressing data...');
    return data.replaceAll('compressed(', '').replaceAll(')', '');
  }
}

// Usage
DataSource source = FileDataSource('data.txt');
source = EncryptionDecorator(source);
source = CompressionDecorator(source);
source.writeData('Sensitive data');
final data = source.readData();
```
