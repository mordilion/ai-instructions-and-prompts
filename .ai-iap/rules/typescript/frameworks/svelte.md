# Svelte Framework

> **Scope**: Apply these rules when working with Svelte/SvelteKit applications
> **Applies to**: .svelte files and Svelte TypeScript files
> **Extends**: typescript/architecture.md, typescript/code-style.md
> **Precedence**: Framework rules OVERRIDE TypeScript rules for Svelte-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use `$:` for reactive statements (Svelte's reactivity system)
> **ALWAYS**: Use `export let` for props (Svelte prop syntax)
> **ALWAYS**: Use stores for shared state (writable, readable, derived)
> **ALWAYS**: Clean up subscriptions with `onDestroy` (prevent memory leaks)
> **ALWAYS**: Use `bind:` for two-way binding (NOT manual event handlers)
> 
> **NEVER**: Use `.subscribe()` without `onDestroy` cleanup (memory leak)
> **NEVER**: Mutate props directly (use events for parent updates)
> **NEVER**: Forget `$:` for derived values (breaks reactivity)
> **NEVER**: Use complex logic in templates (move to reactive statements)
> **NEVER**: Create stores inside components (define at module level)

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Reactive Statements | Derived values, side effects | `$: derivedValue = count * 2` |
| Stores | Shared state across components | `writable()`, `readable()`, `derived()` |
| bind: | Two-way binding | `bind:value`, `bind:checked` |
| on: | Event handling | `on:click={handler}` |
| {#if}/{#each} | Conditional/list rendering | Control flow blocks |

## Core Patterns

### Component with Props & Events
```svelte
<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  
  export let value: string = ''
  export let placeholder: string = 'Enter text'
  
  const dispatch = createEventDispatcher<{
    change: string
    submit: void
  }>()
  
  function handleInput(e: Event) {
    const target = e.target as HTMLInputElement
    dispatch('change', target.value)
  }
</script>

<input
  value={value}
  placeholder={placeholder}
  on:input={handleInput}
  on:keydown={(e) => e.key === 'Enter' && dispatch('submit')}
/>
```

### Reactivity (Core Feature)
```svelte
<script lang="ts">
  let count = 0
  
  // Reactive statement: runs when count changes
  $: doubled = count * 2
  
  // Reactive block: multiple statements
  $: {
    console.log(`Count is ${count}`)
    if (count > 10) {
      console.warn('Count is high!')
    }
  }
  
  // Reactive expression for class/style
  $: className = count > 5 ? 'high' : 'low'
</script>

<div class={className}>
  <p>Count: {count}</p>
  <p>Doubled: {doubled}</p>
  <button on:click={() => count++}>Increment</button>
</div>
```

### Stores (Shared State)
```typescript
// stores/counter.ts
import { writable, derived, readable } from 'svelte/store'

// Writable store
export const count = writable(0)

// Derived store
export const doubled = derived(count, $count => $count * 2)

// Readable store (read-only)
export const time = readable(new Date(), (set) => {
  const interval = setInterval(() => set(new Date()), 1000)
  return () => clearInterval(interval)  // Cleanup function
})

// Usage in component
import { count } from './stores/counter'
import { onDestroy } from 'svelte'

// Auto-subscribe with $
$: console.log($count)  // Automatically subscribes and unsubscribes

// Manual subscribe (requires cleanup)
const unsubscribe = count.subscribe(value => console.log(value))
onDestroy(unsubscribe)
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Missing `$:` for Derived Values** | `const doubled = count * 2` | `$: doubled = count * 2` | Breaks reactivity |
| **Subscribe Without Cleanup** | `store.subscribe()` without `onDestroy` | Use `$store` or cleanup in `onDestroy` | Memory leak |
| **Mutating Props** | `value = 'new'` when `value` is prop | `dispatch('change', 'new')` | Breaks one-way data flow |
| **Stores in Components** | `const store = writable()` in component | Define at module level | Creates new store per instance |
| **Complex Template Logic** | Long expressions in `{...}` | Move to reactive statement | Unreadable, breaks reactivity |

### Anti-Pattern: Missing $: for Derived Values (COMMON ERROR)
```svelte
<!-- ❌ WRONG - Not reactive -->
<script lang="ts">
  let count = 0
  const doubled = count * 2  // Calculated ONCE, never updates
</script>

<!-- ✅ CORRECT - Reactive -->
<script lang="ts">
  let count = 0
  $: doubled = count * 2  // Recalculates when count changes
</script>
```

### Anti-Pattern: Subscribe Without Cleanup (MEMORY LEAK)
```svelte
<!-- ❌ WRONG - Memory leak -->
<script lang="ts">
  import { myStore } from './stores'
  
  myStore.subscribe(value => {
    console.log(value)
  })  // NEVER cleaned up!
</script>

<!-- ✅ CORRECT - Auto-subscribe -->
<script lang="ts">
  import { myStore } from './stores'
  
  $: console.log($myStore)  // Auto-subscribes and cleans up
</script>

<!-- ✅ CORRECT - Manual cleanup -->
<script lang="ts">
  import { onDestroy } from 'svelte'
  import { myStore } from './stores'
  
  const unsubscribe = myStore.subscribe(value => console.log(value))
  onDestroy(unsubscribe)
</script>
```

## AI Self-Check (Verify BEFORE generating Svelte code)

- [ ] Using `$:` for derived values? (NOT const assignments)
- [ ] Props declared with `export let`? (Svelte prop syntax)
- [ ] Events dispatched with `createEventDispatcher`?
- [ ] Stores defined at module level? (NOT inside components)
- [ ] Using `$store` for auto-subscribe? (OR manual cleanup with `onDestroy`)
- [ ] Two-way binding with `bind:`? (NOT manual v-model)
- [ ] Never mutating props directly? (Dispatch events)
- [ ] Cleanup in `onDestroy`? (Subscriptions, timers)
- [ ] Control flow with `{#if}` and `{#each}`?
- [ ] TypeScript types for props and events?

## Control Flow

```svelte
<!-- Conditional rendering -->
{#if condition}
  <p>Shown when true</p>
{:else if otherCondition}
  <p>Alternate</p>
{:else}
  <p>Default</p>
{/if}

<!-- List rendering -->
{#each items as item, index (item.id)}
  <div>{index}: {item.name}</div>
{:else}
  <p>No items</p>
{/each}

<!-- Promises -->
{#await promise}
  <p>Loading...</p>
{:then value}
  <p>Result: {value}</p>
{:catch error}
  <p>Error: {error.message}</p>
{/await}
```

## Bindings

```svelte
<!-- Two-way binding -->
<input bind:value={name} />
<input type="checkbox" bind:checked={accepted} />
<select bind:value={selected}>...</select>

<!-- Component binding -->
<CustomInput bind:value={text} />

<!-- Element binding -->
<div bind:clientWidth={width} bind:clientHeight={height}>...</div>
```

## Key Libraries

- **SvelteKit**: Full-stack framework (replaces Sapper)
- **Svelte Stores**: `writable`, `readable`, `derived`
- **svelte/transition**: Animations and transitions
- **svelte/motion**: Tweened and spring animations
