---
title: Authentication & Authorization Patterns
category: Security
difficulty: intermediate
purpose: Authenticate requests and enforce authorization consistently (JWT/session, RBAC/ABAC checks)
when_to_use:
  - Protecting API endpoints
  - Adding JWT/session authentication
  - Enforcing roles/permissions
  - Access control in services (policy checks)
  - Securing mobile/web API calls
languages:
  typescript:
    - name: JWT verify (jose)
      library: jose
      recommended: true
    - name: Express auth middleware
      library: express
    - name: Fastify auth hook
      library: fastify
    - name: NestJS Guard (JWT)
      library: "@nestjs/common"
    - name: Next.js middleware (edge)
      library: next
  python:
    - name: JWT verify (PyJWT)
      library: PyJWT
      recommended: true
    - name: FastAPI dependency auth
      library: fastapi
    - name: Django view auth
      library: django
    - name: Flask auth decorator
      library: flask
  java:
    - name: Spring Security (method/route auth)
      library: org.springframework.boot:spring-boot-starter-security
      recommended: true
    - name: JWT verify (jjwt)
      library: io.jsonwebtoken:jjwt-api
  csharp:
    - name: ASP.NET Core authorization policies
      library: Microsoft.AspNetCore.App
      recommended: true
    - name: JWT bearer auth
      library: Microsoft.AspNetCore.Authentication.JwtBearer
  php:
    - name: Laravel middleware (auth + abilities)
      library: laravel/framework
      recommended: true
    - name: Symfony security voter
      library: symfony/security-bundle
    - name: JWT verify (firebase/php-jwt)
      library: firebase/php-jwt
  kotlin:
    - name: Ktor JWT auth
      library: io.ktor:ktor-server-auth-jwt
      recommended: true
    - name: Spring Security
      library: org.springframework.boot:spring-boot-starter-security
  swift:
    - name: Vapor auth middleware
      library: vapor/vapor
      recommended: true
  dart:
    - name: Add Authorization header (http/dio)
      library: flutter
      recommended: true
common_patterns:
  - Bearer token extraction + verification
  - Fail closed (401/403) with consistent error body
  - Central authorization checks (policies/guards)
  - RBAC role checks (admin/editor/user)
  - Least privilege and explicit allow lists
best_practices:
  do:
    - Verify signature + issuer/audience where applicable
    - Enforce authorization in server-side code (not client)
    - Use centralized policy/permission checks
    - Return 401 for unauthenticated, 403 for unauthorized
  dont:
    - Trust user-provided roles/claims without verification
    - Put secrets/keys in source control
    - Mix authentication and authorization logic everywhere
related_functions:
  - input-validation.md
  - error-handling.md
  - http-requests.md
  - config-secrets.md
tags: [auth, authorization, jwt, rbac, security, middleware, guards]
updated: 2026-01-09
---

## TypeScript

### JWT verify (jose)
```typescript
import { jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET);

export async function verifyJwt(token: string) {
  const { payload } = await jwtVerify(token, secret, {
    issuer: process.env.JWT_ISSUER,
    audience: process.env.JWT_AUDIENCE,
  });
  return payload;
}
```

### Express auth middleware
```typescript
import type { NextFunction, Request, Response } from 'express';

export async function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.header('authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'unauthenticated' });

  try {
    const claims = await verifyJwt(token);
    (req as any).user = claims;
    return next();
  } catch {
    return res.status(401).json({ error: 'invalid_token' });
  }
}
```

### Fastify auth hook
```typescript
app.addHook('preHandler', async (request, reply) => {
  const header = request.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return reply.code(401).send({ error: 'unauthenticated' });

  try {
    request.user = await verifyJwt(token);
  } catch {
    return reply.code(401).send({ error: 'invalid_token' });
  }
});
```

### NestJS Guard (JWT)
```typescript
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

@Injectable()
export class JwtGuard implements CanActivate {
  async canActivate(ctx: ExecutionContext) {
    const req = ctx.switchToHttp().getRequest();
    const header = req.headers['authorization'] ?? '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return false;
    req.user = await verifyJwt(token);
    return true;
  }
}
```

### Next.js middleware (edge)
```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const token = req.cookies.get('token')?.value ?? null;
  if (!token) return NextResponse.redirect(new URL('/login', req.url));
  return NextResponse.next();
}
```

---

## Python

### JWT verify (PyJWT)
```python
import jwt

def verify_jwt(token: str) -> dict:
    payload = jwt.decode(
        token,
        key=os.environ["JWT_SECRET"],
        algorithms=["HS256"],
        audience=os.getenv("JWT_AUDIENCE"),
        issuer=os.getenv("JWT_ISSUER"),
    )
    return payload
```

### FastAPI dependency auth
```python
from fastapi import Depends, HTTPException, Request

def require_auth(request: Request) -> dict:
    header = request.headers.get("authorization", "")
    token = header.split("Bearer ")[1] if header.startswith("Bearer ") else None
    if not token:
        raise HTTPException(status_code=401, detail="unauthenticated")
    return verify_jwt(token)
```

### Django view auth
```python
from django.contrib.auth.decorators import login_required

@login_required
def dashboard(request):
    return JsonResponse({"ok": True})
```

### Flask auth decorator
```python
from functools import wraps
from flask import request, jsonify

def require_auth(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        header = request.headers.get("Authorization", "")
        token = header.split("Bearer ")[1] if header.startswith("Bearer ") else None
        if not token:
            return jsonify({"error": "unauthenticated"}), 401
        return fn(*args, **kwargs)
    return wrapper
```

---

## Java

### Spring Security (method/route auth)
```java
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AdminController {
  @GetMapping("/admin")
  @PreAuthorize("hasRole('ADMIN')")
  public String admin() {
    return "ok";
  }
}
```

### JWT verify (jjwt)
```java
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

var key = Keys.hmacShaKeyFor(secretBytes);
var claims = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
```

---

## C#

### ASP.NET Core authorization policies
```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
});

app.MapGet("/admin", () => Results.Ok())
   .RequireAuthorization("AdminOnly");
```

### JWT bearer auth
```csharp
builder.Services
  .AddAuthentication("Bearer")
  .AddJwtBearer("Bearer", options => { /* token validation params */ });

app.UseAuthentication();
app.UseAuthorization();
```

---

## PHP

### Laravel middleware (auth + abilities)
```php
<?php

Route::middleware(['auth'])->get('/admin', function () {
  abort_unless(auth()->user()->is_admin, 403);
  return response()->json(['ok' => true]);
});
```

### Symfony security voter
```php
<?php

protected function supports(string $attribute, $subject): bool
{
    return $attribute === 'USER_EDIT';
}
```

### JWT verify (firebase/php-jwt)
```php
<?php

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

$payload = JWT::decode($token, new Key($secret, 'HS256'));
```

---

## Kotlin

### Ktor JWT auth
```kotlin
install(Authentication) {
  jwt("auth-jwt") {
    verifier(jwtVerifier)
    validate { credential -> JWTPrincipal(credential.payload) }
  }
}
```

### Spring Security
```kotlin
@EnableWebSecurity
class SecurityConfig
```

---

## Swift

### Vapor auth middleware
```swift
import Vapor

app.grouped(UserToken.authenticator(), User.guardMiddleware()).get("me") { req async throws in
  try req.auth.require(User.self)
}
```

---

## Dart

### Add Authorization header (http/dio)
```dart
final response = await dio.get(
  '/users/me',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

