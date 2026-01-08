# Alpine.js

> **Scope**: Apply these rules when working with Alpine.js for lightweight JavaScript interactivity.

## Overview

Alpine.js is a lightweight (15KB) JavaScript framework for adding interactivity to server-rendered HTML. Think of it as "Tailwind for JavaScript".

## Best Practices

**MUST**:
- Use x-data for component state
- Use x-cloak to hide elements until Alpine loads
- Use @ and : shorthand
- Keep components small and focused

**SHOULD**:
- Use Alpine.data() for reusable components
- Use Alpine.store() for global state
- Use modifiers (.prevent, .stop, .outside)

**AVOID**:
- Complex SPAs (use Vue/React instead)
- Business logic in HTML
- Missing x-cloak styles

## 1. When to Use Alpine
- **Progressive Enhancement**: Adding interactivity to server-rendered HTML.
- **Simple Interactions**: Dropdowns, modals, tabs, accordions.
- **Avoid For**: Complex SPAs (use Vue/React instead).

## 2. Core Directives

```html
<!-- Core Directives -->
<div x-data="{ open: false, count: 0 }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open">Content</div>
  <input x-model="search" :disabled="loading">
</div>

<!-- Reusable Components -->
<script>
Alpine.data('dropdown', () => ({
  open: false,
  toggle() { this.open = !this.open; }
}));
</script>

<div x-data="dropdown" @click.outside="close">
  <button @click="toggle">Menu</button>
  <ul x-show="open"><li>Item</li></ul>
</div>

<!-- Stores (Global State) -->
<script>
Alpine.store('auth', {
  user: null,
  login(userData) { this.user = userData; }
});
</script>

<div x-data>
  <span x-text="$store.auth.user?.name"></span>
</div>

<!-- x-init & x-effect -->
<div x-data="{ users: [] }" x-init="users = await (await fetch('/api/users')).json()">
  <template x-for="user in users"><div x-text="user.name"></div></template>
</div>

<!-- x-cloak & Transitions -->
<style>[x-cloak] { display: none !important; }</style>
<div x-data="{ open: false }" x-cloak>
  <div x-show="open" x-transition>Content</div>
</div>
```

