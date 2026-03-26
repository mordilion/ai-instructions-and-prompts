---
title: Proxy Pattern
category: Structural Design Pattern
difficulty: intermediate
purpose: Provide a surrogate or placeholder to control access to an object
when_to_use:
  - Lazy initialization (Virtual Proxy)
  - Access control (Protection Proxy)
  - Remote service calls (Remote Proxy)
  - Caching results (Caching Proxy)
  - Logging and monitoring (Logging Proxy)
  - Resource-intensive object creation
languages:
  typescript:
    - name: Class Proxy (Built-in)
      library: javascript-core
      recommended: true
    - name: ES6 Proxy (Built-in)
      library: javascript-core
  python:
    - name: Class Proxy (Built-in)
      library: python-core
      recommended: true
    - name: __getattr__ Proxy (Built-in)
      library: python-core
  java:
    - name: Class Proxy (Built-in)
      library: java-core
      recommended: true
    - name: Dynamic Proxy (Built-in)
      library: java-core
  csharp:
    - name: Class Proxy (Built-in)
      library: dotnet-core
      recommended: true
    - name: DispatchProxy (Built-in)
      library: dotnet-core
  php:
    - name: Class Proxy (Built-in)
      library: php-core
      recommended: true
    - name: __call Magic Method (Built-in)
      library: php-core
  kotlin:
    - name: Class Proxy (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Delegation Proxy (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Class Proxy (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Class Proxy (Built-in)
      library: dart-core
      recommended: true
common_patterns:
  - Virtual proxy (lazy loading)
  - Protection proxy (access control)
  - Remote proxy (network calls)
  - Caching proxy (performance)
  - Smart proxy (additional functionality)
best_practices:
  do:
    - Use proxy for cross-cutting concerns
    - Implement same interface as real subject
    - Handle proxy creation transparently
    - Use for lazy initialization of expensive objects
    - Consider using for access logging and monitoring
  dont:
    - Add business logic to proxy
    - Create complex proxy chains
    - Use proxy when direct access is simpler
    - Forget to handle proxy-specific errors
related_functions:
  - caching.md
  - logging.md
  - auth-authorization.md
tags: [proxy, structural-pattern, lazy-loading, access-control, caching]
updated: 2026-01-20
---

## TypeScript

### Virtual Proxy (Lazy Loading)
```typescript
// Subject interface
interface Image {
  display(): void;
}

// Real subject (expensive to create)
class RealImage implements Image {
  private filename: string;

  constructor(filename: string) {
    this.filename = filename;
    this.loadFromDisk();
  }

  private loadFromDisk(): void {
    console.log(`Loading image from disk: ${this.filename}`);
    // Expensive operation simulated
  }

  display(): void {
    console.log(`Displaying image: ${this.filename}`);
  }
}

// Proxy (lazy initialization)
class ImageProxy implements Image {
  private filename: string;
  private realImage: RealImage | null = null;

  constructor(filename: string) {
    this.filename = filename;
  }

  display(): void {
    if (this.realImage === null) {
      this.realImage = new RealImage(this.filename);
    }
    this.realImage.display();
  }
}

// Usage
const image1: Image = new ImageProxy('photo1.jpg');
const image2: Image = new ImageProxy('photo2.jpg');

console.log('Images created, but not loaded yet');
image1.display(); // Loads and displays
image1.display(); // Only displays (already loaded)
```

### Protection Proxy (Access Control)
```typescript
interface Document {
  read(): string;
  write(content: string): void;
}

class SecureDocument implements Document {
  private content: string = 'Secret document content';

  read(): string {
    return this.content;
  }

  write(content: string): void {
    this.content = content;
  }
}

class DocumentProxy implements Document {
  private document: SecureDocument;
  private userRole: string;

  constructor(userRole: string) {
    this.document = new SecureDocument();
    this.userRole = userRole;
  }

  read(): string {
    console.log(`User with role '${this.userRole}' is reading document`);
    return this.document.read();
  }

  write(content: string): void {
    if (this.userRole === 'admin' || this.userRole === 'editor') {
      console.log(`User with role '${this.userRole}' is writing document`);
      this.document.write(content);
    } else {
      throw new Error('Access denied: Insufficient permissions');
    }
  }
}

// Usage
const adminDoc: Document = new DocumentProxy('admin');
adminDoc.write('Updated content');

const viewerDoc: Document = new DocumentProxy('viewer');
try {
  viewerDoc.write('Unauthorized update');
} catch (error) {
  console.error(error.message);
}
```

### Caching Proxy
```typescript
interface DataService {
  getData(key: string): Promise<string>;
}

class RemoteDataService implements DataService {
  async getData(key: string): Promise<string> {
    console.log(`Fetching data from remote server for key: ${key}`);
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    return `Data for ${key}`;
  }
}

class CachingProxy implements DataService {
  private service: RemoteDataService;
  private cache: Map<string, string> = new Map();

  constructor() {
    this.service = new RemoteDataService();
  }

  async getData(key: string): Promise<string> {
    if (this.cache.has(key)) {
      console.log(`Cache hit for key: ${key}`);
      return this.cache.get(key)!;
    }

    console.log(`Cache miss for key: ${key}`);
    const data = await this.service.getData(key);
    this.cache.set(key, data);
    return data;
  }
}

// Usage
const service: DataService = new CachingProxy();
await service.getData('user:123'); // Cache miss, fetches from remote
await service.getData('user:123'); // Cache hit, instant return
```

---

## Python

### Virtual Proxy (Lazy Loading)
```python
from abc import ABC, abstractmethod

# Subject interface
class Image(ABC):
    @abstractmethod
    def display(self) -> None:
        pass

# Real subject
class RealImage(Image):
    def __init__(self, filename: str):
        self._filename = filename
        self._load_from_disk()

    def _load_from_disk(self) -> None:
        print(f"Loading image from disk: {self._filename}")

    def display(self) -> None:
        print(f"Displaying image: {self._filename}")

# Proxy
class ImageProxy(Image):
    def __init__(self, filename: str):
        self._filename = filename
        self._real_image: RealImage | None = None

    def display(self) -> None:
        if self._real_image is None:
            self._real_image = RealImage(self._filename)
        self._real_image.display()

# Usage
image1: Image = ImageProxy("photo1.jpg")
image2: Image = ImageProxy("photo2.jpg")

print("Images created, but not loaded yet")
image1.display()  # Loads and displays
image1.display()  # Only displays
```

### Protection Proxy
```python
class Document(ABC):
    @abstractmethod
    def read(self) -> str:
        pass

    @abstractmethod
    def write(self, content: str) -> None:
        pass

class SecureDocument(Document):
    def __init__(self):
        self._content = "Secret document content"

    def read(self) -> str:
        return self._content

    def write(self, content: str) -> None:
        self._content = content

class DocumentProxy(Document):
    def __init__(self, user_role: str):
        self._document = SecureDocument()
        self._user_role = user_role

    def read(self) -> str:
        print(f"User with role '{self._user_role}' is reading document")
        return self._document.read()

    def write(self, content: str) -> None:
        if self._user_role in ['admin', 'editor']:
            print(f"User with role '{self._user_role}' is writing document")
            self._document.write(content)
        else:
            raise PermissionError("Access denied: Insufficient permissions")

# Usage
admin_doc: Document = DocumentProxy("admin")
admin_doc.write("Updated content")

viewer_doc: Document = DocumentProxy("viewer")
try:
    viewer_doc.write("Unauthorized update")
except PermissionError as e:
    print(e)
```

---

## Java

### Virtual Proxy
```java
// Subject interface
interface Image {
    void display();
}

// Real subject
class RealImage implements Image {
    private final String filename;

    public RealImage(String filename) {
        this.filename = filename;
        loadFromDisk();
    }

    private void loadFromDisk() {
        System.out.println("Loading image from disk: " + filename);
    }

    @Override
    public void display() {
        System.out.println("Displaying image: " + filename);
    }
}

// Proxy
class ImageProxy implements Image {
    private final String filename;
    private RealImage realImage;

    public ImageProxy(String filename) {
        this.filename = filename;
    }

    @Override
    public void display() {
        if (realImage == null) {
            realImage = new RealImage(filename);
        }
        realImage.display();
    }
}

// Usage
Image image1 = new ImageProxy("photo1.jpg");
Image image2 = new ImageProxy("photo2.jpg");

System.out.println("Images created, but not loaded yet");
image1.display(); // Loads and displays
image1.display(); // Only displays
```

### Protection Proxy
```java
interface Document {
    String read();
    void write(String content);
}

class SecureDocument implements Document {
    private String content = "Secret document content";

    @Override
    public String read() {
        return content;
    }

    @Override
    public void write(String content) {
        this.content = content;
    }
}

class DocumentProxy implements Document {
    private final SecureDocument document;
    private final String userRole;

    public DocumentProxy(String userRole) {
        this.document = new SecureDocument();
        this.userRole = userRole;
    }

    @Override
    public String read() {
        System.out.println("User with role '" + userRole + "' is reading document");
        return document.read();
    }

    @Override
    public void write(String content) {
        if (userRole.equals("admin") || userRole.equals("editor")) {
            System.out.println("User with role '" + userRole + "' is writing document");
            document.write(content);
        } else {
            throw new SecurityException("Access denied: Insufficient permissions");
        }
    }
}

// Usage
Document adminDoc = new DocumentProxy("admin");
adminDoc.write("Updated content");

Document viewerDoc = new DocumentProxy("viewer");
try {
    viewerDoc.write("Unauthorized update");
} catch (SecurityException e) {
    System.err.println(e.getMessage());
}
```

---

## C#

### Virtual Proxy
```csharp
// Subject interface
public interface IImage
{
    void Display();
}

// Real subject
public class RealImage : IImage
{
    private readonly string _filename;

    public RealImage(string filename)
    {
        _filename = filename;
        LoadFromDisk();
    }

    private void LoadFromDisk()
    {
        Console.WriteLine($"Loading image from disk: {_filename}");
    }

    public void Display()
    {
        Console.WriteLine($"Displaying image: {_filename}");
    }
}

// Proxy
public class ImageProxy : IImage
{
    private readonly string _filename;
    private RealImage? _realImage;

    public ImageProxy(string filename)
    {
        _filename = filename;
    }

    public void Display()
    {
        _realImage ??= new RealImage(_filename);
        _realImage.Display();
    }
}

// Usage
IImage image1 = new ImageProxy("photo1.jpg");
IImage image2 = new ImageProxy("photo2.jpg");

Console.WriteLine("Images created, but not loaded yet");
image1.Display(); // Loads and displays
image1.Display(); // Only displays
```

### Protection Proxy
```csharp
public interface IDocument
{
    string Read();
    void Write(string content);
}

public class SecureDocument : IDocument
{
    private string _content = "Secret document content";

    public string Read() => _content;

    public void Write(string content)
    {
        _content = content;
    }
}

public class DocumentProxy : IDocument
{
    private readonly SecureDocument _document;
    private readonly string _userRole;

    public DocumentProxy(string userRole)
    {
        _document = new SecureDocument();
        _userRole = userRole;
    }

    public string Read()
    {
        Console.WriteLine($"User with role '{_userRole}' is reading document");
        return _document.Read();
    }

    public void Write(string content)
    {
        if (_userRole is "admin" or "editor")
        {
            Console.WriteLine($"User with role '{_userRole}' is writing document");
            _document.Write(content);
        }
        else
        {
            throw new UnauthorizedAccessException("Access denied: Insufficient permissions");
        }
    }
}

// Usage
IDocument adminDoc = new DocumentProxy("admin");
adminDoc.Write("Updated content");

IDocument viewerDoc = new DocumentProxy("viewer");
try
{
    viewerDoc.Write("Unauthorized update");
}
catch (UnauthorizedAccessException ex)
{
    Console.Error.WriteLine(ex.Message);
}
```

---

## PHP

### Virtual Proxy
```php
// Subject interface
interface Image
{
    public function display(): void;
}

// Real subject
class RealImage implements Image
{
    public function __construct(private string $filename)
    {
        $this->loadFromDisk();
    }

    private function loadFromDisk(): void
    {
        echo "Loading image from disk: {$this->filename}\n";
    }

    public function display(): void
    {
        echo "Displaying image: {$this->filename}\n";
    }
}

// Proxy
class ImageProxy implements Image
{
    private ?RealImage $realImage = null;

    public function __construct(private string $filename) {}

    public function display(): void
    {
        if ($this->realImage === null) {
            $this->realImage = new RealImage($this->filename);
        }
        $this->realImage->display();
    }
}

// Usage
$image1 = new ImageProxy('photo1.jpg');
$image2 = new ImageProxy('photo2.jpg');

echo "Images created, but not loaded yet\n";
$image1->display(); // Loads and displays
$image1->display(); // Only displays
```

---

## Kotlin

### Virtual Proxy with Lazy Delegation
```kotlin
// Subject interface
interface Image {
    fun display()
}

// Real subject
class RealImage(private val filename: String) : Image {
    init {
        loadFromDisk()
    }

    private fun loadFromDisk() {
        println("Loading image from disk: $filename")
    }

    override fun display() {
        println("Displaying image: $filename")
    }
}

// Proxy using lazy delegation
class ImageProxy(private val filename: String) : Image {
    private val realImage: RealImage by lazy { RealImage(filename) }

    override fun display() {
        realImage.display()
    }
}

// Usage
val image1: Image = ImageProxy("photo1.jpg")
val image2: Image = ImageProxy("photo2.jpg")

println("Images created, but not loaded yet")
image1.display() // Loads and displays
image1.display() // Only displays
```

---

## Swift

### Virtual Proxy
```swift
// Subject protocol
protocol Image {
    func display()
}

// Real subject
class RealImage: Image {
    private let filename: String
    
    init(filename: String) {
        self.filename = filename
        loadFromDisk()
    }
    
    private func loadFromDisk() {
        print("Loading image from disk: \(filename)")
    }
    
    func display() {
        print("Displaying image: \(filename)")
    }
}

// Proxy
class ImageProxy: Image {
    private let filename: String
    private var realImage: RealImage?
    
    init(filename: String) {
        self.filename = filename
    }
    
    func display() {
        if realImage == nil {
            realImage = RealImage(filename: filename)
        }
        realImage?.display()
    }
}

// Usage
let image1: Image = ImageProxy(filename: "photo1.jpg")
let image2: Image = ImageProxy(filename: "photo2.jpg")

print("Images created, but not loaded yet")
image1.display() // Loads and displays
image1.display() // Only displays
```

---

## Dart

### Virtual Proxy
```dart
// Subject interface
abstract class Image {
  void display();
}

// Real subject
class RealImage implements Image {
  final String filename;

  RealImage(this.filename) {
    _loadFromDisk();
  }

  void _loadFromDisk() {
    print('Loading image from disk: $filename');
  }

  @override
  void display() {
    print('Displaying image: $filename');
  }
}

// Proxy
class ImageProxy implements Image {
  final String filename;
  RealImage? _realImage;

  ImageProxy(this.filename);

  @override
  void display() {
    _realImage ??= RealImage(filename);
    _realImage!.display();
  }
}

// Usage
final image1 = ImageProxy('photo1.jpg');
final image2 = ImageProxy('photo2.jpg');

print('Images created, but not loaded yet');
image1.display(); // Loads and displays
image1.display(); // Only displays
```
