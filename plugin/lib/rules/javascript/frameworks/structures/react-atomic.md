# React Atomic Design Structure (JavaScript)

> **Scope**: Atomic Design structure for React (JS)  
> **Applies to**: React (JS) projects with Atomic Design  
> **Extends**: javascript/frameworks/react.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Build from atoms → molecules → organisms → templates → pages
> **ALWAYS**: No skip levels (molecules use atoms, organisms use molecules)
> **ALWAYS**: Atoms are single elements (no dependencies)
> **ALWAYS**: Templates are layouts (no data)
> **ALWAYS**: Pages are templates with data
> 
> **NEVER**: Skip hierarchy levels
> **NEVER**: Data in atoms/molecules
> **NEVER**: Business logic in atoms/molecules
> **NEVER**: Organisms depend on pages
> **NEVER**: Unclear component categorization

## Folder Structure
```
src/
├── components/
│   ├── atoms/                  # Basic building blocks
│   │   ├── Button.jsx
│   │   ├── Input.jsx
│   │   └── Text.jsx
│   ├── molecules/              # Groups of atoms
│   │   ├── SearchBar.jsx       # Input + Button
│   │   └── FormField.jsx       # Label + Input + Error
│   ├── organisms/              # Complex UI sections
│   │   ├── Header.jsx
│   │   ├── UserCard.jsx
│   │   └── ProductGrid.jsx
│   ├── templates/              # Page layouts (no data)
│   │   ├── DashboardLayout.jsx
│   │   └── AuthLayout.jsx
│   └── pages/                  # Templates with data
│       ├── HomePage.jsx
│       └── ProductPage.jsx
├── hooks/
├── utils/
├── App.jsx
└── main.jsx
```

## Hierarchy Rules
| Level | Description | Example |
|-------|-------------|---------|
| **Atoms** | Single elements, no dependencies | Button, Input, Icon |
| **Molecules** | Groups of atoms | SearchBar, FormField |
| **Organisms** | Complex sections, may have logic | Header, ProductCard |
| **Templates** | Page structure, no data | DashboardLayout |
| **Pages** | Templates with real data | HomePage |

## Key Principles
- **Bottom-Up**: Build from atoms to pages.
- **No Skip Levels**: Molecules use atoms, organisms use molecules.
- **Storybook**: Document each level in isolation.

## When to Use
- Design system projects.
- Large teams with dedicated designers.
- Component library development.

## AI Self-Check

- [ ] Building from atoms → molecules → organisms → templates → pages?
- [ ] No skip levels (molecules use atoms)?
- [ ] Atoms are single elements (no dependencies)?
- [ ] Templates are layouts (no data)?
- [ ] Pages are templates with data?
- [ ] Components categorized correctly?
- [ ] Storybook documentation?
- [ ] No data in atoms/molecules?
- [ ] No business logic in atoms/molecules?
- [ ] Hierarchy respected?

