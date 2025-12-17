# React Framework

> **Scope**: Apply these rules when working with React applications (`.tsx` files).

## 1. Component Design
- **Functional Only**: No class components.
- **Single Responsibility**: One component, one purpose.
- **Composition**: Build complex UIs from simple components.

```tsx
// ✅ Good
const UserCard = ({ user }: { user: User }) => (
  <Card>
    <Avatar src={user.avatar} />
    <Text>{user.name}</Text>
  </Card>
);

// ❌ Bad
class UserCard extends React.Component { ... }
```

## 2. Hooks
- **useState**: For local component state.
- **useEffect**: For side effects (API calls, subscriptions).
- **useMemo/useCallback**: For expensive computations and stable references.
- **Custom Hooks**: Extract reusable logic into `use*` hooks.

```tsx
// ✅ Good - Custom hook
const useUser = (id: string) => {
  const [user, setUser] = useState<User | null>(null);
  useEffect(() => { fetchUser(id).then(setUser); }, [id]);
  return user;
};

// ❌ Bad - Logic in component
const UserPage = ({ id }) => {
  const [user, setUser] = useState(null);
  useEffect(() => { /* fetch logic */ }, []);
  // 100 more lines...
};
```

## 3. State Management
- **Local First**: Start with useState/useReducer.
- **Context**: For shared UI state (theme, auth status).
- **Zustand/Jotai**: For global app state.
- **React Query/SWR**: For server state (API data).

## 4. Props & Types
- **Interface for Props**: Define explicit prop types.
- **Destructure Props**: In function signature.
- **Default Props**: Use default parameters.

```tsx
// ✅ Good
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
}

const Button = ({ variant = 'primary', onClick, children }: ButtonProps) => (
  <button className={variant} onClick={onClick}>{children}</button>
);
```

## 5. Event Handling
- **Type Events**: Use React event types.
- **Prevent Default**: When needed.
- **No Inline Complex Logic**: Extract to functions.

```tsx
// ✅ Good
const handleSubmit = (e: React.FormEvent) => {
  e.preventDefault();
  onSubmit(formData);
};

// ❌ Bad
<form onSubmit={(e) => { e.preventDefault(); /* 20 lines */ }}>
```

## 6. Performance
- **React.memo**: For components with stable props.
- **useMemo/useCallback**: Prevent unnecessary recalculations.
- **Lazy Loading**: `React.lazy()` for code splitting.
- **Key Prop**: Always use unique, stable keys in lists.

