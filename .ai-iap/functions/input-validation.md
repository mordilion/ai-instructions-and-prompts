---
title: Input Validation Patterns
category: Security & Data Integrity
difficulty: intermediate
languages: [typescript, python, java, csharp, php, kotlin, swift, dart]
tags: [validation, sanitization, security, xss]
updated: 2026-01-09
---

# Input Validation Patterns

> Validate user input, prevent XSS/injection, sanitize HTML

---

## TypeScript

### Zod (Recommended)
```bash
npm install zod
```

```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().positive().max(120),
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8)
    .regex(/[A-Z]/).regex(/[a-z]/).regex(/[0-9]/),
});

const user = userSchema.parse(data); // Throws on invalid
// Or: const result = userSchema.safeParse(data);
```

### class-validator
```bash
npm install class-validator class-transformer
```

```typescript
import { IsEmail, IsInt, Min, Max, Length } from 'class-validator';

class UserDto {
  @IsEmail()
  email: string;

  @IsInt() @Min(1) @Max(120)
  age: number;

  @Length(1, 100)
  name: string;
}

const errors = await validate(userDto);
```

### HTML Sanitization
```bash
npm install isomorphic-dompurify
```

```typescript
import DOMPurify from 'isomorphic-dompurify';

const clean = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: ['b', 'i', 'p'],
  ALLOWED_ATTR: ['href']
});
```

---

## Python

### Pydantic (Recommended)
```bash
pip install pydantic
```

```python
from pydantic import BaseModel, EmailStr, Field, validator

class UserCreate(BaseModel):
    email: EmailStr
    age: int = Field(gt=0, lt=120)
    name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=8)
    
    @validator('password')
    def password_strength(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('Must contain uppercase')
        return v

user = UserCreate(**data)  # Raises ValidationError
```

### bleach (HTML Sanitization)
```bash
pip install bleach
```

```python
import bleach

clean = bleach.clean(
    dirty,
    tags=['b', 'i', 'p'],
    attributes={'a': ['href']},
    strip=True
)
```

---

## Java

### Bean Validation
```xml
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
</dependency>
```

```java
import javax.validation.constraints.*;

public class UserDto {
    @NotBlank @Email
    private String email;
    
    @Min(1) @Max(120)
    private Integer age;
    
    @Size(min = 1, max = 100)
    private String name;
    
    @Pattern(regexp = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$")
    private String password;
}

Set<ConstraintViolation<UserDto>> violations = validator.validate(user);
```

### Spring Boot Auto-Validation
```java
@RestController
public class UserController {
    @PostMapping("/users")
    public User create(@Valid @RequestBody UserDto dto) {
        return userService.create(dto);
    }
}
```

---

## C#

### Data Annotations
```csharp
using System.ComponentModel.DataAnnotations;

public class UserDto
{
    [Required, EmailAddress]
    public string Email { get; set; }
    
    [Range(1, 120)]
    public int Age { get; set; }
    
    [StringLength(100, MinimumLength = 1)]
    public string Name { get; set; }
    
    [RegularExpression(@"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$")]
    public string Password { get; set; }
}

var results = new List<ValidationResult>();
Validator.TryValidateObject(user, new ValidationContext(user), results, true);
```

### FluentValidation (Recommended)
```bash
dotnet add package FluentValidation
```

```csharp
using FluentValidation;

public class UserValidator : AbstractValidator<UserDto>
{
    public UserValidator()
    {
        RuleFor(x => x.Email).EmailAddress();
        RuleFor(x => x.Age).InclusiveBetween(1, 120);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Password)
            .MinimumLength(8)
            .Matches("[A-Z]").Matches("[a-z]").Matches("[0-9]");
    }
}

var result = await validator.ValidateAsync(dto);
```

---

## PHP

### Laravel Validation (Recommended)
```php
$validated = $request->validate([
    'email' => 'required|email',
    'age' => 'required|integer|min:1|max:120',
    'name' => 'required|string|max:100',
    'password' => [
        'required',
        'min:8',
        'regex:/[A-Z]/',
        'regex:/[a-z]/',
        'regex:/[0-9]/',
    ],
]);
```

### Manual (Plain PHP)
```php
$errors = [];

if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
    $errors['email'] = 'Invalid email';
}

if ($data['age'] < 1 || $data['age'] > 120) {
    $errors['age'] = 'Age must be 1-120';
}

if (empty($errors)) {
    return [
        'email' => filter_var($data['email'], FILTER_SANITIZE_EMAIL),
        'name' => trim($data['name']),
        'age' => (int)$data['age'],
    ];
}
```

---

## Kotlin

### Built-in Validation
```kotlin
data class UserCreate(
    val email: String,
    val age: Int,
    val name: String,
    val password: String
) {
    init {
        require(email.matches(Regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))) {
            "Invalid email"
        }
        require(age in 1..120) { "Age must be 1-120" }
        require(name.isNotBlank()) { "Name required" }
        require(password.length >= 8) { "Password too short" }
        require(password.any { it.isUpperCase() }) { "Need uppercase" }
    }
}
```

### Konform
```kotlin
// build.gradle.kts
implementation("io.konform:konform:0.4.0")
```

```kotlin
import io.konform.validation.Validation

val validateUser = Validation<UserCreate> {
    UserCreate::email {
        pattern("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
    }
    UserCreate::age {
        minimum(1)
        maximum(120)
    }
    UserCreate::password {
        minLength(8)
        pattern("[A-Z]")
        pattern("[a-z]")
        pattern("[0-9]")
    }
}
```

---

## Swift

### Manual Validation
```swift
struct UserCreate {
    let email: String
    let age: Int
    let name: String
    let password: String
    
    init(email: String, age: Int, name: String, password: String) throws {
        guard email.contains("@") else {
            throw ValidationError.invalidEmail
        }
        guard (1...120).contains(age) else {
            throw ValidationError.invalidAge
        }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyName
        }
        guard password.count >= 8 else {
            throw ValidationError.passwordTooShort
        }
        
        self.email = email
        self.age = age
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.password = password
    }
}

enum ValidationError: Error {
    case invalidEmail, invalidAge, emptyName, passwordTooShort
}
```

---

## Dart

### Manual Validation
```dart
class UserCreate {
  final String email;
  final int age;
  final String name;
  final String password;
  
  UserCreate({
    required this.email,
    required this.age,
    required this.name,
    required this.password,
  }) {
    if (!email.contains('@')) {
      throw ValidationException('Invalid email');
    }
    if (age < 1 || age > 120) {
      throw ValidationException('Age must be 1-120');
    }
    if (name.trim().isEmpty) {
      throw ValidationException('Name required');
    }
    if (password.length < 8) {
      throw ValidationException('Password too short');
    }
  }
}
```

### Flutter Form
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  },
)
```

---

## Common Regex Patterns

```regex
Email:     ^[^\s@]+@[^\s@]+\.[^\s@]+$
Password:  ^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$
URL:       ^https?://[^\s]+$
Phone(US): ^\+?1?\d{10}$
```

---

## Quick Rules

✅ Validate server-side (never trust client)
✅ Sanitize HTML before display
✅ Use whitelist (allowed tags/chars)
✅ Trim whitespace
✅ Check types, ranges, formats

❌ Client-only validation
❌ Blacklist filtering
❌ Store unsanitized input
❌ Expose validation logic
