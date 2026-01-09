---
title: Webhooks Patterns
category: API Integration
difficulty: intermediate
purpose: Receive and verify webhooks safely (signature verification + idempotency)
when_to_use:
  - Receiving third-party webhooks (payments, auth, shipping)
  - Verifying HMAC signatures
  - Preventing replay and duplicate processing
  - Idempotent event handling
languages:
  typescript:
    - name: HMAC verification (Node crypto)
      library: javascript-core
      recommended: true
    - name: Express raw body webhook
      library: express
    - name: Fastify raw body webhook
      library: fastify
    - name: NestJS raw body webhook
      library: "@nestjs/common"
    - name: Next.js route handler webhook
      library: next
  python:
    - name: HMAC verification (hmac)
      library: python-core
      recommended: true
    - name: FastAPI webhook
      library: fastapi
    - name: Django webhook
      library: django
    - name: Flask webhook
      library: flask
  java:
    - name: Spring Boot webhook
      library: org.springframework.boot:spring-boot
      recommended: true
  csharp:
    - name: ASP.NET Core webhook
      library: Microsoft.AspNetCore.App
      recommended: true
  php:
    - name: Laravel webhook controller
      library: laravel/framework
      recommended: true
    - name: Symfony webhook controller
      library: symfony/framework-bundle
  kotlin:
    - name: Ktor webhook
      library: io.ktor:ktor-server-core
      recommended: true
  swift:
    - name: Vapor webhook
      library: vapor/vapor
      recommended: true
  dart:
    - name: Serverless verify + parse (HMAC)
      library: dart-core
      recommended: true
common_patterns:
  - Verify signature over raw body
  - Use constant-time comparison
  - Enforce timestamp tolerance (if provided)
  - Store processed event IDs for idempotency
best_practices:
  do:
    - Verify signatures before parsing trusted fields
    - Reject missing/invalid signatures with 401/400
    - Make handlers idempotent by event ID
    - Respond quickly (enqueue background work if needed)
  dont:
    - Parse/transform body before verifying signature
    - Log full payloads containing secrets/PII
    - Process the same event ID multiple times
related_functions:
  - http-requests.md
  - error-handling.md
  - input-validation.md
  - logging.md
tags: [webhooks, hmac, signature, idempotency, replay-protection]
updated: 2026-01-09
---

## TypeScript

### HMAC verification (Node crypto)
```typescript
import crypto from 'crypto';

export function verifyHmac(rawBody: Buffer, signature: string, secret: string) {
  const expected = crypto.createHmac('sha256', secret).update(rawBody).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(signature));
}
```

### Express raw body webhook
```typescript
import express from 'express';

const app = express();
app.post('/webhook', express.raw({ type: '*/*' }), (req, res) => {
  const sig = req.header('x-signature') ?? '';
  const ok = verifyHmac(req.body as Buffer, sig, process.env.WEBHOOK_SECRET!);
  if (!ok) return res.status(401).send('invalid_signature');
  return res.status(200).send('ok');
});
```

### Fastify raw body webhook
```typescript
app.post('/webhook', { config: { rawBody: true } }, async (request, reply) => {
  const sig = request.headers['x-signature']?.toString() ?? '';
  const raw = (request as any).rawBody as Buffer;
  const ok = verifyHmac(raw, sig, process.env.WEBHOOK_SECRET!);
  if (!ok) return reply.code(401).send('invalid_signature');
  return reply.code(200).send('ok');
});
```

### NestJS raw body webhook
```typescript
import { Controller, Headers, Post, Req } from '@nestjs/common';

@Controller()
export class WebhookController {
  @Post('/webhook')
  handle(@Req() req: any, @Headers('x-signature') sig: string) {
    const raw = req.rawBody as Buffer;
    const ok = verifyHmac(raw, sig ?? '', process.env.WEBHOOK_SECRET!);
    if (!ok) throw new Error('invalid_signature');
    return { ok: true };
  }
}
```

### Next.js route handler webhook
```typescript
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  const raw = Buffer.from(await req.arrayBuffer());
  const sig = req.headers.get('x-signature') ?? '';
  const ok = verifyHmac(raw, sig, process.env.WEBHOOK_SECRET!);
  if (!ok) return new NextResponse('invalid_signature', { status: 401 });
  return NextResponse.json({ ok: true });
}
```

---

## Python

### HMAC verification (hmac)
```python
import hmac
import hashlib

def verify_hmac(raw_body: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(secret.encode(), raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

### FastAPI webhook
```python
from fastapi import FastAPI, Header, Request, HTTPException

app = FastAPI()

@app.post("/webhook")
async def webhook(request: Request, x_signature: str = Header(default="")):
    raw = await request.body()
    if not verify_hmac(raw, x_signature, os.environ["WEBHOOK_SECRET"]):
        raise HTTPException(status_code=401, detail="invalid_signature")
    return {"ok": True}
```

### Django webhook
```python
from django.http import HttpResponse

def webhook(request):
    raw = request.body
    sig = request.headers.get("X-Signature", "")
    if not verify_hmac(raw, sig, os.environ["WEBHOOK_SECRET"]):
        return HttpResponse("invalid_signature", status=401)
    return HttpResponse("ok")
```

### Flask webhook
```python
from flask import Flask, request

app = Flask(__name__)

@app.post("/webhook")
def webhook():
    raw = request.get_data()
    sig = request.headers.get("X-Signature", "")
    if not verify_hmac(raw, sig, os.environ["WEBHOOK_SECRET"]):
        return "invalid_signature", 401
    return "ok", 200
```

---

## Java

### Spring Boot webhook
```java
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

@PostMapping("/webhook")
public ResponseEntity<?> webhook(@RequestHeader("X-Signature") String sig, @RequestBody byte[] raw) {
  if (!verify(sig, raw, secret)) return ResponseEntity.status(401).body("invalid_signature");
  return ResponseEntity.ok("ok");
}
```

---

## C#

### ASP.NET Core webhook
```csharp
app.MapPost("/webhook", async (HttpRequest request) =>
{
    using var ms = new MemoryStream();
    await request.Body.CopyToAsync(ms);
    var raw = ms.ToArray();
    var sig = request.Headers["X-Signature"].ToString();
    return Results.Ok();
});
```

---

## PHP

### Laravel webhook controller
```php
<?php

$raw = $request->getContent();
$sig = $request->header('X-Signature', '');
```

### Symfony webhook controller
```php
<?php

$raw = $request->getContent();
$sig = $request->headers->get('X-Signature', '');
```

---

## Kotlin

### Ktor webhook
```kotlin
routing {
  post("/webhook") {
    val raw = call.receiveText().toByteArray()
    val sig = call.request.headers["X-Signature"].orEmpty()
    call.respondText("ok")
  }
}
```

---

## Swift

### Vapor webhook
```swift
app.post("webhook") { req async throws -> String in
  let raw = req.body.data ?? ByteBuffer()
  let sig = req.headers.first(name: "X-Signature") ?? ""
  return "ok"
}
```

---

## Dart

### Serverless verify + parse (HMAC)
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

bool verifyHmac(List<int> raw, String signature, String secret) {
  final expected = Hmac(sha256, utf8.encode(secret)).convert(raw).toString();
  return expected == signature;
}
```

