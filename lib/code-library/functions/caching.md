---
title: Caching Patterns
category: Performance
difficulty: intermediate
purpose: Cache expensive computations and remote data with TTL, invalidation, and safe keys
when_to_use:
  - Cache read-heavy API responses
  - Reduce database load for hot reads
  - Cache derived/expensive computations
  - Add request-level memoization
  - Add distributed caching (multi-instance services)
languages:
  typescript:
    - name: In-memory TTL cache (Built-in)
      library: javascript-core
      recommended: true
    - name: Redis cache
      library: redis
    - name: NestJS CacheModule (cache-manager)
      library: "@nestjs/cache-manager"
    - name: Next.js fetch caching
      library: next
  python:
    - name: functools.lru_cache (Built-in)
      library: python-core
      recommended: true
    - name: Redis cache
      library: redis
    - name: Django cache framework
      library: django
  java:
    - name: Caffeine
      library: com.github.ben-manes.caffeine:caffeine
      recommended: true
    - name: Spring Cache abstraction
      library: org.springframework:spring-context
  csharp:
    - name: IMemoryCache
      library: Microsoft.Extensions.Caching.Memory
      recommended: true
    - name: IDistributedCache
      library: Microsoft.Extensions.Caching.Abstractions
  php:
    - name: PSR-16 SimpleCache
      library: psr/simple-cache
      recommended: true
    - name: Laravel Cache
      library: laravel/framework
    - name: Symfony Cache
      library: symfony/cache
    - name: WordPress transients
      library: wordpress
  kotlin:
    - name: Caffeine
      library: com.github.ben-manes.caffeine:caffeine
      recommended: true
  swift:
    - name: NSCache (Built-in)
      library: Foundation
      recommended: true
  dart:
    - name: In-memory TTL cache (Built-in)
      library: dart-core
      recommended: true
    - name: shared_preferences (simple persistence)
      library: shared_preferences
common_patterns:
  - Cache-aside (read-through by code)
  - TTL-based expiration
  - Explicit invalidation on writes
  - Safe cache keys (namespace + versioning)
  - Stale-while-revalidate (when acceptable)
best_practices:
  do:
    - Namespace keys (e.g., "user:v1:{id}")
    - Set TTLs for remote data caches
    - Invalidate caches on writes affecting cached reads
    - Avoid caching secrets or PII unless required and encrypted
    - Track cache hit rate and eviction
  dont:
    - Use unbounded in-memory caches without size limits
    - Cache error responses by default
    - Use raw user input directly as cache keys
    - Forget to version keys when schema changes
related_functions:
  - database-query.md
  - http-requests.md
  - async-operations.md
tags: [cache, caching, ttl, performance, redis, memoization]
updated: 2026-01-09
---

## TypeScript

### In-memory TTL cache (Built-in)
```typescript
type CacheEntry<T> = { value: T; expiresAt: number };

class TtlCache<T> {
  private store = new Map<string, CacheEntry<T>>();

  get(key: string): T | undefined {
    const entry = this.store.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expiresAt) {
      this.store.delete(key);
      return undefined;
    }
    return entry.value;
  }

  set(key: string, value: T, ttlMs: number) {
    this.store.set(key, { value, expiresAt: Date.now() + ttlMs });
  }
}

const cache = new TtlCache<unknown>();

async function getOrSet<T>(key: string, ttlMs: number, fn: () => Promise<T>): Promise<T> {
  const hit = cache.get(key) as T | undefined;
  if (hit !== undefined) return hit;
  const value = await fn();
  cache.set(key, value, ttlMs);
  return value;
}
```

### Redis cache
```typescript
import { createClient } from 'redis';

const redis = createClient({ url: process.env.REDIS_URL });

async function getOrSetJson<T>(key: string, ttlSeconds: number, fn: () => Promise<T>): Promise<T> {
  const hit = await redis.get(key);
  if (hit) return JSON.parse(hit) as T;

  const value = await fn();
  await redis.setEx(key, ttlSeconds, JSON.stringify(value));
  return value;
}
```

### NestJS CacheModule (cache-manager)
```typescript
import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';
import { Controller, Get, UseInterceptors } from '@nestjs/common';

@Controller('users')
@UseInterceptors(CacheInterceptor)
export class UsersController {
  @Get()
  @CacheTTL(30)
  list() {
    return this.usersService.findActive();
  }
}
```

### Next.js fetch caching
```typescript
const response = await fetch('https://api.example.com/users', {
  next: { revalidate: 30 },
});
const users = await response.json();
```

---

## Python

### functools.lru_cache (Built-in)
```python
from functools import lru_cache

@lru_cache(maxsize=512)
def compute_expensive(user_id: str) -> str:
    return f"value-for-{user_id}"

result = compute_expensive("123")
```

### Redis cache
```python
import json
import redis

r = redis.Redis.from_url(redis_url)

def get_or_set_json(key: str, ttl_seconds: int, fn):
    hit = r.get(key)
    if hit is not None:
        return json.loads(hit)
    value = fn()
    r.setex(key, ttl_seconds, json.dumps(value))
    return value
```

### Django cache framework
```python
from django.core.cache import cache

key = f"user:v1:{user_id}"
user = cache.get(key)
if user is None:
    user = load_user(user_id)
    cache.set(key, user, timeout=60)
```

---

## Java

### Caffeine
```java
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;

import java.time.Duration;

Cache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(Duration.ofMinutes(5))
    .build();

User user = cache.get(userId, id -> userRepository.findById(id).orElseThrow());
```

### Spring Cache abstraction
```java
import org.springframework.cache.annotation.Cacheable;

@Cacheable(cacheNames = "users", key = "'user:v1:' + #userId")
public User getUser(String userId) {
  return userRepository.findById(userId).orElseThrow();
}
```

---

## C#

### IMemoryCache
```csharp
using Microsoft.Extensions.Caching.Memory;

public async Task<User> GetOrSetAsync(
    IMemoryCache cache,
    string key,
    TimeSpan ttl,
    Func<Task<User>> factory)
{
    if (cache.TryGetValue<User>(key, out var hit))
        return hit;

    var value = await factory();
    cache.Set(key, value, ttl);
    return value;
}
```

### IDistributedCache
```csharp
using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;

public static async Task<T> GetOrSetJsonAsync<T>(
    IDistributedCache cache,
    string key,
    TimeSpan ttl,
    Func<Task<T>> factory)
{
    var hit = await cache.GetStringAsync(key);
    if (hit is not null) return JsonSerializer.Deserialize<T>(hit)!;

    var value = await factory();
    await cache.SetStringAsync(
        key,
        JsonSerializer.Serialize(value),
        new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = ttl });
    return value;
}
```

---

## PHP

### PSR-16 SimpleCache
```php
<?php

use Psr\SimpleCache\CacheInterface;

function get_or_set(CacheInterface $cache, string $key, int $ttlSeconds, callable $fn)
{
    $hit = $cache->get($key);
    if ($hit !== null) {
        return $hit;
    }

    $value = $fn();
    $cache->set($key, $value, $ttlSeconds);
    return $value;
}
```

### Laravel Cache
```php
<?php

use Illuminate\Support\Facades\Cache;

$user = Cache::remember(
    "user:v1:$userId",
    now()->addMinutes(5),
    fn () => User::findOrFail($userId)
);
```

### Symfony Cache
```php
<?php

use Symfony\Contracts\Cache\CacheInterface;

$user = $cache->get("user:v1:$userId", function () use ($userId) {
    return User::findOrFail($userId);
});
```

### WordPress transients
```php
<?php

$key = "user_v1_$userId";
$user = get_transient($key);
if ($user === false) {
  $user = load_user($userId);
  set_transient($key, $user, 60);
}
```

---

## Kotlin

### Caffeine
```kotlin
import com.github.benmanes.caffeine.cache.Caffeine
import java.time.Duration

val cache = Caffeine.newBuilder()
  .maximumSize(10_000)
  .expireAfterWrite(Duration.ofMinutes(5))
  .build<String, User>()

val user = cache.get(userId) { id -> userRepository.findById(id).orElseThrow() }
```

---

## Swift

### NSCache (Built-in)
```swift
import Foundation

final class UserCache {
  private let cache = NSCache<NSString, UserBox>()

  func get(_ key: String) -> User? {
    cache.object(forKey: key as NSString)?.value
  }

  func set(_ key: String, _ user: User) {
    cache.setObject(UserBox(user), forKey: key as NSString)
  }
}

final class UserBox: NSObject {
  let value: User
  init(_ value: User) { self.value = value }
}
```

---

## Dart

### In-memory TTL cache (Built-in)
```dart
class CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  CacheEntry(this.value, this.expiresAt);
}

class TtlCache<T> {
  final _store = <String, CacheEntry<T>>{};

  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  void set(String key, T value, Duration ttl) {
    _store[key] = CacheEntry(value, DateTime.now().add(ttl));
  }
}
```

### shared_preferences (simple persistence)
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> getCachedJson(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(key);
  if (value == null) return null;
  return jsonDecode(value) as Map<String, dynamic>;
}

Future<void> setCachedJson(String key, Map<String, dynamic> value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, jsonEncode(value));
}
```

