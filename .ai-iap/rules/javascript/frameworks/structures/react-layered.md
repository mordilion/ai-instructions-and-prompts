# React Layered/Traditional Structure (JavaScript)

> **Scope**: This structure extends the React (JS) framework rules. When selected, use this folder organization.

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

