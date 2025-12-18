# Vue.js (JavaScript)

> **Scope**: Apply these rules when working with Vue.js 3 applications using JavaScript.

## 1. Project Structure
```
src/
├── assets/
├── components/
│   ├── common/           # Shared components
│   └── features/         # Feature-specific components
├── composables/          # Reusable composition functions
├── layouts/
├── pages/                # Route pages
├── stores/               # Pinia stores
├── utils/
├── App.vue
└── main.js
```

## 2. Composition API (Preferred)
- **Always use `<script setup>`**: Most concise syntax.
- **defineProps/defineEmits**: For component API.

```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  userId: { type: String, required: true },
  initialCount: { type: Number, default: 0 }
})

const emit = defineEmits(['update', 'delete'])

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

```javascript
// composables/useUser.js
import { ref, computed } from 'vue'

export function useUser(userId) {
  const user = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const fullName = computed(() => 
    user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
  )

  async function fetchUser() {
    loading.value = true
    try {
      user.value = await api.getUser(userId)
    } catch (e) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  return { user, loading, error, fullName, fetchUser }
}
```

## 4. Pinia State Management
```javascript
// stores/auth.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(null)

  const isAuthenticated = computed(() => !!token.value)

  async function login(email, password) {
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

## 6. Performance
- **defineAsyncComponent**: Lazy load components.
- **v-memo**: Memoize template sections.
- **shallowRef**: For large objects that don't need deep reactivity.

