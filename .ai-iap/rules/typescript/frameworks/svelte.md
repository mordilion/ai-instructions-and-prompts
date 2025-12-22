# Svelte / SvelteKit Framework

> **Scope**: Apply these rules when working with Svelte and SvelteKit applications.

## Overview

Svelte is a component framework that compiles components to highly efficient JavaScript at build time. SvelteKit is the official full-stack framework built on top of Svelte, providing routing, server-side rendering, and API routes.

**Key Capabilities**:
- **No Virtual DOM**: Compiles to vanilla JS (smaller bundles, faster runtime)
- **Runes (Svelte 5)**: Modern reactivity with `$state`, `$derived`, `$effect`
- **Full-Stack**: Server load functions, form actions, API routes
- **TypeScript-First**: Full type safety with generated types
- **Progressive Enhancement**: Forms work without JavaScript

## Pattern Selection

### Component Type
**Use Runes (Svelte 5) when**:
- New projects
- Want better TypeScript support
- More explicit reactivity

**AVOID Legacy Syntax**:
- `let count = 0` for reactive state (use `$state` instead)
- `$:` for reactive statements (use `$derived` instead)
- `createEventDispatcher` (use callback props instead)

### Data Loading Strategy
**Use +page.server.ts when**:
- Need database access
- Need environment secrets
- Server-only data

**Use +page.ts when**:
- Can run on client or server
- Fetching from public APIs
- Want client-side navigation

**Use Form Actions when**:
- Form submissions
- Mutations
- Progressive enhancement needed

### Store vs Component State
**Use Component State ($state) when**:
- Local to single component
- Not shared

**Use Stores when**:
- Shared across multiple components
- Need subscriptions outside components
- Complex derived state

## 1. Project Structure (SvelteKit)
```
src/
├── lib/
│   ├── components/       # Reusable components
│   ├── stores/           # Svelte stores
│   ├── utils/
│   └── server/           # Server-only code
├── routes/
│   ├── +layout.svelte    # Root layout
│   ├── +page.svelte      # Home page
│   ├── api/
│   │   └── users/
│   │       └── +server.ts  # API endpoint
│   └── users/
│       ├── +page.svelte
│       ├── +page.server.ts  # Server load function
│       └── [id]/
│           └── +page.svelte
├── app.html
└── app.d.ts
```

## 2. Component Basics
- **Runes (Svelte 5)**: Use `$state`, `$derived`, `$effect`.
- **Props**: Use `$props()` for type-safe props.
- **Events**: Use callback props instead of `createEventDispatcher`.

```svelte
<!-- ✅ Good - Svelte 5 with Runes -->
<script lang="ts">
  interface Props {
    count?: number;
    onUpdate?: (count: number) => void;
  }

  let { count = 0, onUpdate }: Props = $props();
  
  let doubled = $derived(count * 2);
  
  function increment() {
    count++;
    onUpdate?.(count);
  }
</script>

<button onclick={increment}>
  {count} (doubled: {doubled})
</button>
```

## 3. Stores
- **writable**: Mutable state.
- **readable**: Read-only external state.
- **derived**: Computed from other stores.

```typescript
// stores/auth.ts
import { writable, derived } from 'svelte/store';

interface User {
  id: string;
  name: string;
}

function createAuthStore() {
  const { subscribe, set, update } = writable<User | null>(null);

  return {
    subscribe,
    login: async (email: string, password: string) => {
      const user = await api.login(email, password);
      set(user);
    },
    logout: () => set(null),
  };
}

export const auth = createAuthStore();
export const isAuthenticated = derived(auth, $auth => $auth !== null);
```

## 4. SvelteKit Data Loading
- **+page.server.ts**: Server-side data loading.
- **+page.ts**: Universal (client + server) loading.
- **load function**: Return data for the page.

```typescript
// routes/users/+page.server.ts
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, fetch }) => {
  const response = await fetch('/api/users');
  const users = await response.json();
  
  return {
    users,
    currentUser: locals.user,
  };
};
```

```svelte
<!-- routes/users/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  
  let { data }: { data: PageData } = $props();
</script>

<ul>
  {#each data.users as user}
    <li>{user.name}</li>
  {/each}
</ul>
```

## 5. Form Actions
```typescript
// routes/login/+page.server.ts
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData();
    const email = data.get('email');
    const password = data.get('password');

    if (!email || !password) {
      return fail(400, { email, missing: true });
    }

    const user = await auth.login(email, password);
    if (!user) {
      return fail(401, { email, incorrect: true });
    }

    cookies.set('session', user.token, { path: '/' });
    throw redirect(303, '/dashboard');
  },
};
```

## 6. API Routes
```typescript
// routes/api/users/+server.ts
import type { RequestHandler } from './$types';
import { json, error } from '@sveltejs/kit';

export const GET: RequestHandler = async ({ url }) => {
  const limit = Number(url.searchParams.get('limit')) || 10;
  const users = await db.users.findMany({ take: limit });
  return json(users);
};

export const POST: RequestHandler = async ({ request }) => {
  const data = await request.json();
  const user = await db.users.create({ data });
  return json(user, { status: 201 });
};
```

## 7. Template Syntax
```svelte
<!-- Conditionals -->
{#if loading}
  <p>Loading...</p>
{:else if error}
  <p>Error: {error}</p>
{:else}
  <p>{data}</p>
{/if}

<!-- Loops -->
{#each items as item (item.id)}
  <li>{item.name}</li>
{/each}

<!-- Await blocks -->
{#await promise}
  <p>Loading...</p>
{:then data}
  <p>{data}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}
```

## Best Practices

**MUST**:
- Use Runes (`$state`, `$derived`, `$effect`) in Svelte 5 (NO legacy syntax)
- Use `<script lang="ts">` for ALL components
- Use callback props (NO `createEventDispatcher`)
- Use `(item.id)` key in `{#each}` loops
- Return data from load functions (NO throwing errors without fail())

**SHOULD**:
- Use `+page.server.ts` for server-side data loading
- Use form actions for mutations
- Use `$lib` alias for imports
- Use hooks.server.ts for auth/middleware
- Run `svelte-kit sync` after schema changes

**AVOID**:
- Legacy reactivity (`let count = 0`, `$:`)
- Client-side data fetching in components (use load functions)
- Exposing secrets to client
- Missing type annotations
- Direct database access in `+page.ts` (use `+page.server.ts`)

## Common Patterns

### Runes (Svelte 5)
```svelte
<!-- ✅ GOOD: Runes for reactivity -->
<script lang="ts">
  interface Props {
    initialCount?: number
    onUpdate?: (count: number) => void
  }

  let { initialCount = 0, onUpdate }: Props = $props()
  
  let count = $state(initialCount)  // Reactive state
  let doubled = $derived(count * 2)  // Computed state
  
  $effect(() => {
    console.log('Count changed:', count)  // Side effect
  })
  
  function increment() {
    count++
    onUpdate?.(count)
  }
</script>

<button onclick={increment}>
  {count} (doubled: {doubled})
</button>

<!-- ❌ BAD: Legacy syntax -->
<script lang="ts">
  let count = 0  // NOT reactive in Svelte 5
  $: doubled = count * 2  // Old syntax
  
  $: {
    console.log('Count changed:', count)  // Use $effect instead
  }
</script>
```

### Load Functions
```typescript
// ✅ GOOD: Server load function with types
// routes/users/[id]/+page.server.ts
import type { PageServerLoad } from './$types'
import { error } from '@sveltejs/kit'

export const load: PageServerLoad = async ({ params, locals }) => {
  const user = await db.user.findUnique({
    where: { id: params.id }
  })
  
  if (!user) {
    throw error(404, 'User not found')
  }
  
  return {
    user,
    currentUser: locals.user  // From hooks.server.ts
  }
}

// routes/users/[id]/+page.svelte
<script lang="ts">
  import type { PageData } from './$types'
  
  let { data }: { data: PageData } = $props()
</script>

<h1>{data.user.name}</h1>

// ❌ BAD: Client-side fetching
<script lang="ts">
  import { onMount } from 'svelte'
  
  let user = $state(null)
  
  onMount(async () => {
    const response = await fetch(`/api/users/${id}`)
    user = await response.json()  // Slower, no SSR
  })
</script>
```

### Form Actions
```typescript
// ✅ GOOD: Form action with validation
// routes/login/+page.server.ts
import type { Actions } from './$types'
import { fail, redirect } from '@sveltejs/kit'

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData()
    const email = data.get('email')?.toString()
    const password = data.get('password')?.toString()

    // Validation
    if (!email || !password) {
      return fail(400, { 
        email, 
        error: 'Email and password required' 
      })
    }

    // Authentication
    const user = await auth.login(email, password)
    if (!user) {
      return fail(401, { 
        email, 
        error: 'Invalid credentials' 
      })
    }

    // Set session
    cookies.set('session', user.token, { 
      path: '/',
      httpOnly: true,
      secure: true,
      sameSite: 'strict'
    })

    throw redirect(303, '/dashboard')
  }
}

// routes/login/+page.svelte
<script lang="ts">
  import { enhance } from '$app/forms'
  import type { ActionData } from './$types'
  
  let { form }: { form: ActionData } = $props()
</script>

<form method="POST" use:enhance>
  <input name="email" type="email" required />
  <input name="password" type="password" required />
  {#if form?.error}
    <p class="error">{form.error}</p>
  {/if}
  <button type="submit">Login</button>
</form>

// ❌ BAD: Client-side form submission
<script>
  async function handleSubmit(e) {
    e.preventDefault()
    await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    })  // No progressive enhancement, extra API route
  }
</script>

<form onsubmit={handleSubmit}>
  <!-- ... -->
</form>
```

### Stores
```typescript
// ✅ GOOD: Custom store with methods
// stores/cart.ts
import { writable, derived } from 'svelte/store'

interface CartItem {
  id: string
  name: string
  price: number
  quantity: number
}

function createCartStore() {
  const { subscribe, set, update } = writable<CartItem[]>([])

  return {
    subscribe,
    addItem: (item: CartItem) => {
      update(items => {
        const existing = items.find(i => i.id === item.id)
        if (existing) {
          existing.quantity += item.quantity
          return items
        }
        return [...items, item]
      })
    },
    removeItem: (id: string) => {
      update(items => items.filter(i => i.id !== id))
    },
    clear: () => set([])
  }
}

export const cart = createCartStore()
export const cartTotal = derived(
  cart, 
  $cart => $cart.reduce((sum, item) => sum + item.price * item.quantity, 0)
)

// Usage in component
<script lang="ts">
  import { cart, cartTotal } from '$lib/stores/cart'
</script>

<p>Total: ${$cartTotal}</p>
{#each $cart as item (item.id)}
  <div>{item.name} x {item.quantity}</div>
{/each}
```

## Common Anti-Patterns

**❌ Missing keys in loops**:
```svelte
<!-- BAD -->
{#each items as item}
  <li>{item.name}</li>
{/each}
```

**✅ Always use keys**:
```svelte
<!-- GOOD -->
{#each items as item (item.id)}
  <li>{item.name}</li>
{/each}
```

**❌ Exposing secrets to client**:
```typescript
// BAD - In +page.ts (runs on client)
import { API_SECRET_KEY } from '$env/static/private'  // ERROR
```

**✅ Use server-only files**:
```typescript
// GOOD - In +page.server.ts (server only)
import { API_SECRET_KEY } from '$env/static/private'  // Safe
```

## 8. Best Practices
- **$lib alias**: Import from `$lib/` for lib folder
- **Type Generation**: Run `svelte-kit sync` for types
- **Hooks**: Use `hooks.server.ts` for auth, logging
- **Environment**: Use `$env/static/private` for secrets (server-only)

