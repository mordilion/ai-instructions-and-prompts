# Vue.js Framework

> **Scope**: Apply these rules when working with Vue.js 3 applications.

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

## 8. Performance
- **defineAsyncComponent**: Lazy load components.
- **v-memo**: Memoize template sections.
- **shallowRef/shallowReactive**: For large objects.

