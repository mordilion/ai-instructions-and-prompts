# React Modular Structure

> Organize by feature/module with co-located concerns. Best for medium to large apps where features are relatively independent.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Co-locate feature concerns (components, hooks, services, types)  
> **ALWAYS**: Export through feature index.ts (barrel pattern)  
> **ALWAYS**: Keep shared code in `shared/`  
> **NEVER**: Cross-feature imports (feature-a → feature-b)  
> **NEVER**: Deep imports (use barrel exports)

## Directory Structure

```
src/
├── features/{feature-name}/
│   ├── components/    # Feature-specific UI
│   ├── hooks/         # Feature-specific hooks
│   ├── services/      # Feature API calls
│   ├── types/         # Feature types
│   └── index.ts       # Public API
├── shared/            # Cross-feature code
│   ├── components/, hooks/, services/, types/, utils/
├── app/               # App-level (routes, providers)
└── main.tsx
```

## Core Pattern (One Example)

```typescript
// features/user/types/User.ts
export interface User { id: string; name: string; email: string }

// features/user/services/userService.ts
export const userService = {
  async getAll(): Promise<User[]> { return httpClient.get('/api/users') }
}

// features/user/hooks/useUsers.ts
export function useUsers() {
  const [users, setUsers] = useState<User[]>([])
  useEffect(() => { userService.getAll().then(setUsers) }, [])
  return users
}

// features/user/components/UserList.tsx
export function UserList() {
  const users = useUsers()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// features/user/index.ts - Public API
export { UserList } from './components/UserList'
export { useUsers } from './hooks/useUsers'
export type { User } from './types/User'
// DON'T export: userService (internal)
```

## Cross-Feature Communication

```typescript
// ❌ WRONG: Direct import
import { userService } from '../../user/services/userService'

// ✅ CORRECT: Use public API or props
import { useUsers } from '@/features/user'
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Cross-feature imports | Use public API via `index.ts` |
| No barrel exports | Export through `index.ts` |
| Shared code in features | Move to `shared/` |

## When to Use

- ✅ Medium/large apps (5+ features)
- ✅ Independent features
- ❌ Small apps (<3 features)
- ❌ Highly interconnected features
