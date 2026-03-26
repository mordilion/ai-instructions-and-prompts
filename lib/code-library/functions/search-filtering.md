---
title: Search & Filtering Patterns
category: Data Retrieval
difficulty: intermediate
purpose: Build dynamic queries, full-text search, and advanced filtering
when_to_use:
  - Search functionality in applications
  - Advanced filtering in list views
  - E-commerce product search
  - Full-text search across content
  - Dynamic query building from user input
languages:
  typescript:
    - name: Prisma (ORM)
      library: "@prisma/client"
      recommended: true
    - name: TypeORM QueryBuilder
      library: typeorm
    - name: Elasticsearch
      library: "@elastic/elasticsearch"
  python:
    - name: Django Q objects
      library: django
      recommended: true
    - name: SQLAlchemy filters
      library: sqlalchemy
    - name: Elasticsearch DSL
      library: elasticsearch-dsl
  java:
    - name: Spring Data Specifications
      library: spring-data-jpa
      recommended: true
    - name: Hibernate Criteria API
      library: hibernate
    - name: Elasticsearch Java Client
      library: elasticsearch-java
  csharp:
    - name: Entity Framework LINQ
      library: Microsoft.EntityFrameworkCore
      recommended: true
    - name: Dynamic LINQ
      library: System.Linq.Dynamic.Core
  php:
    - name: Laravel Query Builder
      library: laravel/framework
      recommended: true
    - name: Doctrine QueryBuilder
      library: doctrine/orm
    - name: Laravel Scout (full-text)
      library: laravel/scout
  kotlin:
    - name: Spring Data Specifications
      library: spring-data-jpa
      recommended: true
    - name: Exposed DSL
      library: exposed
  swift:
    - name: Fluent QueryBuilder (Vapor)
      library: vapor/fluent
      recommended: true
    - name: CoreData NSPredicate
      library: CoreData
  dart:
    - name: Manual query building
      library: postgres
      recommended: true
    - name: Drift (SQL builder)
      library: drift
common_patterns:
  - Dynamic AND/OR conditions
  - Full-text search with ranking
  - Range filters (dates, prices)
  - Multi-field search
  - Fuzzy matching
best_practices:
  do:
    - Use parameterized queries (prevent SQL injection)
    - Index searchable columns
    - Limit search result count
    - Use full-text indexes for text search
    - Sanitize user input
    - Provide search suggestions/autocomplete
    - Use Elasticsearch for complex search needs
  dont:
    - Concatenate user input into SQL strings
    - Search without indexes on large tables
    - Return unlimited results
    - Use LIKE '%term%' on large datasets (slow)
    - Skip input validation
related_functions:
  - database-query.md
  - input-validation.md
  - pagination.md
tags: [search, filtering, query-building, full-text-search, elasticsearch]
updated: 2026-01-20
---

## TypeScript

### Prisma Dynamic Filtering (Recommended)

```typescript
import { Prisma, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface ProductFilters {
  search?: string;
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  inStock?: boolean;
}

async function searchProducts(filters: ProductFilters) {
  const where: Prisma.ProductWhereInput = {};
  
  // Text search across multiple fields
  if (filters.search) {
    where.OR = [
      { name: { contains: filters.search, mode: 'insensitive' } },
      { description: { contains: filters.search, mode: 'insensitive' } }
    ];
  }
  
  // Category filter
  if (filters.category) {
    where.category = filters.category;
  }
  
  // Price range
  if (filters.minPrice || filters.maxPrice) {
    where.price = {};
    if (filters.minPrice) where.price.gte = filters.minPrice;
    if (filters.maxPrice) where.price.lte = filters.maxPrice;
  }
  
  // Stock status
  if (filters.inStock !== undefined) {
    where.inStock = filters.inStock;
  }
  
  const products = await prisma.product.findMany({
    where,
    take: 50,
    orderBy: { createdAt: 'desc' }
  });
  
  return products;
}

// Full-text search (if using PostgreSQL)
async function fullTextSearch(query: string) {
  const products = await prisma.$queryRaw`
    SELECT * FROM "Product"
    WHERE to_tsvector('english', name || ' ' || description) 
    @@ plainto_tsquery('english', ${query})
    ORDER BY ts_rank(to_tsvector('english', name || ' ' || description), 
                     plainto_tsquery('english', ${query})) DESC
    LIMIT 50
  `;
  
  return products;
}
```

### Elasticsearch Integration

```typescript
import { Client } from '@elastic/elasticsearch';

const esClient = new Client({ node: 'http://localhost:9200' });

async function searchElastic(query: string, filters: any) {
  const { body } = await esClient.search({
    index: 'products',
    body: {
      query: {
        bool: {
          must: [
            {
              multi_match: {
                query,
                fields: ['name^2', 'description'], // Boost name field
                fuzziness: 'AUTO'
              }
            }
          ],
          filter: [
            ...(filters.category ? [{ term: { category: filters.category } }] : []),
            ...(filters.minPrice || filters.maxPrice ? [{
              range: {
                price: {
                  ...(filters.minPrice && { gte: filters.minPrice }),
                  ...(filters.maxPrice && { lte: filters.maxPrice })
                }
              }
            }] : [])
          ]
        }
      },
      size: 50
    }
  });
  
  return body.hits.hits.map(hit => hit._source);
}
```

---

## Python

### Django Q Objects (Recommended)

```python
from django.db.models import Q
from django.core.paginator import Paginator

def search_products(search=None, category=None, min_price=None, max_price=None, in_stock=None):
    queryset = Product.objects.all()
    
    # Text search
    if search:
        queryset = queryset.filter(
            Q(name__icontains=search) | Q(description__icontains=search)
        )
    
    # Category filter
    if category:
        queryset = queryset.filter(category=category)
    
    # Price range
    if min_price is not None:
        queryset = queryset.filter(price__gte=min_price)
    if max_price is not None:
        queryset = queryset.filter(price__lte=max_price)
    
    # Stock status
    if in_stock is not None:
        queryset = queryset.filter(in_stock=in_stock)
    
    return queryset.order_by('-created_at')[:50]

# Full-text search (PostgreSQL)
from django.contrib.postgres.search import SearchVector, SearchQuery, SearchRank

def full_text_search(query: str):
    search_vector = SearchVector('name', weight='A') + SearchVector('description', weight='B')
    search_query = SearchQuery(query)
    
    results = Product.objects.annotate(
        rank=SearchRank(search_vector, search_query)
    ).filter(rank__gte=0.1).order_by('-rank')[:50]
    
    return results
```

### SQLAlchemy Dynamic Filters

```python
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import Session

def search_products_sqlalchemy(
    db: Session,
    search: str = None,
    category: str = None,
    min_price: float = None,
    max_price: float = None
):
    stmt = select(Product)
    filters = []
    
    # Text search
    if search:
        filters.append(
            or_(
                Product.name.ilike(f'%{search}%'),
                Product.description.ilike(f'%{search}%')
            )
        )
    
    # Category
    if category:
        filters.append(Product.category == category)
    
    # Price range
    if min_price is not None:
        filters.append(Product.price >= min_price)
    if max_price is not None:
        filters.append(Product.price <= max_price)
    
    if filters:
        stmt = stmt.where(and_(*filters))
    
    stmt = stmt.order_by(Product.created_at.desc()).limit(50)
    
    return db.execute(stmt).scalars().all()
```

---

## Java

### Spring Data Specifications (Recommended)

```java
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ProductRepository extends JpaRepository<Product, Long>, 
                                           JpaSpecificationExecutor<Product> {}

@Service
public class ProductSearchService {
    
    @Autowired
    private ProductRepository productRepository;
    
    public List<Product> searchProducts(
            String search, String category, Double minPrice, Double maxPrice) {
        
        Specification<Product> spec = Specification.where(null);
        
        // Text search
        if (search != null && !search.isEmpty()) {
            spec = spec.and((root, query, cb) -> 
                cb.or(
                    cb.like(cb.lower(root.get("name")), "%" + search.toLowerCase() + "%"),
                    cb.like(cb.lower(root.get("description")), "%" + search.toLowerCase() + "%")
                )
            );
        }
        
        // Category filter
        if (category != null) {
            spec = spec.and((root, query, cb) -> 
                cb.equal(root.get("category"), category)
            );
        }
        
        // Price range
        if (minPrice != null) {
            spec = spec.and((root, query, cb) -> 
                cb.greaterThanOrEqualTo(root.get("price"), minPrice)
            );
        }
        if (maxPrice != null) {
            spec = spec.and((root, query, cb) -> 
                cb.lessThanOrEqualTo(root.get("price"), maxPrice)
            );
        }
        
        return productRepository.findAll(spec, 
                PageRequest.of(0, 50, Sort.by("createdAt").descending()))
            .getContent();
    }
}
```

### Hibernate Criteria API

```java
import javax.persistence.criteria.*;

public List<Product> searchWithCriteria(
        EntityManager em, String search, String category, 
        Double minPrice, Double maxPrice) {
    
    CriteriaBuilder cb = em.getCriteriaBuilder();
    CriteriaQuery<Product> cq = cb.createQuery(Product.class);
    Root<Product> product = cq.from(Product.class);
    
    List<Predicate> predicates = new ArrayList<>();
    
    // Text search
    if (search != null && !search.isEmpty()) {
        predicates.add(cb.or(
            cb.like(cb.lower(product.get("name")), "%" + search.toLowerCase() + "%"),
            cb.like(cb.lower(product.get("description")), "%" + search.toLowerCase() + "%")
        ));
    }
    
    // Category
    if (category != null) {
        predicates.add(cb.equal(product.get("category"), category));
    }
    
    // Price range
    if (minPrice != null) {
        predicates.add(cb.ge(product.get("price"), minPrice));
    }
    if (maxPrice != null) {
        predicates.add(cb.le(product.get("price"), maxPrice));
    }
    
    cq.where(predicates.toArray(new Predicate[0]));
    cq.orderBy(cb.desc(product.get("createdAt")));
    
    return em.createQuery(cq)
             .setMaxResults(50)
             .getResultList();
}
```

---

## C#

### Entity Framework LINQ (Recommended)

```csharp
using Microsoft.EntityFrameworkCore;

public class ProductSearchService
{
    private readonly AppDbContext _context;
    
    public ProductSearchService(AppDbContext context)
    {
        _context = context;
    }
    
    public async Task<List<Product>> SearchProducts(
        string search = null,
        string category = null,
        decimal? minPrice = null,
        decimal? maxPrice = null,
        bool? inStock = null)
    {
        var query = _context.Products.AsQueryable();
        
        // Text search
        if (!string.IsNullOrEmpty(search))
        {
            var searchLower = search.ToLower();
            query = query.Where(p => 
                p.Name.ToLower().Contains(searchLower) || 
                p.Description.ToLower().Contains(searchLower));
        }
        
        // Category filter
        if (!string.IsNullOrEmpty(category))
        {
            query = query.Where(p => p.Category == category);
        }
        
        // Price range
        if (minPrice.HasValue)
        {
            query = query.Where(p => p.Price >= minPrice.Value);
        }
        if (maxPrice.HasValue)
        {
            query = query.Where(p => p.Price <= maxPrice.Value);
        }
        
        // Stock status
        if (inStock.HasValue)
        {
            query = query.Where(p => p.InStock == inStock.Value);
        }
        
        return await query
            .OrderByDescending(p => p.CreatedAt)
            .Take(50)
            .ToListAsync();
    }
}
```

### Full-Text Search (SQL Server)

```csharp
public async Task<List<Product>> FullTextSearch(string search)
{
    var sql = @"
        SELECT * FROM Products
        WHERE CONTAINS((Name, Description), @search)
        ORDER BY [RANK] DESC
    ";
    
    return await _context.Products
        .FromSqlRaw(sql, new SqlParameter("@search", search))
        .Take(50)
        .ToListAsync();
}
```

---

## PHP

### Laravel Query Builder (Recommended)

```php
<?php

use Illuminate\Http\Request;
use App\Models\Product;

public function search(Request $request)
{
    $query = Product::query();
    
    // Text search
    if ($search = $request->query('search')) {
        $query->where(function ($q) use ($search) {
            $q->where('name', 'LIKE', "%{$search}%")
              ->orWhere('description', 'LIKE', "%{$search}%");
        });
    }
    
    // Category filter
    if ($category = $request->query('category')) {
        $query->where('category', $category);
    }
    
    // Price range
    if ($minPrice = $request->query('min_price')) {
        $query->where('price', '>=', $minPrice);
    }
    if ($maxPrice = $request->query('max_price')) {
        $query->where('price', '<=', $maxPrice);
    }
    
    // Stock status
    if ($request->has('in_stock')) {
        $query->where('in_stock', (bool) $request->query('in_stock'));
    }
    
    return $query->orderByDesc('created_at')
                 ->limit(50)
                 ->get();
}
```

### Laravel Scout (Full-Text Search)

```php
<?php

use Laravel\Scout\Searchable;

class Product extends Model
{
    use Searchable;
    
    public function toSearchableArray()
    {
        return [
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'price' => $this->price,
        ];
    }
}

// Search with Scout
$products = Product::search($query)
    ->where('category', $category)
    ->where('price', '>=', $minPrice)
    ->take(50)
    ->get();
```

---

## Kotlin

### Spring Data Specifications (Recommended)

```kotlin
import org.springframework.data.jpa.domain.Specification

@Service
class ProductSearchService(private val productRepository: ProductRepository) {
    
    fun searchProducts(
        search: String?,
        category: String?,
        minPrice: Double?,
        maxPrice: Double?
    ): List<Product> {
        var spec = Specification.where<Product>(null)
        
        // Text search
        if (!search.isNullOrBlank()) {
            spec = spec.and { root, query, cb ->
                cb.or(
                    cb.like(cb.lower(root.get("name")), "%${search.lowercase()}%"),
                    cb.like(cb.lower(root.get("description")), "%${search.lowercase()}%")
                )
            }
        }
        
        // Category
        if (category != null) {
            spec = spec.and { root, _, cb ->
                cb.equal(root.get<String>("category"), category)
            }
        }
        
        // Price range
        if (minPrice != null) {
            spec = spec.and { root, _, cb ->
                cb.ge(root.get("price"), minPrice)
            }
        }
        if (maxPrice != null) {
            spec = spec.and { root, _, cb ->
                cb.le(root.get("price"), maxPrice)
            }
        }
        
        return productRepository.findAll(
            spec,
            PageRequest.of(0, 50, Sort.by("createdAt").descending())
        ).content
    }
}
```

---

## Swift

### Fluent QueryBuilder (Vapor) - Recommended

```swift
import Vapor
import Fluent

func searchProducts(req: Request) async throws -> [Product] {
    var query = Product.query(on: req.db)
    
    // Text search
    if let search = req.query[String.self, at: "search"] {
        query = query.group(.or) { group in
            group.filter(\.$name, .custom("ILIKE"), "%\(search)%")
            group.filter(\.$description, .custom("ILIKE"), "%\(search)%")
        }
    }
    
    // Category
    if let category = req.query[String.self, at: "category"] {
        query = query.filter(\.$category == category)
    }
    
    // Price range
    if let minPrice = req.query[Double.self, at: "min_price"] {
        query = query.filter(\.$price >= minPrice)
    }
    if let maxPrice = req.query[Double.self, at: "max_price"] {
        query = query.filter(\.$price <= maxPrice)
    }
    
    // Stock status
    if let inStock = req.query[Bool.self, at: "in_stock"] {
        query = query.filter(\.$inStock == inStock)
    }
    
    return try await query
        .sort(\.$createdAt, .descending)
        .limit(50)
        .all()
}
```

---

## Dart

### Manual Query Building (Recommended)

```dart
import 'package:postgres/postgres.dart';

class ProductSearchService {
  final PostgreSQLConnection _connection;
  
  ProductSearchService(this._connection);
  
  Future<List<Map<String, dynamic>>> searchProducts({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
  }) async {
    final conditions = <String>[];
    final values = <String, dynamic>{};
    
    // Text search
    if (search != null && search.isNotEmpty) {
      conditions.add('(name ILIKE @search OR description ILIKE @search)');
      values['search'] = '%$search%';
    }
    
    // Category
    if (category != null) {
      conditions.add('category = @category');
      values['category'] = category;
    }
    
    // Price range
    if (minPrice != null) {
      conditions.add('price >= @min_price');
      values['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      conditions.add('price <= @max_price');
      values['max_price'] = maxPrice;
    }
    
    // Stock status
    if (inStock != null) {
      conditions.add('in_stock = @in_stock');
      values['in_stock'] = inStock;
    }
    
    final whereClause = conditions.isEmpty 
        ? '' 
        : 'WHERE ${conditions.join(' AND ')}';
    
    final query = '''
      SELECT * FROM products
      $whereClause
      ORDER BY created_at DESC
      LIMIT 50
    ''';
    
    final results = await _connection.query(
      query,
      substitutionValues: values,
    );
    
    return results.map((row) => row.toColumnMap()).toList();
  }
}
```

### Full-Text Search (PostgreSQL)

```dart
Future<List<Map<String, dynamic>>> fullTextSearch(String query) async {
  final sql = '''
    SELECT * FROM products
    WHERE to_tsvector('english', name || ' ' || description) 
    @@ plainto_tsquery('english', @query)
    ORDER BY ts_rank(
      to_tsvector('english', name || ' ' || description),
      plainto_tsquery('english', @query)
    ) DESC
    LIMIT 50
  ''';
  
  final results = await _connection.query(
    sql,
    substitutionValues: {'query': query},
  );
  
  return results.map((row) => row.toColumnMap()).toList();
}
```
