# React (JavaScript)

> **Scope**: Apply these rules when working with React applications using JavaScript (`.jsx` files).

## 1. Component Design
- **Functional Only**: No class components.
- **Single Responsibility**: One component, one purpose.
- **Composition**: Build complex UIs from simple components.

```jsx
// ✅ Good
const UserCard = ({ user }) => (
  <div className="card">
    <img src={user.avatar} alt={user.name} />
    <span>{user.name}</span>
  </div>
);

// ❌ Bad
class UserCard extends React.Component { ... }
```

## 2. PropTypes
- **Always define PropTypes** for component validation.
- **Use `isRequired`** for mandatory props.
- **Default props** via default parameters.

```jsx
import PropTypes from 'prop-types';

const Button = ({ variant = 'primary', onClick, children }) => (
  <button className={variant} onClick={onClick}>{children}</button>
);

Button.propTypes = {
  variant: PropTypes.oneOf(['primary', 'secondary']),
  onClick: PropTypes.func.isRequired,
  children: PropTypes.node.isRequired,
};
```

## 3. Hooks
- **useState**: Local component state.
- **useEffect**: Side effects (API calls, subscriptions).
- **useMemo/useCallback**: Expensive computations, stable references.
- **Custom Hooks**: Extract reusable logic into `use*` hooks.

```jsx
// ✅ Good - Custom hook
const useUser = (id) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(id).then(setUser).finally(() => setLoading(false));
  }, [id]);

  return { user, loading };
};
```

## 4. State Management
- **Local First**: Start with useState/useReducer.
- **Context**: For shared UI state (theme, auth).
- **Zustand/Jotai**: For global app state.
- **React Query/SWR**: For server state (API data).

## 5. Event Handling
- **No Inline Complex Logic**: Extract to named functions.

```jsx
// ✅ Good
const handleSubmit = (e) => {
  e.preventDefault();
  onSubmit(formData);
};

// ❌ Bad
<form onSubmit={(e) => { e.preventDefault(); /* 20 lines */ }}>
```

## 6. Performance
- **React.memo**: Wrap components with stable props.
- **useMemo/useCallback**: Prevent unnecessary recalculations.
- **Lazy Loading**: `React.lazy()` for code splitting.
- **Key Prop**: Always use unique, stable keys in lists.

