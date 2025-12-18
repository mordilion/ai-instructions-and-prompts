# Preact

> **Scope**: Apply these rules when working with Preact, the lightweight (3kB) React alternative.

## 1. When to Use Preact
- **Performance Critical**: Smaller bundle size than React.
- **React Compatibility**: Drop-in replacement via `preact/compat`.
- **Embedded Widgets**: Third-party embeds, performance-sensitive contexts.

## 2. Component Syntax
```jsx
import { h } from 'preact';
import { useState, useEffect } from 'preact/hooks';

// Functional component (same as React)
const UserCard = ({ user, onDelete }) => {
  const [loading, setLoading] = useState(false);

  const handleDelete = async () => {
    setLoading(true);
    await onDelete(user.id);
    setLoading(false);
  };

  return (
    <div class="card">
      <h3>{user.name}</h3>
      <button onClick={handleDelete} disabled={loading}>
        {loading ? 'Deleting...' : 'Delete'}
      </button>
    </div>
  );
};
```

## 3. Key Differences from React
| Feature | React | Preact |
|---------|-------|--------|
| Attribute names | `className`, `htmlFor` | `class`, `for` (both work) |
| Event handlers | `onChange` | `onInput` (for real-time) |
| createElement | `React.createElement` | `h` |
| Synthetic events | Yes | No (uses native) |

```jsx
// Preact prefers native attribute names
<label for="email" class="label">
  <input id="email" class="input" onInput={handleInput} />
</label>
```

## 4. Hooks (Same API as React)
```jsx
import { useState, useEffect, useRef, useMemo, useCallback } from 'preact/hooks';

const SearchList = ({ items }) => {
  const [query, setQuery] = useState('');
  const inputRef = useRef(null);

  const filtered = useMemo(
    () => items.filter(item => item.name.includes(query)),
    [items, query]
  );

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return (
    <div>
      <input ref={inputRef} value={query} onInput={e => setQuery(e.target.value)} />
      <ul>
        {filtered.map(item => <li key={item.id}>{item.name}</li>)}
      </ul>
    </div>
  );
};
```

## 5. Signals (Preact-specific State)
```jsx
import { signal, computed } from '@preact/signals';

// Global reactive state (no Context needed)
const count = signal(0);
const doubled = computed(() => count.value * 2);

// Use directly in components
const Counter = () => (
  <div>
    <p>Count: {count} (doubled: {doubled})</p>
    <button onClick={() => count.value++}>Increment</button>
  </div>
);
```

## 6. React Compatibility (preact/compat)
```javascript
// vite.config.js or webpack alias
{
  resolve: {
    alias: {
      'react': 'preact/compat',
      'react-dom': 'preact/compat',
      'react-dom/test-utils': 'preact/test-utils',
      'react/jsx-runtime': 'preact/jsx-runtime'
    }
  }
}
```

## 7. Performance Tips
- **Avoid Reconciliation**: Use `key` props correctly.
- **Signals for Shared State**: Skip Context overhead.
- **Code Splitting**: Use dynamic imports.

```jsx
import { lazy, Suspense } from 'preact/compat';

const HeavyComponent = lazy(() => import('./HeavyComponent'));

const App = () => (
  <Suspense fallback={<div>Loading...</div>}>
    <HeavyComponent />
  </Suspense>
);
```

## 8. Project Structure
```
src/
├── components/
│   ├── common/
│   └── features/
├── hooks/
├── signals/          # Preact signals (global state)
├── utils/
├── app.jsx
└── index.jsx
```

