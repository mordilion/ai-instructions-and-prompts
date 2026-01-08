# Preact

> **Scope**: Apply these rules when working with Preact, the lightweight (3kB) React alternative.

## Overview

Preact is a fast 3kB React alternative with the same API. Use preact/compat for full React compatibility.

## Best Practices

**MUST**:
- Use class and for (NOT className/htmlFor)
- Use onInput for real-time updates (NOT onChange)
- Import from preact/hooks (NOT react)

**SHOULD**:
- Use Signals for global state
- Use preact/compat for React libraries
- Use lazy loading for code splitting

**AVOID**:
- Assuming React behavior (check differences)
- Large bundles (defeats purpose)

## 1. When to Use Preact
- **Performance Critical**: Smaller bundle size than React.
- **React Compatibility**: Drop-in replacement via `preact/compat`.
- **Embedded Widgets**: Third-party embeds, performance-sensitive contexts.

## 2. Component Syntax

```jsx
import { useState } from 'preact/hooks';

const UserCard = ({ user, onDelete }) => {
  const [loading, setLoading] = useState(false);
  return <div class="card"><button onClick={() => onDelete(user.id)}>{user.name}</button></div>;
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
<label for="email" class="label">
  <input onInput={handleInput} />
</label>
```

## 4. Hooks

```jsx
import { useState, useMemo } from 'preact/hooks';

const SearchList = ({ items }) => {
  const [query, setQuery] = useState('');
  const filtered = useMemo(() => items.filter(i => i.name.includes(query)), [items, query]);
  return <input onInput={e => setQuery(e.target.value)} />;
};
```

## 5. Signals

```jsx
import { signal } from '@preact/signals';

const count = signal(0);
const Counter = () => <button onClick={() => count.value++}>Count: {count}</button>;
```

## 6. React Compat

```javascript
// vite.config.js
{ resolve: { alias: { 'react': 'preact/compat', 'react-dom': 'preact/compat' } } }
```

