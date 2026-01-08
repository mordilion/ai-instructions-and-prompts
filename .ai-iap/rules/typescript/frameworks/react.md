# React Framework

> **Scope**: React 18+ applications
> **Applies to**: .tsx and .jsx files
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use functional components with hooks  
> **Why**: React 18+ optimizations (Concurrent Rendering, Suspense, Transitions) work best with hooks. Cleaner code, better composition.
> 
> **ALWAYS**: Use TypeScript for props/state  
> **Why**: Catches prop/state errors at compile-time, improves IDE autocomplete, self-documenting interfaces.
> 
> **ALWAYS**: Clean up effects with return function  
> **Why**: Prevents memory leaks, race conditions, and stale closures when components unmount or re-render.
> 
> **ALWAYS**: Use key prop for lists  
> **Why**: React needs stable identity to efficiently update/reorder list items without re-creating DOM nodes.
> 
> **ALWAYS**: Follow Rules of Hooks  
> **Why**: React relies on hook call order to maintain state. Conditional hooks break this contract and cause bugs.
> 
> **NEVER**: Use class components (NEW code)  
> **Why**: Deprecated pattern. Verbose, harder to test, can't use hooks, no concurrent features. **Exception**: Error boundaries until React 19.
> 
> **NEVER**: Mutate state directly  
> **Why**: React uses reference equality to detect changes. Mutation bypasses React's reconciliation, causing missed updates.
> 
> **NEVER**: Call hooks conditionally  
> **Why**: Violates Rules of Hooks. React tracks hooks by call order - conditionals break this, causing state mismatch.
> 
> **NEVER**: Forget effect dependencies  
> **Why**: Stale closures capture old values, causing bugs. Linter (`react-hooks/exhaustive-deps`) catches these.
> 
> **NEVER**: Use index as key for dynamic lists  
> **Why**: Index changes when items reorder, causing React to recreate components instead of moving them. Use stable IDs.

## Core Patterns

### Component with Props

```typescript
interface UserCardProps {
  user: User
  onDelete?: (id: number) => void
}

export function UserCard({ user, onDelete }: UserCardProps) {
  return (
    <div className="card">
      <h3>{user.name}</h3>
      <button onClick={() => onDelete?.(user.id)}>Delete</button>
    </div>
  )
}
```

### State Management

```typescript
function Counter() {
  const [count, setCount] = useState(0)
  
  const increment = () => setCount(prev => prev + 1)
  
  return <button onClick={increment}>Count: {count}</button>
}
```

### Effects with Cleanup

```typescript
function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null)
  
  useEffect(() => {
    const controller = new AbortController()
    
    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then(res => res.json())
      .then(setUser)
    
    return () => controller.abort()  // Cleanup
  }, [userId])
  
  return user ? <div>{user.name}</div> : <div>Loading...</div>
}
```

### Performance Optimization

```typescript
function ExpensiveComponent({ items, onSelect }: Props) {
  // Memoize callback
  const handleSelect = useCallback((id: number) => {
    onSelect(id)
  }, [onSelect])
  
  // Memoize expensive calculation
  const sortedItems = useMemo(() => 
    [...items].sort((a, b) => a.name.localeCompare(b.name))
  , [items])
  
  return (
    <ul>
      {sortedItems.map(item => (
        <li key={item.id} onClick={() => handleSelect(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  )
}
```

### Custom Hook

```typescript
function useUser(userId: number) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    setLoading(true)
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)
        setLoading(false)
      })
  }, [userId])
  
  return { user, loading }
}

// Usage
function UserProfile({ userId }: Props) {
  const { user, loading } = useUser(userId)
  
  if (loading) return <div>Loading...</div>
  return <div>{user?.name}</div>
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct Mutation** | `state.push(item)` | `setState([...state, item])` |
| **Missing Dependencies** | `useEffect(() => {}, [])` with closures | Include all dependencies |
| **Index as Key** | `key={index}` | `key={item.id}` |
| **Conditional Hooks** | `if (x) { useState() }` | Hooks at top level |

### Anti-Pattern: Direct Mutation

```typescript
// ❌ WRONG
setUsers(users.push(newUser))  // Mutates!

// ✅ CORRECT
setUsers([...users, newUser])
```

### Anti-Pattern: Missing Dependencies

```typescript
// ❌ WRONG
useEffect(() => {
  fetchData(userId)  // userId not in deps!
}, [])

// ✅ CORRECT
useEffect(() => {
  fetchData(userId)
}, [userId])
```

## AI Self-Check

- [ ] Functional components only?
- [ ] TypeScript for props?
- [ ] Hooks at top level?
- [ ] Effect cleanup functions?
- [ ] All dependencies listed?
- [ ] Stable keys for lists?
- [ ] useCallback for callbacks?
- [ ] useMemo for expensive calculations?
- [ ] Custom hooks for reusable logic?
- [ ] No direct state mutation?

## Key Hooks

| Hook | Purpose |
|------|---------|
| `useState` | Component state |
| `useEffect` | Side effects |
| `useCallback` | Memoize callbacks |
| `useMemo` | Memoize values |
| `useRef` | Persistent values |
| `useContext` | Context API |

## Best Practices

**MUST**: Functional components, TypeScript, hooks rules, effect cleanup
**SHOULD**: useCallback, useMemo, custom hooks, stable keys
**AVOID**: Class components, mutations, missing dependencies, index keys
