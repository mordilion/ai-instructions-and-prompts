# React Atomic Design Structure

> **Scope**: Use this structure for design-system-focused React applications.
> **Precedence**: When loaded, this structure overrides any default folder organization from the base React rules.

## Project Structure
```
src/
├── components/
│   ├── atoms/              # Basic building blocks
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.styles.ts
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Label/
│   │   └── Icon/
│   ├── molecules/          # Groups of atoms
│   │   ├── FormField/      # Label + Input + Error
│   │   ├── SearchBox/      # Input + Button
│   │   └── NavItem/
│   ├── organisms/          # Complex UI sections
│   │   ├── Header/
│   │   ├── LoginForm/
│   │   └── UserCard/
│   ├── templates/          # Page layouts
│   │   ├── MainLayout/
│   │   └── AuthLayout/
│   └── pages/              # Full pages
│       ├── HomePage/
│       └── LoginPage/
├── hooks/
├── services/
├── utils/
└── main.tsx
```

## Hierarchy Rules
| Level | Contains | Examples |
|-------|----------|----------|
| **Atoms** | Single HTML element | Button, Input, Icon |
| **Molecules** | 2-3 atoms combined | FormField, SearchBox |
| **Organisms** | Multiple molecules | Header, LoginForm |
| **Templates** | Page structure | MainLayout, DashboardLayout |
| **Pages** | Templates + data | HomePage, UserPage |

## Rules
- **Atoms**: No dependencies on other components
- **Molecules**: Only import atoms
- **Organisms**: Import atoms and molecules
- **Templates**: Import organisms, no business logic
- **Pages**: Connect data to templates

## When to Use
- Design system development
- Component library projects
- Teams with dedicated designers
- Consistent UI across large apps

