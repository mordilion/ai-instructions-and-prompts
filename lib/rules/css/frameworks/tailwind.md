# Tailwind CSS

> **Scope**: Apply these rules when working with Tailwind CSS utility-first framework.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use utility classes over custom CSS
> **ALWAYS**: Configure purging/content paths in `tailwind.config.js`
> **ALWAYS**: Use responsive prefixes (`sm:`, `md:`, `lg:`, `xl:`, `2xl:`)
> **ALWAYS**: Extract components when utilities repeat 3+ times
> **ALWAYS**: Use JIT mode for development
> 
> **NEVER**: Use `@apply` excessively (defeats utility-first purpose)
> **NEVER**: Mix Tailwind with other CSS frameworks
> **NEVER**: Override Tailwind classes with `!important`
> **NEVER**: Hardcode colors/spacing (use theme values)
> **NEVER**: Skip purging in production (huge file sizes)

## Overview

Tailwind CSS is a utility-first CSS framework. Build designs directly in markup using pre-defined utility classes.

**Key Points**:
- Utility-first approach (no predefined components)
- JIT (Just-In-Time) compiler for faster builds
- Highly customizable via `tailwind.config.js`
- Responsive and dark mode built-in

## Best Practices

**MUST**:
- Use utility classes for styling
- Configure purging/content paths correctly
- Use responsive prefixes for breakpoints
- Extract repeated patterns into components
- Enable JIT mode

**SHOULD**:
- Use design tokens from theme (colors, spacing)
- Leverage dark mode with `dark:` prefix
- Use arbitrary values sparingly `[#hex]`, `[10px]`
- Group utilities logically (layout → spacing → typography → colors)
- Use plugins for extended functionality

**AVOID**:
- Overusing `@apply` (use components instead)
- Mixing with Bootstrap or other frameworks
- Hardcoding values when theme tokens exist
- Writing custom CSS when utilities suffice
- Forgetting to purge unused CSS

## 1. Configuration

**tailwind.config.js** - Essential setup:

```javascript
// ✅ Good - Complete configuration
module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx,html,vue,svelte}',
    './public/index.html'
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          500: '#0ea5e9',
          900: '#0c4a6e'
        }
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography')
  ]
};

// ❌ Bad - Missing content paths
module.exports = {
  content: [], // Will purge everything!
  theme: {}
};
```

## 2. Utility-First Patterns

**Component Extraction** - When to use components vs utilities:

```jsx
// ✅ Good - Utilities for unique layouts
<div className="flex items-center justify-between p-4 bg-white rounded-lg shadow">
  <h2 className="text-xl font-bold text-gray-900">Title</h2>
  <button className="px-4 py-2 text-white bg-blue-500 rounded hover:bg-blue-600">
    Action
  </button>
</div>

// ✅ Good - Component for repeated patterns
const Card = ({ title, children }) => (
  <div className="p-6 bg-white rounded-lg shadow-md">
    <h3 className="text-lg font-semibold mb-4">{title}</h3>
    {children}
  </div>
);

// ❌ Bad - Excessive @apply usage
.card {
  @apply p-6 bg-white rounded-lg shadow-md text-gray-900 font-sans;
  /* Just use a component instead! */
}
```

## 3. Responsive Design

**Mobile-First Approach** - Use breakpoint prefixes:

```jsx
// ✅ Good - Mobile-first responsive
<div className="
  grid grid-cols-1
  sm:grid-cols-2
  md:grid-cols-3
  lg:grid-cols-4
  gap-4
">
  {/* Cards */}
</div>

// ✅ Good - Responsive typography
<h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
  Responsive Heading
</h1>

// ❌ Bad - Desktop-first (backwards)
<div className="grid-cols-4 md:grid-cols-3 sm:grid-cols-2">
  {/* Wrong order! */}
</div>
```

## 4. Dark Mode

**Dark Mode Support** - Use `dark:` variant:

```jsx
// ✅ Good - Dark mode support
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">Title</h1>
  <p className="text-gray-600 dark:text-gray-300">Description</p>
</div>

// tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
  // ...
};

// ❌ Bad - No dark mode consideration
<div className="bg-white">
  <h1 className="text-gray-900">Title</h1>
</div>
```

## 5. Performance

**Optimization Strategies**:

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Purging** | No content config | Configure all template paths |
| **JIT** | Disabled | Enable for development |
| **Arbitrary Values** | Overuse `[value]` | Use theme tokens |
| **Custom CSS** | Lots of `@apply` | Use components |

```javascript
// ✅ Good - JIT + Purging
module.exports = {
  mode: 'jit',
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  // Production CSS: ~10KB gzipped
};

// ❌ Bad - No purging
module.exports = {
  content: [],
  // Production CSS: ~3MB uncompressed!
};
```

## 6. Common Patterns

**Layout**:
```jsx
// Flexbox centering
<div className="flex items-center justify-center min-h-screen">

// Grid layout
<div className="grid grid-cols-12 gap-4">

// Container
<div className="container mx-auto px-4">
```

**Typography**:
```jsx
// Heading with responsive sizing
<h1 className="text-3xl md:text-4xl font-bold text-gray-900">

// Paragraph with line height
<p className="text-base leading-relaxed text-gray-700">
```

**Spacing**:
```jsx
// Consistent spacing
<div className="space-y-4"> {/* Vertical spacing */}
<div className="space-x-2"> {/* Horizontal spacing */}
```

## AI Self-Check

- [ ] Using utility-first approach (not writing custom CSS)?
- [ ] Configured content paths for purging?
- [ ] Using JIT mode for development?
- [ ] Using responsive prefixes (`sm:`, `md:`, etc.)?
- [ ] Extracting components for repeated patterns?
- [ ] Using theme tokens instead of hardcoded values?
- [ ] Implementing dark mode where appropriate?
- [ ] Avoiding excessive `@apply` usage?
- [ ] Not mixing with other CSS frameworks?
- [ ] Purging unused CSS in production?
- [ ] Using plugins for extended features?
- [ ] Grouping utilities logically in markup?
