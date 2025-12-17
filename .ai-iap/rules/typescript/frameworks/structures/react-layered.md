# React Layered/Traditional Structure

> **Scope**: Use this structure for small-to-medium React apps organized by technical layer.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base React rules.

## Project Structure
```
src/
├── components/             # All React components
│   ├── common/             # Shared components
│   │   ├── Button.tsx
│   │   └── Modal.tsx
│   ├── layout/
│   │   ├── Header.tsx
│   │   └── Sidebar.tsx
│   └── forms/
│       ├── LoginForm.tsx
│       └── UserForm.tsx
├── hooks/                  # All custom hooks
│   ├── useAuth.ts
│   └── useUsers.ts
├── services/               # API calls
│   ├── api.ts              # Base API config
│   ├── authService.ts
│   └── userService.ts
├── store/                  # State management
│   ├── authStore.ts
│   └── userStore.ts
├── types/                  # TypeScript types
│   ├── auth.ts
│   └── user.ts
├── utils/                  # Helper functions
├── pages/                  # Route pages
│   ├── HomePage.tsx
│   └── LoginPage.tsx
├── App.tsx
└── main.tsx
```

## Rules
- **Group by Type**: Components together, hooks together, etc.
- **Flat Structure**: Avoid deep nesting within layers
- **Clear Naming**: File name = export name

## Import Pattern
```typescript
import { Button, Modal } from '@/components/common';
import { useAuth } from '@/hooks/useAuth';
import { authService } from '@/services/authService';
```

## When to Use
- Small to medium applications
- Solo developers or small teams
- Rapid prototyping
- Learning React

