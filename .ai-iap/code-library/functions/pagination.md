---
title: Pagination Patterns
category: API Design
difficulty: intermediate
purpose: Efficient data pagination for APIs and database queries
when_to_use:
  - API endpoints returning large datasets
  - Database queries with many results
  - Infinite scroll implementations
  - List views with page navigation
languages:
  typescript:
    - name: Prisma (ORM)
      library: "@prisma/client"
      recommended: true
    - name: TypeORM
      library: typeorm
    - name: Manual SQL
      library: pg / mysql2
  python:
    - name: Django Paginator
      library: django
      recommended: true
    - name: FastAPI + SQLAlchemy
      library: fastapi + sqlalchemy
    - name: Flask-SQLAlchemy
      library: flask-sqlalchemy
  java:
    - name: Spring Data Page
      library: spring-data
      recommended: true
    - name: JPA Criteria API
      library: jakarta.persistence
  csharp:
    - name: Entity Framework Skip/Take
      library: Microsoft.EntityFrameworkCore
      recommended: true
    - name: LINQ
      library: System.Linq
  php:
    - name: Laravel Paginator
      library: laravel/framework
      recommended: true
    - name: Doctrine Paginator
      library: doctrine/orm
  kotlin:
    - name: Spring Data Page
      library: spring-data
      recommended: true
    - name: Exposed
      library: exposed
  swift:
    - name: Fluent (Vapor)
      library: vapor/fluent
      recommended: true
    - name: CoreData NSFetchRequest
      library: CoreData
  dart:
    - name: Shelf Pagination
      library: shelf
      recommended: true
    - name: Manual offset/limit
      library: postgres
common_patterns:
  - Offset pagination (page + size)
  - Cursor-based pagination (for real-time data)
  - Keyset pagination (for performance)
  - Return total count for UI
best_practices:
  do:
    - Limit maximum page size (prevent DoS)
    - Use cursor pagination for real-time data
    - Include total count when needed
    - Use keyset/cursor for large datasets
    - Return pagination metadata (page, size, total)
    - Index database columns used for pagination
  dont:
    - Allow unlimited page sizes
    - Use offset for very large datasets (slow)
    - Forget to validate page/size parameters
    - Skip total count when UI needs it
    - Use offset with frequently changing data
related_functions:
  - database-query.md
  - input-validation.md
tags: [pagination, api-design, database, performance]
updated: 2026-01-20
---

## TypeScript

### Prisma Offset Pagination (Recommended)

```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface PaginationParams {
  page: number;
  size: number;
}

interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    size: number;
    total: number;
    totalPages: number;
  };
}

async function getUsers(params: PaginationParams): Promise<PaginatedResponse<User>> {
  const page = Math.max(1, params.page);
  const size = Math.min(100, Math.max(1, params.size)); // Max 100
  const skip = (page - 1) * size;
  
  const [data, total] = await Promise.all([
    prisma.user.findMany({
      skip,
      take: size,
      orderBy: { createdAt: 'desc' }
    }),
    prisma.user.count()
  ]);
  
  return {
    data,
    pagination: {
      page,
      size,
      total,
      totalPages: Math.ceil(total / size)
    }
  };
}
```

### Cursor-Based Pagination (for real-time data)

```typescript
interface CursorPaginationParams {
  cursor?: string;
  size: number;
}

async function getUsersCursor(params: CursorPaginationParams) {
  const size = Math.min(100, params.size);
  
  const users = await prisma.user.findMany({
    take: size + 1, // Fetch one extra to know if there's more
    ...(params.cursor && {
      cursor: { id: params.cursor },
      skip: 1 // Skip the cursor
    }),
    orderBy: { createdAt: 'desc' }
  });
  
  const hasMore = users.length > size;
  const data = hasMore ? users.slice(0, -1) : users;
  const nextCursor = hasMore ? data[data.length - 1].id : null;
  
  return {
    data,
    pagination: {
      nextCursor,
      hasMore,
      size
    }
  };
}
```

### Express API Route

```typescript
app.get('/users', async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const size = parseInt(req.query.size as string) || 20;
  
  const result = await getUsers({ page, size });
  res.json(result);
});
```

---

## Python

### Django Paginator (Recommended)

```python
from django.core.paginator import Paginator, EmptyPage
from django.http import JsonResponse

def list_users(request):
    page = int(request.GET.get('page', 1))
    size = min(int(request.GET.get('size', 20)), 100)  # Max 100
    
    users = User.objects.all().order_by('-created_at')
    paginator = Paginator(users, size)
    
    try:
        page_obj = paginator.page(page)
    except EmptyPage:
        page_obj = paginator.page(paginator.num_pages)
    
    return JsonResponse({
        'data': list(page_obj.object_list.values()),
        'pagination': {
            'page': page_obj.number,
            'size': size,
            'total': paginator.count,
            'total_pages': paginator.num_pages,
            'has_next': page_obj.has_next(),
            'has_previous': page_obj.has_previous(),
        }
    })
```

### FastAPI + SQLAlchemy

```python
from fastapi import FastAPI, Query
from sqlalchemy.orm import Session
from sqlalchemy import select, func

app = FastAPI()

@app.get("/users")
async def list_users(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    skip = (page - 1) * size
    
    # Parallel queries for data and count
    stmt = select(User).offset(skip).limit(size).order_by(User.created_at.desc())
    count_stmt = select(func.count()).select_from(User)
    
    users = db.execute(stmt).scalars().all()
    total = db.execute(count_stmt).scalar()
    
    return {
        "data": users,
        "pagination": {
            "page": page,
            "size": size,
            "total": total,
            "total_pages": (total + size - 1) // size
        }
    }
```

### Cursor-Based Pagination (FastAPI)

```python
from typing import Optional

@app.get("/users/cursor")
async def list_users_cursor(
    cursor: Optional[str] = None,
    size: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    stmt = select(User).order_by(User.created_at.desc()).limit(size + 1)
    
    if cursor:
        stmt = stmt.where(User.id < cursor)
    
    users = db.execute(stmt).scalars().all()
    
    has_more = len(users) > size
    data = users[:size]
    next_cursor = data[-1].id if has_more else None
    
    return {
        "data": data,
        "pagination": {
            "next_cursor": next_cursor,
            "has_more": has_more,
            "size": size
        }
    }
```

---

## Java

### Spring Data Page (Recommended)

```java
import org.springframework.data.domain.*;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserRepository userRepository;
    
    @GetMapping
    public ResponseEntity<Map<String, Object>> listUsers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        page = Math.max(1, page);
        size = Math.min(100, Math.max(1, size)); // Max 100
        
        Pageable pageable = PageRequest.of(
            page - 1, // Spring uses 0-based
            size,
            Sort.by("createdAt").descending()
        );
        
        Page<User> pageResult = userRepository.findAll(pageable);
        
        return ResponseEntity.ok(Map.of(
            "data", pageResult.getContent(),
            "pagination", Map.of(
                "page", page,
                "size", size,
                "total", pageResult.getTotalElements(),
                "totalPages", pageResult.getTotalPages()
            )
        ));
    }
}
```

### Cursor-Based with Spring Data

```java
@GetMapping("/cursor")
public ResponseEntity<Map<String, Object>> listUsersCursor(
        @RequestParam(required = false) String cursor,
        @RequestParam(defaultValue = "20") int size) {
    
    size = Math.min(100, size);
    
    Pageable pageable = PageRequest.of(0, size + 1, 
                                       Sort.by("createdAt").descending());
    
    List<User> users;
    if (cursor != null) {
        users = userRepository.findByCursorAfter(cursor, pageable);
    } else {
        users = userRepository.findAll(pageable).getContent();
    }
    
    boolean hasMore = users.size() > size;
    List<User> data = hasMore ? users.subList(0, size) : users;
    String nextCursor = hasMore ? data.get(size - 1).getId() : null;
    
    return ResponseEntity.ok(Map.of(
        "data", data,
        "pagination", Map.of(
            "nextCursor", nextCursor,
            "hasMore", hasMore,
            "size", size
        )
    ));
}
```

---

## C#

### Entity Framework Skip/Take (Recommended)

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/users")]
public class UserController : ControllerBase
{
    private readonly AppDbContext _context;
    
    public UserController(AppDbContext context)
    {
        _context = context;
    }
    
    [HttpGet]
    public async Task<ActionResult<PaginatedResponse<User>>> GetUsers(
        [FromQuery] int page = 1,
        [FromQuery] int size = 20)
    {
        page = Math.Max(1, page);
        size = Math.Min(100, Math.Max(1, size)); // Max 100
        
        var skip = (page - 1) * size;
        
        var query = _context.Users.OrderByDescending(u => u.CreatedAt);
        
        var total = await query.CountAsync();
        var data = await query.Skip(skip).Take(size).ToListAsync();
        
        return Ok(new PaginatedResponse<User>
        {
            Data = data,
            Pagination = new PaginationMeta
            {
                Page = page,
                Size = size,
                Total = total,
                TotalPages = (int)Math.Ceiling((double)total / size)
            }
        });
    }
}

public class PaginatedResponse<T>
{
    public List<T> Data { get; set; }
    public PaginationMeta Pagination { get; set; }
}

public class PaginationMeta
{
    public int Page { get; set; }
    public int Size { get; set; }
    public int Total { get; set; }
    public int TotalPages { get; set; }
}
```

### Cursor-Based Pagination

```csharp
[HttpGet("cursor")]
public async Task<ActionResult<CursorPaginatedResponse<User>>> GetUsersCursor(
    [FromQuery] string cursor = null,
    [FromQuery] int size = 20)
{
    size = Math.Min(100, size);
    
    var query = _context.Users.OrderByDescending(u => u.CreatedAt);
    
    if (!string.IsNullOrEmpty(cursor))
    {
        query = query.Where(u => string.Compare(u.Id, cursor) < 0);
    }
    
    var users = await query.Take(size + 1).ToListAsync();
    
    var hasMore = users.Count > size;
    var data = hasMore ? users.Take(size).ToList() : users;
    var nextCursor = hasMore ? data.Last().Id : null;
    
    return Ok(new CursorPaginatedResponse<User>
    {
        Data = data,
        Pagination = new CursorPaginationMeta
        {
            NextCursor = nextCursor,
            HasMore = hasMore,
            Size = size
        }
    });
}
```

---

## PHP

### Laravel Paginator (Recommended)

```php
<?php

use Illuminate\Http\Request;
use App\Models\User;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $page = max(1, (int) $request->query('page', 1));
        $size = min(100, max(1, (int) $request->query('size', 20)));
        
        $users = User::orderByDesc('created_at')
            ->paginate($size, ['*'], 'page', $page);
        
        return response()->json([
            'data' => $users->items(),
            'pagination' => [
                'page' => $users->currentPage(),
                'size' => $users->perPage(),
                'total' => $users->total(),
                'total_pages' => $users->lastPage(),
            ],
        ]);
    }
}
```

### Laravel Cursor Pagination

```php
<?php

public function cursorPaginate(Request $request)
{
    $size = min(100, (int) $request->query('size', 20));
    $cursor = $request->query('cursor');
    
    $query = User::orderByDesc('created_at');
    
    if ($cursor) {
        $query->where('id', '<', $cursor);
    }
    
    $users = $query->limit($size + 1)->get();
    
    $hasMore = $users->count() > $size;
    $data = $hasMore ? $users->take($size) : $users;
    $nextCursor = $hasMore ? $data->last()->id : null;
    
    return response()->json([
        'data' => $data,
        'pagination' => [
            'next_cursor' => $nextCursor,
            'has_more' => $hasMore,
            'size' => $size,
        ],
    ]);
}
```

---

## Kotlin

### Spring Data Page (Recommended)

```kotlin
import org.springframework.data.domain.*
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/users")
class UserController(private val userRepository: UserRepository) {
    
    @GetMapping
    fun listUsers(
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): PaginatedResponse<User> {
        val validPage = page.coerceAtLeast(1)
        val validSize = size.coerceIn(1, 100) // Max 100
        
        val pageable = PageRequest.of(
            validPage - 1, // Spring uses 0-based
            validSize,
            Sort.by("createdAt").descending()
        )
        
        val pageResult = userRepository.findAll(pageable)
        
        return PaginatedResponse(
            data = pageResult.content,
            pagination = PaginationMeta(
                page = validPage,
                size = validSize,
                total = pageResult.totalElements,
                totalPages = pageResult.totalPages
            )
        )
    }
}

data class PaginatedResponse<T>(
    val data: List<T>,
    val pagination: PaginationMeta
)

data class PaginationMeta(
    val page: Int,
    val size: Int,
    val total: Long,
    val totalPages: Int
)
```

---

## Swift

### Fluent (Vapor) - Recommended

```swift
import Vapor
import Fluent

func routes(_ app: Application) throws {
    app.get("users") { req async throws -> PaginatedResponse<User> in
        let page = req.query[Int.self, at: "page"] ?? 1
        let size = min(100, max(1, req.query[Int.self, at: "size"] ?? 20))
        
        let pageRequest = PageRequest(page: page, per: size)
        let pageResult = try await User.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .paginate(pageRequest)
        
        return PaginatedResponse(
            data: pageResult.items,
            pagination: PaginationMeta(
                page: page,
                size: size,
                total: pageResult.metadata.total,
                totalPages: pageResult.metadata.pageCount
            )
        )
    }
}

struct PaginatedResponse<T: Content>: Content {
    let data: [T]
    let pagination: PaginationMeta
}

struct PaginationMeta: Content {
    let page: Int
    let size: Int
    let total: Int
    let totalPages: Int
}
```

---

## Dart

### Shelf Pagination (Recommended)

```dart
import 'package:shelf/shelf.dart';
import 'package:postgres/postgres.dart';

Future<Response> listUsers(Request request) async {
  final params = request.url.queryParameters;
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final size = (int.tryParse(params['size'] ?? '20') ?? 20).clamp(1, 100);
  
  final offset = (page - 1) * size;
  
  final connection = await PostgreSQLConnection(...).open();
  
  // Get data and count in parallel
  final results = await Future.wait([
    connection.query(
      'SELECT * FROM users ORDER BY created_at DESC LIMIT @limit OFFSET @offset',
      substitutionValues: {'limit': size, 'offset': offset},
    ),
    connection.query('SELECT COUNT(*) FROM users'),
  ]);
  
  await connection.close();
  
  final data = results[0].map((row) => row.toColumnMap()).toList();
  final total = results[1].first[0] as int;
  final totalPages = (total / size).ceil();
  
  return Response.ok(
    json.encode({
      'data': data,
      'pagination': {
        'page': page,
        'size': size,
        'total': total,
        'total_pages': totalPages,
      },
    }),
    headers: {'content-type': 'application/json'},
  );
}
```

### Cursor-Based Pagination (Dart)

```dart
Future<Response> listUsersCursor(Request request) async {
  final params = request.url.queryParameters;
  final cursor = params['cursor'];
  final size = (int.tryParse(params['size'] ?? '20') ?? 20).clamp(1, 100);
  
  final connection = await PostgreSQLConnection(...).open();
  
  String query = 'SELECT * FROM users';
  Map<String, dynamic> values = {'limit': size + 1};
  
  if (cursor != null) {
    query += ' WHERE id < @cursor';
    values['cursor'] = cursor;
  }
  
  query += ' ORDER BY created_at DESC LIMIT @limit';
  
  final results = await connection.query(query, substitutionValues: values);
  await connection.close();
  
  final users = results.map((row) => row.toColumnMap()).toList();
  final hasMore = users.length > size;
  final data = hasMore ? users.sublist(0, size) : users;
  final nextCursor = hasMore ? data.last['id'] : null;
  
  return Response.ok(
    json.encode({
      'data': data,
      'pagination': {
        'next_cursor': nextCursor,
        'has_more': hasMore,
        'size': size,
      },
    }),
    headers: {'content-type': 'application/json'},
  );
}
```
