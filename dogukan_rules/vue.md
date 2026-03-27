---
globs: ["**/*.vue", "**/*.ts", "**/*.tsx", "**/vite.config.*", "**/composables/**"]
alwaysApply: false
---

# Vue 3 & PrimeVue Frontend Rules

<!-- Last updated: 2025-01-19 -->

<checklist>
## Before Writing Code
- [ ] Check existing components to reuse
- [ ] Review Figma design if available
- [ ] Plan component hierarchy
- [ ] Define TypeScript interfaces first
- [ ] Plan i18n keys (German + English)
</checklist>

<script-setup>
## Script Setup Syntax (Required)

Always use `<script setup lang="ts">` syntax.

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import Button from 'primevue/button'

interface Props {
  id: number
  title: string
  disabled?: boolean
}

interface Emits {
  (e: 'submit', payload: FormData): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false
})

const emit = defineEmits<Emits>()

const { t } = useI18n()
const isLoading = ref(false)

const handleSubmit = () => {
  emit('submit', formData.value)
}
</script>

<template>
  <div class="form-container">
    <h2>{{ t('forms.title') }}</h2>
    <Button
      :label="t('common.submit')"
      :disabled="props.disabled"
      :loading="isLoading"
      @click="handleSubmit"
    />
  </div>
</template>

<style scoped>
.form-container {
  padding: 1rem;
}
</style>
```
</script-setup>

<typescript>
## TypeScript Patterns

### Props & Emits with Interfaces
```typescript
interface UserProps {
  userId: number
  userName: string
  roles: string[]
}

interface UserEmits {
  (e: 'select', user: UserProps): void
  (e: 'edit', userId: number): void
  (e: 'delete', userId: number): void
}

const props = withDefaults(defineProps<UserProps>(), {
  roles: () => []
})

const emit = defineEmits<UserEmits>()
```

### No `any` Types
```typescript
// GOOD: Explicit types
const user = ref<User | null>(null)
const items = ref<string[]>([])
const config = ref<Partial<Config>>({})

// BAD: Using any
const data: any = {}
```

### Reactive State
```typescript
import { ref, reactive, computed } from 'vue'

// Primitives: use ref
const count = ref(0)
const message = ref('')

// Objects: prefer ref with type
const user = ref<User>({ name: '', email: '' })

// Access with .value in script
count.value++
user.value.name = 'John'
```
</typescript>

<solid-dry-yagni>
## SOLID, DRY & YAGNI

### Single Responsibility Principle (SRP)
Each component/function has ONE job. Split if name uses "and", has multiple operations, or exceeds 15 lines.

```typescript
// GOOD: Each function does ONE thing
const validateEmail = (email: string) => /^[^\s@]+@[^\s@]+$/.test(email)
const formatUserName = (first: string, last: string) => `${first} ${last}`
const saveUser = async (user: User) => await api.post('/users', user)

// BAD: Function doing multiple things
const validateAndSaveUser = async (user: User) => {
  if (!user.email || !user.name) throw new Error('Invalid')
  const formatted = `${user.first} ${user.last}`
  await api.post('/users', { ...user, name: formatted })
  toast.success('Saved!')
  router.push('/users')
}
```

```vue
<!-- GOOD: Component with single purpose -->
<UserAvatar :user="user" />
<UserStatusBadge :status="user.status" />

<!-- BAD: Component doing too much -->
<UserCard>
  <!-- Displays avatar, status, actions, edit form, validation... -->
</UserCard>
```

```typescript
// GOOD: Single-purpose computed
const fullName = computed(() => `${user.firstName} ${user.lastName}`)
const isActive = computed(() => user.status === 'active')

// BAD: Computed doing too much
const userData = computed(() => ({
  fullName: `${user.firstName} ${user.lastName}`,
  isActive: user.status === 'active',
  formattedDate: format(user.createdAt, 'dd.MM.yyyy'),
  permissions: user.roles.flatMap(r => r.permissions)
}))
```

### DRY (Don't Repeat Yourself)
Extract repeated code into composables or utilities. Reuse existing components before creating new ones.

```typescript
// GOOD: Shared composable
export function useFormValidation() {
  const errors = ref<Record<string, string>>({})
  const validate = (rules: ValidationRules) => { /* ... */ }
  return { errors, validate }
}
```

```vue
<!-- GOOD: Reusable component with slots -->
<BaseCard>
  <template #header>{{ title }}</template>
  <slot />
</BaseCard>

<!-- BAD: Copy-pasting card markup everywhere -->
```

### YAGNI (You Aren't Gonna Need It)
Only implement what's needed NOW. No speculative features. Remove unused code, don't comment it out.

```typescript
// GOOD: Simple, focused
const props = defineProps<{
  userId: number
  userName: string
}>()

// BAD: Over-engineered for hypothetical needs
const props = defineProps<{
  userId: number
  userName: string
  userRole?: string        // Not used yet
  permissions?: string[]   // "Might need later"
  metadata?: Record<string, unknown>  // "Just in case"
}>()
```
</solid-dry-yagni>

<composables>
## Composables for Reusable Logic

Extract common functionality into composables.

```typescript
// composables/useUser.ts
import { ref, computed, onMounted } from 'vue'
import type { User } from '@/types/user'

export function useUser(userId: number) {
  const user = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const fullName = computed(() => {
    if (!user.value) return ''
    return `${user.value.firstName} ${user.value.lastName}`
  })

  const fetchUser = async () => {
    isLoading.value = true
    error.value = null
    try {
      const response = await fetch(`/api/users/${userId}`)
      user.value = await response.json()
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error'
    } finally {
      isLoading.value = false
    }
  }

  onMounted(fetchUser)

  return { user, isLoading, error, fullName, refetch: fetchUser }
}
```

Usage:
```vue
<script setup lang="ts">
import { useUser } from '@/composables/useUser'

const props = defineProps<{ userId: number }>()
const { user, isLoading, fullName } = useUser(props.userId)
</script>
```
</composables>

<primevue>
## PrimeVue Patterns

### Form Components
```vue
<script setup lang="ts">
import { ref } from 'vue'
import InputText from 'primevue/inputtext'
import Dropdown from 'primevue/dropdown'
import Button from 'primevue/button'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

interface FormData {
  email: string
  department: string
}

const form = ref<FormData>({ email: '', department: '' })

const departments = [
  { label: t('departments.it'), value: 'IT' },
  { label: t('departments.hr'), value: 'HR' }
]
</script>

<template>
  <form @submit.prevent="handleSubmit">
    <div class="field">
      <label for="email">{{ t('forms.email') }}</label>
      <InputText
        id="email"
        v-model="form.email"
        type="email"
        required
        aria-label="Email address"
      />
    </div>

    <div class="field">
      <label for="dept">{{ t('forms.department') }}</label>
      <Dropdown
        id="dept"
        v-model="form.department"
        :options="departments"
        option-label="label"
        option-value="value"
        :placeholder="t('common.select')"
      />
    </div>

    <Button type="submit" :label="t('common.submit')" />
  </form>
</template>
```

### DataTable with Pagination
```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'

interface User {
  id: number
  name: string
  email: string
}

const users = ref<User[]>([])
const isLoading = ref(false)
const totalRecords = ref(0)
const pageSize = ref(10)

const handlePageChange = (event: any) => {
  // fetch with new page
}

onMounted(() => { /* fetch */ })
</script>

<template>
  <DataTable
    :value="users"
    :loading="isLoading"
    :total-records="totalRecords"
    :rows="pageSize"
    paginator
    lazy
    @page="handlePageChange"
  >
    <Column field="name" :header="t('table.name')" sortable />
    <Column field="email" :header="t('table.email')" />
  </DataTable>
</template>
```
</primevue>

<pinia>
## Pinia State Management

### Setup Store Pattern (Recommended)
```typescript
// stores/userStore.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/types/user'

export const useUserStore = defineStore('user', () => {
  // State
  const users = ref<User[]>([])
  const currentUser = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const totalUsers = computed(() => users.value.length)
  const activeUsers = computed(() =>
    users.value.filter(u => u.status === 'active')
  )

  // Actions
  const fetchUsers = async () => {
    isLoading.value = true
    error.value = null
    try {
      const response = await fetch('/api/users')
      users.value = await response.json()
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Error'
    } finally {
      isLoading.value = false
    }
  }

  const reset = () => {
    users.value = []
    currentUser.value = null
    error.value = null
  }

  return { users, currentUser, isLoading, error, totalUsers, activeUsers, fetchUsers, reset }
})
```

### Store Usage with storeToRefs
```vue
<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores/userStore'
import { onMounted } from 'vue'

const userStore = useUserStore()

// Destructure with storeToRefs to maintain reactivity
const { users, isLoading, activeUsers } = storeToRefs(userStore)

// Actions don't need storeToRefs
const { fetchUsers, reset } = userStore

onMounted(fetchUsers)
</script>
```

### DRY with Slots
```vue
<!-- BaseCard.vue -->
<template>
  <div class="card">
    <div class="card-header"><slot name="header" /></div>
    <div class="card-body"><slot /></div>
    <div v-if="$slots.footer" class="card-footer"><slot name="footer" /></div>
  </div>
</template>

<!-- Usage -->
<BaseCard>
  <template #header><h2>Title</h2></template>
  <p>Content here</p>
  <template #footer><Button label="Save" /></template>
</BaseCard>
```
</pinia>

<i18n>
## Internationalization

- Always add translations to BOTH `de/` and `en/` locale files
- UI strings must support German AND English
- See `i18n.md` for detailed patterns
</i18n>

<patterns>
## Required Patterns
- `<script setup lang="ts">` syntax
- Props/Emits interfaces defined
- Component names in PascalCase
- Scoped styles (`<style scoped>`)
- No `any` types
- `:key` on all `v-for` loops
- Semantic HTML elements
- Keyboard navigation support
- i18n for all UI strings (German + English)
</patterns>

<anti-patterns>
## Anti-Patterns to Avoid
- Options API in new components
- Using `any` type
- Missing `:key` on `v-for`
- Global styles (use scoped)
- Hardcoded strings (use i18n)
- Logic in templates (use computed)
- Direct store state mutation outside actions
- Missing TypeScript interfaces
</anti-patterns>
