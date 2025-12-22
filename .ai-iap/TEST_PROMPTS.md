# Cross-AI Compatibility Test Suite
## Standardized Tests to Ensure All AIs Produce Same Quality Code

---

## Purpose

These test prompts verify that ALL major AI models (GPT-4, Claude, Gemini, Codestral, GPT-3.5) generate identical quality code when using your rule files.

**How to use**:
1. Load your rules into each AI tool
2. Run each test prompt below
3. Compare outputs against expected results
4. Document any failures
5. Iterate on rules until all AIs pass

---

## Test 1: Spring Boot Service ⭐ CRITICAL

### Prompt
```
Create a Spring Boot service class that uses UserRepository to fetch a user by ID.
The service should handle the case where the user is not found.
```

### Expected Output (ALL AIs must generate this)
```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    
    public UserDto getUser(Long id) {
        return userRepository.findById(id)
            .map(UserMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
}
```

### Critical Checks
- [x] @RequiredArgsConstructor (NOT @Autowired on fields)
- [x] final field for repository
- [x] @Transactional(readOnly = true) on class
- [x] Returns UserDto (NOT User entity)
- [x] Proper exception handling (orElseThrow)
- [x] Maps entity to DTO

### Common Failures
❌ Uses `@Autowired private UserRepository repo;` (field injection)  
❌ Missing `@Transactional`  
❌ Returns `User` entity instead of `UserDto`  
❌ Uses `.get()` instead of `.orElseThrow()`

---

## Test 2: React Component with Data Fetching ⭐ CRITICAL

### Prompt
```
Create a React component that fetches and displays a user by ID.
The component should show a loading state while fetching and handle the case where the user is not found.
```

### Expected Output (ALL AIs must generate this)
```tsx
interface UserProfileProps {
  userId: string;
}

const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);  // ← userId MUST be in dependencies
  
  if (loading) return <Loading />;
  if (!user) return <NotFound />;
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
};
```

### Critical Checks
- [x] Functional component (NOT class component)
- [x] PascalCase component name
- [x] Props typed with interface
- [x] useState with proper type annotation
- [x] useEffect includes userId in dependency array
- [x] Loading state handled
- [x] Null/error state handled

### Common Failures
❌ Class component instead of functional  
❌ Empty dependency array in useEffect (missing userId)  
❌ camelCase component name instead of PascalCase  
❌ No loading state  
❌ Missing type annotations

---

## Test 3: ASP.NET Core Controller ⭐ CRITICAL

### Prompt
```
Create an ASP.NET Core controller with a GET endpoint that fetches a user by ID.
Return 404 if the user is not found.
```

### Expected Output (ALL AIs must generate this)
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    
    public UsersController(IUserService userService)
    {
        _userService = userService;
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(int id)
    {
        var user = await _userService.GetUserAsync(id);
        return user is null ? NotFound() : Ok(user);
    }
}
```

### Critical Checks
- [x] Constructor injection (NOT property injection)
- [x] ActionResult<UserDto> return type
- [x] Returns UserDto (NOT User entity)
- [x] Async/await pattern
- [x] Proper null handling with pattern matching
- [x] No business logic in controller

### Common Failures
❌ Property injection or field injection  
❌ Returns `User` entity instead of `UserDto`  
❌ Missing async/await  
❌ Business logic in controller  
❌ Direct database access in controller

---

## Test 4: FastAPI Endpoint

### Prompt
```
Create a FastAPI endpoint that creates a new user.
Validate the email format and return 201 Created status.
```

### Expected Output (ALL AIs must generate this)
```python
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr

class CreateUserRequest(BaseModel):
    name: str
    email: EmailStr

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    
    class Config:
        from_attributes = True

@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(request: CreateUserRequest):
    user = await user_service.create(request)
    return user
```

### Critical Checks
- [x] Pydantic models for request/response
- [x] EmailStr for email validation
- [x] response_model specified
- [x] status_code=201 for create
- [x] async def for endpoint
- [x] Type hints everywhere

### Common Failures
❌ Sync def instead of async def  
❌ Missing response_model  
❌ No email validation  
❌ Wrong status code

---

## Test 5: Next.js Server Component

### Prompt
```
Create a Next.js page that displays a list of users fetched from a database.
Use the App Router and Server Components.
```

### Expected Output (ALL AIs must generate this)
```tsx
// app/users/page.tsx
async function UsersPage() {
  const users = await prisma.user.findMany();  // Direct DB access in Server Component
  
  return (
    <div>
      <h1>Users</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}

export default UsersPage;
```

### Critical Checks
- [x] Server Component (NO 'use client')
- [x] async function
- [x] Direct database access (allowed in Server Components)
- [x] No useState or useEffect
- [x] Proper key prop in list

### Common Failures
❌ Adds 'use client' (unnecessary)  
❌ Uses useEffect for data fetching  
❌ Tries to use useState  
❌ Missing async/await

---

## Test 6: Kotlin Data Class with Immutability

### Prompt
```
Create a Kotlin data class for a User with id, name, and email.
Ensure immutability.
```

### Expected Output (ALL AIs must generate this)
```kotlin
data class User(
    val id: Long,
    val name: String,
    val email: String
)
```

### Critical Checks
- [x] data class (NOT regular class)
- [x] val properties (NOT var - immutability)
- [x] All properties in constructor

### Common Failures
❌ Uses var instead of val  
❌ Regular class instead of data class  
❌ Properties outside constructor

---

## Test 7: Swift Protocol-Oriented Repository

### Prompt
```
Create a Swift protocol for a UserRepository with a method to find a user by ID.
Include an async implementation.
```

### Expected Output (ALL AIs must generate this)
```swift
protocol UserRepository {
    func findById(_ id: UUID) async throws -> User?
}

struct DatabaseUserRepository: UserRepository {
    func findById(_ id: UUID) async throws -> User? {
        // Implementation
        return try await database.fetch(User.self, id: id)
    }
}
```

### Critical Checks
- [x] Protocol definition
- [x] async throws in signature
- [x] Optional return type (User?)
- [x] struct implementation

### Common Failures
❌ Missing async  
❌ Missing throws  
❌ Non-optional return type

---

## Test 8: Python Type Hints

### Prompt
```
Create a Python function that fetches a user by ID from a repository.
Return None if not found. Use type hints.
```

### Expected Output (ALL AIs must generate this)
```python
async def get_user(user_id: int, repository: UserRepository) -> User | None:
    user = await repository.find_by_id(user_id)
    return user
```

### Critical Checks
- [x] async def
- [x] Type hints on parameters
- [x] Return type annotation with Union/|
- [x] await on async call

### Common Failures
❌ Missing type hints  
❌ Sync def instead of async  
❌ Missing await

---

## Test 9: PHP Constructor Property Promotion

### Prompt
```
Create a PHP 8.1+ service class with constructor property promotion for dependency injection.
```

### Expected Output (ALL AIs must generate this)
```php
<?php
declare(strict_types=1);

final readonly class UserService
{
    public function __construct(
        private UserRepository $repository,
        private LoggerInterface $logger,
    ) {}
    
    public function getUser(int $id): User
    {
        return $this->repository->findById($id) 
            ?? throw new UserNotFoundException($id);
    }
}
```

### Critical Checks
- [x] declare(strict_types=1)
- [x] readonly class
- [x] Constructor property promotion (private in constructor)
- [x] Type hints everywhere
- [x] Null coalescing with throw

### Common Failures
❌ Missing strict_types  
❌ Properties defined outside constructor  
❌ Missing type hints

---

## Test 10: Dart/Flutter Widget

### Prompt
```
Create a Flutter StatelessWidget that displays a user's name and email.
```

### Expected Output (ALL AIs must generate this)
```dart
class UserCard extends StatelessWidget {
  final User user;
  
  const UserCard({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}
```

### Critical Checks
- [x] StatelessWidget (NOT StatefulWidget for static display)
- [x] const constructor
- [x] final properties
- [x] required parameters

### Common Failures
❌ StatefulWidget for static content  
❌ Missing const  
❌ Mutable properties (var instead of final)

---

## Scoring Guide

### Per Test
- **Pass (100%)**: Output matches expected exactly
- **Minor Issues (90%)**: 1-2 small fixes needed (missing const, etc.)
- **Major Issues (70%)**: 3-5 fixes needed (wrong pattern, missing key features)
- **Fail (<70%)**: Fundamental mistakes (wrong paradigm, security issues)

### Overall AI Score
- **Excellent (95-100%)**: 9-10 tests pass
- **Good (85-94%)**: 8 tests pass
- **Fair (75-84%)**: 7 tests pass
- **Poor (<75%)**: 6 or fewer tests pass

---

## Testing Protocol

### Step 1: Baseline (Before Rule Updates)
Test GPT-4, Claude, Gemini, Codestral, GPT-3.5 with CURRENT rules.

**Expected Results**:
- GPT-4: 10/10 ✅
- Claude: 10/10 ✅
- Gemini: 7-8/10 ⚠️
- Codestral: 6-7/10 ⚠️
- GPT-3.5: 5-6/10 ❌

### Step 2: After Rule Updates
Test same AIs with UPDATED rules (with ALWAYS/NEVER directives).

**Target Results**:
- GPT-4: 10/10 ✅
- Claude: 10/10 ✅
- Gemini: 9-10/10 ✅
- Codestral: 9-10/10 ✅
- GPT-3.5: 8-9/10 ✅

### Step 3: Document Failures
For each failure, document:
1. Which AI failed
2. Which test failed
3. What was generated (wrong output)
4. What directive was missed
5. How to fix the rule file

### Step 4: Iterate
Update rule files based on failures, re-test until all AIs score 95%+.

---

## Test Results Template

```markdown
## Test Results - [Date]

### GPT-4
- Test 1 (Spring Boot): ✅ Pass
- Test 2 (React): ✅ Pass
- Test 3 (ASP.NET): ✅ Pass
- Test 4 (FastAPI): ✅ Pass
- Test 5 (Next.js): ✅ Pass
- Test 6 (Kotlin): ✅ Pass
- Test 7 (Swift): ✅ Pass
- Test 8 (Python): ✅ Pass
- Test 9 (PHP): ✅ Pass
- Test 10 (Dart): ✅ Pass
**Score: 100%**

### Gemini Pro
- Test 1 (Spring Boot): ❌ Fail - Used @Autowired field injection
- Test 2 (React): ⚠️ Minor - Missing loading state
- Test 3 (ASP.NET): ✅ Pass
- Test 4 (FastAPI): ✅ Pass
- Test 5 (Next.js): ❌ Fail - Added 'use client' unnecessarily
- Test 6 (Kotlin): ✅ Pass
- Test 7 (Swift): ✅ Pass
- Test 8 (Python): ✅ Pass
- Test 9 (PHP): ✅ Pass
- Test 10 (Dart): ✅ Pass
**Score: 80% - Needs improvement**

[Continue for each AI...]
```

---

## Success Criteria

✅ All major AIs (GPT-4, Claude, Gemini, Codestral) score 95%+ on test suite  
✅ No AI-specific workarounds needed in production  
✅ Team reports consistent code quality regardless of AI tool used  
✅ Code review findings drop by 50%+ for AI-generated code

---

**Use this test suite after implementing the cross-AI compatibility fixes from `PRIORITY_ACTIONS.md`**


