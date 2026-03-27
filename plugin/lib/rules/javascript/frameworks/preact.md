# Preact

> **Scope**: Preact lightweight React alternative  
> **Applies to**: JavaScript/TypeScript files using Preact  
> **Extends**: javascript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use class and for (not className/htmlFor)
> **ALWAYS**: Use onInput for real-time updates (not onChange)
> **ALWAYS**: Import from preact/hooks (not react)
> **ALWAYS**: Keep bundle small (<10kB gzipped)
> **ALWAYS**: Use Signals for global state
> 
> **NEVER**: Assume React behavior (check differences)
> **NEVER**: Large bundles (defeats purpose)
> **NEVER**: Import from react (use preact/compat)
> **NEVER**: className/htmlFor (use class/for)
> **NEVER**: onChange for inputs (use onInput)

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

## AI Self-Check

- [ ] Using class and for (not className/htmlFor)?
- [ ] Using onInput (not onChange)?
- [ ] Importing from preact/hooks (not react)?
- [ ] Bundle size <10kB gzipped?
- [ ] Signals for global state?
- [ ] preact/compat for React libraries?
- [ ] Lazy loading for code splitting?
- [ ] No assuming React behavior?
- [ ] No large bundles?
- [ ] preact/compat aliased in build config?
- [ ] Functional components preferred?
- [ ] Hooks used correctly?

