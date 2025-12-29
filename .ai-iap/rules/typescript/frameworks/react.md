# React Framework

> **Scope**: Apply these rules when working with React 18+ applications
> **Applies to**: .tsx and .jsx files in React projects
> **Extends**: typescript/architecture.md, typescript/code-style.md
> **Precedence**: Framework rules OVERRIDE TypeScript rules for React-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use functional components with hooks (NOT class components)
> **ALWAYS**: Use TypeScript for props and state (type safety required)
> **ALWAYS**: Use useCallback/useMemo for expensive operations (performance)
> **ALWAYS**: Clean up effects with return function (prevent memory leaks)
> **ALWAYS**: Use key prop for lists (stable identity)
> 
> **NEVER**: Use class components in new code (legacy pattern)
> **NEVER**: Mutate state directly (use setState or state updater)
> **NEVER**: Call hooks conditionally (breaks Rules of Hooks)
> **NEVER**: Forget dependencies in useEffect/useCallback (stale closures)
> **NEVER**: Use index as key for dynamic lists (causes bugs)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Functional Components | Always (React 16.8+) | `function Component() {}`, arrow functions |
| useState | Component-local state | `const [state, setState] = useState()` |
| useEffect | Side effects, subscriptions | `useEffect(() => {}, [deps])` |
| useCallback | Memoize callbacks | `useCallback(() => {}, [deps])` |
| useMemo | Memoize expensive calculations | `useMemo(() => compute(), [deps])` |
| Custom Hooks | Reusable logic | `function useCustomHook() {}` |

## Core Patterns

### Functional Component with Props
```typescript
interface UserCardProps {
  user: User
  onDelete?: (id: number) => void
}

export function UserCard({ user, onDelete }: UserCardProps) {
  const handleDelete = () => {
    onDelete?.(user.id)
  }
  
  return (
    <div className="card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <button onClick={handleDelete}>Delete</button>
    </div>
  )
}
```

### State Management with useState
```typescript
function Counter() {
  const [count, setCount] = useState(0)
  
  // ✅ CORRECT - Functional update
  const increment = () => setCount(prev => prev + 1)
  
  // ❌ WRONG - Direct mutation
  // const increment = () => count++  // DOESN'T WORK!
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
    </div>
  )
}
```

### Effects with Cleanup
```typescript
function ChatRoom({ roomId }: { roomId: string }) {
  const [messages, setMessages] = useState<Message[]>([])
  
  useEffect(() => {
    const subscription = chatAPI.subscribe(roomId, (message) => {
      setMessages(prev => [...prev, message])
    })
    
    // ✅ Cleanup function (prevents memory leaks)
    return () => subscription.unsubscribe()
  }, [roomId])  // Re-run when roomId changes
  
  return <MessageList messages={messages} />
}
```

### Custom Hooks (Reusable Logic)
```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  
  useEffect(() => {
    let cancelled = false
    
    fetch(url)
      .then(res => res.json())
      .then(data => {
        if (!cancelled) {
          setData(data)
          setLoading(false)
        }
      })
      .catch(err => {
        if (!cancelled) {
          setError(err)
          setLoading(false)
        }
      })
    
    return () => { cancelled = true }  // Cleanup
  }, [url])
  
  return { data, loading, error }
}

// Usage
function UserList() {
  const { data, loading, error } = useFetch<User[]>('/api/users')
  
  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  
  return (
    <ul>
      {data?.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  )
}
```

### Performance Optimization
```typescript
function ProductList({ products, onSelect }: ProductListProps) {
  // ✅ Memoize callback to prevent child re-renders
  const handleSelect = useCallback((id: number) => {
    onSelect(id)
  }, [onSelect])
  
  // ✅ Memoize expensive calculation
  const sortedProducts = useMemo(() => {
    return [...products].sort((a, b) => a.price - b.price)
  }, [products])
  
  return (
    <div>
      {sortedProducts.map(product => (
        <ProductCard
          key={product.id}
          product={product}
          onSelect={handleSelect}
        />
      ))}
    </div>
  )
}
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Class Components** | `class Component extends React.Component` | Functional components + hooks | Legacy pattern |
| **Mutating State** | `state.count++` or `user.name = 'x'` | `setState` with new object | React won't re-render |
| **Conditional Hooks** | `if (x) { useState() }` | Always call hooks unconditionally | Breaks React internals |
| **Missing Dependencies** | `useEffect(() => {}, [])` with stale closure | Include all dependencies | Stale values, bugs |
| **Index as Key** | `key={index}` for dynamic lists | `key={item.id}` | Causes rendering bugs |

### Anti-Pattern: Class Components (FORBIDDEN in new code)
```typescript
// ❌ WRONG - Class component (legacy)
class Counter extends React.Component {
  state = { count: 0 }
  
  increment = () => {
    this.setState({ count: this.state.count + 1 })
  }
  
  render() {
    return <button onClick={this.increment}>{this.state.count}</button>
  }
}

// ✅ CORRECT - Functional component
function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}
```

### Anti-Pattern: Conditional Hooks (BREAKS REACT)
```typescript
// ❌ WRONG - Conditional hook call
function Component({ show }: { show: boolean }) {
  if (show) {
    const [state, setState] = useState(0)  // BREAKS RULES OF HOOKS!
  }
  return <div>...</div>
}

// ✅ CORRECT - Always call hooks unconditionally
function Component({ show }: { show: boolean }) {
  const [state, setState] = useState(0)  // Always called
  
  if (!show) return null  // Conditional rendering
  
  return <div>{state}</div>
}
```

### Anti-Pattern: Missing Dependencies (STALE CLOSURES)
```typescript
// ❌ WRONG - Missing dependency
function SearchResults({ query }: { query: string }) {
  useEffect(() => {
    fetchResults(query)  // Uses 'query' but not in deps!
  }, [])  // Only runs once with initial query value
}

// ✅ CORRECT - Include all dependencies
function SearchResults({ query }: { query: string }) {
  useEffect(() => {
    fetchResults(query)
  }, [query])  // Re-runs when query changes
}
```

## AI Self-Check (Verify BEFORE generating React code)

- [ ] Using functional components? (NOT class components)
- [ ] Props typed with TypeScript interface?
- [ ] Using useState for state? (NOT direct mutation)
- [ ] useEffect has cleanup function? (If needed)
- [ ] All dependencies in useEffect/useCallback? (No stale closures)
- [ ] Hooks called unconditionally? (NOT in if/loops)
- [ ] Keys for lists use stable IDs? (NOT index)
- [ ] useCallback/useMemo for performance? (When appropriate)
- [ ] Event handlers properly bound?
- [ ] Following React naming conventions?

## Hooks

| Hook | Purpose | Example |
|------|---------|---------|
| useState | Local state | `const [count, setCount] = useState(0)` |
| useEffect | Side effects | `useEffect(() => { }, [deps])` |
| useContext | Context consumer | `const value = useContext(MyContext)` |
| useReducer | Complex state | `const [state, dispatch] = useReducer(reducer, init)` |
| useCallback | Memoize callbacks | `useCallback(() => { }, [deps])` |
| useMemo | Memoize values | `useMemo(() => compute(), [deps])` |
| useRef | DOM refs, mutable values | `const ref = useRef<HTMLDivElement>(null)` |

## Context API

```typescript
const UserContext = createContext<User | null>(null)

function App() {
  const [user, setUser] = useState<User | null>(null)
  
  return (
    <UserContext.Provider value={user}>
      <Dashboard />
    </UserContext.Provider>
  )
}

function Dashboard() {
  const user = useContext(UserContext)
  return <div>Welcome, {user?.name}</div>
}
```

## Key Libraries

- **React Router**: `useNavigate`, `useParams`, `Link`
- **React Query**: `useQuery`, `useMutation`
- **Zustand/Redux**: Global state management
- **React Hook Form**: Form handling
