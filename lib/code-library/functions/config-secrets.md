---
title: Configuration & Secrets Patterns
category: Configuration
difficulty: beginner
purpose: Load configuration safely from environment/config providers without leaking secrets
when_to_use:
  - Reading env vars (API_URL, DB_URL, REDIS_URL)
  - Loading configuration in apps/services
  - Managing secrets and redaction
  - Validating required configuration at startup
languages:
  typescript:
    - name: process.env with typed config (Built-in)
      library: javascript-core
      recommended: true
    - name: dotenv (local development)
      library: dotenv
    - name: NestJS ConfigModule
      library: "@nestjs/config"
    - name: Next.js runtime config (process.env)
      library: next
    - name: AdonisJS Env/Config
      library: "@adonisjs/core"
    - name: Angular environment files
      library: "@angular/core"
  python:
    - name: os.environ (Built-in)
      library: python-core
      recommended: true
    - name: Pydantic Settings
      library: pydantic
    - name: Django settings
      library: django
    - name: Flask config
      library: flask
  java:
    - name: System.getenv / System.getProperty (Built-in)
      library: java-core
      recommended: true
    - name: Spring @ConfigurationProperties
      library: org.springframework.boot:spring-boot
  csharp:
    - name: IConfiguration + Options
      library: Microsoft.Extensions.Configuration
      recommended: true
  php:
    - name: getenv + defaults (Built-in)
      library: php-core
      recommended: true
    - name: Symfony Dotenv
      library: symfony/dotenv
    - name: Laravel config/env
      library: laravel/framework
    - name: WordPress wp-config.php
      library: wordpress
  kotlin:
    - name: System.getenv (Built-in)
      library: kotlin-stdlib
      recommended: true
  swift:
    - name: ProcessInfo environment (Built-in)
      library: Foundation
      recommended: true
    - name: Vapor Environment
      library: vapor/vapor
  dart:
    - name: const String.fromEnvironment (Built-in)
      library: dart-core
      recommended: true
    - name: flutter_dotenv (runtime)
      library: flutter_dotenv
    - name: Flutter --dart-define (compile-time)
      library: flutter
common_patterns:
  - Required config validation at startup (fail fast)
  - Defaults for non-sensitive values
  - Separate secrets from non-secrets
  - Redaction when logging configuration
best_practices:
  do:
    - Fail fast if required config is missing
    - Keep secrets out of source control
    - Redact secrets in logs
    - Keep config centralized (one config object)
  dont:
    - Hardcode API keys, passwords, tokens
    - Print secrets in logs or exceptions
    - Scatter getenv calls throughout business logic
related_functions:
  - input-validation.md
  - logging.md
tags: [config, environment, secrets, dotenv, settings, redaction]
updated: 2026-01-09
---

## TypeScript

### process.env with typed config (Built-in)
```typescript
function requiredEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}

function optionalEnv(name: string, fallback: string): string {
  return process.env[name] ?? fallback;
}

export const config = {
  env: optionalEnv('NODE_ENV', 'development'),
  apiUrl: requiredEnv('API_URL'),
  databaseUrl: requiredEnv('DATABASE_URL'),
  redisUrl: process.env.REDIS_URL,
};
```

### dotenv (local development)
```typescript
import 'dotenv/config';

const apiUrl = process.env.API_URL;
```

### NestJS ConfigModule
```typescript
import { ConfigModule, ConfigService } from '@nestjs/config';

ConfigModule.forRoot({ isGlobal: true });
const apiUrl = new ConfigService().get<string>('API_URL');
```

### Next.js runtime config (process.env)
```typescript
export const apiUrl = process.env.API_URL;
```

### AdonisJS Env/Config
```typescript
import env from '#start/env';

const apiUrl = env.get('API_URL');
```

### Angular environment files
```typescript
// environment.ts / environment.prod.ts
export const environment = {
  apiUrl: 'https://api.example.com',
};
```

---

## Python

### os.environ (Built-in)
```python
import os

def required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required env var: {name}")
    return value

def optional_env(name: str, default: str) -> str:
    return os.getenv(name, default)

config = {
    "env": optional_env("ENV", "development"),
    "api_url": required_env("API_URL"),
    "database_url": required_env("DATABASE_URL"),
}
```

### Pydantic Settings
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    env: str = "development"
    api_url: str
    database_url: str

settings = Settings()
```

### Django settings
```python
# settings.py
import os

API_URL = os.getenv("API_URL")
```

### Flask config
```python
from flask import Flask

app = Flask(__name__)
app.config["API_URL"] = os.getenv("API_URL")
```

---

## Java

### System.getenv / System.getProperty (Built-in)
```java
public final class Config {
  public static String requiredEnv(String key) {
    String value = System.getenv(key);
    if (value == null || value.isBlank()) throw new IllegalStateException("Missing env var: " + key);
    return value;
  }

  public static String optionalEnv(String key, String fallback) {
    String value = System.getenv(key);
    return (value == null || value.isBlank()) ? fallback : value;
  }

  public static final String API_URL = requiredEnv("API_URL");
  public static final String DATABASE_URL = requiredEnv("DATABASE_URL");
}
```

### Spring @ConfigurationProperties
```java
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public record AppConfig(String apiUrl, String databaseUrl) {}
```

---

## C#

### IConfiguration + Options
```csharp
public sealed class AppOptions
{
    public string ApiUrl { get; init; } = null!;
    public string DatabaseUrl { get; init; } = null!;
}

// builder.Configuration.AddEnvironmentVariables();
// services.Configure<AppOptions>(builder.Configuration.GetSection("App"));
```

---

## PHP

### getenv + defaults (Built-in)
```php
<?php

function required_env(string $name): string
{
    $value = getenv($name);
    if ($value === false || $value === '') {
        throw new RuntimeException("Missing required env var: {$name}");
    }
    return $value;
}

function optional_env(string $name, string $default): string
{
    $value = getenv($name);
    if ($value === false || $value === '') return $default;
    return $value;
}

$config = [
    'env' => optional_env('APP_ENV', 'development'),
    'apiUrl' => required_env('API_URL'),
    'databaseUrl' => required_env('DATABASE_URL'),
];
```

### Symfony Dotenv
```php
<?php

use Symfony\Component\Dotenv\Dotenv;

(new Dotenv())->bootEnv(dirname(__DIR__) . '/.env');
```

### Laravel config/env
```php
<?php

$apiUrl = config('app.api_url');
$databaseUrl = env('DATABASE_URL');
```

### WordPress wp-config.php
```php
<?php

define('DB_NAME', 'my_db');
define('DB_USER', 'my_user');
define('DB_PASSWORD', 'my_password');
define('DB_HOST', 'localhost');
```

---

## Kotlin

### System.getenv (Built-in)
```kotlin
fun requiredEnv(name: String): String =
  System.getenv(name)?.takeIf { it.isNotBlank() }
    ?: throw IllegalStateException("Missing required env var: $name")

data class AppConfig(
  val apiUrl: String,
  val databaseUrl: String,
)

val config = AppConfig(
  apiUrl = requiredEnv("API_URL"),
  databaseUrl = requiredEnv("DATABASE_URL"),
)
```

---

## Swift

### ProcessInfo environment (Built-in)
```swift
import Foundation

func requiredEnv(_ key: String) throws -> String {
  let value = ProcessInfo.processInfo.environment[key]
  if let v = value, !v.isEmpty { return v }
  throw NSError(domain: "Config", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing env var: \(key)"])
}

let apiUrl = try requiredEnv("API_URL")
```

### Vapor Environment
```swift
import Vapor

let apiUrl = Environment.get("API_URL")
```

---

## Dart

### const String.fromEnvironment (Built-in)
```dart
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://example.invalid');
```

### flutter_dotenv (runtime)
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiUrl = dotenv.env['API_URL'];
```

### Flutter --dart-define (compile-time)
```dart
const apiUrl = String.fromEnvironment('API_URL');
```
