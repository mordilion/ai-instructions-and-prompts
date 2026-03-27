# React Atomic Design Structure

> **Scope**: Atomic Design structure for React (TypeScript)  
> **Applies to**: React TypeScript projects with Atomic Design  
> **Extends**: typescript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Build from atoms → molecules → organisms → templates → pages
> **ALWAYS**: No skip levels (molecules use atoms)
> **ALWAYS**: Atoms are single elements (no dependencies)
> **ALWAYS**: Templates are layouts (no data)
> **ALWAYS**: Pages are templates with data
> 
> **NEVER**: Skip hierarchy levels
> **NEVER**: Data in atoms/molecules
> **NEVER**: Business logic in atoms/molecules
> **NEVER**: Organisms depend on pages
> **NEVER**: Unclear component categorization

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

## AI Self-Check

- [ ] Building from atoms → molecules → organisms → templates → pages?
- [ ] No skip levels?
- [ ] Atoms are single elements?
- [ ] Templates are layouts (no data)?
- [ ] Pages are templates with data?
- [ ] Components categorized correctly?
- [ ] Storybook documentation?
- [ ] No data in atoms/molecules?
- [ ] No business logic in atoms/molecules?
- [ ] Hierarchy respected?

