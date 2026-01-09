# Error Handling Patterns

> **Purpose**: Consistent error handling across all languages
>
> **When to use**: API errors, validation failures, external service failures, unexpected conditions

---

## TypeScript / JavaScript

### Basic Try-Catch
```typescript
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  if (error instanceof ValidationError) {
    throw new BadRequestError(error.message);
  }
  if (error instanceof DatabaseError) {
    throw new ServiceUnavailableError('Database connection failed');
  }
  throw error; // Re-throw unknown errors
}
```

### Custom Error Classes
```typescript
class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public isOperational = true
  ) {
    super(message);
    Error.captureStackTrace(this, this.constructor);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, `${resource} not found`);
  }
}
```

### Error Boundary (React)
```typescript
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logger.error('React Error:', { error, errorInfo });
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

---

## Python

### Basic Try-Except
```python
try:
    result = risky_operation()
    return result
except ValidationError as e:
    raise BadRequestError(str(e))
except DatabaseError as e:
    raise ServiceUnavailableError("Database connection failed")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise
```

### Custom Exceptions
```python
class AppError(Exception):
    """Base exception for application errors"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class NotFoundError(AppError):
    def __init__(self, resource: str):
        super().__init__(f"{resource} not found", status_code=404)
```

### Context Manager
```python
from contextlib import contextmanager

@contextmanager
def handle_db_errors():
    try:
        yield
    except IntegrityError:
        raise ValidationError("Duplicate entry")
    except OperationalError:
        raise ServiceUnavailableError("Database unavailable")

# Usage
with handle_db_errors():
    db.session.add(user)
    db.session.commit()
```

---

## Java

### Basic Try-Catch
```java
try {
    Result result = riskyOperation();
    return result;
} catch (ValidationException e) {
    throw new BadRequestException(e.getMessage());
} catch (SQLException e) {
    throw new ServiceUnavailableException("Database connection failed");
} catch (Exception e) {
    logger.error("Unexpected error", e);
    throw new InternalServerErrorException(e);
}
```

### Custom Exceptions
```java
public class AppException extends RuntimeException {
    private final int statusCode;
    private final boolean isOperational;

    public AppException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = true;
    }

    public int getStatusCode() {
        return statusCode;
    }
}

public class NotFoundException extends AppException {
    public NotFoundException(String resource) {
        super(resource + " not found", 404);
    }
}
```

### Try-with-Resources
```java
try (Connection conn = dataSource.getConnection();
     PreparedStatement stmt = conn.prepareStatement(sql)) {
    
    ResultSet rs = stmt.executeQuery();
    return processResults(rs);
    
} catch (SQLException e) {
    logger.error("Database error", e);
    throw new DatabaseException("Query failed", e);
}
```

---

## C# (.NET)

### Basic Try-Catch
```csharp
try
{
    var result = await RiskyOperationAsync();
    return result;
}
catch (ValidationException ex)
{
    throw new BadRequestException(ex.Message);
}
catch (DbException ex)
{
    throw new ServiceUnavailableException("Database connection failed");
}
catch (Exception ex)
{
    _logger.LogError(ex, "Unexpected error");
    throw;
}
```

### Custom Exceptions
```csharp
public class AppException : Exception
{
    public int StatusCode { get; }
    public bool IsOperational { get; }

    public AppException(string message, int statusCode = 500, bool isOperational = true)
        : base(message)
    {
        StatusCode = statusCode;
        IsOperational = isOperational;
    }
}

public class NotFoundException : AppException
{
    public NotFoundException(string resource)
        : base($"{resource} not found", 404)
    {
    }
}
```

### Using Statement
```csharp
using (var connection = new SqlConnection(connectionString))
using (var command = new SqlCommand(sql, connection))
{
    try
    {
        await connection.OpenAsync();
        var result = await command.ExecuteReaderAsync();
        return ProcessResults(result);
    }
    catch (SqlException ex)
    {
        _logger.LogError(ex, "Database error");
        throw new DatabaseException("Query failed", ex);
    }
}
```

---

## PHP

### Basic Try-Catch
```php
try {
    $result = riskyOperation();
    return $result;
} catch (ValidationException $e) {
    throw new BadRequestException($e->getMessage());
} catch (PDOException $e) {
    throw new ServiceUnavailableException('Database connection failed');
} catch (Exception $e) {
    $logger->error('Unexpected error: ' . $e->getMessage());
    throw $e;
}
```

### Custom Exceptions
```php
class AppException extends Exception
{
    protected int $statusCode;
    protected bool $isOperational;

    public function __construct(
        string $message,
        int $statusCode = 500,
        bool $isOperational = true
    ) {
        parent::__construct($message);
        $this->statusCode = $statusCode;
        $this->isOperational = $isOperational;
    }

    public function getStatusCode(): int
    {
        return $this->statusCode;
    }
}

class NotFoundException extends AppException
{
    public function __construct(string $resource)
    {
        parent::__construct("$resource not found", 404);
    }
}
```

---

## Kotlin

### Basic Try-Catch
```kotlin
try {
    val result = riskyOperation()
    return result
} catch (e: ValidationException) {
    throw BadRequestException(e.message)
} catch (e: SQLException) {
    throw ServiceUnavailableException("Database connection failed")
} catch (e: Exception) {
    logger.error("Unexpected error", e)
    throw InternalServerErrorException(e)
}
```

### Sealed Class for Results
```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable) : Result<Nothing>()
}

fun fetchUser(id: String): Result<User> {
    return try {
        val user = database.getUser(id)
        Result.Success(user)
    } catch (e: Exception) {
        Result.Error(e)
    }
}

// Usage
when (val result = fetchUser("123")) {
    is Result.Success -> println(result.data)
    is Result.Error -> handleError(result.exception)
}
```

### Custom Exceptions
```kotlin
open class AppException(
    message: String,
    val statusCode: Int = 500,
    val isOperational: Boolean = true
) : RuntimeException(message)

class NotFoundException(resource: String) : AppException(
    message = "$resource not found",
    statusCode = 404
)
```

---

## Swift

### Basic Do-Catch
```swift
do {
    let result = try riskyOperation()
    return result
} catch let error as ValidationError {
    throw BadRequestError(error.localizedDescription)
} catch let error as DatabaseError {
    throw ServiceUnavailableError("Database connection failed")
} catch {
    logger.error("Unexpected error: \(error)")
    throw error
}
```

### Custom Errors (Enum)
```swift
enum AppError: Error {
    case notFound(resource: String)
    case validation(message: String)
    case serviceUnavailable(message: String)
    case unauthorized
    
    var statusCode: Int {
        switch self {
        case .notFound: return 404
        case .validation: return 400
        case .serviceUnavailable: return 503
        case .unauthorized: return 401
        }
    }
}

// Usage
throw AppError.notFound(resource: "User")
```

### Result Type
```swift
func fetchUser(id: String) -> Result<User, Error> {
    do {
        let user = try database.getUser(id)
        return .success(user)
    } catch {
        return .failure(error)
    }
}

// Usage
switch fetchUser(id: "123") {
case .success(let user):
    print(user)
case .failure(let error):
    handleError(error)
}
```

---

## Dart (Flutter)

### Basic Try-Catch
```dart
try {
  final result = await riskyOperation();
  return result;
} on ValidationException catch (e) {
  throw BadRequestException(e.message);
} on DatabaseException catch (e) {
  throw ServiceUnavailableException('Database connection failed');
} catch (e, stackTrace) {
  logger.error('Unexpected error: $e\n$stackTrace');
  rethrow;
}
```

### Custom Exceptions
```dart
class AppException implements Exception {
  final String message;
  final int statusCode;
  final bool isOperational;

  AppException(
    this.message, {
    this.statusCode = 500,
    this.isOperational = true,
  });

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

class NotFoundException extends AppException {
  NotFoundException(String resource)
      : super('$resource not found', statusCode: 404);
}
```

### Either Type (with dartz package)
```dart
import 'package:dartz/dartz.dart';

Future<Either<Failure, User>> fetchUser(String id) async {
  try {
    final user = await database.getUser(id);
    return Right(user);
  } on NotFoundException catch (e) {
    return Left(NotFoundFailure(e.message));
  } catch (e) {
    return Left(ServerFailure());
  }
}

// Usage
final result = await fetchUser('123');
result.fold(
  (failure) => handleError(failure),
  (user) => displayUser(user),
);
```

---

## Common Pitfalls

❌ **DON'T**:
- Catch exceptions without logging
- Return generic "Error occurred" messages
- Swallow errors silently
- Use exceptions for flow control
- Expose stack traces to users

✅ **DO**:
- Log errors with context
- Provide specific error messages
- Rethrow if you can't handle
- Use custom error types
- Sanitize errors for users

---

## Best Practices

1. **Always log errors** with sufficient context (user ID, request ID, timestamp)
2. **Use typed errors** (custom classes/enums) for different scenarios
3. **Fail fast** - validate early, throw immediately
4. **Wrap third-party errors** in your own error types
5. **Never expose sensitive data** in error messages (passwords, tokens, internal paths)
6. **Provide actionable messages** - tell users what to do next
7. **Monitor error rates** - set up alerts for spikes
8. **Test error paths** - don't just test happy paths

---

## Quick Decision Tree

```
Error occurs
    ↓
Can you recover? ──YES──→ Handle and continue
    ↓ NO
Is it expected? ──YES──→ Throw custom error with context
    ↓ NO
Is it operational? ──YES──→ Log + throw with retry info
    ↓ NO
Programming bug ────────→ Log + throw + alert developers
```
