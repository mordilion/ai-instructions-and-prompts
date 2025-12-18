# React Modular/Feature-Based Structure (JavaScript)

> **Scope**: This structure extends the React (JS) framework rules. When selected, use this folder organization.

## Folder Structure
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.jsx
│   │   │   └── RegisterForm.jsx
│   │   ├── hooks/
│   │   │   └── useAuth.js
│   │   ├── api/
│   │   │   └── auth.api.js
│   │   └── index.js            # Public exports
│   ├── users/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── index.js
│   └── dashboard/
├── shared/
│   ├── components/             # Reusable UI components
│   │   ├── Button.jsx
│   │   └── Modal.jsx
│   ├── hooks/                  # Shared hooks
│   └── utils/                  # Helper functions
├── App.jsx
└── main.jsx
```

## Key Principles
- **Feature Isolation**: Each feature owns its components, hooks, and API calls.
- **Public API**: Export only what other features need via `index.js`.
- **Cross-Feature**: Import from feature's `index.js`, not internal files.
- **Shared**: Only truly reusable code goes in `shared/`.

## Import Rules
```javascript
// ✅ Good - Import from feature's public API
import { LoginForm, useAuth } from '@/features/auth';

// ❌ Bad - Import internal files
import { LoginForm } from '@/features/auth/components/LoginForm';
```

