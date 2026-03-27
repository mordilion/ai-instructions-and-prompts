---
title: Singleton Pattern
category: Creational Design Pattern
difficulty: beginner
purpose: Ensure a class has only one instance and provide a global point of access to it
when_to_use:
  - Database connection pools
  - Configuration managers
  - Logger instances
  - Cache managers
  - Thread pools
  - Registry objects
languages:
  typescript:
    - name: Class-based Singleton (Built-in)
      library: javascript-core
      recommended: true
    - name: Module Singleton (Built-in)
      library: javascript-core
  python:
    - name: Class with __new__ (Built-in)
      library: python-core
      recommended: true
    - name: Module-level Singleton (Built-in)
      library: python-core
    - name: Metaclass Singleton (Built-in)
      library: python-core
  java:
    - name: Eager Initialization (Built-in)
      library: java-core
      recommended: true
    - name: Lazy Initialization (Built-in)
      library: java-core
    - name: Thread-Safe Lazy (Built-in)
      library: java-core
    - name: Enum Singleton (Built-in)
      library: java-core
  csharp:
    - name: Lazy<T> (Built-in)
      library: dotnet-core
      recommended: true
    - name: Static Constructor (Built-in)
      library: dotnet-core
    - name: Thread-Safe Lazy (Built-in)
      library: dotnet-core
  php:
    - name: Private Constructor (Built-in)
      library: php-core
      recommended: true
    - name: Laravel Container Singleton
      library: laravel/framework
  kotlin:
    - name: Object Declaration (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Companion Object (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Static Property (Built-in)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Factory Constructor (Built-in)
      library: dart-core
      recommended: true
    - name: GetIt Service Locator
      library: get_it
common_patterns:
  - Thread-safe initialization
  - Lazy vs eager instantiation
  - Preventing cloning and serialization
  - Dependency injection as alternative
best_practices:
  do:
    - Use dependency injection instead when possible
    - Make singleton immutable after initialization
    - Consider thread safety in multi-threaded environments
    - Use built-in language features (object in Kotlin, Lazy<T> in C#)
    - Test by injecting dependencies instead of using singleton directly
  dont:
    - Overuse singletons - they create hidden dependencies
    - Store mutable state in singletons
    - Use singletons for data that should be scoped (per-request, per-user)
    - Make singleton constructor public
    - Use singletons for unit-testable code without abstraction
related_functions:
  - config-secrets.md
  - logging.md
  - database-query.md
tags: [singleton, creational-pattern, global-state, thread-safety]
updated: 2026-01-20
---

## TypeScript

### Class-based Singleton
```typescript
class DatabaseConnection {
  private static instance: DatabaseConnection;
  private connection: any;

  private constructor() {
    this.connection = this.initializeConnection();
  }

  public static getInstance(): DatabaseConnection {
    if (!DatabaseConnection.instance) {
      DatabaseConnection.instance = new DatabaseConnection();
    }
    return DatabaseConnection.instance;
  }

  private initializeConnection() {
    return { /* connection details */ };
  }

  public query(sql: string) {
    return this.connection.execute(sql);
  }
}

// Usage
const db = DatabaseConnection.getInstance();
```

### Module Singleton (Recommended for TypeScript/JavaScript)
```typescript
// database.ts
class DatabaseConnection {
  private connection: any;

  constructor() {
    this.connection = this.initializeConnection();
  }

  private initializeConnection() {
    return { /* connection details */ };
  }

  public query(sql: string) {
    return this.connection.execute(sql);
  }
}

// Export single instance
export const database = new DatabaseConnection();

// Usage in other files
import { database } from './database';
database.query('SELECT * FROM users');
```

---

## Python

### Class with __new__
```python
class DatabaseConnection:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.connection = self._create_connection()

    def _create_connection(self):
        return None  # connection details

    def query(self, sql: str):
        return self.connection.execute(sql)

# Usage
db1 = DatabaseConnection()
db2 = DatabaseConnection()
assert db1 is db2  # Same instance
```

### Module-level Singleton (Recommended for Python)
```python
# database.py
class _DatabaseConnection:
    def __init__(self):
        self.connection = self._create_connection()

    def _create_connection(self):
        return None  # connection details

    def query(self, sql: str):
        return self.connection.execute(sql)

# Create single instance
database = _DatabaseConnection()

# Usage in other modules
from database import database
database.query("SELECT * FROM users")
```

### Metaclass Singleton
```python
class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class DatabaseConnection(metaclass=SingletonMeta):
    def __init__(self):
        self.connection = self._create_connection()

    def _create_connection(self):
        return None

    def query(self, sql: str):
        return self.connection.execute(sql)
```

---

## Java

### Eager Initialization
```java
public class DatabaseConnection {
    private static final DatabaseConnection INSTANCE = new DatabaseConnection();
    private Connection connection;

    private DatabaseConnection() {
        this.connection = initializeConnection();
    }

    public static DatabaseConnection getInstance() {
        return INSTANCE;
    }

    private Connection initializeConnection() {
        // connection details
        return null;
    }

    public ResultSet query(String sql) throws SQLException {
        return connection.createStatement().executeQuery(sql);
    }
}

// Usage
DatabaseConnection db = DatabaseConnection.getInstance();
```

### Lazy Initialization (Not thread-safe)
```java
public class DatabaseConnection {
    private static DatabaseConnection instance;
    private Connection connection;

    private DatabaseConnection() {
        this.connection = initializeConnection();
    }

    public static DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    private Connection initializeConnection() {
        return null;
    }
}
```

### Thread-Safe Lazy (Double-checked locking)
```java
public class DatabaseConnection {
    private static volatile DatabaseConnection instance;
    private Connection connection;

    private DatabaseConnection() {
        this.connection = initializeConnection();
    }

    public static DatabaseConnection getInstance() {
        if (instance == null) {
            synchronized (DatabaseConnection.class) {
                if (instance == null) {
                    instance = new DatabaseConnection();
                }
            }
        }
        return instance;
    }

    private Connection initializeConnection() {
        return null;
    }
}
```

### Enum Singleton (Recommended for Java)
```java
public enum DatabaseConnection {
    INSTANCE;

    private final Connection connection;

    DatabaseConnection() {
        this.connection = initializeConnection();
    }

    private Connection initializeConnection() {
        // connection details
        return null;
    }

    public ResultSet query(String sql) throws SQLException {
        return connection.createStatement().executeQuery(sql);
    }
}

// Usage
DatabaseConnection.INSTANCE.query("SELECT * FROM users");
```

---

## C#

### Lazy<T> (Recommended)
```csharp
public sealed class DatabaseConnection
{
    private static readonly Lazy<DatabaseConnection> _instance = 
        new Lazy<DatabaseConnection>(() => new DatabaseConnection());

    private readonly DbConnection _connection;

    private DatabaseConnection()
    {
        _connection = InitializeConnection();
    }

    public static DatabaseConnection Instance => _instance.Value;

    private DbConnection InitializeConnection()
    {
        // connection details
        return null;
    }

    public async Task<DbDataReader> QueryAsync(string sql)
    {
        var command = _connection.CreateCommand();
        command.CommandText = sql;
        return await command.ExecuteReaderAsync();
    }
}

// Usage
var db = DatabaseConnection.Instance;
```

### Static Constructor
```csharp
public sealed class DatabaseConnection
{
    private static readonly DatabaseConnection _instance = new DatabaseConnection();
    private readonly DbConnection _connection;

    static DatabaseConnection() { }

    private DatabaseConnection()
    {
        _connection = InitializeConnection();
    }

    public static DatabaseConnection Instance => _instance;

    private DbConnection InitializeConnection()
    {
        return null;
    }
}
```

### Thread-Safe Lazy (Manual)
```csharp
public sealed class DatabaseConnection
{
    private static DatabaseConnection _instance;
    private static readonly object _lock = new object();
    private readonly DbConnection _connection;

    private DatabaseConnection()
    {
        _connection = InitializeConnection();
    }

    public static DatabaseConnection Instance
    {
        get
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = new DatabaseConnection();
                    }
                }
            }
            return _instance;
        }
    }

    private DbConnection InitializeConnection()
    {
        return null;
    }
}
```

---

## PHP

### Private Constructor
```php
class DatabaseConnection
{
    private static ?self $instance = null;
    private $connection;

    private function __construct()
    {
        $this->connection = $this->initializeConnection();
    }

    private function __clone() {}

    public function __wakeup()
    {
        throw new \Exception("Cannot unserialize singleton");
    }

    public static function getInstance(): self
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function initializeConnection()
    {
        return null; // connection details
    }

    public function query(string $sql): array
    {
        return $this->connection->query($sql)->fetchAll();
    }
}

// Usage
$db = DatabaseConnection::getInstance();
```

### Laravel Container Singleton
```php
// In a service provider
public function register()
{
    $this->app->singleton(DatabaseConnection::class, function ($app) {
        return new DatabaseConnection(
            config('database.connection')
        );
    });
}

// Usage
$db = app(DatabaseConnection::class);
// or
$db = resolve(DatabaseConnection::class);
```

---

## Kotlin

### Object Declaration (Recommended)
```kotlin
object DatabaseConnection {
    private val connection: Connection = initializeConnection()

    private fun initializeConnection(): Connection {
        // connection details
        return TODO()
    }

    fun query(sql: String): ResultSet {
        return connection.createStatement().executeQuery(sql)
    }
}

// Usage
val result = DatabaseConnection.query("SELECT * FROM users")
```

### Companion Object
```kotlin
class DatabaseConnection private constructor() {
    private val connection: Connection = initializeConnection()

    companion object {
        @Volatile
        private var instance: DatabaseConnection? = null

        fun getInstance(): DatabaseConnection {
            return instance ?: synchronized(this) {
                instance ?: DatabaseConnection().also { instance = it }
            }
        }
    }

    private fun initializeConnection(): Connection {
        return TODO()
    }

    fun query(sql: String): ResultSet {
        return connection.createStatement().executeQuery(sql)
    }
}

// Usage
val db = DatabaseConnection.getInstance()
```

---

## Swift

### Static Property (Recommended)
```swift
final class DatabaseConnection {
    static let shared = DatabaseConnection()
    
    private let connection: Connection
    
    private init() {
        self.connection = initializeConnection()
    }
    
    private func initializeConnection() -> Connection {
        // connection details
        return Connection()
    }
    
    func query(_ sql: String) -> ResultSet {
        return connection.execute(sql)
    }
}

// Usage
let db = DatabaseConnection.shared
db.query("SELECT * FROM users")
```

### Thread-Safe Lazy (dispatch_once alternative)
```swift
final class DatabaseConnection {
    private static var _shared: DatabaseConnection?
    private static let lock = NSLock()
    
    static var shared: DatabaseConnection {
        if _shared == nil {
            lock.lock()
            defer { lock.unlock() }
            if _shared == nil {
                _shared = DatabaseConnection()
            }
        }
        return _shared!
    }
    
    private let connection: Connection
    
    private init() {
        self.connection = initializeConnection()
    }
    
    private func initializeConnection() -> Connection {
        return Connection()
    }
}
```

---

## Dart

### Factory Constructor (Recommended)
```dart
class DatabaseConnection {
  static DatabaseConnection? _instance;
  final Connection _connection;

  DatabaseConnection._internal() : _connection = _initializeConnection();

  factory DatabaseConnection() {
    _instance ??= DatabaseConnection._internal();
    return _instance!;
  }

  static Connection _initializeConnection() {
    // connection details
    return Connection();
  }

  Future<ResultSet> query(String sql) async {
    return await _connection.execute(sql);
  }
}

// Usage
final db1 = DatabaseConnection();
final db2 = DatabaseConnection();
assert(identical(db1, db2)); // Same instance
```

### GetIt Service Locator (Dependency Injection Alternative)
```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupSingletons() {
  getIt.registerSingleton<DatabaseConnection>(DatabaseConnection());
}

class DatabaseConnection {
  final Connection _connection;

  DatabaseConnection() : _connection = _initializeConnection();

  static Connection _initializeConnection() {
    return Connection();
  }

  Future<ResultSet> query(String sql) async {
    return await _connection.execute(sql);
  }
}

// Usage
void main() {
  setupSingletons();
  final db = getIt<DatabaseConnection>();
}
```
