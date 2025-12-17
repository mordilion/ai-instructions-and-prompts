# React Modular/Feature-Based Structure

> **Scope**: Use this structure for large React applications organized by feature/domain.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base React rules.

## Project Structure
```
src/
├── app/                    # App-level setup
│   ├── App.tsx
│   ├── routes.tsx
│   └── providers.tsx
├── features/               # Feature modules
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── api/
│   │   │   └── authApi.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts        # Public exports
│   ├── users/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api/
│   │   └── index.ts
│   └── dashboard/
├── shared/                 # Shared across features
│   ├── components/         # Generic UI (Button, Modal)
│   ├── hooks/              # Generic hooks
│   ├── utils/
│   └── types/
└── main.tsx
```

## Rules
- **Feature Isolation**: Each feature is self-contained with its own components, hooks, API
- **Public API**: Export only public interface via `index.ts`
- **No Cross-Feature Imports**: Features communicate via shared state or events
- **Shared Only Generic**: Only truly reusable code goes in `shared/`

## Import Pattern
```typescript
// ✅ Good - Import from feature's public API
import { LoginForm, useAuth } from '@/features/auth';

// ❌ Bad - Direct import into feature internals
import { LoginForm } from '@/features/auth/components/LoginForm';
```

## When to Use
- Large applications with multiple domains
- Team-based development (team per feature)
- Features that may become separate apps/packages

