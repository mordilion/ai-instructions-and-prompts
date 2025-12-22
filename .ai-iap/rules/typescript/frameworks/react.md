# React Framework

> **Scope**: Apply these rules when working with React applications (`.tsx` files).

## Overview
React: JavaScript library for building user interfaces using components and declarative syntax.
Virtual DOM for efficient updates, one-way data flow, and huge ecosystem of libraries.
Best for interactive web UIs, SPAs, and when you need component reusability across projects.

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

## Pattern Selection

### State Management
**Use useState when**:
- Local component state
- Simple values (strings, numbers, booleans)
- State doesn't need to be shared

**Use useReducer when**:
- Complex state logic with multiple sub-values
- State transitions based on previous state
- Multiple actions that update state

**Use Context when**:
- Sharing state across many components (theme, auth, locale)
- Avoiding prop drilling
- UI state (NOT server data)

**Use React Query/SWR when**:
- Server state (API data)
- Need caching, refetching, mutations
- Async data management

## Best Practices

**MUST**:
- Use functional components with hooks (NO class components)
- Use TypeScript with proper types (NO `any`)
- Keep components small (< 200 lines - extract subcomponents)
- Use custom hooks for reusable logic (`useUser`, `useAuth`)
- Always include dependency arrays in useEffect

**SHOULD**:
- Use React.memo for expensive renders with stable props
- Use useMemo/useCallback to prevent unnecessary recalculations
- Use React.lazy() for code splitting large components
- Use unique, stable keys in lists (NOT index)
- Extract event handlers to named functions

**AVOID**:
- Prop drilling (use Context or state management)
- Inline functions in JSX (causes re-renders)
- Missing dependencies in useEffect (causes bugs)
- Mutating state directly (use setState)
- God components (split into smaller components)

## Common Patterns

### Custom Hooks
```tsx
// ✅ GOOD: Reusable logic in custom hook
const useUser = (id: string) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchUser(id)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [id]);  // Dependency array prevents infinite loops
  
  return { user, loading };
};

// Usage
const UserProfile = ({ userId }: { userId: string }) => {
  const { user, loading } = useUser(userId);  // Clean, reusable
  if (loading) return <Loading />;
  return <Profile user={user} />;
};

// ❌ BAD: Logic in component
const UserProfile = ({ userId }: { userId: string }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);
  // Repeated in every component that needs user data
};
```

### Performance Optimization
```tsx
// ✅ GOOD: React.memo prevents unnecessary renders
const ExpensiveComponent = React.memo(({ data }: { data: Data }) => {
  return <div>{/* Expensive rendering */}</div>;
});

// ✅ GOOD: useCallback for stable function reference
const UserList = () => {
  const handleClick = useCallback((id: string) => {
    navigate(`/user/${id}`);
  }, [navigate]);  // Function reference stays same between renders
  
  return users.map(u => <UserCard key={u.id} onClick={handleClick} />);
};

// ❌ BAD: New function every render (causes child re-renders)
const UserList = () => {
  return users.map(u => (
    <UserCard 
      key={u.id} 
      onClick={(id) => navigate(`/user/${id}`)}  // New function each render!
    />
  ));
};
```

### useEffect Dependencies
```tsx
// ✅ GOOD: All dependencies included
useEffect(() => {
  fetchData(userId, filter);
}, [userId, filter]);  // Updates when either changes

// ❌ BAD: Missing dependencies
useEffect(() => {
  fetchData(userId, filter);
}, [userId]);  // filter changes ignored! Bug!

// ❌ BAD: Empty array when should have dependencies
useEffect(() => {
  console.log(count);  // Always logs initial count (0)
}, []);  // Should include [count]
```

## 6. Performance
- **React.memo**: For components with stable props
- **useMemo/useCallback**: Prevent unnecessary recalculations
- **Lazy Loading**: `React.lazy()` for code splitting
- **Key Prop**: Always use unique, stable keys in lists

