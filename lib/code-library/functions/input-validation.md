---
title: Input Validation Patterns
category: Security & Data Integrity
difficulty: intermediate
purpose: Validate and sanitize user input to prevent security issues and data corruption
when_to_use:
  - API endpoints receiving user data
  - Form submissions
  - File uploads
  - Query parameters
  - Any user-provided input
languages:
  typescript:
    - name: Zod (Type-safe schema validation)
      library: zod
      recommended: true
    - name: class-validator (Decorator-based)
      library: class-validator
    - name: NestJS ValidationPipe (class-validator)
      library: "@nestjs/common"
    - name: Angular Validators (Reactive Forms)
      library: "@angular/forms"
    - name: AdonisJS Validator
      library: "@adonisjs/validator"
    - name: Express request validation (Zod)
      library: express
    - name: Fastify request validation (Zod)
      library: fastify
    - name: Koa request validation (Zod)
      library: koa
    - name: Hapi payload validation (Zod)
      library: "@hapi/hapi"
    - name: DOMPurify (HTML sanitization)
      library: isomorphic-dompurify
  python:
    - name: Pydantic (Type hints validation)
      library: pydantic
      recommended: true
    - name: marshmallow (Serialization + validation)
      library: marshmallow
    - name: Django Forms (Django projects)
      library: django
    - name: FastAPI (Pydantic models)
      library: fastapi
    - name: Flask (request validation)
      library: flask
    - name: bleach (HTML sanitization)
      library: bleach
  java:
    - name: Bean Validation JSR-380 (Standard)
      library: javax.validation
      recommended: true
    - name: Hibernate Validator (Implementation)
      library: hibernate-validator
    - name: Spring Boot Validation (Auto-validation)
      library: spring-boot-starter-validation
  csharp:
    - name: Data Annotations (Built-in)
      library: System.ComponentModel.DataAnnotations
      recommended: true
    - name: FluentValidation (Fluent API)
      library: FluentValidation
    - name: HtmlSanitizer (HTML cleaning)
      library: HtmlSanitizer
    - name: Blazor EditForm validation
      library: Microsoft.AspNetCore.Components.Forms
  php:
    - name: Laravel Validation (Laravel framework)
      library: laravel/framework
      recommended: true
    - name: Symfony Validator (Symfony framework)
      library: symfony/validator
    - name: WordPress sanitization
      library: wordpress
    - name: Slim request validation
      library: slim/slim
    - name: Laminas InputFilter
      library: laminas/laminas-inputfilter
    - name: HTML Purifier (HTML sanitization)
      library: ezyang/htmlpurifier
  kotlin:
    - name: Built-in validation (Native Kotlin)
      library: kotlin-stdlib
      recommended: true
    - name: Konform (DSL validation)
      library: io.konform:konform
  swift:
    - name: Manual validation (Native Swift)
      library: swift-stdlib
      recommended: true
  dart:
    - name: Manual validation (Native Dart)
      library: dart-core
      recommended: true
    - name: Flutter Form (UI validation)
      library: flutter
    - name: formz (Reusable validation)
      library: formz
common_patterns:
  - Email format validation
  - Password strength (min 8 chars, uppercase, lowercase, number, special)
  - Age range validation (1-120)
  - String length limits (min/max)
  - URL format validation
  - Required field checks
  - Type validation (int, string, boolean)
best_practices:
  do:
    - Validate on both client and server
    - Provide specific error messages
    - Sanitize before storing
    - Use whitelist, not blacklist
    - Validate data types and ranges
    - Trim whitespace from strings
  dont:
    - Trust client-side validation alone
    - Expose internal validation logic
    - Allow arbitrary HTML without sanitization
    - Store unsanitized input
    - Use blacklist filtering
regex_patterns:
  email: "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
  password: "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$"
  url: "^https?://[^\\s]+$"
  phone_us: "^\\+?1?\\d{10}$"
tags: [validation, sanitization, security, xss, input, forms]
updated: 2026-01-09
---

## TypeScript

### Zod
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().positive().max(120),
  name: z.string().min(1).max(100).trim(),
  password: z.string().min(8)
    .regex(/[A-Z]/).regex(/[a-z]/).regex(/[0-9]/),
});

const user = userSchema.parse(data);
// Or: const result = userSchema.safeParse(data);
```

### class-validator
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

### DOMPurify
```typescript
import DOMPurify from 'isomorphic-dompurify';

const clean = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: ['b', 'i', 'p'],
  ALLOWED_ATTR: ['href']
});
```

### NestJS ValidationPipe (class-validator)
```typescript
import { ValidationPipe } from '@nestjs/common';

app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  })
);
```

### Angular Validators (Reactive Forms)
```typescript
import { FormControl, Validators } from '@angular/forms';

const email = new FormControl('', [Validators.required, Validators.email]);
const age = new FormControl(0, [Validators.min(1), Validators.max(120)]);
```

### AdonisJS Validator
```typescript
import { schema, rules } from '@adonisjs/validator';

const userSchema = schema.create({
  email: schema.string({}, [rules.email()]),
  age: schema.number([rules.range(1, 120)]),
  name: schema.string({}, [rules.minLength(1), rules.maxLength(100)]),
});

const payload = await request.validate({ schema: userSchema });
```

### Express request validation (Zod)
```typescript
import { z } from 'zod';
import type { Request, Response } from 'express';

const schema = z.object({ email: z.string().email() });

export function handler(req: Request, res: Response) {
  const payload = schema.parse(req.body);
  res.json(payload);
}
```

### Fastify request validation (Zod)
```typescript
import { z } from 'zod';

const schema = z.object({ email: z.string().email() });

app.post('/users', async (request, reply) => {
  const payload = schema.parse(request.body);
  reply.send(payload);
});
```

### Koa request validation (Zod)
```typescript
import { z } from 'zod';

const schema = z.object({ email: z.string().email() });

router.post('/users', async (ctx) => {
  const payload = schema.parse(ctx.request.body);
  ctx.body = payload;
});
```

### Hapi payload validation (Zod)
```typescript
import { z } from 'zod';

const schema = z.object({ email: z.string().email() });

server.route({
  method: 'POST',
  path: '/users',
  handler: async (request, h) => {
    const payload = schema.parse(request.payload);
    return h.response(payload).code(200);
  },
});
```

---

## Python

### Pydantic
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

user = UserCreate(**data)
```

### marshmallow
```python
from marshmallow import Schema, fields, validate

class UserSchema(Schema):
    email = fields.Email(required=True)
    age = fields.Integer(required=True, validate=validate.Range(min=1, max=120))
    name = fields.String(required=True, validate=validate.Length(min=1, max=100))

schema = UserSchema()
validated = schema.load(request_data)
```

### Django Forms
```python
from django import forms

class UserForm(forms.Form):
    email = forms.EmailField()
    age = forms.IntegerField(min_value=1, max_value=120)
    name = forms.CharField(min_length=1, max_length=100)

form = UserForm(request.POST)
if form.is_valid():
    save_user(form.cleaned_data)
```

### FastAPI (Pydantic models)
```python
from fastapi import FastAPI

app = FastAPI()

@app.post("/users")
async def create_user(payload: UserCreate):
    return payload.model_dump()
```

### Flask (request validation)
```python
from flask import request

payload = request.get_json(force=True, silent=False)
validated = schema.load(payload)
```

### bleach
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

### Spring Boot
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

Validator.TryValidateObject(user, new ValidationContext(user), results, true);
```

### FluentValidation
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

### Blazor EditForm validation
```csharp
<EditForm Model="@model" OnValidSubmit="@OnSubmit">
    <DataAnnotationsValidator />
    <ValidationSummary />
    <InputText @bind-Value="model.Email" />
</EditForm>

@code {
    private UserDto model = new();
    private Task OnSubmit() => Task.CompletedTask;
}
```

---

## PHP

### Laravel
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

### Symfony Validator
```php
<?php

use Symfony\Component\Validator\Validation;
use Symfony\Component\Validator\Constraints as Assert;

$validator = Validation::createValidator();
$violations = $validator->validate($data['email'] ?? null, [
  new Assert\NotBlank(),
  new Assert\Email(),
]);
```

### HTML Purifier
```php
<?php

$cleanHtml = $purifier->purify($dirtyHtml);
```

### WordPress sanitization
```php
<?php

$email = sanitize_email($_POST['email'] ?? '');
$name = sanitize_text_field($_POST['name'] ?? '');
```

### Slim request validation
```php
<?php

$body = (array)($request->getParsedBody() ?? []);
if (!filter_var($body['email'] ?? '', FILTER_VALIDATE_EMAIL)) {
  return $response->withStatus(400);
}
```

### Laminas InputFilter
```php
<?php

use Laminas\InputFilter\InputFilter;
use Laminas\Validator\EmailAddress;

$filter = new InputFilter();
$filter->add([
  'name' => 'email',
  'required' => true,
  'validators' => [new EmailAddress()],
]);
```

### Plain PHP
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

### Built-in
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

### Manual
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

### Manual
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
