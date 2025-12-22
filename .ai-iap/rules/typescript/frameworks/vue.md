# Vue.js Framework

> **Scope**: Apply these rules when working with Vue.js 3 applications.

## Overview

Vue.js is a progressive JavaScript framework for building user interfaces. Vue 3 introduces the Composition API, which provides better TypeScript support and code reusability compared to Options API.

**Key Capabilities**:
- **Composition API**: Better logic reuse and TypeScript support
- **Reactivity System**: Fine-grained reactivity with refs and reactive
- **Single-File Components**: HTML, CSS, and JS in one file
- **Progressive**: Can be adopted incrementally
- **Pinia**: Official state management (replaces Vuex)

## Pattern Selection

### API Selection
**Use Composition API (script setup) when**:
- New projects (Vue 3)
- Need TypeScript support
- Want better code organization
- Reusing logic across components

**AVOID Options API**:
- Legacy syntax (Vue 2)
- Poor TypeScript support
- Harder to reuse logic

### Reactivity Choice
**Use `ref()` when**:
- Primitive values (string, number, boolean)
- Need `.value` access
- Simple state

**Use `reactive()` when**:
- Objects with multiple properties
- Want direct property access (no .value)
- Complex nested state

**Use `computed()` when**:
- Derived state
- Expensive calculations to cache
- Dependent on other reactive values

### State Management
**Use Component State when**:
- Local UI state
- Not shared across components

**Use Composables when**:
- Reusable logic
- Shared across few components

**Use Pinia when**:
- Global application state
- Shared across many components
- Need devtools

## 1. Project Structure
```
src/
├── assets/
├── components/
│   ├── common/           # Shared components
│   └── features/         # Feature-specific components
├── composables/          # Reusable composition functions
├── layouts/
├── pages/                # Route pages (with vue-router)
├── stores/               # Pinia stores
├── types/
├── utils/
├── App.vue
└── main.ts
```

## 2. Composition API
- **Always use `<script setup>`**: Most concise syntax.
- **TypeScript**: Use `lang="ts"`.
- **defineProps/defineEmits**: For component API.

```vue
<!-- ✅ Good -->
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

interface Props {
  userId: string
  initialCount?: number
}

const props = withDefaults(defineProps<Props>(), {
  initialCount: 0
})

const emit = defineEmits<{
  update: [count: number]
  delete: []
}>()

const count = ref(props.initialCount)
const doubled = computed(() => count.value * 2)

const increment = () => {
  count.value++
  emit('update', count.value)
}

onMounted(() => {
  console.log('Mounted with userId:', props.userId)
})
</script>

<template>
  <button @click="increment">{{ count }} ({{ doubled }})</button>
</template>
```

## 3. Composables
- **Naming**: Start with `use` prefix.
- **Return**: Reactive refs and methods.
- **Encapsulation**: Hide implementation details.

```typescript
// composables/useUser.ts
import { ref, computed } from 'vue'

export function useUser(userId: string) {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const fullName = computed(() => 
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  )

  async function fetchUser() {
    loading.value = true
    error.value = null
    try {
      user.value = await api.getUser(userId)
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Unknown error'
    } finally {
      loading.value = false
    }
  }

  return { user, loading, error, fullName, fetchUser }
}
```

## 4. Pinia State Management
- **defineStore**: Use setup syntax for better TypeScript.
- **Actions**: Async operations.
- **Getters**: Computed derived state.

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  async function login(email: string, password: string) {
    const response = await api.login(email, password)
    user.value = response.user
    token.value = response.token
  }

  function logout() {
    user.value = null
    token.value = null
  }

  return { user, token, isAuthenticated, login, logout }
})
```

## 5. Template Best Practices
- **v-bind shorthand**: `:prop` instead of `v-bind:prop`.
- **v-on shorthand**: `@event` instead of `v-on:event`.
- **v-if vs v-show**: `v-if` for conditional, `v-show` for frequent toggles.
- **Key attribute**: Always use `:key` in `v-for`.

```vue
<template>
  <!-- ✅ Good -->
  <ul>
    <li v-for="item in items" :key="item.id">
      {{ item.name }}
    </li>
  </ul>

  <!-- Conditional rendering -->
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>{{ data }}</div>
</template>
```

## 6. Component Communication
- **Props**: Parent to child (one-way).
- **Emits**: Child to parent events.
- **Provide/Inject**: Deep component trees.
- **Pinia**: Global state.

## 7. Vue Router
```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: () => import('@/pages/Home.vue'),
    },
    {
      path: '/users/:id',
      component: () => import('@/pages/UserDetail.vue'),
      props: true,
    },
  ],
})

// Navigation guard
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return '/login'
  }
})
```

## Best Practices

**MUST**:
- Use `<script setup lang="ts">` for ALL components
- Use Composition API (NO Options API)
- Use `defineProps` and `defineEmits` with TypeScript types
- Use `:key` in `v-for` loops (unique, stable keys)
- Use `async` pipe or composables for data fetching (NO direct fetch in setup)

**SHOULD**:
- Use composables for reusable logic (prefix with `use`)
- Use Pinia for global state management
- Use Vue Router for navigation
- Use computed for derived state
- Use async pipe in templates (let Vue handle subscriptions)

**AVOID**:
- Options API (use Composition API instead)
- Direct DOM manipulation (use refs)
- Mutating props (emit events instead)
- Index as key in v-for (use unique ID)
- Watchers for everything (use computed when possible)

## Common Patterns

### Composables (Reusable Logic)
```vue
<!-- ✅ GOOD: Composable for reusable logic -->
<!-- composables/useUser.ts -->
<script setup lang="ts">
import { ref, computed } from 'vue'

export function useUser(userId: string) {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const fullName = computed(() => 
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  )

  const fetchUser = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await fetch(`/api/users/${userId}`)
      user.value = await response.json()
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Unknown error'
    } finally {
      loading.value = false
    }
  }

  // Auto-fetch on mount
  onMounted(fetchUser)

  return { user, loading, error, fullName, fetchUser }
}
</script>

<!-- Usage in component -->
<script setup lang="ts">
const { user, loading, error, fullName } = useUser(props.userId)
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>{{ fullName }}</div>
</template>

<!-- ❌ BAD: Logic duplicated in components -->
<script setup lang="ts">
const user = ref<User | null>(null)
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  const response = await fetch(`/api/users/${props.userId}`)
  user.value = await response.json()
  loading.value = false
})  // Repeated in every component that needs user data
</script>
```

### Pinia Store
```typescript
// ✅ GOOD: Pinia store with setup syntax
// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  
  // Getters
  const isAuthenticated = computed(() => !!token.value)
  const userName = computed(() => user.value?.name ?? 'Guest')
  
  // Actions
  async function login(email: string, password: string) {
    const response = await api.login(email, password)
    user.value = response.user
    token.value = response.token
    localStorage.setItem('token', response.token)
  }
  
  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }
  
  return { user, token, isAuthenticated, userName, login, logout }
})

// Usage in component
<script setup lang="ts">
const auth = useAuthStore()

const handleLogin = async () => {
  await auth.login(email.value, password.value)
  router.push('/dashboard')
}
</script>

<template>
  <div v-if="auth.isAuthenticated">
    Welcome, {{ auth.userName }}!
  </div>
</template>

// ❌ BAD: Global variables
let currentUser = null  // NOT reactive, no devtools
export function setUser(user) {
  currentUser = user  // Mutating global state
}
```

### Props & Emits with TypeScript
```vue
<!-- ✅ GOOD: Typed props and emits -->
<script setup lang="ts">
interface Props {
  userId: string
  initialCount?: number
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  initialCount: 0,
  disabled: false
})

interface Emits {
  (e: 'update', count: number): void
  (e: 'delete'): void
}

const emit = defineEmits<Emits>()

const count = ref(props.initialCount)

const increment = () => {
  count.value++
  emit('update', count.value)  // Type-safe
}

const handleDelete = () => {
  emit('delete')  // Type-safe
}
</script>

<template>
  <div>
    <button @click="increment" :disabled="disabled">
      {{ count }}
    </button>
    <button @click="handleDelete">Delete</button>
  </div>
</template>

<!-- ❌ BAD: Untyped props -->
<script setup>
const props = defineProps(['userId', 'initialCount'])  // No types
const emit = defineEmits(['update', 'delete'])

emit('update')  // No type checking
emit('updte', count.value)  // Typo not caught
</script>
```

### Computed vs Watch
```vue
<script setup lang="ts">
// ✅ GOOD: Use computed for derived state
const user = ref<User | null>(null)
const fullName = computed(() => 
  user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
)  // Auto-updates when user changes, cached

// ✅ GOOD: Use watch for side effects
watch(() => route.params.id, async (newId) => {
  // Side effect: fetch data when route changes
  user.value = await fetchUser(newId as string)
})

// ❌ BAD: Watch for derived state
const fullName = ref('')
watch(user, (newUser) => {
  fullName.value = newUser ? `${newUser.firstName} ${newUser.lastName}` : ''
})  // Use computed instead
</script>
```

### v-for with :key
```vue
<template>
  <!-- ✅ GOOD: Unique, stable key -->
  <ul>
    <li v-for="item in items" :key="item.id">
      {{ item.name }}
    </li>
  </ul>

  <!-- ❌ BAD: Index as key -->
  <ul>
    <li v-for="(item, index) in items" :key="index">
      {{ item.name }}
    </li>
  </ul>  <!-- Causes issues when items reorder/remove -->

  <!-- ❌ BAD: No key -->
  <ul>
    <li v-for="item in items">
      {{ item.name }}
    </li>
  </ul>  <!-- Vue can't track changes efficiently -->
</template>
```

## Common Anti-Patterns

**❌ Mutating props**:
```vue
<script setup>
const props = defineProps<{ count: number }>()
const increment = () => {
  props.count++  // ERROR: Mutating prop
}
</script>
```

**✅ Emit events instead**:
```vue
<script setup>
const props = defineProps<{ count: number }>()
const emit = defineEmits<{ (e: 'update', count: number): void }>()

const increment = () => {
  emit('update', props.count + 1)  // Parent updates prop
}
</script>
```

**❌ Forgetting .value**:
```typescript
const count = ref(0)
console.log(count)  // BAD: Logs ref object
count++  // BAD: Error
```

**✅ Use .value**:
```typescript
const count = ref(0)
console.log(count.value)  // GOOD: Logs 0
count.value++  // GOOD: Increments
```

## 8. Performance
- **defineAsyncComponent**: Lazy load components
- **v-memo**: Memoize template sections (reduce re-renders)
- **shallowRef/shallowReactive**: For large objects (only top-level reactivity)

