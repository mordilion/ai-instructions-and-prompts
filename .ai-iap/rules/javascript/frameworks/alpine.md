# Alpine.js

> **Scope**: Apply these rules when working with Alpine.js for lightweight JavaScript interactivity.

## 1. When to Use Alpine
- **Progressive Enhancement**: Adding interactivity to server-rendered HTML.
- **Simple Interactions**: Dropdowns, modals, tabs, accordions.
- **Avoid For**: Complex SPAs (use Vue/React instead).

## 2. Core Directives

### x-data (Component State)
```html
<!-- Component with state -->
<div x-data="{ open: false, count: 0 }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open">Content</div>
</div>
```

### x-bind & x-on (Shorthand)
```html
<!-- Attribute binding -->
<button :class="active ? 'bg-blue' : 'bg-gray'">Click</button>
<input :disabled="loading">

<!-- Event handling -->
<button @click="handleClick">Click</button>
<form @submit.prevent="submitForm">...</form>
```

### x-model (Two-way Binding)
```html
<input x-model="search" placeholder="Search...">
<select x-model="selected">
  <option value="a">Option A</option>
  <option value="b">Option B</option>
</select>
```

## 3. Reusable Components
```javascript
// Define reusable component data
document.addEventListener('alpine:init', () => {
  Alpine.data('dropdown', () => ({
    open: false,
    toggle() {
      this.open = !this.open
    },
    close() {
      this.open = false
    }
  }))
})
```

```html
<!-- Usage -->
<div x-data="dropdown" @click.outside="close">
  <button @click="toggle">Menu</button>
  <ul x-show="open">
    <li>Item 1</li>
    <li>Item 2</li>
  </ul>
</div>
```

## 4. Stores (Global State)
```javascript
// Global store
document.addEventListener('alpine:init', () => {
  Alpine.store('auth', {
    user: null,
    isAuthenticated: false,
    
    login(userData) {
      this.user = userData
      this.isAuthenticated = true
    },
    
    logout() {
      this.user = null
      this.isAuthenticated = false
    }
  })
})
```

```html
<!-- Access store -->
<div x-data>
  <span x-text="$store.auth.user?.name"></span>
  <button x-show="$store.auth.isAuthenticated" @click="$store.auth.logout()">
    Logout
  </button>
</div>
```

## 5. x-effect & x-init
```html
<!-- Run effect when dependencies change -->
<div x-data="{ search: '' }" x-effect="console.log('Search:', search)">
  <input x-model="search">
</div>

<!-- Initialize with async data -->
<div x-data="{ users: [] }" x-init="users = await (await fetch('/api/users')).json()">
  <template x-for="user in users">
    <div x-text="user.name"></div>
  </template>
</div>
```

## 6. Best Practices
- **Keep Components Small**: Alpine excels at micro-interactions.
- **Use `x-cloak`**: Hide elements until Alpine initializes.
- **Modifiers**: Use `.prevent`, `.stop`, `.window`, `.outside`.
- **Transitions**: Use `x-transition` for smooth animations.

```html
<style>[x-cloak] { display: none !important; }</style>

<div x-data="{ open: false }" x-cloak>
  <div x-show="open" x-transition.duration.300ms>
    Smooth modal content
  </div>
</div>
```

