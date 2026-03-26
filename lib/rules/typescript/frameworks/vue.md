# Vue.js Framework

> **Scope**: Vue.js 3.x applications  
> **Applies to**: .vue files and Vue TypeScript files
> **Extends**: typescript/architecture.md, typescript/code-style.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Composition API with `<script setup>`
> **ALWAYS**: Use `ref()` or `reactive()` for state
> **ALWAYS**: Define props with TypeScript interfaces
> **ALWAYS**: Use computed() for derived state
> **ALWAYS**: Clean up side effects in onBeforeUnmount
> 
> **NEVER**: Use Options API in new code
> **NEVER**: Mutate props directly
> **NEVER**: Access refs without .value in `<script>`
> **NEVER**: Forget to define emits
> **NEVER**: Use `any` type for props/emits

## Core Patterns

```vue
<script setup lang="ts">
// Props & Emits
interface Props { modelValue: string; placeholder?: string }
interface Emits { (e: 'update:modelValue', value: string): void }
const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Reactive State
const count = ref(0)  // Primitives
const state = reactive({ user: { name: 'John' } })  // Objects
const doubled = computed(() => count.value * 2)  // Derived

// Lifecycle
onMounted(() => interval = setInterval(tick, 1000))
onBeforeUnmount(() => clearInterval(interval))
</script>

<template>
  <button @click="count++">{{ count }}</button>  <!-- No .value in template -->
</template>
```

### Composables

```typescript
// composables/useCounter.ts
export function useCounter(initial = 0) {
  const count = ref(initial)
  return { count, increment: () => count.value++ }
}
```

## Common AI Mistakes

| Mistake | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Options API** | `data() { return ... }` | `const state = ref()` |
| **No .value** | `count++` in script | `count.value++` |
| **Prop Mutation** | `props.value = x` | `emit('update:value', x)` |
| **any Type** | `props: any` | Interface with types |

## AI Self-Check

- [ ] Composition API with <script setup>?
- [ ] ref()/reactive() for state?
- [ ] TypeScript interfaces for props?
- [ ] computed() for derived?
- [ ] Side effects cleanup?
- [ ] .value in <script>?
- [ ] Emits defined?
- [ ] No prop mutation?
- [ ] No any types?

## Key Features

| Feature | Purpose |
|---------|---------|
| <script setup> | Composition API |
| ref() | Reactive primitives |
| reactive() | Reactive objects |
| computed() | Derived state |
| Composables | Reusable logic |

## Best Practices

**MUST**: Composition API, ref()/reactive(), TypeScript, computed(), cleanup
**SHOULD**: Composables, v-model, provide/inject, Pinia
**AVOID**: Options API, prop mutation, any types, no .value
