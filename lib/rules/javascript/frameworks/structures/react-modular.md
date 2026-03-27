# React Modular/Feature-Based Structure (JavaScript)

> **Scope**: Modular structure for React (JavaScript)  
> **Applies to**: React JavaScript projects with modular structure  
> **Extends**: javascript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Features self-contained in src/features/
> **ALWAYS**: Public API via feature index.js
> **ALWAYS**: Import from feature's public API (not internal files)
> **ALWAYS**: Shared folder for cross-feature code
> **ALWAYS**: Features independent
> 
> **NEVER**: Import internal feature files directly
> **NEVER**: Cross-feature dependencies (use shared/)
> **NEVER**: Split feature across locations
> **NEVER**: Deep folder nesting
> **NEVER**: Share state between features directly

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

## AI Self-Check

- [ ] Features self-contained in src/features/?
- [ ] Public API via index.js?
- [ ] Importing from feature's public API (not internal)?
- [ ] Shared folder for cross-feature code?
- [ ] Features independent?
- [ ] Components, hooks, API co-located per feature?
- [ ] No internal file imports?
- [ ] No cross-feature dependencies?
- [ ] Features <500 lines each?
- [ ] Barrel exports configured?

