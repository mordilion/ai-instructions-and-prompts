# React Layered/Traditional Structure (JavaScript)

> **Scope**: Layered structure for React (JS)  
> **Applies to**: React (JS) projects with layered structure  
> **Extends**: javascript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Components in components/ folder
> **ALWAYS**: Hooks in hooks/ folder
> **ALWAYS**: API calls in api/ folder
> **ALWAYS**: Context for global state
> **ALWAYS**: Separation: UI, logic, data
> 
> **NEVER**: Business logic in components
> **NEVER**: API calls in components (use hooks)
> **NEVER**: Deep folder nesting
> **NEVER**: Mixed concerns
> **NEVER**: Skip hook extraction for reusable logic

## Folder Structure
```
src/
├── components/
│   ├── common/                 # Shared components
│   │   ├── Button.jsx
│   │   └── Modal.jsx
│   ├── layout/
│   │   ├── Header.jsx
│   │   └── Sidebar.jsx
│   └── pages/                  # Page components
│       ├── HomePage.jsx
│       └── UserPage.jsx
├── hooks/
│   ├── useAuth.js
│   └── useFetch.js
├── context/
│   └── AuthContext.jsx
├── api/
│   ├── client.js
│   └── users.api.js
├── utils/
│   └── helpers.js
├── App.jsx
└── main.jsx
```

## Key Principles
- **Grouped by Type**: All components together, all hooks together.
- **Flat Structure**: Easier navigation for smaller projects.
- **Clear Layers**: Separation between UI, logic, and data.

## When to Use
- Small to medium projects.
- Teams familiar with traditional React patterns.
- Projects without complex feature boundaries.

## AI Self-Check

- [ ] Components in components/ folder?
- [ ] Hooks in hooks/ folder?
- [ ] API calls in api/ folder?
- [ ] Context for global state?
- [ ] UI, logic, and data separated?
- [ ] No business logic in components?
- [ ] No API calls in components (using hooks)?
- [ ] No deep folder nesting?
- [ ] Hooks extracted for reusable logic?
- [ ] Clear layer boundaries?

