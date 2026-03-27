# TypeScript Code Style

> **Scope**: TypeScript formatting and maintainability  
> **Applies to**: *.ts, *.tsx, *.mts, *.cts files  
> **Extends**: General code style, typescript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Enable strict mode (`strict: true`)
> **ALWAYS**: Use ESLint + Prettier for formatting
> **ALWAYS**: Explicit return types for public methods
> **ALWAYS**: Use unknown (not any)
> **ALWAYS**: Use const for immutable values
> 
> **NEVER**: Use any (use unknown + type guards)
> **NEVER**: Use var (use const/let)
> **NEVER**: Use Function type (use specific signature)
> **NEVER**: Use ! (non-null assertion) without justification
> **NEVER**: Ignore TypeScript errors with @ts-ignore

## Naming Conventions

```typescript
// PascalCase for types, interfaces, classes
interface User {}
class UserService {}
type UserRole = 'admin' | 'user';

// camelCase for variables, functions
const userName = 'John';
function getUser() {}

// UPPER_SNAKE_CASE for constants
const API_BASE_URL = 'https://api.example.com';

// Prefix interfaces with 'I' only when needed
interface UserRepository {}  // Good
interface IUserRepository {}  // Avoid unless necessary
```

## Type Annotations

```typescript
// Explicit for function params and returns
function getUser(id: string): Promise<User> {
  return api.fetchUser(id);
}

// Infer for variables when obvious
const count = 10;  // number inferred
const user: User = { id: '1', name: 'John', email: 'john@test.com' };
```

## Functions

```typescript
// Arrow functions for simple operations
const double = (x: number): number => x * 2;

// Named functions for complex logic
async function processUserData(user: User): Promise<void> {
  // Complex logic
}

// Use async/await over promises
async function fetchData(): Promise<Data> {
  const response = await fetch(url);
  return response.json();
}
```

## Interfaces vs Types

```typescript
// Use interface for object shapes
interface User {
  id: string;
  name: string;
}

// Use type for unions, intersections, utilities
type UserRole = 'admin' | 'user';
type UserWithRole = User & { role: UserRole };
```

## Error Handling

```typescript
class UserNotFoundError extends Error {
  constructor(id: string) {
    super(`User ${id} not found`);
    this.name = 'UserNotFoundError';
  }
}

async function getUser(id: string): Promise<User> {
  const user = await repository.findById(id);
  if (!user) throw new UserNotFoundError(id);
  return user;
}
```

## Null Safety

```typescript
// Use optional chaining
const email = user?.profile?.email;

// Use nullish coalescing
const name = user.name ?? 'Anonymous';

// Avoid null, prefer undefined
function findUser(id: string): User | undefined {
  return users.find(u => u.id === id);
}
```

## Generics

```typescript
function identity<T>(value: T): T {
  return value;
}

interface Repository<T> {
  findById(id: string): Promise<T | undefined>;
  save(item: T): Promise<T>;
}
```

## Best Practices

```typescript
// Use const for immutability
const users: ReadonlyArray<User> = [];

// Use type guards
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && obj !== null && 'id' in obj;
}

// Destructuring
const { id, name } = user;
const [first, ...rest] = items;

// Template literals
const message = `User ${name} created`;
```

## AI Self-Check

- [ ] Strict mode enabled (`strict: true`)?
- [ ] ESLint + Prettier configured?
- [ ] Explicit return types for public methods?
- [ ] Using unknown (not any)?
- [ ] Using const for immutable values?
- [ ] PascalCase for types/interfaces/classes?
- [ ] camelCase for variables/functions?
- [ ] No var (using const/let)?
- [ ] No Function type (specific signatures)?
- [ ] No ! (non-null assertion) without justification?
- [ ] No @ts-ignore (using @ts-expect-error if needed)?
- [ ] Readonly arrays/objects where appropriate?
