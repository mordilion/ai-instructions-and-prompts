# React Modular Structure

> Organize by feature/module with co-located concerns. Best for medium to large apps where features are relatively independent.

## Directory Structure

```
src/features/user/
├── components/
│   ├── UserList.tsx
│   └── UserDetail.tsx
├── hooks/
│   └── useUsers.ts
├── services/
│   └── userService.ts
├── types/
│   └── User.ts
└── index.ts
```

## Implementation

```typescript
// types/User.ts
export interface User {
  id: string;
  name: string;
}

// services/userService.ts
export const userService = {
  async getUsers(): Promise<User[]> {
    const res = await fetch('/api/users');
    return res.json();
  }
};

// hooks/useUsers.ts
export function useUsers() {
  const [users, setUsers] = useState<User[]>([]);
  
  useEffect(() => {
    userService.getUsers().then(setUsers);
  }, []);
  
  return users;
}

// components/UserList.tsx
export function UserList() {
  const users = useUsers();
  
  return (
    <ul>
      {users.map(u => <li key={u.id}>{u.name}</li>)}
    </ul>
  );
}
```

## When to Use
- Medium to large apps
- Feature-focused development
