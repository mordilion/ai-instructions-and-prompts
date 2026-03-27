# Vue.js (JavaScript)

> **Scope**: Vue.js 3 applications (JavaScript)  
> **Applies to**: .vue files (JavaScript)  
> **Extends**: javascript/architecture.md

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Composition API with `<script setup>`
> **ALWAYS**: Use defineProps and defineEmits
> **ALWAYS**: Use .value for refs
> **ALWAYS**: Use :key in v-for loops
> **ALWAYS**: Use Pinia for state management
> 
> **NEVER**: Use Options API (use Composition API)
> **NEVER**: Mutate props
> **NEVER**: Missing .value on refs
> **NEVER**: Index as key in v-for
> **NEVER**: Expose reactive state (use computed/readonly)

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

## AI Self-Check

- [ ] Composition API with `<script setup>`?
- [ ] defineProps and defineEmits used?
- [ ] .value for refs?
- [ ] :key in v-for loops?
- [ ] Pinia for state management?
- [ ] Composables for reusable logic?
- [ ] computed for derived state?
- [ ] No Options API?
- [ ] No mutating props?
- [ ] No missing .value on refs?
- [ ] No index as key?
- [ ] defineAsyncComponent for code splitting?

