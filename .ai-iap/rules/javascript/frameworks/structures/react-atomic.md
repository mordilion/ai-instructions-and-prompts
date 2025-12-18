# React Atomic Design Structure (JavaScript)

> **Scope**: This structure extends the React (JS) framework rules. When selected, use this folder organization.

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

