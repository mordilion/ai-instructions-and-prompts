# React (JavaScript)

> **Scope**: Apply these rules when working with React applications using JavaScript (`.jsx` files).

## Overview

React is a JavaScript library for building user interfaces. This is the JavaScript version - for TypeScript, see `typescript/frameworks/react.md`.

**Key Points**:
- Functional components with hooks
- PropTypes for runtime validation
- Same patterns as TypeScript React but without types

## Best Practices

**MUST**:
- Use functional components (NO class components)
- Define PropTypes for all props
- Use hooks (useState, useEffect, etc.)
- Extract event handlers to named functions
- Use key prop in lists

**SHOULD**:
- Use custom hooks for reusable logic
- Use React.memo for expensive renders
- Use useMemo/useCallback appropriately
- Keep components small (<200 lines)

**AVOID**:
- Class components
- Missing PropTypes
- Inline functions in JSX
- Missing dependency arrays
- Mutating state directly

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

## 7. Testing Patterns

> **ALWAYS**: Test user behavior, not implementation details  
> **ALWAYS**: Use React Testing Library (NOT Enzyme)  
> **ALWAYS**: Query by role/label/text, NOT by test IDs or classes  
> **NEVER**: Test component internals (state, props, methods)  
> **NEVER**: Shallow render (use full render)

**Framework**: React Testing Library + Jest

```jsx
// ✅ Good - Test behavior
test('submits form with user data', async () => {
  render(<UserForm onSubmit={mockSubmit} />);
  
  await userEvent.type(screen.getByLabelText('Name'), 'John');
  await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
  
  expect(mockSubmit).toHaveBeenCalledWith({ name: 'John' });
});

// ❌ Bad - Test implementation
test('updates state on input change', () => {
  const wrapper = shallow(<UserForm />);
  wrapper.find('input').simulate('change', { target: { value: 'John' } });
  expect(wrapper.state('name')).toBe('John'); // Testing internals!
});
```

**Query Priority**:
1. `getByRole` - Accessibility-focused ⭐
2. `getByLabelText` - Form elements
3. `getByText` - Non-interactive content
4. `getByTestId` - Last resort only

**Async Testing**:
```jsx
// Wait for element to appear
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument();
});

// Wait for element to disappear
await waitForElementToBeRemoved(() => screen.queryByText('Loading...'));
```

## 8. Logging Patterns

> **ALWAYS**: Use structured logging in production  
> **ALWAYS**: Include context (userId, requestId)  
> **NEVER**: Log sensitive data (passwords, tokens, PII)  
> **NEVER**: Use console.log in production code

**Development**:
```jsx
// ✅ Good - Structured with context
console.info('[UserList] Fetching users', { count: users.length, timestamp: Date.now() });
console.error('[UserList] Failed to fetch', { error: err.message, userId });

// ❌ Bad - Unstructured
console.log('fetching users');
console.log(err); // Raw error object
```

**Production** (use logging library):
```jsx
import logger from './logger'; // winston, pino, etc.

// ✅ Good
logger.info('user.fetch.success', { userId, count: users.length });
logger.error('user.fetch.failure', { userId, error: err.message, stack: err.stack });

// ❌ Bad - console.log in production
console.log('User fetched'); // Remove before deploy
```

**Error Boundaries**:
```jsx
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    // ✅ Log to monitoring service
    logger.error('react.error.boundary', {
      error: error.message,
      componentStack: errorInfo.componentStack,
      timestamp: Date.now()
    });
  }
}
```

**Performance Logging**:
```jsx
// ✅ Good - Log slow renders in development
useEffect(() => {
  if (process.env.NODE_ENV === 'development') {
    const start = performance.now();
    return () => {
      const duration = performance.now() - start;
      if (duration > 16) { // 60fps threshold
        logger.warn('component.slow.render', { component: 'UserList', duration });
      }
    };
  }
}, []);
```
