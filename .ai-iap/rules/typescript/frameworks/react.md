# React Framework

> **Scope**: Apply these rules when working with React applications (`.tsx` files).
> **Applies to**: *.tsx, *.jsx files in React projects
> **Extends**: typescript/code-style.md, typescript/architecture.md
> **Precedence**: Framework rules OVERRIDE TypeScript rules for React-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use functional components with hooks (class components FORBIDDEN since React 16.8)
> **ALWAYS**: Include ALL dependencies in useEffect arrays (missing deps cause bugs)
> **ALWAYS**: Use PascalCase for component names (overrides TypeScript camelCase rule)
> **ALWAYS**: Extract complex logic to custom hooks (keep components simple)
> **ALWAYS**: Type all props with interfaces (NO implicit any)
> 
> **NEVER**: Generate class components (deprecated, lack modern React features)
> **NEVER**: Omit dependencies from useEffect (causes stale closures and bugs)
> **NEVER**: Use inline functions in JSX for complex logic (extract to named functions)
> **NEVER**: Use array index as key prop (causes rendering bugs)
> **NEVER**: Mutate state directly (always use setState functions)

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

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

### Mistake 1: Missing useEffect Dependencies ⚠️ CRITICAL
```tsx
// ❌ WRONG - Common AI error (causes stale closure bug)
useEffect(() => {
  fetchUser(userId);  // Uses userId...
  updateFilter(filter);  // Uses filter...
}, []);  // ...but dependencies NOT included! CAUSES BUGS!

// ❌ WRONG - Partial dependencies (still buggy)
useEffect(() => {
  fetchUser(userId);
  updateFilter(filter);
}, [userId]);  // Missing filter! Will not update when filter changes!

// ✅ CORRECT - ALL dependencies included (REQUIRED)
useEffect(() => {
  fetchUser(userId);
  updateFilter(filter);
}, [userId, filter]);  // ← Both dependencies included
```
**Why wrong**: Stale closures - effect uses old values when deps change  
**Why critical**: Most common React bug, hard to debug  
**How to fix**: Include EVERY variable/prop/state used inside effect

### Mistake 2: Class Components ⚠️ FORBIDDEN
```tsx
// ❌ WRONG - Class component (DO NOT GENERATE THIS)
class UserCard extends React.Component<Props> {
  render() {
    return <div>{this.props.user.name}</div>;
  }
}

// ❌ WRONG - Class with state (STILL FORBIDDEN)
class UserCard extends React.Component<Props, State> {
  state = { loading: false };
  render() { /* ... */ }
}

// ✅ CORRECT - Functional component (REQUIRED)
const UserCard: React.FC<Props> = ({ user }) => {
  return <div>{user.name}</div>;
};

// ✅ CORRECT - Functional with state (use useState hook)
const UserCard: React.FC<Props> = ({ user }) => {
  const [loading, setLoading] = useState(false);
  return <div>{user.name}</div>;
};
```
**Why wrong**: Class components deprecated, lack concurrent features, verbose  
**Why critical**: React 18+ concurrent mode requires hooks (unavailable in classes)  
**How to fix**: ALWAYS use functional components with hooks

### Mistake 3: Component Naming (camelCase vs PascalCase)
```tsx
// ❌ WRONG - camelCase (violates React convention)
const userProfile = ({ user }: Props) => {  // Lowercase = not a component
  return <div>{user.name}</div>;
};

// ❌ WRONG - Using it (won't work properly)
<userProfile user={user} />  // React treats lowercase as HTML element

// ✅ CORRECT - PascalCase (REQUIRED for components)
const UserProfile = ({ user }: Props) => {  // Uppercase = component
  return <div>{user.name}</div>;
};

// ✅ CORRECT - Usage
<UserProfile user={user} />  // Properly recognized as React component
```
**Why wrong**: React convention requires PascalCase, tooling expects it  
**Why critical**: Lowercase treated as HTML elements, not components  
**How to fix**: ALWAYS PascalCase for components (overrides TypeScript camelCase)

### Mistake 4: Array Index as Key
```tsx
// ❌ WRONG - Using array index as key (causes bugs)
{users.map((user, index) => (
  <UserCard key={index} user={user} />  // ← Index changes on reorder!
))}

// ✅ CORRECT - Use stable unique ID (REQUIRED)
{users.map(user => (
  <UserCard key={user.id} user={user} />  // ← Stable ID
))}

// ✅ CORRECT - If no ID, generate stable key
{users.map(user => (
  <UserCard key={`user-${user.email}`} user={user} />
))}
```
**Why wrong**: Index changes when list reorders, causes wrong component updates  
**Why critical**: Leads to state bugs, form inputs losing data  
**How to fix**: Use unique stable identifier (id, email, etc.)

### Mistake 5: Inline Functions in Lists
```tsx
// ❌ WRONG - New function every render (causes performance issues)
{users.map(user => (
  <UserCard 
    key={user.id}
    onClick={() => navigate(`/user/${user.id}`)}  // ← New function each render!
  />
))}

// ✅ CORRECT - Extract function with useCallback
const handleUserClick = useCallback((id: string) => {
  navigate(`/user/${id}`);
}, [navigate]);

{users.map(user => (
  <UserCard 
    key={user.id}
    onClick={() => handleUserClick(user.id)}  // Better, but still creates function
  />
))}

// ✅ BEST - Pass stable reference
{users.map(user => (
  <UserCard 
    key={user.id}
    userId={user.id}
    onUserClick={handleUserClick}  // ← Stable reference, no new functions
  />
))}
```
**Why wrong**: Creates new function references, triggers child re-renders  
**Why critical**: Performance issues in large lists  
**How to fix**: Use useCallback or pass stable handlers

## AI Self-Check (Verify BEFORE generating React code)

Before generating any React component, verify:
- [ ] Functional component? (NOT class - classes are forbidden)
- [ ] PascalCase name? (NOT camelCase - required for components)
- [ ] All useEffect dependencies included? (Check each variable used inside)
- [ ] Proper key prop in lists? (NOT index - use unique ID)
- [ ] Props typed with interface? (NO implicit any)
- [ ] Component < 200 lines? (If larger, split into smaller components)
- [ ] Complex logic extracted to custom hooks? (Keep component simple)

**If ANY checkbox is unchecked, DO NOT generate code. Fix the issue first.**

## 6. Performance
- **React.memo**: For components with stable props
- **useMemo/useCallback**: Prevent unnecessary recalculations
- **Lazy Loading**: `React.lazy()` for code splitting
- **Key Prop**: Always use unique, stable keys in lists

