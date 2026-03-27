---
title: Logging Patterns
category: Observability
difficulty: beginner
purpose: Produce consistent, structured logs with correlation IDs and safe redaction
when_to_use:
  - API request/response logging
  - Background jobs and workers
  - Error reporting and incident investigation
  - Performance timing and slow-operation logging
  - Audit trails (when required)
languages:
  typescript:
    - name: Console + structured fields (Built-in)
      library: javascript-core
      recommended: true
    - name: pino
      library: pino
    - name: winston
      library: winston
    - name: Express request logging
      library: express
    - name: Fastify request logging
      library: fastify
    - name: Koa request logging
      library: koa
    - name: Hapi request logging
      library: "@hapi/hapi"
    - name: NestJS Logger
      library: "@nestjs/common"
    - name: Next.js (server logs)
      library: next
    - name: AdonisJS Logger
      library: "@adonisjs/core"
    - name: Angular Logger service (built-in)
      library: "@angular/core"
    - name: Vue app.config.errorHandler logging
      library: vue
  python:
    - name: logging (Built-in)
      library: python-core
      recommended: true
    - name: structlog
      library: structlog
    - name: Django LOGGING config
      library: django
    - name: FastAPI request logging
      library: fastapi
    - name: Flask app.logger
      library: flask
  java:
    - name: SLF4J + Logback
      library: org.slf4j:slf4j-api
      recommended: true
    - name: java.util.logging (Built-in)
      library: java-core
    - name: Spring Boot Logger (SLF4J)
      library: org.springframework.boot:spring-boot
  csharp:
    - name: Microsoft.Extensions.Logging
      library: Microsoft.Extensions.Logging
      recommended: true
    - name: Serilog
      library: Serilog
    - name: ASP.NET Core request logging
      library: Microsoft.AspNetCore.App
  php:
    - name: error_log + JSON (Built-in)
      library: php-core
      recommended: true
    - name: Monolog
      library: monolog/monolog
    - name: Laravel Log facade
      library: laravel/framework
    - name: Symfony Monolog bundle
      library: symfony/monolog-bundle
  kotlin:
    - name: SLF4J + Logback
      library: org.slf4j:slf4j-api
      recommended: true
    - name: KotlinLogging
      library: io.github.microutils:kotlin-logging
    - name: Ktor CallLogging
      library: io.ktor:ktor-server-call-logging
  swift:
    - name: Logger (OSLog)
      library: os
      recommended: true
    - name: Vapor Logger
      library: vapor/vapor
  dart:
    - name: log() (dart:developer)
      library: dart:developer
      recommended: true
    - name: logging
      library: logging
    - name: Flutter debugPrint
      library: flutter
common_patterns:
  - Structured logs (event name + JSON fields)
  - Correlation/request IDs for tracing
  - Safe redaction of secrets and PII
  - Log levels (debug/info/warn/error)
  - Duration logging for slow operations
best_practices:
  do:
    - Use stable event names (e.g., "user.create.success")
    - Include correlation IDs and key identifiers (userId, orderId)
    - Redact secrets (tokens, passwords) before logging
    - Log errors with enough context to reproduce
    - Prefer structured fields over string concatenation
  dont:
    - Log secrets, access tokens, passwords, or session cookies
    - Log full request bodies by default
    - Use logs as a database (avoid high-cardinality spam)
    - Rely on parsing human-formatted strings
related_functions:
  - error-handling.md
  - http-requests.md
tags: [logging, observability, structured-logging, correlation-id, redaction]
updated: 2026-01-09
---

## TypeScript

### Console + structured fields (Built-in)
```typescript
type LogLevel = 'debug' | 'info' | 'warn' | 'error';

function log(level: LogLevel, event: string, fields: Record<string, unknown> = {}) {
  const payload = {
    ts: new Date().toISOString(),
    level,
    event,
    ...fields,
  };
  // eslint-disable-next-line no-console
  console[level === 'debug' ? 'log' : level](JSON.stringify(payload));
}

log('info', 'user.create.success', { userId, requestId });
```

### pino
```typescript
import pino from 'pino';

const logger = pino({ level: process.env.LOG_LEVEL ?? 'info' });

logger.info({ event: 'user.fetch.success', userId, requestId }, 'user fetched');
logger.error({ event: 'user.fetch.failure', userId, requestId, err }, 'user fetch failed');
```

### winston
```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL ?? 'info',
  format: winston.format.json(),
  transports: [new winston.transports.Console()],
});

logger.info('user.create.success', { event: 'user.create.success', userId, requestId });
```

### Express request logging
```typescript
app.use((req, _res, next) => {
  req.log?.info?.({ event: 'http.request', method: req.method, path: req.path });
  next();
});
```

### Fastify request logging
```typescript
app.addHook('onRequest', async (request) => {
  request.log.info({ event: 'http.request', method: request.method, url: request.url });
});
```

### Koa request logging
```typescript
app.use(async (ctx, next) => {
  console.log('http.request', { method: ctx.method, path: ctx.path });
  await next();
});
```

### Hapi request logging
```typescript
server.events.on('response', (request) => {
  console.log('http.request', { method: request.method, path: request.path, status: request.response?.statusCode });
});
```

### NestJS Logger
```typescript
import { Logger } from '@nestjs/common';

const logger = new Logger('UsersService');
logger.log('user.create.success');
logger.error('user.create.failure', err?.stack);
```

### Next.js (server logs)
```typescript
export async function GET() {
  console.log('users.list', { requestId });
  return new Response('ok');
}
```

### AdonisJS Logger
```typescript
import logger from '@adonisjs/core/services/logger';

logger.info({ event: 'user.create.success', userId, requestId });
```

### Angular Logger service (built-in)
```typescript
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class LogService {
  info(event: string, fields: Record<string, unknown> = {}) {
    console.log(event, fields);
  }
}
```

### Vue app.config.errorHandler logging
```typescript
import { createApp } from 'vue';

const app = createApp(App);
app.config.errorHandler = (err, instance, info) => {
  console.error('vue.error', { err, info });
};
```

---

## Python

### logging (Built-in)
```python
import json
import logging
from datetime import datetime

logger = logging.getLogger("app")
logger.setLevel(logging.INFO)

def log(level: int, event: str, **fields):
    payload = {
        "ts": datetime.utcnow().isoformat() + "Z",
        "event": event,
        **fields,
    }
    logger.log(level, json.dumps(payload))

log(logging.INFO, "user.create.success", userId=user_id, requestId=request_id)
```

### structlog
```python
import structlog

logger = structlog.get_logger()

logger.info("user.fetch.success", event="user.fetch.success", userId=user_id, requestId=request_id)
logger.error("user.fetch.failure", event="user.fetch.failure", userId=user_id, requestId=request_id, exc_info=True)
```

### Django LOGGING config
```python
LOGGING = {
    "version": 1,
    "handlers": {"console": {"class": "logging.StreamHandler"}},
    "root": {"handlers": ["console"], "level": "INFO"},
}
```

### FastAPI request logging
```python
import logging
from fastapi import FastAPI, Request

log = logging.getLogger("app")
app = FastAPI()

@app.middleware("http")
async def log_requests(request: Request, call_next):
    log.info("http.request", extra={"path": request.url.path})
    return await call_next(request)
```

### Flask app.logger
```python
from flask import Flask

app = Flask(__name__)
app.logger.info("app.started")
```

---

## Java

### SLF4J + Logback
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

public class AppLogger {
  private static final Logger log = LoggerFactory.getLogger(AppLogger.class);

  public static void info(String event, Map<String, Object> fields) {
    log.info("{} {}", event, fields);
  }
}

AppLogger.info("user.create.success", Map.of("userId", userId, "requestId", requestId));
```

### java.util.logging (Built-in)
```java
import java.util.logging.Logger;

Logger log = Logger.getLogger("app");
log.info("{\"event\":\"user.create.success\",\"userId\":\"" + userId + "\",\"requestId\":\"" + requestId + "\"}");
```

### Spring Boot Logger (SLF4J)
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger log = LoggerFactory.getLogger(UserService.class);
log.info("user.fetch.success userId={} requestId={}", userId, requestId);
```

---

## C#

### Microsoft.Extensions.Logging
```csharp
using Microsoft.Extensions.Logging;

public class UserService
{
    private readonly ILogger<UserService> _logger;
    public UserService(ILogger<UserService> logger) => _logger = logger;

    public void Created(string userId, string requestId)
    {
        _logger.LogInformation("user.create.success {UserId} {RequestId}", userId, requestId);
    }
}
```

### Serilog
```csharp
using Serilog;

Log.Information("user.fetch.success {@Fields}", new { eventName = "user.fetch.success", userId, requestId });
Log.Error(ex, "user.fetch.failure {@Fields}", new { eventName = "user.fetch.failure", userId, requestId });
```

### ASP.NET Core request logging
```csharp
app.Use(async (context, next) =>
{
    logger.LogInformation("http.request {Path}", context.Request.Path);
    await next();
});
```

---

## PHP

### error_log + JSON (Built-in)
```php
<?php

function log_event(string $level, string $event, array $fields = []): void
{
    $payload = array_merge([
        'ts' => gmdate('c'),
        'level' => $level,
        'event' => $event,
    ], $fields);

    error_log(json_encode($payload, JSON_UNESCAPED_SLASHES));
}

log_event('info', 'user.create.success', ['userId' => $userId, 'requestId' => $requestId]);
```

### Monolog
```php
<?php

use Monolog\Logger;
use Monolog\Handler\StreamHandler;

$logger = new Logger('app');
$logger->pushHandler(new StreamHandler('php://stdout'));

$logger->info('user.fetch.success', ['event' => 'user.fetch.success', 'userId' => $userId, 'requestId' => $requestId]);
```

### Laravel Log facade
```php
<?php

use Illuminate\Support\Facades\Log;

Log::info('user.fetch.success', ['event' => 'user.fetch.success', 'userId' => $userId, 'requestId' => $requestId]);
```

### Symfony Monolog bundle
```php
<?php

$logger->info('user.fetch.success', ['event' => 'user.fetch.success', 'userId' => $userId, 'requestId' => $requestId]);
```

---

## Kotlin

### SLF4J + Logback
```kotlin
import org.slf4j.LoggerFactory

private val log = LoggerFactory.getLogger("app")

fun logInfo(event: String, fields: Map<String, Any?>) {
  log.info("{} {}", event, fields)
}

logInfo("user.create.success", mapOf("userId" to userId, "requestId" to requestId))
```

### KotlinLogging
```kotlin
import mu.KotlinLogging

private val log = KotlinLogging.logger {}

log.info { "user.fetch.success userId=$userId requestId=$requestId" }
```

### Ktor CallLogging
```kotlin
import io.ktor.server.application.*
import io.ktor.server.plugins.callloging.*

fun Application.module() {
  install(CallLogging)
}
```

---

## Swift

### Logger (OSLog)
```swift
import os

let logger = Logger(subsystem: "com.example.app", category: "app")

logger.info("user.create.success userId=\(userId, privacy: .private) requestId=\(requestId, privacy: .public)")
```

### Vapor Logger
```swift
import Vapor

req.logger.info("user.fetch.success userId=\(userId)")
```

---

## Dart

### log() (dart:developer)
```dart
import 'dart:convert';
import 'dart:developer' as dev;

void logEvent(String level, String event, Map<String, Object?> fields) {
  final payload = {
    'ts': DateTime.now().toUtc().toIso8601String(),
    'level': level,
    'event': event,
    ...fields,
  };
  dev.log(jsonEncode(payload), name: 'app');
}

logEvent('info', 'user.create.success', {'userId': userId, 'requestId': requestId});
```

### logging
```dart
import 'dart:convert';
import 'package:logging/logging.dart';

final logger = Logger('app');

void logEvent(String event, Map<String, Object?> fields) {
  logger.info(jsonEncode({'event': event, ...fields}));
}
```

### Flutter debugPrint
```dart
import 'package:flutter/foundation.dart';

debugPrint('user.create.success userId=$userId requestId=$requestId');
```
