# Svelte / SvelteKit Framework

> **Scope**: Apply these rules when working with Svelte and SvelteKit applications.

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

## 8. Best Practices
- **$lib alias**: Import from `$lib/` for lib folder.
- **Type Generation**: Run `svelte-kit sync` for types.
- **Hooks**: Use `hooks.server.ts` for auth, logging.
- **Environment**: Use `$env/static/private` for secrets.

