---
title: Error Handling Patterns
category: Error Management
difficulty: intermediate
purpose: Handle failures, validation errors, API errors, and unexpected conditions consistently
when_to_use:
  - API error responses
  - Validation failures
  - External service failures
  - Database errors
  - Unexpected conditions
  - User-facing error messages
languages:
  typescript:
    - name: Native try-catch (Built-in)
      library: javascript-core
      recommended: true
    - name: neverthrow (Result type)
      library: neverthrow
    - name: React Error Boundary (React)
      library: react
    - name: Express error middleware
      library: express
    - name: Fastify error handler
      library: fastify
    - name: Koa error middleware
      library: koa
    - name: Hapi onPreResponse
      library: "@hapi/hapi"
    - name: NestJS Exception Filter
      library: "@nestjs/common"
    - name: Next.js Route Handler (errors)
      library: next
    - name: AdonisJS Exception Handler
      library: "@adonisjs/core"
    - name: Angular ErrorHandler
      library: "@angular/core"
    - name: Vue app.config.errorHandler
      library: vue
    - name: Preact Error Boundary
      library: preact
    - name: Browser global error handler (SPA)
      library: javascript-core
  python:
    - name: Native try-except (Built-in)
      library: python-core
      recommended: true
    - name: result (Result type)
      library: result
    - name: Context managers (Built-in)
      library: python-core
    - name: FastAPI exception handlers
      library: fastapi
    - name: Django middleware (error handling)
      library: django
    - name: Flask errorhandler
      library: flask
  java:
    - name: Native try-catch (Built-in)
      library: java-core
      recommended: true
    - name: Try-with-resources (Built-in)
      library: java-core
    - name: Vavr (Result/Either type)
      library: io.vavr:vavr
    - name: Spring Boot @ControllerAdvice
      library: org.springframework.boot:spring-boot
  csharp:
    - name: Native try-catch (Built-in)
      library: dotnet-core
      recommended: true
    - name: Using statement (Built-in)
      library: dotnet-core
    - name: LanguageExt (Result/Either type)
      library: LanguageExt.Core
    - name: ASP.NET Core exception handler middleware
      library: Microsoft.AspNetCore.App
    - name: Blazor ErrorBoundary
      library: Microsoft.AspNetCore.Components.Web
    - name: .NET MAUI global exception handlers
      library: Microsoft.Maui
    - name: MediatR pipeline behavior
      library: MediatR
  php:
    - name: Native try-catch (Built-in)
      library: php-core
      recommended: true
    - name: Laravel Exception Handler
      library: laravel/framework
    - name: Symfony exception listener
      library: symfony/http-kernel
    - name: Slim ErrorMiddleware
      library: slim/slim
    - name: Laminas Mezzio error handler
      library: mezzio/mezzio
    - name: WordPress wp_die / wp_send_json_error
      library: wordpress
  kotlin:
    - name: Native try-catch (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: Result type (Built-in)
      library: kotlin-stdlib
    - name: Arrow (Either type)
      library: io.arrow-kt:arrow-core
    - name: Ktor StatusPages
      library: io.ktor:ktor-server-status-pages
  swift:
    - name: Native do-catch (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Result type (Built-in)
      library: swift-stdlib
    - name: Vapor AbortError
      library: vapor/vapor
  dart:
    - name: Native try-catch (Built-in)
      library: dart-core
      recommended: true
    - name: dartz (Either type)
      library: dartz
    - name: FlutterError + Zone
      library: flutter
common_patterns:
  - Custom error classes with status codes
  - Error type discrimination (instanceof, is, etc.)
  - Result/Either types for functional error handling
  - Error boundaries for UI frameworks
  - Context managers for resource cleanup
  - Error wrapping and re-throwing
best_practices:
  do:
    - Log errors with context (user ID, request ID, timestamp)
    - Use typed errors (custom classes/enums)
    - Fail fast - validate early, throw immediately
    - Wrap third-party errors in your own types
    - Provide actionable error messages
    - Monitor error rates and set up alerts
  dont:
    - Catch exceptions without logging
    - Return generic "Error occurred" messages
    - Swallow errors silently
    - Expose stack traces to users in production
    - Log passwords or tokens in error messages
    - Use exceptions for flow control
related_functions:
  - input-validation.md
  - http-requests.md
tags: [errors, exceptions, try-catch, result-types, error-boundaries]
updated: 2026-01-09
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

### Preact Error Boundary
```typescript
import { Component } from 'preact';

export class ErrorBoundary extends Component {
  componentDidCatch(error: unknown) {
    console.error('preact.error', { error });
  }
  render() {
    return this.props.children as any;
  }
}
```

### Express error middleware
```typescript
import type { NextFunction, Request, Response } from 'express';

export function errorHandler(err: unknown, req: Request, res: Response, _next: NextFunction) {
  req.log?.error?.({ err }, 'request failed');
  res.status(500).json({ error: 'internal_error' });
}
```

### Fastify error handler
```typescript
app.setErrorHandler((err, request, reply) => {
  request.log.error({ err }, 'request failed');
  reply.code(500).send({ error: 'internal_error' });
});
```

### Koa error middleware
```typescript
import type { Context, Next } from 'koa';

export async function errorMiddleware(ctx: Context, next: Next) {
  try {
    await next();
  } catch (err) {
    ctx.status = 500;
    ctx.body = { error: 'internal_error' };
    ctx.app.emit('error', err, ctx);
  }
}
```

### Hapi onPreResponse
```typescript
server.ext('onPreResponse', (request, h) => {
  const response = request.response as any;
  if (!response?.isBoom) return h.continue;

  const statusCode = response.output.statusCode ?? 500;
  return h.response({ error: 'internal_error' }).code(statusCode);
});
```

### NestJS Exception Filter
```typescript
import { ArgumentsHost, Catch, ExceptionFilter, HttpException } from '@nestjs/common';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();

    const status =
      exception instanceof HttpException ? exception.getStatus() : 500;

    response.status(status).json({ error: 'request_failed' });
  }
}
```

### Next.js Route Handler (errors)
```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    throw new Error('boom');
  } catch {
    return NextResponse.json({ error: 'internal_error' }, { status: 500 });
  }
}
```

### Angular ErrorHandler
```typescript
import { ErrorHandler, Injectable } from '@angular/core';

@Injectable()
export class AppErrorHandler implements ErrorHandler {
  handleError(error: unknown) {
    // send to logging backend here
    console.error(error);
  }
}
```

### Vue app.config.errorHandler
```typescript
import { createApp } from 'vue';

const app = createApp(App);
app.config.errorHandler = (err, instance, info) => {
  console.error('vue.error', { err, info });
};
```

### Browser global error handler (SPA)
```typescript
window.addEventListener('error', (event) => {
  console.error('window.error', { message: event.message, filename: event.filename });
});

window.addEventListener('unhandledrejection', (event) => {
  console.error('window.unhandledrejection', { reason: event.reason });
});
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

with handle_db_errors():
    db.session.add(user)
    db.session.commit()
```

### FastAPI exception handlers
```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"error": "internal_error"})
```

### Django middleware (error handling)
```python
class HandleExceptionsMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            return self.get_response(request)
        except Exception:
            return JsonResponse({"error": "internal_error"}, status=500)
```

### Flask errorhandler
```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.errorhandler(Exception)
def handle_exception(e):
    return jsonify({"error": "internal_error"}), 500
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

### Spring Boot @ControllerAdvice
```java
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(Exception.class)
  public ResponseEntity<?> handle(Exception ex) {
    return ResponseEntity.status(500).body(Map.of("error", "internal_error"));
  }
}
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

### ASP.NET Core exception handler middleware
```csharp
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await context.Response.WriteAsJsonAsync(new { error = "internal_error" });
    });
});
```

### Blazor ErrorBoundary
```csharp
<ErrorBoundary>
    <ChildContent>
        <MyComponent />
    </ChildContent>
    <ErrorContent>
        <p>Something went wrong.</p>
    </ErrorContent>
</ErrorBoundary>
```

### .NET MAUI global exception handlers
```csharp
AppDomain.CurrentDomain.UnhandledException += (_, e) =>
{
    // log crash
};

TaskScheduler.UnobservedTaskException += (_, e) =>
{
    // log unobserved exceptions
    e.SetObserved();
};
```

### MediatR pipeline behavior
```csharp
using MediatR;

public sealed class ExceptionBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        try { return await next(); }
        catch { throw; }
    }
}
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
public function register()
{
    $this->renderable(function (NotFoundException $e, $request) {
        return response()->json([
            'message' => $e->getMessage()
        ], 404);
    });
}
```

### Symfony exception listener
```php
<?php

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Event\ExceptionEvent;

public function onKernelException(ExceptionEvent $event): void
{
    $event->setResponse(new JsonResponse(['error' => 'internal_error'], 500));
}
```

### Slim ErrorMiddleware
```php
<?php

$errorMiddleware = $app->addErrorMiddleware(true, true, true);
$errorMiddleware->setDefaultErrorHandler(function ($request, Throwable $exception) {
    return new \Slim\Psr7\Response(500);
});
```

### Laminas Mezzio error handler
```php
<?php

use Mezzio\Middleware\ErrorResponseGenerator;
use Mezzio\Middleware\ErrorResponseGeneratorInterface;

$container->set(ErrorResponseGeneratorInterface::class, new ErrorResponseGenerator());
```

### WordPress wp_die / wp_send_json_error
```php
<?php

if (empty($_POST['email'])) {
  wp_send_json_error(['error' => 'validation_failed'], 400);
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

### Ktor StatusPages
```kotlin
import io.ktor.server.application.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*

install(StatusPages) {
  exception<Throwable> { call, _ ->
    call.respond(500, mapOf("error" to "internal_error"))
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

### Vapor AbortError
```swift
import Vapor

throw Abort(.notFound, reason: "user not found")
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

### FlutterError + Zone
```dart
import 'package:flutter/foundation.dart';

FlutterError.onError = (details) {
  FlutterError.presentError(details);
  // send to crash reporting here
};

runZonedGuarded(() {
  runApp(const MyApp());
}, (error, stack) {
  debugPrint('unhandled: $error');
});
```
