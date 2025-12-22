# TypeScript Architecture

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
