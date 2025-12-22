# TypeScript Architecture

> **Scope**: TypeScript architectural patterns and principles
> **Applies to**: *.ts, *.tsx files
> **Extends**: general/architecture.md
> **Precedence**: Structure > Framework > Language > General

## Rule Precedence Matrix

When rules conflict across multiple files, use this priority order:

| Your Context | Winning Rule File | Overrides |
|-------------|-------------------|-----------|
| React component structure | react.md → react-modular.md | TypeScript + General rules |
| Next.js Server Component | nextjs.md | React + TypeScript rules |
| Angular service | angular.md | TypeScript + General rules |
| Generic TypeScript class | **This file** | General rules only |
| NestJS controller | nestjs.md | TypeScript + General rules |

**Rule**: MOST SPECIFIC FILE ALWAYS WINS.

### Example Conflict Resolution

```
Context: React TypeScript component naming
Question: Should it be camelCase or PascalCase?

Precedence check:
1. Structure rules (react-modular.md)? → No naming guidance
2. Framework rules (react.md)? → "PascalCase for components" ← USE THIS
3. Language rules (this file)? → "camelCase for functions" ← IGNORE
4. General rules? → "camelCase" ← IGNORE

Answer: PascalCase (Framework rule wins over language rule)
```

```
Context: Generic TypeScript utility function
Question: How to structure error handling?

Precedence check:
1. Structure rules? → Not applicable (no structure selected)
2. Framework rules? → Not applicable (not framework-specific)
3. Language rules (this file)? → Use Result<T, E> type ← USE THIS
4. General rules? → Throw exceptions ← IGNORE (language rule more specific)

Answer: Use Result<T, E> (Language rule wins over general rule)
```

## Overview
Type-safe architecture with clean separation, modularity, and maintainability.

## Core Principles

### Type Safety
```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

// Avoid any
type UserData = Pick<User, 'name' | 'email'>;
```

### Immutability
```typescript
const user: Readonly<User> = { id: '1', name: 'John', email: 'john@test.com' };

// Use immutable operations
const updatedUsers = users.map(u => u.id === id ? { ...u, ...updates } : u);
```

### Error Handling
```typescript
type Result<T, E = Error> = { success: true; data: T } | { success: false; error: E };

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const user = await api.getUser(id);
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: error as Error };
  }
}
```

## Dependency Management

### Dependency Injection
```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<User>;
}

class UserService {
  constructor(private repository: UserRepository) {}
  
  async getUser(id: string): Promise<User> {
    const user = await this.repository.findById(id);
    if (!user) throw new Error('User not found');
    return user;
  }
}
```

### Interface Segregation
```typescript
interface Readable<T> {
  findById(id: string): Promise<T | null>;
  findAll(): Promise<T[]>;
}

interface Writable<T> {
  save(item: T): Promise<T>;
  delete(id: string): Promise<void>;
}

type Repository<T> = Readable<T> & Writable<T>;
```

## Modularity

### Feature Modules
```typescript
// user/index.ts
export { UserService } from './UserService';
export type { User } from './types';

// app.ts
import { UserService } from './user';
```

### Barrel Exports
```typescript
// features/index.ts
export * from './user';
export * from './post';
```

## Best Practices

### Strict Mode
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

### Use Enums/Unions
```typescript
type UserRole = 'admin' | 'user' | 'guest';

enum OrderStatus {
  Pending = 'PENDING',
  Shipped = 'SHIPPED',
  Delivered = 'DELIVERED'
}
```

### Utility Types
```typescript
type PartialUser = Partial<User>;
type RequiredUser = Required<User>;
type ReadonlyUser = Readonly<User>;
type UserWithoutEmail = Omit<User, 'email'>;
```
