# Bootstrap

> **Scope**: Apply these rules when working with Bootstrap CSS framework.

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Bootstrap's grid system (12-column layout)
> **ALWAYS**: Use built-in components over custom implementations
> **ALWAYS**: Customize via Sass variables (not overriding CSS)
> **ALWAYS**: Use utility classes for spacing/alignment
> **ALWAYS**: Import only needed components (tree-shaking)
> 
> **NEVER**: Override with `!important` (use Sass variables)
> **NEVER**: Mix Bootstrap grid with other grid systems
> **NEVER**: Hardcode breakpoint values (use Bootstrap's)
> **NEVER**: Import entire Bootstrap if using few components
> **NEVER**: Ignore accessibility features (ARIA, focus states)

## Overview

Bootstrap is a component-based CSS framework with pre-built UI components and a responsive grid system.

**Key Points**:
- 12-column responsive grid system
- Pre-built components (buttons, modals, forms, etc.)
- Mobile-first responsive design
- Extensive customization via Sass

## Best Practices

**MUST**:
- Use Bootstrap's grid system
- Leverage built-in components
- Customize via Sass variables
- Use utility classes for spacing
- Import only needed components

**SHOULD**:
- Use responsive breakpoints (`-sm`, `-md`, `-lg`, `-xl`, `-xxl`)
- Follow Bootstrap's naming conventions
- Use `data-bs-*` attributes for JS components
- Test across all breakpoints
- Use Bootstrap icons or compatible icon library

**AVOID**:
- Overriding with `!important`
- Mixing with other CSS frameworks
- Ignoring accessibility features
- Using deprecated classes (Bootstrap 4 → 5)
- Importing entire framework unnecessarily

## 1. Grid System

**12-Column Layout** - Mobile-first responsive grid:

```html
<!-- ✅ Good - Responsive grid -->
<div class="container">
  <div class="row">
    <div class="col-12 col-md-8 col-lg-6">Main content</div>
    <div class="col-12 col-md-4 col-lg-6">Sidebar</div>
  </div>
</div>

<!-- ✅ Good - Equal width columns -->
<div class="row">
  <div class="col">Column 1</div>
  <div class="col">Column 2</div>
  <div class="col">Column 3</div>
</div>

<!-- ❌ Bad - Not using Bootstrap grid -->
<div style="display: grid; grid-template-columns: 1fr 1fr;">
  <!-- Use Bootstrap grid instead! -->
</div>
```

**Breakpoints**:
- `xs`: < 576px (default, no prefix)
- `sm`: ≥ 576px
- `md`: ≥ 768px
- `lg`: ≥ 992px
- `xl`: ≥ 1200px
- `xxl`: ≥ 1400px

## 2. Components

**Use Built-in Components** - Don't reinvent the wheel:

```html
<!-- ✅ Good - Bootstrap button -->
<button type="button" class="btn btn-primary">
  Primary Button
</button>

<!-- ✅ Good - Bootstrap modal -->
<div class="modal fade" id="exampleModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Modal title</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">Content</div>
    </div>
  </div>
</div>

<!-- ❌ Bad - Custom modal when Bootstrap exists -->
<div class="custom-overlay">
  <div class="custom-modal">
    <!-- Use Bootstrap modal instead! -->
  </div>
</div>
```

## 3. Customization

**Sass Variables** - Customize theme properly:

```scss
// ✅ Good - Override Sass variables
// custom.scss
$primary: #0056b3;
$font-family-base: 'Inter', sans-serif;
$border-radius: 0.5rem;

@import '~bootstrap/scss/bootstrap';

// ✅ Good - Selective imports
@import '~bootstrap/scss/functions';
@import '~bootstrap/scss/variables';
@import '~bootstrap/scss/mixins';
@import '~bootstrap/scss/grid';
@import '~bootstrap/scss/utilities';
@import '~bootstrap/scss/buttons';

// ❌ Bad - CSS overrides with !important
.btn-primary {
  background-color: #0056b3 !important;
  /* Use Sass variables instead! */
}
```

## 4. Utility Classes

**Spacing & Alignment** - Use Bootstrap utilities:

```html
<!-- ✅ Good - Bootstrap utilities -->
<div class="d-flex justify-content-between align-items-center mb-4">
  <h2 class="mb-0">Title</h2>
  <button class="btn btn-primary">Action</button>
</div>

<!-- ✅ Good - Spacing utilities -->
<div class="mt-3 mb-4 p-3">
  <!-- m = margin, p = padding, t/b/l/r/x/y = top/bottom/left/right/horizontal/vertical -->
</div>

<!-- ❌ Bad - Inline styles when utilities exist -->
<div style="margin-top: 1rem; padding: 1rem;">
  <!-- Use mt-3 p-3 instead! -->
</div>
```

**Common Utilities**:
- Display: `d-none`, `d-block`, `d-flex`, `d-grid`
- Spacing: `m-*`, `p-*`, `mt-*`, `mb-*`, `mx-*`, `my-*` (0-5, auto)
- Text: `text-start`, `text-center`, `text-end`, `text-primary`
- Background: `bg-primary`, `bg-light`, `bg-white`
- Borders: `border`, `rounded`, `border-0`

## 5. Responsive Design

**Mobile-First Approach**:

```html
<!-- ✅ Good - Responsive visibility -->
<div class="d-none d-md-block">
  <!-- Hidden on mobile, visible on tablet+ -->
</div>

<!-- ✅ Good - Responsive text alignment -->
<h1 class="text-center text-md-start">
  <!-- Centered on mobile, left-aligned on tablet+ -->
</h1>

<!-- ✅ Good - Responsive spacing -->
<div class="py-3 py-md-5">
  <!-- Less padding on mobile, more on tablet+ -->
</div>
```

## 6. Accessibility

**ARIA & Semantics** - Bootstrap components include accessibility:

```html
<!-- ✅ Good - Accessible dropdown -->
<div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" 
          type="button" 
          id="dropdownMenuButton" 
          data-bs-toggle="dropdown" 
          aria-expanded="false">
    Dropdown
  </button>
  <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton">
    <li><a class="dropdown-item" href="#">Action</a></li>
  </ul>
</div>

<!-- ✅ Good - Form labels -->
<div class="mb-3">
  <label for="emailInput" class="form-label">Email address</label>
  <input type="email" class="form-control" id="emailInput" required>
</div>

<!-- ❌ Bad - Missing accessibility attributes -->
<div class="dropdown">
  <button class="dropdown-toggle">Dropdown</button>
  <!-- Missing data-bs-toggle, aria-expanded, etc. -->
</div>
```

## 7. Performance

**Selective Imports** - Only import what you need:

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Imports** | Import entire Bootstrap | Import specific components |
| **Customization** | Override with CSS | Use Sass variables |
| **JavaScript** | Load all plugins | Load only needed plugins |
| **Grid** | Always use `.container-fluid` | Use appropriate container |

```javascript
// ✅ Good - Selective JS imports
import { Modal, Dropdown } from 'bootstrap';

// ❌ Bad - Import everything
import 'bootstrap';
```

## 8. Migration (Bootstrap 4 → 5)

**Key Changes**:
- `data-*` → `data-bs-*`
- jQuery removed (vanilla JS)
- `.ml-*`, `.mr-*` → `.ms-*`, `.me-*` (start/end)
- `.left`, `.right` → `.start`, `.end`
- Form styles require `.form-control` explicitly

```html
<!-- Bootstrap 5 -->
<button data-bs-toggle="modal" data-bs-target="#myModal">

<!-- Bootstrap 4 (deprecated) -->
<button data-toggle="modal" data-target="#myModal">
```

## AI Self-Check

- [ ] Using Bootstrap's 12-column grid system?
- [ ] Leveraging built-in components?
- [ ] Customizing via Sass variables (not CSS overrides)?
- [ ] Using utility classes for spacing/alignment?
- [ ] Importing only needed components?
- [ ] Using responsive breakpoints correctly?
- [ ] Following mobile-first approach?
- [ ] Including accessibility attributes?
- [ ] Using Bootstrap 5 syntax (not deprecated)?
- [ ] Not mixing with other CSS frameworks?
- [ ] Testing across all breakpoints?
- [ ] Avoiding `!important` overrides?
