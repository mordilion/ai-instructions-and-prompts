# React Layered/Traditional Structure

> **Scope**: Layered structure for React (TypeScript)  
> **Applies to**: React TypeScript projects with layered structure  
> **Extends**: typescript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Components in components/ folder
> **ALWAYS**: Hooks in hooks/ folder
> **ALWAYS**: Services for API calls
> **ALWAYS**: Types in types/ folder
> **ALWAYS**: Separation: UI, logic, data
> 
> **NEVER**: Business logic in components
> **NEVER**: API calls in components (use hooks/services)
> **NEVER**: Deep folder nesting
> **NEVER**: Mixed concerns
> **NEVER**: Skip type definitions

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

## AI Self-Check

- [ ] Components in components/ folder?
- [ ] Hooks in hooks/ folder?
- [ ] Services for API calls?
- [ ] Types in types/ folder?
- [ ] UI, logic, and data separated?
- [ ] No business logic in components?
- [ ] No API calls in components?
- [ ] No deep folder nesting?
- [ ] Hooks extracted for reusable logic?
- [ ] Type definitions complete?

