---
title: Error Handling Patterns
category: Error Management
difficulty: intermediate
languages: [typescript, python, java, csharp, php, kotlin, swift, dart]
tags: [errors, exceptions, try-catch, result-types]
updated: 2026-01-09
---

# Error Handling Patterns

> Handle failures, validation errors, API errors, unexpected conditions

---

## TypeScript

### Native try-catch
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
  logger.error('Unexpected error', { error, context: { userId } });
  throw error;
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

// Usage
throw new NotFoundError('User');
```

### Result Type (neverthrow)
```typescript
import { Result, ok, err } from 'neverthrow';

function fetchUser(id: string): Result<User, Error> {
  try {
    const user = database.getUser(id);
    return ok(user);
  } catch (error) {
    return err(new Error('User not found'));
  }
}

result.match(
  (user) => console.log(user),
  (error) => console.error(error)
);
```

### React Error Boundary
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

### Native try-except
```python
try:
    result = risky_operation()
    return result
except ValidationError as e:
    raise BadRequestError(str(e))
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise ServiceUnavailableError("Database connection failed")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise
```

### Custom Exceptions
```python
class AppError(Exception):
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class NotFoundError(AppError):
    def __init__(self, resource: str):
        super().__init__(f"{resource} not found", status_code=404)

# Usage
raise NotFoundError("User")
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

### Native try-catch
```java
try {
    Result result = riskyOperation();
    return result;
} catch (ValidationException e) {
    throw new BadRequestException(e.getMessage());
} catch (SQLException e) {
    logger.error("Database error", e);
    throw new ServiceUnavailableException("Database connection failed");
}
```

### Custom Exceptions
```java
public class AppException extends RuntimeException {
    private final int statusCode;

    public AppException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
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

### Vavr Result Type
```java
import io.vavr.control.Try;

Try<User> result = Try.of(() -> database.getUser(userId));
result.onSuccess(user -> System.out.println(user))
      .onFailure(error -> logger.error("Error", error));
```

---

## C#

### Native try-catch
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
    _logger.LogError(ex, "Database error");
    throw new ServiceUnavailableException("Database connection failed");
}
```

### Custom Exceptions
```csharp
public class AppException : Exception
{
    public int StatusCode { get; }

    public AppException(string message, int statusCode = 500)
        : base(message)
    {
        StatusCode = statusCode;
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
    await connection.OpenAsync();
    var result = await command.ExecuteReaderAsync();
    return ProcessResults(result);
}
```

### LanguageExt Result Type
```csharp
using LanguageExt;

Either<string, User> FetchUser(string id)
{
    try
    {
        var user = _database.GetUser(id);
        return Right<string, User>(user);
    }
    catch (Exception ex)
    {
        return Left<string, User>($"User not found: {ex.Message}");
    }
}

result.Match(
    Left: error => HandleError(error),
    Right: user => HandleSuccess(user)
);
```

---

## PHP

### Native try-catch
```php
try {
    $result = riskyOperation();
    return $result;
} catch (ValidationException $e) {
    throw new BadRequestException($e->getMessage());
} catch (PDOException $e) {
    $logger->error('Database error: ' . $e->getMessage());
    throw new ServiceUnavailableException('Database connection failed');
}
```

### Custom Exceptions
```php
class AppException extends Exception
{
    protected int $statusCode;

    public function __construct(string $message, int $statusCode = 500)
    {
        parent::__construct($message);
        $this->statusCode = $statusCode;
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

### Laravel Exception Handler
```php
// app/Exceptions/Handler.php
public function register()
{
    $this->renderable(function (NotFoundException $e, $request) {
        return response()->json([
            'message' => $e->getMessage()
        ], 404);
    });
}
```

---

## Kotlin

### Native try-catch
```kotlin
try {
    val result = riskyOperation()
    return result
} catch (e: ValidationException) {
    throw BadRequestException(e.message)
} catch (e: SQLException) {
    logger.error("Database error", e)
    throw ServiceUnavailableException("Database connection failed")
}
```

### Custom Exceptions
```kotlin
open class AppException(
    message: String,
    val statusCode: Int = 500
) : RuntimeException(message)

class NotFoundException(resource: String) : AppException(
    message = "$resource not found",
    statusCode = 404
)
```

### Result Type (Built-in)
```kotlin
fun fetchUser(id: String): Result<User> {
    return try {
        val user = database.getUser(id)
        Result.success(user)
    } catch (e: Exception) {
        Result.failure(e)
    }
}

result.fold(
    onSuccess = { user -> handleSuccess(user) },
    onFailure = { error -> handleError(error) }
)
```

### Arrow Either Type
```kotlin
import arrow.core.Either
import arrow.core.left
import arrow.core.right

fun validateEmail(email: String): Either<ValidationError, String> {
    return if (email.contains("@")) {
        email.right()
    } else {
        ValidationError.InvalidEmail(email).left()
    }
}
```

---

## Swift

### Native do-catch
```swift
do {
    let result = try riskyOperation()
    return result
} catch let error as ValidationError {
    throw BadRequestError(error.localizedDescription)
} catch let error as DatabaseError {
    logger.error("Database error: \(error)")
    throw ServiceUnavailableError("Database connection failed")
}
```

### Custom Errors (Enum)
```swift
enum AppError: Error {
    case notFound(resource: String)
    case validation(message: String)
    case serviceUnavailable(message: String)
    
    var statusCode: Int {
        switch self {
        case .notFound: return 404
        case .validation: return 400
        case .serviceUnavailable: return 503
        }
    }
}

// Usage
throw AppError.notFound(resource: "User")
```

### Result Type (Built-in)
```swift
func fetchUser(id: String) -> Result<User, Error> {
    do {
        let user = try database.getUser(id)
        return .success(user)
    } catch {
        return .failure(error)
    }
}

switch fetchUser(id: "123") {
case .success(let user):
    handleSuccess(user)
case .failure(let error):
    handleError(error)
}
```

---

## Dart

### Native try-catch
```dart
try {
  final result = await riskyOperation();
  return result;
} on ValidationException catch (e) {
  throw BadRequestException(e.message);
} on DatabaseException catch (e) {
  logger.error('Database error: $e');
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

  AppException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

class NotFoundException extends AppException {
  NotFoundException(String resource)
      : super('$resource not found', statusCode: 404);
}
```

### Either Type (dartz)
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

result.fold(
  (failure) => handleError(failure),
  (user) => displayUser(user),
);
```

---

## Quick Rules

✅ Log errors with context
✅ Use typed errors (custom classes)
✅ Fail fast - validate early
✅ Wrap third-party errors
✅ Never expose sensitive data in errors

❌ Catch without logging
❌ Generic "Error occurred" messages
❌ Swallow errors silently
❌ Expose stack traces to users
