# Input Validation Patterns

> **Purpose**: Validate and sanitize user input to prevent security issues and data corruption
>
> **When to use**: API endpoints, form submissions, user input, file uploads, query parameters

---

## TypeScript / JavaScript

```typescript
// Zod validation
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().positive().max(120),
  name: z.string().min(1).max(100).trim(),
  website: z.string().url().optional(),
});

// Usage
function createUser(data: unknown) {
  const validated = userSchema.parse(data); // Throws on invalid
  // Or
  const result = userSchema.safeParse(data); // Returns {success, data/error}
  
  if (!result.success) {
    throw new ValidationError(result.error.message);
  }
  
  return saveUser(result.data);
}

// Manual validation
function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Sanitization
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href']
  });
}
```

---

## Python

```python
# Pydantic validation
from pydantic import BaseModel, EmailStr, validator, Field

class UserCreate(BaseModel):
    email: EmailStr
    age: int = Field(gt=0, lt=120)
    name: str = Field(min_length=1, max_length=100)
    website: HttpUrl | None = None
    
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()

# Usage
try:
    user = UserCreate(**request_data)
    save_user(user)
except ValidationError as e:
    return {'errors': e.errors()}

# Manual validation
import re

def validate_email(email: str) -> bool:
    pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
    return bool(re.match(pattern, email))

# Sanitization
import bleach

def sanitize_html(dirty: str) -> str:
    return bleach.clean(
        dirty,
        tags=['b', 'i', 'em', 'strong', 'a'],
        attributes={'a': ['href']},
        strip=True
    )
```

---

## Java

```java
// Bean Validation (JSR-380)
import javax.validation.constraints.*;

public class UserCreateDTO {
    @NotBlank(message = "Name is required")
    @Size(min = 1, max = 100)
    private String name;
    
    @Email(message = "Invalid email format")
    @NotNull
    private String email;
    
    @Min(value = 1, message = "Age must be positive")
    @Max(value = 120, message = "Age must be realistic")
    private Integer age;
    
    @Pattern(regexp = "^https?://.*", message = "Invalid URL")
    private String website;
}

// Usage with validator
Validator validator = Validation.buildDefaultValidatorFactory().getValidator();
Set<ConstraintViolation<UserCreateDTO>> violations = validator.validate(user);

if (!violations.isEmpty()) {
    throw new ValidationException(
        violations.stream()
            .map(ConstraintViolation::getMessage)
            .collect(Collectors.joining(", "))
    );
}

// Sanitization
import org.owasp.html.PolicyFactory;
import org.owasp.html.Sanitizers;

String sanitized = Sanitizers.FORMATTING
    .and(Sanitizers.LINKS)
    .sanitize(untrustedHtml);
```

---

## C# (.NET)

```csharp
// Data Annotations
using System.ComponentModel.DataAnnotations;

public class UserCreateDto
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 1)]
    public string Name { get; set; }
    
    [Required]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; }
    
    [Range(1, 120, ErrorMessage = "Age must be between 1 and 120")]
    public int Age { get; set; }
    
    [Url(ErrorMessage = "Invalid URL format")]
    public string? Website { get; set; }
}

// Usage
var context = new ValidationContext(user);
var results = new List<ValidationResult>();

if (!Validator.TryValidateObject(user, context, results, true))
{
    var errors = results.Select(r => r.ErrorMessage);
    throw new ValidationException(string.Join(", ", errors));
}

// FluentValidation (alternative)
public class UserCreateValidator : AbstractValidator<UserCreateDto>
{
    public UserCreateValidator()
    {
        RuleFor(x => x.Email).EmailAddress();
        RuleFor(x => x.Age).InclusiveBetween(1, 120);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
    }
}

// Sanitization
using Ganss.Xss;

var sanitizer = new HtmlSanitizer();
sanitizer.AllowedTags.Clear();
sanitizer.AllowedTags.Add("b");
sanitizer.AllowedTags.Add("i");
string clean = sanitizer.Sanitize(dirty);
```

---

## PHP

```php
// Manual validation
function validateUser(array $data): array
{
    $errors = [];
    
    if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = 'Valid email is required';
    }
    
    if (empty($data['name']) || strlen(trim($data['name'])) < 1) {
        $errors['name'] = 'Name is required';
    }
    
    if (!isset($data['age']) || $data['age'] < 1 || $data['age'] > 120) {
        $errors['age'] = 'Age must be between 1 and 120';
    }
    
    if (!empty($errors)) {
        throw new ValidationException(json_encode($errors));
    }
    
    return [
        'name' => trim($data['name']),
        'email' => filter_var($data['email'], FILTER_SANITIZE_EMAIL),
        'age' => (int)$data['age'],
    ];
}

// Laravel validation
$validated = $request->validate([
    'email' => 'required|email',
    'age' => 'required|integer|min:1|max:120',
    'name' => 'required|string|max:100',
    'website' => 'nullable|url',
]);

// Sanitization
$clean = filter_var($dirty, FILTER_SANITIZE_SPECIAL_CHARS);

// HTML Purifier
$config = HTMLPurifier_Config::createDefault();
$purifier = new HTMLPurifier($config);
$clean = $purifier->purify($dirty);
```

---

## Kotlin

```kotlin
// Manual validation
data class UserCreate(
    val email: String,
    val age: Int,
    val name: String,
    val website: String? = null
) {
    init {
        require(email.matches(Regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))) {
            "Invalid email format"
        }
        require(age in 1..120) { "Age must be between 1 and 120" }
        require(name.isNotBlank()) { "Name cannot be empty" }
        website?.let {
            require(it.startsWith("http")) { "Invalid URL" }
        }
    }
}

// Custom validator
fun validateUser(data: Map<String, Any?>): Result<UserCreate> {
    return try {
        Result.success(UserCreate(
            email = data["email"] as? String ?: throw IllegalArgumentException("Email required"),
            age = (data["age"] as? Number)?.toInt() ?: throw IllegalArgumentException("Age required"),
            name = (data["name"] as? String)?.trim() ?: throw IllegalArgumentException("Name required")
        ))
    } catch (e: Exception) {
        Result.failure(e)
    }
}

// Arrow validation (functional)
import arrow.core.Either
import arrow.core.left
import arrow.core.right

sealed class ValidationError {
    data class InvalidEmail(val email: String) : ValidationError()
    data class InvalidAge(val age: Int) : ValidationError()
}

fun validateEmail(email: String): Either<ValidationError, String> {
    return if (email.contains("@")) email.right()
    else ValidationError.InvalidEmail(email).left()
}
```

---

## Swift

```swift
// Manual validation
struct UserCreate {
    let email: String
    let age: Int
    let name: String
    let website: String?
    
    init(email: String, age: Int, name: String, website: String? = nil) throws {
        guard email.contains("@") && email.contains(".") else {
            throw ValidationError.invalidEmail
        }
        guard (1...120).contains(age) else {
            throw ValidationError.invalidAge
        }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyName
        }
        
        self.email = email
        self.age = age
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.website = website
    }
}

enum ValidationError: Error {
    case invalidEmail
    case invalidAge
    case emptyName
}

// Validator protocol
protocol Validator {
    func validate() throws
}

extension UserCreate: Validator {
    func validate() throws {
        // Validation logic
    }
}

// Result type
func validateUser(data: [String: Any]) -> Result<UserCreate, ValidationError> {
    guard let email = data["email"] as? String else {
        return .failure(.invalidEmail)
    }
    // ...
    return .success(UserCreate(...))
}
```

---

## Dart (Flutter)

```dart
// Manual validation
class UserCreate {
  final String email;
  final int age;
  final String name;
  final String? website;
  
  UserCreate({
    required this.email,
    required this.age,
    required this.name,
    this.website,
  }) {
    if (!email.contains('@') || !email.contains('.')) {
      throw ValidationException('Invalid email format');
    }
    if (age < 1 || age > 120) {
      throw ValidationException('Age must be between 1 and 120');
    }
    if (name.trim().isEmpty) {
      throw ValidationException('Name cannot be empty');
    }
  }
}

// Form validation (Flutter)
class UserForm extends StatefulWidget {
  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Invalid email format';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Process data
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Sanitization
String sanitizeHtml(String dirty) {
  return dirty
      .replaceAll(RegExp(r'<script[^>]*>.*?</script>'), '')
      .replaceAll(RegExp(r'<[^>]+>'), '');
}
```

---

## Best Practices

✅ **DO**:
- Validate on both client and server
- Provide specific error messages
- Sanitize before storing
- Use whitelist, not blacklist
- Validate data types and ranges
- Trim whitespace from strings

❌ **DON'T**:
- Trust client-side validation alone
- Expose internal validation logic
- Allow arbitrary HTML without sanitization
- Validate with regex only (use libraries)
- Store unsanitized input

---

## Security Checklist

- [ ] Email: Valid format, not disposable
- [ ] Passwords: Min length, complexity, not common
- [ ] URLs: Valid protocol, not malicious
- [ ] File uploads: Extension, size, MIME type
- [ ] Numbers: Range, type, not NaN/Infinity
- [ ] Dates: Valid format, reasonable range
- [ ] HTML: Sanitized, no XSS vectors
- [ ] SQL: Parameterized queries (see database-query.md)
