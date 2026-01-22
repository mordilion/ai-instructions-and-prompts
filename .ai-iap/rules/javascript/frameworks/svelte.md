# Svelte/SvelteKit (JavaScript)

> **Scope**: Svelte/SvelteKit applications (JavaScript)  
> **Applies to**: .svelte files (JavaScript)  
> **Extends**: javascript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Runes ($state, $derived, $effect) in Svelte 5
> **ALWAYS**: Use (item.id) keys in {#each} loops
> **ALWAYS**: Use +page.server.js for server-side data
> **ALWAYS**: Use form actions for mutations
> **ALWAYS**: Use stores for shared state
> 
> **NEVER**: Use legacy syntax (use Runes)
> **NEVER**: Client-side data fetching (use load functions)
> **NEVER**: Missing keys in loops
> **NEVER**: Expose secrets to client
> **NEVER**: Index as key in {#each}

## 1. Project Structure (SvelteKit)
```
src/
├── lib/
│   ├── components/       # Reusable components
│   ├── stores/           # Svelte stores
│   └── utils/            # Helper functions
├── routes/
│   ├── +layout.svelte    # Root layout
│   ├── +page.svelte      # Home page
│   └── [slug]/           # Dynamic routes
├── app.html
└── hooks.server.js       # Server hooks
```

## 2. Component Syntax
- **Runes (Svelte 5)**: `$state`, `$derived`, `$effect` preferred.
- **Legacy**: `let` for state, `$:` for reactive (Svelte 4).

```svelte
<!-- Svelte 5 (Runes) -->
<script>
  let { userId, initialCount = 0 } = $props()
  
  let count = $state(initialCount)
  let doubled = $derived(count * 2)
  
  $effect(() => {
    console.log('Count changed:', count)
  })
</script>

<button onclick={() => count++}>
  {count} (doubled: {doubled})
</button>
```

## 3. Stores
```javascript
// stores/auth.js
import { writable, derived } from 'svelte/store'

function createAuthStore() {
  const { subscribe, set, update } = writable({
    user: null,
    token: null
  })

  return {
    subscribe,
    login: async (email, password) => {
      const response = await api.login(email, password)
      set({ user: response.user, token: response.token })
    },
    logout: () => set({ user: null, token: null })
  }
}

export const auth = createAuthStore()
export const isAuthenticated = derived(auth, ($auth) => !!$auth.token)
```

## 4. SvelteKit Features
- **Load Functions**: Fetch data before rendering.
- **Form Actions**: Handle forms server-side.
- **API Routes**: `+server.js` for REST endpoints.

```javascript
// routes/users/[id]/+page.js
export async function load({ params, fetch }) {
  const response = await fetch(`/api/users/${params.id}`)
  return { user: await response.json() }
}
```

```javascript
// routes/login/+page.server.js
export const actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData()
    const token = await authenticate(data.get('email'), data.get('password'))
    cookies.set('token', token, { path: '/' })
    return { success: true }
  }
}
```

## 5. Props & Events
```svelte
<script>
  // Props with defaults
  let { name, count = 0 } = $props()
  
  // Event dispatcher (Svelte 4) or callback props (Svelte 5)
  let { onUpdate } = $props()
</script>

<button onclick={() => onUpdate?.(count + 1)}>
  {name}: {count}
</button>
```

## 6. Performance
- **{#key}**: Force re-render when value changes.
- **{#await}**: Handle async data in templates.
- **$effect.pre**: Run before DOM updates.

## AI Self-Check

- [ ] Using Runes ($state, $derived, $effect)?
- [ ] Keys in {#each} loops (item.id)?
- [ ] +page.server.js for server data?
- [ ] Form actions for mutations?
- [ ] Stores for shared state?
- [ ] Load functions for data fetching?
- [ ] $lib alias for imports?
- [ ] No legacy syntax?
- [ ] No client-side data fetching?
- [ ] No missing keys in loops?
- [ ] No secrets exposed to client?
- [ ] {#await} for async rendering?

