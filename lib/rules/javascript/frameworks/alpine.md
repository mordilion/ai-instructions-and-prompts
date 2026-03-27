# Alpine.js

> **Scope**: Alpine.js for lightweight interactivity  
> **Applies to**: HTML files with Alpine.js  
> **Extends**: javascript/architecture.md, html/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use x-data for component state
> **ALWAYS**: Use x-cloak to prevent flash
> **ALWAYS**: Use @ and : shorthand
> **ALWAYS**: Keep components small and focused
> **ALWAYS**: Alpine.store() for global state
> 
> **NEVER**: Build complex SPAs (use Vue/React)
> **NEVER**: Put business logic in HTML attributes
> **NEVER**: Skip x-cloak styles
> **NEVER**: Use Alpine for >50 components
> **NEVER**: Mix Alpine with Vue/React

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

## AI Self-Check

- [ ] Using x-data for component state?
- [ ] x-cloak to prevent flash?
- [ ] @ and : shorthand used?
- [ ] Components small and focused?
- [ ] Alpine.data() for reusable components?
- [ ] Alpine.store() for global state?
- [ ] Modifiers used (.prevent, .stop)?
- [ ] x-cloak styles present?
- [ ] No complex SPAs (using Vue/React for that)?
- [ ] No business logic in HTML attributes?
- [ ] Progressive enhancement from server HTML?
- [ ] <50 components (otherwise use larger framework)?

