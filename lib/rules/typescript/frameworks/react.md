# React Framework

> **Scope**: React 18+ applications
> **Applies to**: .tsx files
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use functional components with hooks
> **ALWAYS**: Use TypeScript for props/state
> **ALWAYS**: Clean up effects with return function
> **ALWAYS**: Use key prop for lists (stable IDs, not index)
> **ALWAYS**: Follow Rules of Hooks
> 
> **NEVER**: Use class components in new code (except error boundaries)
> **NEVER**: Mutate state directly
> **NEVER**: Call hooks conditionally
> **NEVER**: Forget effect dependencies
> **NEVER**: Use index as key for dynamic lists

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
useEffect(() => {
  const controller = new AbortController()
  fetch(`/api/users/${userId}`, { signal: controller.signal })
    .then(res => res.json()).then(setUser)
  return () => controller.abort()  // Cleanup on unmount
}, [userId])
```

### Performance Optimization

```typescript
// Memoize callbacks
const handleSelect = useCallback((id: number) => onSelect(id), [onSelect])

// Memoize expensive calculations
const sortedItems = useMemo(() => [...items].sort((a, b) => a.name.localeCompare(b.name)), [items])
```

### Custom Hook

```typescript
function useUser(userId: number) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(setUser)
      .finally(() => setLoading(false))
  }, [userId])
  return { user, loading }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Direct Mutation** | `state.push(item)` | `setState([...state, item])` |
| **Missing Dependencies** | `useEffect(() => {}, [])` with closures | Include all dependencies |
| **Index as Key** | `key={index}` | `key={item.id}` |
| **Conditional Hooks** | `if (x) { useState() }` | Hooks at top level |

### Anti-Patterns

❌ **Direct Mutation**: `setUsers(users.push(newUser))` → Mutates state!  
✅ **Immutable Update**: `setUsers([...users, newUser])`

❌ **Missing Dependencies**: `useEffect(() => fetchData(userId), [])` → Stale closure!  
✅ **Include Dependencies**: `useEffect(() => fetchData(userId), [userId])`

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
