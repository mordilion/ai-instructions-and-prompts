---
title: Builder Pattern
category: Creational Design Pattern
difficulty: intermediate
purpose: Construct complex objects step by step, separating construction from representation
when_to_use:
  - Creating objects with many optional parameters
  - Building complex configurations
  - Constructing composite objects
  - Query builders (SQL, API filters)
  - Document builders (HTML, PDF, XML)
  - Test data builders
languages:
  typescript:
    - name: Method Chaining Builder (Built-in)
      library: javascript-core
      recommended: true
    - name: Fluent Builder (Built-in)
      library: javascript-core
  python:
    - name: Method Chaining Builder (Built-in)
      library: python-core
      recommended: true
    - name: Dataclass Builder (Built-in)
      library: python-core
  java:
    - name: Method Chaining Builder (Built-in)
      library: java-core
      recommended: true
    - name: Lombok @Builder
      library: org.projectlombok:lombok
  csharp:
    - name: Fluent Builder (Built-in)
      library: dotnet-core
      recommended: true
    - name: Init-only Properties (Built-in)
      library: dotnet-core
  php:
    - name: Method Chaining Builder (Built-in)
      library: php-core
      recommended: true
  kotlin:
    - name: Apply/Also Builder (Built-in)
      library: kotlin-stdlib
      recommended: true
    - name: DSL Builder (Built-in)
      library: kotlin-stdlib
  swift:
    - name: Method Chaining Builder (Built-in)
      library: swift-stdlib
      recommended: true
    - name: Result Builder (Built-in)
      library: swift-stdlib
  dart:
    - name: Cascade Notation Builder (Built-in)
      library: dart-core
      recommended: true
    - name: Method Chaining Builder (Built-in)
      library: dart-core
common_patterns:
  - Fluent interface with method chaining
  - Separate builder from product
  - Director class for complex builds
  - Reset method to reuse builder
  - Build validation
best_practices:
  do:
    - Use for objects with 4+ optional parameters
    - Validate in build() method
    - Make builder immutable or provide reset()
    - Return builder from each method for chaining
    - Consider default values for common configurations
  dont:
    - Use for simple objects (use constructor or named parameters)
    - Forget validation in build()
    - Make builder mutable without reset capability
    - Create builder for objects that rarely change
related_functions:
  - input-validation.md
  - database-query.md
tags: [builder, creational-pattern, fluent-interface, method-chaining]
updated: 2026-01-20
---

## TypeScript

### Method Chaining Builder
```typescript
class User {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly email: string,
    public readonly age?: number,
    public readonly phone?: string,
    public readonly address?: string,
    public readonly isActive: boolean = true
  ) {}
}

class UserBuilder {
  private id?: string;
  private name?: string;
  private email?: string;
  private age?: number;
  private phone?: string;
  private address?: string;
  private isActive: boolean = true;

  setId(id: string): this {
    this.id = id;
    return this;
  }

  setName(name: string): this {
    this.name = name;
    return this;
  }

  setEmail(email: string): this {
    this.email = email;
    return this;
  }

  setAge(age: number): this {
    this.age = age;
    return this;
  }

  setPhone(phone: string): this {
    this.phone = phone;
    return this;
  }

  setAddress(address: string): this {
    this.address = address;
    return this;
  }

  setIsActive(isActive: boolean): this {
    this.isActive = isActive;
    return this;
  }

  build(): User {
    if (!this.id || !this.name || !this.email) {
      throw new Error('id, name, and email are required');
    }
    return new User(
      this.id,
      this.name,
      this.email,
      this.age,
      this.phone,
      this.address,
      this.isActive
    );
  }

  reset(): this {
    this.id = undefined;
    this.name = undefined;
    this.email = undefined;
    this.age = undefined;
    this.phone = undefined;
    this.address = undefined;
    this.isActive = true;
    return this;
  }
}

// Usage
const user = new UserBuilder()
  .setId('123')
  .setName('John Doe')
  .setEmail('john@example.com')
  .setAge(30)
  .setPhone('+1234567890')
  .build();
```

### Query Builder Example
```typescript
class QueryBuilder {
  private table?: string;
  private selectFields: string[] = ['*'];
  private whereConditions: string[] = [];
  private orderByField?: string;
  private limitValue?: number;

  from(table: string): this {
    this.table = table;
    return this;
  }

  select(...fields: string[]): this {
    this.selectFields = fields;
    return this;
  }

  where(condition: string): this {
    this.whereConditions.push(condition);
    return this;
  }

  orderBy(field: string): this {
    this.orderByField = field;
    return this;
  }

  limit(value: number): this {
    this.limitValue = value;
    return this;
  }

  build(): string {
    if (!this.table) throw new Error('Table is required');

    let query = `SELECT ${this.selectFields.join(', ')} FROM ${this.table}`;
    
    if (this.whereConditions.length > 0) {
      query += ` WHERE ${this.whereConditions.join(' AND ')}`;
    }
    
    if (this.orderByField) {
      query += ` ORDER BY ${this.orderByField}`;
    }
    
    if (this.limitValue) {
      query += ` LIMIT ${this.limitValue}`;
    }
    
    return query;
  }
}

// Usage
const query = new QueryBuilder()
  .from('users')
  .select('id', 'name', 'email')
  .where('age > 18')
  .where('is_active = true')
  .orderBy('created_at')
  .limit(10)
  .build();
```

---

## Python

### Method Chaining Builder
```python
from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class User:
    id: str
    name: str
    email: str
    age: Optional[int] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    is_active: bool = True

class UserBuilder:
    def __init__(self):
        self._id: Optional[str] = None
        self._name: Optional[str] = None
        self._email: Optional[str] = None
        self._age: Optional[int] = None
        self._phone: Optional[str] = None
        self._address: Optional[str] = None
        self._is_active: bool = True

    def set_id(self, id: str) -> 'UserBuilder':
        self._id = id
        return self

    def set_name(self, name: str) -> 'UserBuilder':
        self._name = name
        return self

    def set_email(self, email: str) -> 'UserBuilder':
        self._email = email
        return self

    def set_age(self, age: int) -> 'UserBuilder':
        self._age = age
        return self

    def set_phone(self, phone: str) -> 'UserBuilder':
        self._phone = phone
        return self

    def set_address(self, address: str) -> 'UserBuilder':
        self._address = address
        return self

    def set_is_active(self, is_active: bool) -> 'UserBuilder':
        self._is_active = is_active
        return self

    def build(self) -> User:
        if not self._id or not self._name or not self._email:
            raise ValueError("id, name, and email are required")
        
        return User(
            id=self._id,
            name=self._name,
            email=self._email,
            age=self._age,
            phone=self._phone,
            address=self._address,
            is_active=self._is_active
        )

    def reset(self) -> 'UserBuilder':
        self.__init__()
        return self

# Usage
user = (UserBuilder()
    .set_id("123")
    .set_name("John Doe")
    .set_email("john@example.com")
    .set_age(30)
    .set_phone("+1234567890")
    .build())
```

### Context Manager Builder
```python
class QueryBuilder:
    def __init__(self):
        self._table: Optional[str] = None
        self._select_fields: list[str] = ["*"]
        self._where_conditions: list[str] = []
        self._order_by_field: Optional[str] = None
        self._limit_value: Optional[int] = None

    def from_(self, table: str) -> 'QueryBuilder':
        self._table = table
        return self

    def select(self, *fields: str) -> 'QueryBuilder':
        self._select_fields = list(fields)
        return self

    def where(self, condition: str) -> 'QueryBuilder':
        self._where_conditions.append(condition)
        return self

    def order_by(self, field: str) -> 'QueryBuilder':
        self._order_by_field = field
        return self

    def limit(self, value: int) -> 'QueryBuilder':
        self._limit_value = value
        return self

    def build(self) -> str:
        if not self._table:
            raise ValueError("Table is required")

        query = f"SELECT {', '.join(self._select_fields)} FROM {self._table}"
        
        if self._where_conditions:
            query += f" WHERE {' AND '.join(self._where_conditions)}"
        
        if self._order_by_field:
            query += f" ORDER BY {self._order_by_field}"
        
        if self._limit_value:
            query += f" LIMIT {self._limit_value}"
        
        return query

# Usage
query = (QueryBuilder()
    .from_("users")
    .select("id", "name", "email")
    .where("age > 18")
    .where("is_active = true")
    .order_by("created_at")
    .limit(10)
    .build())
```

---

## Java

### Method Chaining Builder
```java
public class User {
    private final String id;
    private final String name;
    private final String email;
    private final Integer age;
    private final String phone;
    private final String address;
    private final boolean isActive;

    private User(Builder builder) {
        this.id = builder.id;
        this.name = builder.name;
        this.email = builder.email;
        this.age = builder.age;
        this.phone = builder.phone;
        this.address = builder.address;
        this.isActive = builder.isActive;
    }

    public static class Builder {
        private String id;
        private String name;
        private String email;
        private Integer age;
        private String phone;
        private String address;
        private boolean isActive = true;

        public Builder setId(String id) {
            this.id = id;
            return this;
        }

        public Builder setName(String name) {
            this.name = name;
            return this;
        }

        public Builder setEmail(String email) {
            this.email = email;
            return this;
        }

        public Builder setAge(Integer age) {
            this.age = age;
            return this;
        }

        public Builder setPhone(String phone) {
            this.phone = phone;
            return this;
        }

        public Builder setAddress(String address) {
            this.address = address;
            return this;
        }

        public Builder setIsActive(boolean isActive) {
            this.isActive = isActive;
            return this;
        }

        public User build() {
            if (id == null || name == null || email == null) {
                throw new IllegalStateException("id, name, and email are required");
            }
            return new User(this);
        }
    }

    // Getters
    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
}

// Usage
User user = new User.Builder()
    .setId("123")
    .setName("John Doe")
    .setEmail("john@example.com")
    .setAge(30)
    .setPhone("+1234567890")
    .build();
```

### Lombok @Builder
```java
import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class User {
    String id;
    String name;
    String email;
    Integer age;
    String phone;
    String address;
    @Builder.Default
    boolean isActive = true;
}

// Usage
User user = User.builder()
    .id("123")
    .name("John Doe")
    .email("john@example.com")
    .age(30)
    .phone("+1234567890")
    .build();
```

---

## C#

### Fluent Builder
```csharp
public class User
{
    public string Id { get; }
    public string Name { get; }
    public string Email { get; }
    public int? Age { get; }
    public string? Phone { get; }
    public string? Address { get; }
    public bool IsActive { get; }

    private User(Builder builder)
    {
        Id = builder.Id ?? throw new ArgumentNullException(nameof(Id));
        Name = builder.Name ?? throw new ArgumentNullException(nameof(Name));
        Email = builder.Email ?? throw new ArgumentNullException(nameof(Email));
        Age = builder.Age;
        Phone = builder.Phone;
        Address = builder.Address;
        IsActive = builder.IsActive;
    }

    public class Builder
    {
        public string? Id { get; private set; }
        public string? Name { get; private set; }
        public string? Email { get; private set; }
        public int? Age { get; private set; }
        public string? Phone { get; private set; }
        public string? Address { get; private set; }
        public bool IsActive { get; private set; } = true;

        public Builder SetId(string id)
        {
            Id = id;
            return this;
        }

        public Builder SetName(string name)
        {
            Name = name;
            return this;
        }

        public Builder SetEmail(string email)
        {
            Email = email;
            return this;
        }

        public Builder SetAge(int age)
        {
            Age = age;
            return this;
        }

        public Builder SetPhone(string phone)
        {
            Phone = phone;
            return this;
        }

        public Builder SetAddress(string address)
        {
            Address = address;
            return this;
        }

        public Builder SetIsActive(bool isActive)
        {
            IsActive = isActive;
            return this;
        }

        public User Build()
        {
            return new User(this);
        }
    }
}

// Usage
var user = new User.Builder()
    .SetId("123")
    .SetName("John Doe")
    .SetEmail("john@example.com")
    .SetAge(30)
    .SetPhone("+1234567890")
    .Build();
```

### Init-only Properties (C# 9+)
```csharp
public record User
{
    public required string Id { get; init; }
    public required string Name { get; init; }
    public required string Email { get; init; }
    public int? Age { get; init; }
    public string? Phone { get; init; }
    public string? Address { get; init; }
    public bool IsActive { get; init; } = true;
}

// Usage (not a traditional builder, but simpler for C#)
var user = new User
{
    Id = "123",
    Name = "John Doe",
    Email = "john@example.com",
    Age = 30,
    Phone = "+1234567890"
};
```

---

## PHP

### Method Chaining Builder
```php
class User
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly string $email,
        public readonly ?int $age = null,
        public readonly ?string $phone = null,
        public readonly ?string $address = null,
        public readonly bool $isActive = true
    ) {}
}

class UserBuilder
{
    private ?string $id = null;
    private ?string $name = null;
    private ?string $email = null;
    private ?int $age = null;
    private ?string $phone = null;
    private ?string $address = null;
    private bool $isActive = true;

    public function setId(string $id): self
    {
        $this->id = $id;
        return $this;
    }

    public function setName(string $name): self
    {
        $this->name = $name;
        return $this;
    }

    public function setEmail(string $email): self
    {
        $this->email = $email;
        return $this;
    }

    public function setAge(int $age): self
    {
        $this->age = $age;
        return $this;
    }

    public function setPhone(string $phone): self
    {
        $this->phone = $phone;
        return $this;
    }

    public function setAddress(string $address): self
    {
        $this->address = $address;
        return $this;
    }

    public function setIsActive(bool $isActive): self
    {
        $this->isActive = $isActive;
        return $this;
    }

    public function build(): User
    {
        if ($this->id === null || $this->name === null || $this->email === null) {
            throw new InvalidArgumentException('id, name, and email are required');
        }

        return new User(
            id: $this->id,
            name: $this->name,
            email: $this->email,
            age: $this->age,
            phone: $this->phone,
            address: $this->address,
            isActive: $this->isActive
        );
    }

    public function reset(): self
    {
        $this->id = null;
        $this->name = null;
        $this->email = null;
        $this->age = null;
        $this->phone = null;
        $this->address = null;
        $this->isActive = true;
        return $this;
    }
}

// Usage
$user = (new UserBuilder())
    ->setId('123')
    ->setName('John Doe')
    ->setEmail('john@example.com')
    ->setAge(30)
    ->setPhone('+1234567890')
    ->build();
```

---

## Kotlin

### Apply/Also Builder (Idiomatic)
```kotlin
data class User(
    val id: String,
    val name: String,
    val email: String,
    val age: Int? = null,
    val phone: String? = null,
    val address: String? = null,
    val isActive: Boolean = true
)

class UserBuilder {
    var id: String? = null
    var name: String? = null
    var email: String? = null
    var age: Int? = null
    var phone: String? = null
    var address: String? = null
    var isActive: Boolean = true

    fun build(): User {
        require(id != null && name != null && email != null) {
            "id, name, and email are required"
        }
        return User(
            id = id!!,
            name = name!!,
            email = email!!,
            age = age,
            phone = phone,
            address = address,
            isActive = isActive
        )
    }
}

// Usage with apply
val user = UserBuilder().apply {
    id = "123"
    name = "John Doe"
    email = "john@example.com"
    age = 30
    phone = "+1234567890"
}.build()
```

### DSL Builder (Type-safe)
```kotlin
@DslMarker
annotation class UserDsl

@UserDsl
class UserBuilder {
    var id: String? = null
    var name: String? = null
    var email: String? = null
    var age: Int? = null
    var phone: String? = null
    var address: String? = null
    var isActive: Boolean = true

    fun build(): User {
        require(id != null && name != null && email != null) {
            "id, name, and email are required"
        }
        return User(id!!, name!!, email!!, age, phone, address, isActive)
    }
}

fun user(init: UserBuilder.() -> Unit): User {
    return UserBuilder().apply(init).build()
}

// Usage with DSL
val user = user {
    id = "123"
    name = "John Doe"
    email = "john@example.com"
    age = 30
    phone = "+1234567890"
}
```

---

## Swift

### Method Chaining Builder
```swift
struct User {
    let id: String
    let name: String
    let email: String
    let age: Int?
    let phone: String?
    let address: String?
    let isActive: Bool
}

class UserBuilder {
    private var id: String?
    private var name: String?
    private var email: String?
    private var age: Int?
    private var phone: String?
    private var address: String?
    private var isActive: Bool = true

    func setId(_ id: String) -> Self {
        self.id = id
        return self
    }

    func setName(_ name: String) -> Self {
        self.name = name
        return self
    }

    func setEmail(_ email: String) -> Self {
        self.email = email
        return self
    }

    func setAge(_ age: Int) -> Self {
        self.age = age
        return self
    }

    func setPhone(_ phone: String) -> Self {
        self.phone = phone
        return self
    }

    func setAddress(_ address: String) -> Self {
        self.address = address
        return self
    }

    func setIsActive(_ isActive: Bool) -> Self {
        self.isActive = isActive
        return self
    }

    func build() -> User {
        guard let id = id, let name = name, let email = email else {
            fatalError("id, name, and email are required")
        }
        
        return User(
            id: id,
            name: name,
            email: email,
            age: age,
            phone: phone,
            address: address,
            isActive: isActive
        )
    }
}

// Usage
let user = UserBuilder()
    .setId("123")
    .setName("John Doe")
    .setEmail("john@example.com")
    .setAge(30)
    .setPhone("+1234567890")
    .build()
```

---

## Dart

### Cascade Notation Builder (Idiomatic)
```dart
class User {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String? phone;
  final String? address;
  final bool isActive;

  User._({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.phone,
    this.address,
    this.isActive = true,
  });
}

class UserBuilder {
  String? _id;
  String? _name;
  String? _email;
  int? _age;
  String? _phone;
  String? _address;
  bool _isActive = true;

  void setId(String id) => _id = id;
  void setName(String name) => _name = name;
  void setEmail(String email) => _email = email;
  void setAge(int age) => _age = age;
  void setPhone(String phone) => _phone = phone;
  void setAddress(String address) => _address = address;
  void setIsActive(bool isActive) => _isActive = isActive;

  User build() {
    if (_id == null || _name == null || _email == null) {
      throw StateError('id, name, and email are required');
    }

    return User._(
      id: _id!,
      name: _name!,
      email: _email!,
      age: _age,
      phone: _phone,
      address: _address,
      isActive: _isActive,
    );
  }
}

// Usage with cascade notation
final user = UserBuilder()
  ..setId('123')
  ..setName('John Doe')
  ..setEmail('john@example.com')
  ..setAge(30)
  ..setPhone('+1234567890')
  ..build();
```

### Method Chaining Builder
```dart
class UserBuilder {
  String? _id;
  String? _name;
  String? _email;
  int? _age;
  String? _phone;
  String? _address;
  bool _isActive = true;

  UserBuilder setId(String id) {
    _id = id;
    return this;
  }

  UserBuilder setName(String name) {
    _name = name;
    return this;
  }

  UserBuilder setEmail(String email) {
    _email = email;
    return this;
  }

  UserBuilder setAge(int age) {
    _age = age;
    return this;
  }

  UserBuilder setPhone(String phone) {
    _phone = phone;
    return this;
  }

  UserBuilder setAddress(String address) {
    _address = address;
    return this;
  }

  UserBuilder setIsActive(bool isActive) {
    _isActive = isActive;
    return this;
  }

  User build() {
    if (_id == null || _name == null || _email == null) {
      throw StateError('id, name, and email are required');
    }

    return User._(
      id: _id!,
      name: _name!,
      email: _email!,
      age: _age,
      phone: _phone,
      address: _address,
      isActive: _isActive,
    );
  }
}

// Usage
final user = UserBuilder()
  .setId('123')
  .setName('John Doe')
  .setEmail('john@example.com')
  .setAge(30)
  .setPhone('+1234567890')
  .build();
```
