# Vue.js Framework

> **Scope**: Apply these rules when working with Vue.js 3.x applications
> **Applies to**: .vue files and Vue TypeScript files
> **Extends**: typescript/architecture.md, typescript/code-style.md
> **Precedence**: Framework rules OVERRIDE TypeScript rules for Vue-specific patterns

## CRITICAL REQUIREMENTS (AI: Verify ALL before generating code)

> **ALWAYS**: Use Composition API with `<script setup>` (Vue 3 standard)
> **ALWAYS**: Use `ref()` or `reactive()` for state (explicit reactivity required)
> **ALWAYS**: Define props with TypeScript interfaces (type safety)
> **ALWAYS**: Use computed() for derived state (NOT methods for calculations)
> **ALWAYS**: Clean up side effects in onBeforeUnmount (prevent memory leaks)
> 
> **NEVER**: Use Options API in new code (legacy pattern)
> **NEVER**: Mutate props directly (one-way data flow)
> **NEVER**: Access refs without .value in `<script>` (Vue 3 requirement)
> **NEVER**: Forget to define emits (breaks type safety)
> **NEVER**: Use `any` type for props or emits

## Pattern Selection

| Pattern | Use When | Keywords |
|---------|----------|----------|
| Composition API + `<script setup>` | Always (Vue 3 standard) | `<script setup lang="ts">` |
| ref() | Primitive values | `const count = ref(0)` |
| reactive() | Objects/arrays | `const state = reactive({ ... })` |
| computed() | Derived state | `const fullName = computed(() => ...)` |
| watch/watchEffect | Side effects | `watch(source, callback)` |
| provide/inject | Dependency injection | `provide('key', value)`, `inject('key')` |

## Core Patterns

### Component with Props & Emits (REQUIRED)
```vue
<script setup lang="ts">
interface Props {
  modelValue: string
  placeholder?: string
}

interface Emits {
  (e: 'update:modelValue', value: string): void
  (e: 'submit'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const handleInput = (e: Event) => {
  const target = e.target as HTMLInputElement
  emit('update:modelValue', target.value)
}
</script>

<template>
  <input 
    :value="modelValue" 
    :placeholder="placeholder"
    @input="handleInput"
  />
</template>
```

### Reactivity Patterns
```typescript
import { ref, reactive, computed, watch } from 'vue'

// Primitives: use ref()
const count = ref(0)
const increment = () => count.value++  // .value required in script

// Objects: use reactive()
const state = reactive({
  user: { name: 'John', age: 30 },
  posts: []
})

// Derived state: use computed()
const fullName = computed(() => `${state.user.name} (${state.user.age})`)

// Side effects: use watch/watchEffect
watch(() => state.user.name, (newName) => {
  console.log(`Name changed to: ${newName}`)
})
```

### Composables (Reusable Logic)
```typescript
// composables/useCounter.ts
import { ref } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  
  const increment = () => count.value++
  const decrement = () => count.value--
  const reset = () => count.value = initialValue
  
  return { count, increment, decrement, reset }
}

// Usage in component
import { useCounter } from '@/composables/useCounter'
const { count, increment } = useCounter(10)
```

## Common AI Mistakes (DO NOT MAKE THESE ERRORS)

| Mistake | ❌ Wrong | ✅ Correct | Why Critical |
|---------|---------|-----------|--------------|
| **Using Options API** | `export default { data() {...} }` | `<script setup>` + Composition API | Options API is legacy |
| **Forgetting .value** | `count++` in script | `count.value++` | Ref requires .value access |
| **Mutating Props** | `props.modelValue = 'x'` | `emit('update:modelValue', 'x')` | Breaks one-way data flow |
| **Missing Emit Definitions** | Emit without `defineEmits` | Define all emits with types | Breaks type safety |
| **Methods for Derived State** | Function returning calculated value | `computed()` for caching | Performance degradation |

### Anti-Pattern: Options API (FORBIDDEN in new code)
```vue
<!-- ❌ WRONG - Options API (legacy) -->
<script lang="ts">
export default {
  data() {
    return { count: 0 }
  },
  methods: {
    increment() {
      this.count++
    }
  }
}
</script>

<!-- ✅ CORRECT - Composition API -->
<script setup lang="ts">
import { ref } from 'vue'
const count = ref(0)
const increment = () => count.value++
</script>
```

### Anti-Pattern: Forgetting .value (COMMON ERROR)
```typescript
// ❌ WRONG - Missing .value
const count = ref(0)
count++  // Does NOT work
if (count > 5) { }  // Does NOT work

// ✅ CORRECT - Use .value in script
const count = ref(0)
count.value++  // Works
if (count.value > 5) { }  // Works
```

## AI Self-Check (Verify BEFORE generating Vue code)

- [ ] Using Composition API with `<script setup>`? (NOT Options API)
- [ ] Props defined with TypeScript interface? (Type safety)
- [ ] Emits defined with `defineEmits<T>`? (All events declared)
- [ ] Using ref() for primitives, reactive() for objects?
- [ ] Accessing refs with .value in `<script>`? (Required)
- [ ] Using computed() for derived state? (NOT methods)
- [ ] Never mutating props directly? (Emit for updates)
- [ ] Cleaning up in onBeforeUnmount? (Timers, subscriptions)
- [ ] Template uses correct v-model syntax?
- [ ] Composables for reusable logic?

## Component Communication

| Pattern | Use Case | Example |
|---------|----------|---------|
| Props | Parent → Child | `defineProps<Props>()` |
| Emits | Child → Parent | `emit('eventName', payload)` |
| v-model | Two-way binding | `v-model="value"` |
| provide/inject | Ancestor → Descendant | `provide()`, `inject()` |
| Pinia/Vuex | Global state | Store pattern |

## Lifecycle Hooks

```typescript
import { onMounted, onUpdated, onBeforeUnmount } from 'vue'

onMounted(() => {
  // Component mounted, DOM available
})

onUpdated(() => {
  // After reactive data changes
})

onBeforeUnmount(() => {
  // Cleanup: remove event listeners, clear timers
})
```

## Key Libraries

- **Vue Router**: `useRouter()`, `useRoute()`
- **Pinia**: `defineStore()`, `storeToRefs()`
- **VueUse**: Composable utilities collection
- **Vite**: Build tool (replaces Vue CLI)
