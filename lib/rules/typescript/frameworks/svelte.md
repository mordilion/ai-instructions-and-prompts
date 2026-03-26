# Svelte Framework

> **Scope**: Svelte/SvelteKit applications  
> **Applies to**: .svelte files and Svelte TypeScript files
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use `$:` for reactive statements
> **ALWAYS**: Use `export let` for props
> **ALWAYS**: Use stores for shared state
> **ALWAYS**: Clean up subscriptions with onDestroy
> **ALWAYS**: Use `bind:` for two-way binding
> 
> **NEVER**: Use `.subscribe()` without onDestroy
> **NEVER**: Mutate props directly
> **NEVER**: Forget `$:` for derived values
> **NEVER**: Use complex logic in templates
> **NEVER**: Create stores inside components

## Core Patterns

### Component with Props & Events

```svelte
<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  
  export let value: string = ''
  export let placeholder: string = 'Enter text'
  
  const dispatch = createEventDispatcher<{ change: string }>()
  
  function handleInput(e: Event) {
    dispatch('change', (e.target as HTMLInputElement).value)
  }
</script>

<input {value} {placeholder} on:input={handleInput} />
```

### Reactive Statements

```svelte
<script lang="ts">
  let count = 0
  $: doubled = count * 2  // Reactive declaration
  $: console.log(`count is ${count}`)  // Side effect
  $: if (count > 10) alert('Too high!')  // Conditional
</script>

<button on:click={() => count++}>
  {count} (doubled: {doubled})
</button>
```

### Stores

```typescript
// stores.ts
import { writable, derived, readable } from 'svelte/store'

export const count = writable(0)
export const doubled = derived(count, $count => $count * 2)
export const time = readable(new Date(), set => {
  const interval = setInterval(() => set(new Date()), 1000)
  return () => clearInterval(interval)
})

// Component.svelte
<script lang="ts">
  import { count } from './stores'
  // Auto-subscribes with $, auto-unsubscribes
</script>

<button on:click={() => $count++}>{$count}</button>
```

### Two-Way Binding

```svelte
<script lang="ts">
  let name = ''
  let isChecked = false
</script>

<input bind:value={name} />
<input type="checkbox" bind:checked={isChecked} />
```

### Control Flow

```svelte
{#if user}
  <p>Hello {user.name}!</p>
{:else}
  <p>Please log in</p>
{/if}

{#each items as item (item.id)}
  <div>{item.name}</div>
{/each}

{#await promise}
  <p>Loading...</p>
{:then data}
  <p>Data: {data}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **No $:** | `const doubled = count * 2` | `$: doubled = count * 2` |
| **Prop Mutation** | `value = 'new'` | `dispatch('change', 'new')` |
| **No Cleanup** | `store.subscribe()` | `$store` or onDestroy |
| **Store in Component** | `const s = writable()` inside | Define at module level |

## AI Self-Check

- [ ] Using $: for reactivity?
- [ ] export let for props?
- [ ] Stores for shared state?
- [ ] onDestroy for cleanup?
- [ ] bind: for two-way binding?
- [ ] No prop mutation?
- [ ] No complex template logic?
- [ ] No store creation in components?
- [ ] Using $store syntax?

## Key Features

| Feature | Purpose |
|---------|---------|
| $: | Reactive statements |
| Stores | Shared state |
| bind: | Two-way binding |
| on: | Event handling |
| $store | Auto-subscribe |

## Best Practices

**MUST**: $: for reactivity, export let, stores, onDestroy, bind:
**SHOULD**: Derived stores, readable stores, auto-subscribe ($)
**AVOID**: Prop mutation, complex templates, store creation in components
