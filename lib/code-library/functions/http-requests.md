---
title: HTTP Request Patterns
category: API Integration
difficulty: beginner
purpose: Make HTTP requests to external APIs with proper error handling, timeouts, retry logic, and authentication
when_to_use:
  - REST API calls
  - GraphQL queries
  - Webhooks
  - Third-party service integration
  - File uploads/downloads
  - Authentication flows
languages:
  typescript:
    - name: fetch (Built-in)
      library: javascript-core
      recommended: true
    - name: axios
      library: axios
    - name: Express handler (fetch/axios)
      library: express
    - name: Fastify route (fetch/axios)
      library: fastify
    - name: Koa middleware (fetch/axios)
      library: koa
    - name: Hapi route (fetch/axios)
      library: "@hapi/hapi"
    - name: NestJS HttpService
      library: "@nestjs/axios"
    - name: Angular HttpClient
      library: "@angular/common/http"
    - name: Next.js Route Handler (fetch)
      library: next
  python:
    - name: httpx (Async)
      library: httpx
      recommended: true
    - name: requests (Sync)
      library: requests
    - name: Django view (requests)
      library: django
    - name: FastAPI endpoint (httpx)
      library: fastapi
    - name: Flask route (requests)
      library: flask
  java:
    - name: HttpClient (Built-in)
      library: java.net.http (java 11+)
      recommended: true
    - name: Spring WebClient
      library: org.springframework.boot:spring-boot-starter-webflux
  csharp:
    - name: HttpClient (Built-in)
      library: System.Net.Http
      recommended: true
    - name: Refit
      library: Refit
    - name: Blazor HttpClient (DI)
      library: Microsoft.AspNetCore.Components
  php:
    - name: Guzzle
      library: guzzlehttp/guzzle
      recommended: true
    - name: Laravel HTTP
      library: laravel/framework
    - name: Symfony HttpClient
      library: symfony/http-client
    - name: WordPress HTTP API
      library: wordpress
  kotlin:
    - name: Retrofit
      library: com.squareup.retrofit2:retrofit
      recommended: true
    - name: Ktor Client
      library: io.ktor:ktor-client-core
  swift:
    - name: URLSession (Built-in)
      library: Foundation
      recommended: true
    - name: Alamofire
      library: Alamofire
    - name: Vapor Client
      library: vapor/vapor
  dart:
    - name: http (Official)
      library: http
      recommended: true
    - name: dio
      library: dio
http_methods:
  GET: Retrieve data
  POST: Create new resource
  PUT: Update entire resource
  PATCH: Partially update resource
  DELETE: Remove resource
  HEAD: Check resource existence
  OPTIONS: Check allowed methods
common_headers:
  Content-Type: "application/json"
  Authorization: "Bearer <token>"
  Accept: "application/json"
  User-Agent: "MyApp/1.0"
  X-API-Key: "<api-key>"
status_codes:
  - "200 OK: Success"
  - "201 Created: Resource created"
  - "204 No Content: Success with no body"
  - "400 Bad Request: Invalid input"
  - "401 Unauthorized: Missing/invalid auth"
  - "403 Forbidden: No permission"
  - "404 Not Found: Resource doesn't exist"
  - "429 Too Many Requests: Rate limited"
  - "500 Internal Server Error: Server error"
  - "502 Bad Gateway: Upstream error"
  - "503 Service Unavailable: Server overloaded"
best_practices:
  do:
    - Set timeouts (5-30s depending on operation)
    - Implement retry logic with exponential backoff
    - Use AbortController for request cancellation
    - Validate responses before parsing
    - Log request/response for debugging
    - Use environment variables for API URLs
  dont:
    - Hardcode API keys in code
    - Ignore HTTP status codes
    - Make requests without timeout
    - Log sensitive data (tokens, passwords)
    - Retry on 4xx errors (client errors)
    - Use synchronous requests in UI thread
related_functions:
  - async-operations.md
  - error-handling.md
  - input-validation.md
tags: [http, api, rest, fetch, axios, requests, retry, timeout]
updated: 2026-01-09
---

## TypeScript

### fetch - GET Request
```typescript
const response = await fetch('https://api.example.com/users/123');
if (!response.ok) {
  throw new Error(`HTTP error! status: ${response.status}`);
}
const user = await response.json();
```

### fetch - POST Request
```typescript
const response = await fetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  },
  body: JSON.stringify({ name: 'John', email: 'john@example.com' }),
});

const user = await response.json();
```

### fetch - With Timeout
```typescript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch(url, { signal: controller.signal });
  const data = await response.json();
  return data;
} catch (error) {
  if (error.name === 'AbortError') {
    throw new Error('Request timed out');
  }
  throw error;
} finally {
  clearTimeout(timeoutId);
}
```

### axios - GET Request
```typescript
import axios from 'axios';

const response = await axios.get('https://api.example.com/users/123', {
  headers: { Authorization: `Bearer ${token}` },
  timeout: 5000,
});

const user = response.data;
```

### axios - POST Request
```typescript
const response = await axios.post('https://api.example.com/users', {
  name: 'John',
  email: 'john@example.com',
}, {
  headers: { Authorization: `Bearer ${token}` },
});

const user = response.data;
```

### axios - Retry Logic
```typescript
import axios from 'axios';
import axiosRetry from 'axios-retry';

axiosRetry(axios, {
  retries: 3,
  retryDelay: axiosRetry.exponentialDelay,
  retryCondition: (error) => {
    return axiosRetry.isNetworkOrIdempotentRequestError(error) ||
           error.response?.status === 429;
  },
});

const response = await axios.get(url);
```

### Express handler (fetch/axios)
```typescript
import type { Request, Response } from 'express';

export async function getUser(req: Request, res: Response) {
  const upstream = await fetch(`https://api.example.com/users/${req.params.id}`);
  res.status(upstream.status).json(await upstream.json());
}
```

### Fastify route (fetch/axios)
```typescript
app.get('/users/:id', async (request, reply) => {
  const upstream = await fetch(`https://api.example.com/users/${request.params.id}`);
  reply.code(upstream.status).send(await upstream.json());
});
```

### Koa middleware (fetch/axios)
```typescript
router.get('/users/:id', async (ctx) => {
  const upstream = await fetch(`https://api.example.com/users/${ctx.params.id}`);
  ctx.status = upstream.status;
  ctx.body = await upstream.json();
});
```

### Hapi route (fetch/axios)
```typescript
server.route({
  method: 'GET',
  path: '/users/{id}',
  handler: async (request, h) => {
    const upstream = await fetch(`https://api.example.com/users/${request.params.id}`);
    return h.response(await upstream.json()).code(upstream.status);
  },
});
```

### NestJS HttpService
```typescript
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

const response = await firstValueFrom(
  httpService.get('https://api.example.com/users/123', {
    headers: { Authorization: `Bearer ${token}` },
  })
);

const user = response.data;
```

### Angular HttpClient
```typescript
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
const user = await firstValueFrom(
  http.get<User>('https://api.example.com/users/123', { headers })
);
```

### Next.js Route Handler (fetch)
```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  const response = await fetch('https://api.example.com/users/123', {
    headers: { Authorization: `Bearer ${process.env.API_TOKEN}` },
    cache: 'no-store',
  });

  if (!response.ok) return NextResponse.json({ error: 'upstream_error' }, { status: 502 });
  return NextResponse.json(await response.json());
}
```

---

## Python

### httpx - Async GET Request
```python
import httpx

async with httpx.AsyncClient() as client:
    response = await client.get('https://api.example.com/users/123')
    response.raise_for_status()
    user = response.json()
```

### httpx - POST Request
```python
async with httpx.AsyncClient() as client:
    response = await client.post(
        'https://api.example.com/users',
        json={'name': 'John', 'email': 'john@example.com'},
        headers={'Authorization': f'Bearer {token}'},
    )
    user = response.json()
```

### httpx - With Timeout
```python
async with httpx.AsyncClient(timeout=5.0) as client:
    response = await client.get('https://api.example.com/users/123')
    user = response.json()
```

### httpx - Retry Logic
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=1, max=10))
async def fetch_user(user_id: str):
    async with httpx.AsyncClient() as client:
        response = await client.get(f'https://api.example.com/users/{user_id}')
        response.raise_for_status()
        return response.json()
```

### requests - Sync GET Request
```python
import requests

response = requests.get('https://api.example.com/users/123', timeout=5)
response.raise_for_status()
user = response.json()
```

### requests - POST Request
```python
response = requests.post(
    'https://api.example.com/users',
    json={'name': 'John', 'email': 'john@example.com'},
    headers={'Authorization': f'Bearer {token}'},
    timeout=5,
)
user = response.json()
```

### Django view (requests)
```python
from django.http import JsonResponse
import requests

def users(request):
    upstream = requests.get("https://api.example.com/users", timeout=5)
    return JsonResponse(upstream.json(), safe=False, status=upstream.status_code)
```

### FastAPI endpoint (httpx)
```python
from fastapi import FastAPI
import httpx

app = FastAPI()

@app.get("/users")
async def users():
    async with httpx.AsyncClient(timeout=5.0) as client:
        upstream = await client.get("https://api.example.com/users")
        return upstream.json()
```

### Flask route (requests)
```python
from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.get("/users")
def users():
    upstream = requests.get("https://api.example.com/users", timeout=5)
    return jsonify(upstream.json()), upstream.status_code
```

---

## Java

### HttpClient - GET Request
```java
import java.net.http.*;
import java.net.*;

HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://api.example.com/users/123"))
    .header("Authorization", "Bearer " + token)
    .timeout(Duration.ofSeconds(5))
    .GET()
    .build();

HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

if (response.statusCode() == 200) {
    String body = response.body();
}
```

### HttpClient - POST Request
```java
String json = "{\"name\":\"John\",\"email\":\"john@example.com\"}";

HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://api.example.com/users"))
    .header("Content-Type", "application/json")
    .header("Authorization", "Bearer " + token)
    .POST(HttpRequest.BodyPublishers.ofString(json))
    .build();

HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
```

### Spring WebClient - Reactive
```java
import org.springframework.web.reactive.function.client.WebClient;

WebClient client = WebClient.create("https://api.example.com");

User user = client.get()
    .uri("/users/{id}", userId)
    .header("Authorization", "Bearer " + token)
    .retrieve()
    .bodyToMono(User.class)
    .timeout(Duration.ofSeconds(5))
    .retry(3)
    .block();
```

---

## C#

### HttpClient - GET Request
```csharp
using var client = new HttpClient();
client.Timeout = TimeSpan.FromSeconds(5);
client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

var response = await client.GetAsync("https://api.example.com/users/123");
response.EnsureSuccessStatusCode();

var user = await response.Content.ReadFromJsonAsync<User>();
```

### HttpClient - POST Request
```csharp
using var client = new HttpClient();
client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

var newUser = new { Name = "John", Email = "john@example.com" };
var response = await client.PostAsJsonAsync("https://api.example.com/users", newUser);
response.EnsureSuccessStatusCode();

var user = await response.Content.ReadFromJsonAsync<User>();
```

### Refit - Type-Safe API Client
```csharp
using Refit;

public interface IUserApi
{
    [Get("/users/{id}")]
    Task<User> GetUserAsync(string id);
    
    [Post("/users")]
    Task<User> CreateUserAsync([Body] CreateUserRequest request);
}

var api = RestService.For<IUserApi>("https://api.example.com");
var user = await api.GetUserAsync("123");
```

### Blazor HttpClient (DI)
```csharp
@inject HttpClient Http

@code {
    private User? user;

    protected override async Task OnInitializedAsync()
    {
        user = await Http.GetFromJsonAsync<User>("/api/users/123");
    }
}
```

---

## PHP

### Guzzle - GET Request
```php
use GuzzleHttp\Client;

$client = new Client(['base_uri' => 'https://api.example.com']);

$response = $client->request('GET', '/users/123', [
    'headers' => ['Authorization' => "Bearer $token"],
    'timeout' => 5,
]);

$user = json_decode($response->getBody(), true);
```

### Guzzle - POST Request
```php
$response = $client->request('POST', '/users', [
    'json' => [
        'name' => 'John',
        'email' => 'john@example.com',
    ],
    'headers' => ['Authorization' => "Bearer $token"],
]);

$user = json_decode($response->getBody(), true);
```

### Laravel HTTP - Fluent API
```php
use Illuminate\Support\Facades\Http;

$response = Http::withToken($token)
    ->timeout(5)
    ->retry(3, 1000)
    ->get('https://api.example.com/users/123');

if ($response->successful()) {
    $user = $response->json();
}
```

### Laravel HTTP - POST Request
```php
$response = Http::withToken($token)
    ->post('https://api.example.com/users', [
        'name' => 'John',
        'email' => 'john@example.com',
    ]);

$user = $response->json();
```

### Symfony HttpClient
```php
<?php

use Symfony\Component\HttpClient\HttpClient;

$client = HttpClient::create();
$response = $client->request('GET', 'https://api.example.com/users/123', [
  'headers' => ['Authorization' => "Bearer {$token}"],
]);

$user = $response->toArray();
```

### WordPress HTTP API
```php
<?php

$response = wp_remote_get('https://api.example.com/users/123', [
  'headers' => ['Authorization' => "Bearer {$token}"],
  'timeout' => 5,
]);

$body = wp_remote_retrieve_body($response);
$user = json_decode($body, true);
```

---

## Kotlin

### Retrofit - Interface Definition
```kotlin
import retrofit2.http.*

interface UserApi {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") userId: String): User
    
    @POST("users")
    suspend fun createUser(@Body request: CreateUserRequest): User
}
```

### Retrofit - Usage
```kotlin
val retrofit = Retrofit.Builder()
    .baseUrl("https://api.example.com")
    .addConverterFactory(GsonConverterFactory.create())
    .build()

val api = retrofit.create(UserApi::class.java)

try {
    val user = api.getUser("123")
    println(user)
} catch (e: Exception) {
    println("Error: ${e.message}")
}
```

### Ktor Client - GET Request
```kotlin
import io.ktor.client.*
import io.ktor.client.request.*
import io.ktor.client.statement.*

val client = HttpClient()

val response: HttpResponse = client.get("https://api.example.com/users/123") {
    header("Authorization", "Bearer $token")
    timeout {
        requestTimeoutMillis = 5000
    }
}

val user = response.bodyAsText()
client.close()
```

---

## Swift

### URLSession - GET Request
```swift
let url = URL(string: "https://api.example.com/users/123")!
var request = URLRequest(url: url)
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
request.timeoutInterval = 5

let (data, response) = try await URLSession.shared.data(for: request)

guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200 else {
    throw URLError(.badServerResponse)
}

let user = try JSONDecoder().decode(User.self, from: data)
```

### URLSession - POST Request
```swift
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

let body = ["name": "John", "email": "john@example.com"]
request.httpBody = try JSONEncoder().encode(body)

let (data, _) = try await URLSession.shared.data(for: request)
let user = try JSONDecoder().decode(User.self, from: data)
```

### Alamofire - GET Request
```swift
import Alamofire

AF.request("https://api.example.com/users/123",
           method: .get,
           headers: ["Authorization": "Bearer \(token)"])
    .validate()
    .responseDecodable(of: User.self) { response in
        switch response.result {
        case .success(let user):
            print(user)
        case .failure(let error):
            print("Error: \(error)")
        }
    }
```

### Alamofire - POST Request
```swift
let parameters: [String: Any] = [
    "name": "John",
    "email": "john@example.com"
]

AF.request("https://api.example.com/users",
           method: .post,
           parameters: parameters,
           encoding: JSONEncoding.default,
           headers: ["Authorization": "Bearer \(token)"])
    .responseDecodable(of: User.self) { response in
        print(response.value)
    }
```

### Vapor Client
```swift
import Vapor

func fetchUser(_ req: Request) async throws -> User {
  let response = try await req.client.get("https://api.example.com/users/123")
  return try response.content.decode(User.self)
}
```

---

## Dart

### http - GET Request
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.get(
  Uri.parse('https://api.example.com/users/123'),
  headers: {'Authorization': 'Bearer $token'},
).timeout(Duration(seconds: 5));

if (response.statusCode == 200) {
  final user = jsonDecode(response.body);
  print(user);
}
```

### http - POST Request
```dart
final response = await http.post(
  Uri.parse('https://api.example.com/users'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'name': 'John',
    'email': 'john@example.com',
  }),
);

final user = jsonDecode(response.body);
```

### dio - GET Request
```dart
import 'package:dio/dio.dart';

final dio = Dio();
dio.options.baseUrl = 'https://api.example.com';
dio.options.connectTimeout = Duration(seconds: 5);
dio.options.headers['Authorization'] = 'Bearer $token';

try {
  final response = await dio.get('/users/123');
  final user = response.data;
  print(user);
} on DioException catch (e) {
  print('Error: ${e.message}');
}
```

### dio - Retry Interceptor
```dart
import 'package:dio/dio.dart';

dio.interceptors.add(
  RetryInterceptor(
    dio: dio,
    retries: 3,
    retryDelays: [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  ),
);

final response = await dio.get('/users/123');
```
