# React Modular Structure

> Organize by feature/module with co-located concerns. Best for medium to large apps where features are relatively independent.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Co-locate feature concerns (components, hooks, services, types)
> **ALWAYS**: Export through feature index.ts
> **ALWAYS**: Keep shared code in separate directory
> **NEVER**: Cross-feature imports (use shared/)
> **NEVER**: Deep imports (use index.ts barrel exports)

## Full Directory Structure

```
src/
├── features/              # Feature modules
│   ├── auth/
│   │   ├── components/    # Feature-specific UI
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/         # Feature-specific hooks
│   │   │   ├── useAuth.ts
│   │   │   └── useAuthUser.ts
│   │   ├── services/      # Feature API calls
│   │   │   └── authService.ts
│   │   ├── types/         # Feature types
│   │   │   └── Auth.ts
│   │   ├── utils/         # Feature utilities
│   │   │   └── validators.ts
│   │   └── index.ts       # Public exports
│   │
│   ├── user/
│   │   ├── components/
│   │   │   ├── UserList.tsx
│   │   │   ├── UserDetail.tsx
│   │   │   └── UserForm.tsx
│   │   ├── hooks/
│   │   │   ├── useUsers.ts
│   │   │   └── useUserDetail.ts
│   │   ├── services/
│   │   │   └── userService.ts
│   │   ├── types/
│   │   │   └── User.ts
│   │   └── index.ts
│   │
│   └── dashboard/
│       ├── components/
│       ├── hooks/
│       └── index.ts
│
├── shared/                # Cross-feature code
│   ├── components/        # Reusable UI (Button, Modal)
│   ├── hooks/             # Reusable hooks (useDebounce)
│   ├── services/          # Shared API (httpClient)
│   ├── types/             # Shared types (ApiResponse)
│   ├── utils/             # Utilities (formatDate)
│   └── constants/         # App-wide constants
│
├── app/                   # App-level concerns
│   ├── App.tsx
│   ├── routes.tsx
│   └── providers.tsx
│
└── main.tsx               # Entry point
```

## Complete Implementation Example

### Feature Types

```typescript
// features/user/types/User.ts
export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  createdAt: Date;
}

export interface CreateUserDto {
  name: string;
  email: string;
}
```

### Feature Service

```typescript
// features/user/services/userService.ts
import { httpClient } from '@/shared/services/httpClient';
import { User, CreateUserDto } from '../types/User';

export const userService = {
  async getAll(): Promise<User[]> {
    return httpClient.get<User[]>('/api/users');
  },
  
  async getById(id: string): Promise<User> {
    return httpClient.get<User>(`/api/users/${id}`);
  },
  
  async create(data: CreateUserDto): Promise<User> {
    return httpClient.post<User>('/api/users', data);
  },
  
  async delete(id: string): Promise<void> {
    return httpClient.delete(`/api/users/${id}`);
  }
};
```

### Feature Hooks

```typescript
// features/user/hooks/useUsers.ts
import { useState, useEffect } from 'react';
import { User } from '../types/User';
import { userService } from '../services/userService';

export function useUsers() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    const controller = new AbortController();
    
    userService.getAll()
      .then(setUsers)
      .catch(setError)
      .finally(() => setLoading(false));
    
    return () => controller.abort();
  }, []);
  
  return { users, loading, error };
}

// features/user/hooks/useUserDetail.ts
export function useUserDetail(id: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    userService.getById(id)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [id]);
  
  return { user, loading };
}
```

### Feature Components

```typescript
// features/user/components/UserList.tsx
import { useUsers } from '../hooks/useUsers';
import { LoadingSpinner } from '@/shared/components/LoadingSpinner';
import { ErrorMessage } from '@/shared/components/ErrorMessage';

export function UserList() {
  const { users, loading, error } = useUsers();
  
  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return (
    <ul className="user-list">
      {users.map(user => (
        <li key={user.id}>
          <UserCard user={user} />
        </li>
      ))}
    </ul>
  );
}

// features/user/components/UserDetail.tsx
import { useUserDetail } from '../hooks/useUserDetail';

interface UserDetailProps {
  userId: string;
}

export function UserDetail({ userId }: UserDetailProps) {
  const { user, loading } = useUserDetail(userId);
  
  if (loading) return <LoadingSpinner />;
  if (!user) return <div>User not found</div>;
  
  return (
    <div className="user-detail">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}
```

### Feature Barrel Export

```typescript
// features/user/index.ts
// Public API of user feature
export { UserList } from './components/UserList';
export { UserDetail } from './components/UserDetail';
export { useUsers } from './hooks/useUsers';
export type { User } from './types/User';

// DO NOT export:
// - userService (internal implementation)
// - internal components
// - utility functions
```

## Cross-Cutting Concerns

### Shared HTTP Client

```typescript
// shared/services/httpClient.ts
export const httpClient = {
  async get<T>(url: string): Promise<T> {
    const res = await fetch(url);
    if (!res.ok) throw new Error(res.statusText);
    return res.json();
  },
  
  async post<T>(url: string, data: unknown): Promise<T> {
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(res.statusText);
    return res.json();
  }
};
```

### Shared Components

```typescript
// shared/components/LoadingSpinner.tsx
export function LoadingSpinner() {
  return <div className="spinner">Loading...</div>;
}

// shared/components/ErrorMessage.tsx
interface ErrorMessageProps {
  error: Error;
}

export function ErrorMessage({ error }: ErrorMessageProps) {
  return <div className="error">{error.message}</div>;
}
```

## Feature Communication

### ❌ **WRONG**: Direct cross-feature imports

```typescript
// features/dashboard/components/Dashboard.tsx
import { userService } from '../../user/services/userService'; // ❌ BAD
```

### ✅ **CORRECT**: Through shared services or props

```typescript
// features/dashboard/components/Dashboard.tsx
import { useUsers } from '@/features/user'; // ✅ Public API

// OR: Pass data via props
interface DashboardProps {
  users: User[]; // From parent
}
```

## Testing Strategy

```typescript
// features/user/hooks/useUsers.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { useUsers } from './useUsers';
import { userService } from '../services/userService';

jest.mock('../services/userService');

test('loads users', async () => {
  const mockUsers = [{ id: '1', name: 'John' }];
  (userService.getAll as jest.Mock).mockResolvedValue(mockUsers);
  
  const { result } = renderHook(() => useUsers());
  
  expect(result.current.loading).toBe(true);
  
  await waitFor(() => {
    expect(result.current.users).toEqual(mockUsers);
    expect(result.current.loading).toBe(false);
  });
});
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Cross-feature imports** | `features/dashboard` → `features/user/services` | Use public API via `index.ts` |
| **No barrel exports** | Direct file imports | Export through `index.ts` |
| **Shared in feature** | Button in `features/user/components` | Move to `shared/components` |
| **Deep imports** | `features/user/components/UserList` | `features/user` (via index.ts) |

## When to Use

✅ **Use Modular Structure if**:
- Medium to large apps (5+ features)
- Features are relatively independent
- Team scales by feature (auth team, user team)
- Clear feature boundaries

❌ **Don't use if**:
- Small app (<3 features) → Use simpler structure
- Highly interconnected features → Consider layered
- Atomic design focus → Use react-atomic

## Migration from Other Structures

**From flat structure**:
1. Group related files into features
2. Create `index.ts` barrel exports
3. Move shared code to `shared/`
4. Update imports gradually

**From layered structure**:
1. Identify feature boundaries
2. Move components, hooks, services together
3. Keep infrastructure in `shared/`

## Benefits

- ✅ Co-located code (easy to find/change)
- ✅ Clear feature boundaries
- ✅ Easy to add/remove features
- ✅ Scalable team organization
- ✅ Reduced merge conflicts
