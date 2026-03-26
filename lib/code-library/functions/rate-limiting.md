---
title: Rate Limiting Patterns
category: Security
difficulty: intermediate
purpose: Protect endpoints against abuse using per-IP/user rate limits (fixed window / token bucket)
when_to_use:
  - Public APIs and auth endpoints
  - Protecting expensive operations
  - Preventing brute force attacks
  - Controlling traffic spikes
  - Enforcing fair usage tiers
languages:
  typescript:
    - name: Express rate limit middleware
      library: express
      recommended: true
    - name: Fastify rate limit plugin
      library: fastify
    - name: NestJS Throttler
      library: "@nestjs/throttler"
    - name: Next.js middleware (basic)
      library: next
  python:
    - name: FastAPI dependency limit (in-memory)
      library: fastapi
      recommended: true
    - name: Django rate limit (cache-based)
      library: django
    - name: Flask limiter (in-memory)
      library: flask
  java:
    - name: Spring filter (in-memory token bucket)
      library: org.springframework.boot:spring-boot
      recommended: true
  csharp:
    - name: ASP.NET Core rate limiting middleware
      library: Microsoft.AspNetCore.RateLimiting
      recommended: true
  php:
    - name: Laravel throttle middleware
      library: laravel/framework
      recommended: true
    - name: Symfony RateLimiter
      library: symfony/rate-limiter
  kotlin:
    - name: Ktor plugin (token bucket)
      library: io.ktor:ktor-server-core
      recommended: true
  swift:
    - name: Vapor middleware (token bucket)
      library: vapor/vapor
      recommended: true
  dart:
    - name: Client-side backoff (retry delay)
      library: dart-core
      recommended: true
common_patterns:
  - Key by userId if authenticated, else by IP
  - Separate limits per route group (login stricter)
  - Return 429 with Retry-After
  - Centralized limiter implementation (middleware/filter)
best_practices:
  do:
    - Use shared storage for multi-instance services (Redis) when needed
    - Use stricter limits for auth endpoints
    - Include Retry-After header on 429
    - Log rate-limit events (without PII)
  dont:
    - Use in-memory rate limits in multi-instance production without shared storage
    - Rate limit purely by IP for authenticated traffic tiers
    - Retry aggressively on 429
related_functions:
  - error-handling.md
  - logging.md
  - caching.md
tags: [rate-limiting, throttling, security, abuse, 429, token-bucket]
updated: 2026-01-09
---

## TypeScript

### Express rate limit middleware
```typescript
import rateLimit from 'express-rate-limit';

export const limiter = rateLimit({
  windowMs: 60_000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api', limiter);
```

### Fastify rate limit plugin
```typescript
import rateLimit from '@fastify/rate-limit';

await app.register(rateLimit, { max: 60, timeWindow: '1 minute' });
```

### NestJS Throttler
```typescript
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

ThrottlerModule.forRoot([{ ttl: 60_000, limit: 60 }]);

providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }];
```

### Next.js middleware (basic)
```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const hits = new Map<string, { count: number; resetAt: number }>();

export function middleware(req: NextRequest) {
  const key = req.ip ?? 'unknown';
  const now = Date.now();
  const entry = hits.get(key) ?? { count: 0, resetAt: now + 60_000 };
  if (now > entry.resetAt) {
    entry.count = 0;
    entry.resetAt = now + 60_000;
  }
  entry.count += 1;
  hits.set(key, entry);
  if (entry.count > 60) return new NextResponse('Too Many Requests', { status: 429 });
  return NextResponse.next();
}
```

---

## Python

### FastAPI dependency limit (in-memory)
```python
import time
from fastapi import Depends, HTTPException, Request

hits = {}

def rate_limit(request: Request, limit: int = 60, window: int = 60):
    key = request.client.host
    now = time.time()
    count, reset_at = hits.get(key, (0, now + window))
    if now > reset_at:
        count, reset_at = 0, now + window
    count += 1
    hits[key] = (count, reset_at)
    if count > limit:
        raise HTTPException(status_code=429, detail="too_many_requests")
```

### Django rate limit (cache-based)
```python
from django.core.cache import cache
from django.http import JsonResponse

def limited_view(request):
    key = f"rl:{request.META.get('REMOTE_ADDR')}"
    count = cache.get(key, 0) + 1
    cache.set(key, count, timeout=60)
    if count > 60:
        return JsonResponse({"error": "too_many_requests"}, status=429)
    return JsonResponse({"ok": True})
```

### Flask limiter (in-memory)
```python
import time
from flask import request, jsonify

hits = {}

def rate_limit(limit=60, window=60):
    def decorator(fn):
        def wrapper(*args, **kwargs):
            key = request.remote_addr
            now = time.time()
            count, reset_at = hits.get(key, (0, now + window))
            if now > reset_at:
                count, reset_at = 0, now + window
            count += 1
            hits[key] = (count, reset_at)
            if count > limit:
                return jsonify({"error": "too_many_requests"}), 429
            return fn(*args, **kwargs)
        return wrapper
    return decorator
```

---

## Java

### Spring filter (in-memory token bucket)
```java
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

public class RateLimitFilter implements Filter {
  private final ConcurrentHashMap<String, Integer> hits = new ConcurrentHashMap<>();

  @Override
  public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
    var key = req.getRemoteAddr();
    var count = hits.merge(key, 1, Integer::sum);
    if (count > 60) {
      ((HttpServletResponse) res).setStatus(429);
      return;
    }
    chain.doFilter(req, res);
  }
}
```

---

## C#

### ASP.NET Core rate limiting middleware
```csharp
using System.Threading.RateLimiting;

builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", limiterOptions =>
    {
        limiterOptions.PermitLimit = 60;
        limiterOptions.Window = TimeSpan.FromMinutes(1);
        limiterOptions.QueueLimit = 0;
    });
});

app.UseRateLimiter();
app.MapGet("/api", () => Results.Ok()).RequireRateLimiting("fixed");
```

---

## PHP

### Laravel throttle middleware
```php
<?php

Route::middleware('throttle:60,1')->get('/api/users', fn () => response()->json([]));
```

### Symfony RateLimiter
```php
<?php

$limiter = $limiterFactory->create($request->getClientIp() ?? 'unknown');
$limit = $limiter->consume(1);
if (!$limit->isAccepted()) {
  return new JsonResponse(['error' => 'too_many_requests'], 429);
}
```

---

## Kotlin

### Ktor plugin (token bucket)
```kotlin
import io.ktor.server.application.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.util.concurrent.ConcurrentHashMap

val hits = ConcurrentHashMap<String, Int>()

fun Application.rateLimit() {
  intercept(ApplicationCallPipeline.Plugins) {
    val key = call.request.origin.remoteHost
    val count = hits.merge(key, 1, Int::plus) ?: 1
    if (count > 60) {
      call.respondText("Too Many Requests", status = io.ktor.http.HttpStatusCode.TooManyRequests)
      finish()
    }
  }
}
```

---

## Swift

### Vapor middleware (token bucket)
```swift
import Vapor

struct RateLimitMiddleware: AsyncMiddleware {
  static var hits: [String: Int] = [:]

  func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let key = req.remoteAddress?.ipAddress ?? "unknown"
    Self.hits[key, default: 0] += 1
    if Self.hits[key, default: 0] > 60 {
      return Response(status: .tooManyRequests)
    }
    return try await next.respond(to: req)
  }
}
```

---

## Dart

### Client-side backoff (retry delay)
```dart
if (response.statusCode == 429) {
  await Future.delayed(const Duration(seconds: 2));
}
```

