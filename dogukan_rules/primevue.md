---
globs: ["**/*.vue"]
alwaysApply: false
---

# PrimeVue Rules

<versions>
## Version Matrix

| Project | UI Framework | PrimeVue | Notes |
|---------|-------------|----------|-------|
| bep-2-backend-pharmacy | **Quasar 2.x** (primary) + PrimeVue 4.x | 4.2.x | Quasar is main UI lib, PrimeVue secondary. Also uses UnoCSS + Tailwind |
| bss-ui-pharmacy-cockpit | PrimeVue 4.x | 4.5.x | Auto-import, Tailwind integration |
| partner-portal | PrimeVue 4.x | 4.4.x | Auto-import |
| ia-reservation-system | PrimeVue 3.x | 3.48.x | Manual imports, CSS-only styling |
| teambee | PrimeVue 3.x | 3.47.x | Manual imports |

**BEP uses Quasar as primary UI framework.** Prefer Quasar components (QBtn, QDialog, QTable) over PrimeVue equivalents when working in BEP.

**Always check `package.json` for the project's UI framework before writing components.**
</versions>

<v4-setup>
## PrimeVue 4 Setup (Modern Projects)

### Theme with definePreset
```typescript
// primevue-setup.ts
import { definePreset } from '@primevue/themes'
import Lara from '@primevue/themes/lara'

const MyPreset = definePreset(Lara, {
  semantic: {
    primary: { 50: '#...', 500: '#...', 900: '#...' },
  },
  components: {
    button: { paddingX: '1rem', paddingY: '0.3175rem' },
    datatable: { headerCell: { padding: '0.875rem' } }
  }
})

app.use(PrimeVue, {
  theme: {
    preset: MyPreset,
    options: { darkModeSelector: '.fake-dark-selector', cssLayer: false }
  },
  pt: ptOptions
})
```

### Auto-Import (v4 only)
```typescript
// vite.config.ts
import { PrimeVueResolver } from '@primevue/auto-import-resolver'
import Components from 'unplugin-vue-components/vite'

Components({ resolvers: [PrimeVueResolver()] })
```
- Components auto-imported in templates (no manual imports needed)
- Composables (`useToast`, `useConfirm`) still need manual imports
</v4-setup>

<passthrough>
## Passthrough Props (pt) - v4 Only

### Basic Usage
```vue
<Button
  label="Click"
  :pt="{ root: { class: 'custom-class' } }"
  :pt-options="{ mergeProps: true }"
/>
```

### Conditional Styling
```typescript
export const pt = {
  toast: {
    container: ({ props }: ToastPassThroughMethodOptions) => ({
      class: {
        '!bg-green-50': props.message?.severity === 'success',
        '!bg-red-50': props.message?.severity === 'error',
      },
    }),
  },
}

export const ptOptions = { mergeProps: true }
```

### Rules
- **Always use `mergeProps: true`** to merge with defaults (not replace)
- Use function syntax `({ props, state })` for conditional styling
- Access component state and props inside pt functions
- Prefix utility classes with `!` for important when overriding defaults
</passthrough>

<components>
## Component Patterns

### Toast
```typescript
// Setup (main.ts)
import ToastService from 'primevue/toastservice'
app.use(ToastService)

// Template (App.vue or layout) - REQUIRED
<Toast position="top-right" />

// Usage in component
import { useToast } from 'primevue/usetoast'
const toast = useToast()
toast.add({ severity: 'success', summary: 'Done', detail: 'Saved', life: 3000 })
```

**BSS pattern - Toast composable wrapper:**
```typescript
export function useToaster() {
  const LIFE_TIME = 4000
  const ERROR_LIFE_TIME = 0  // stays until dismissed

  function success({ summary, detail, lifeTime = LIFE_TIME }) {
    toast.add({ severity: 'success', summary: t(summary), detail: t(detail), life: lifeTime })
  }
  function error({ summary, detail }) {
    toast.add({ severity: 'error', summary: t(summary), detail: t(detail), life: ERROR_LIFE_TIME })
  }
  return { success, error, warn }
}
```

### Dialog
```vue
<Dialog
  v-model:visible="visible"
  modal
  dismissable-mask
  closable
  :draggable="false"
  :style="{ width: '600px' }"
  :append-to="appendToContainer"
  :pt-options="{ mergeProps: true }"
  @update:visible="handleClose"
>
  <template #header>
    <h3 class="text-xl font-bold">{{ title }}</h3>
  </template>

  <template #default>
    <slot />
  </template>

  <template #footer>
    <Button :label="t('common.cancel')" outlined @click="handleClose" />
    <Button :label="t('common.confirm')" @click="handleConfirm" />
  </template>
</Dialog>
```

**Dialog rules:**
- Always set `modal` for overlay backdrop
- Always set `dismissable-mask` for click-outside-to-close
- Always set `:draggable="false"` unless drag is specifically needed
- Use `append-to` to solve z-index issues with nested dialogs
- Focus first interactive element on open

### DataTable
```vue
<DataTable
  :value="items"
  :loading="isLoading"
  :total-records="totalRecords"
  :rows="pageSize"
  paginator
  lazy
  paginator-template="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
  :aria-label="t('table.ariaLabel')"
  @page="handlePageChange"
>
  <Column field="name" :header="t('table.name')" sortable />
  <Column field="email" :header="t('table.email')" />
  <Column :header="t('table.actions')" style="width: 150px">
    <template #body="{ data }">
      <Button icon="pi pi-pencil" :aria-label="t('common.edit')" @click="editItem(data)" />
    </template>
  </Column>
</DataTable>
```

**DataTable rules:**
- Always use `lazy` + `paginator` for server-side data
- Always provide `aria-label` on the table
- Always provide `aria-label` on icon-only action buttons
- Use `paginator-template` for consistent pagination across the app

### DatePicker / Calendar
```vue
<!-- v4: DatePicker (renamed from Calendar) -->
<DatePicker
  v-model="selectedDate"
  date-format="dd.mm.yy"
  :show-time="false"
  :show-icon="true"
/>

<!-- v3: Calendar -->
<Calendar
  v-model="selectedDate"
  date-format="dd.mm.yy"
/>
```

**DatePicker pitfalls:**
- v4 renamed `Calendar` to `DatePicker`
- Use `date-format` (kebab-case), NOT `dateFormat` (camelCase) in templates
- German format: `dd.mm.yy` (2-digit year) or `dd.mm.yyyy` (4-digit - custom)
- `pt` passthrough has limited support for inner elements — check docs before attempting deep customization
</components>

<confirm>
## Reusable ConfirmModal Pattern (BEP2 Standard)

```vue
<script setup lang="ts">
const props = defineProps<{
  visible: boolean
  title: string
  description: string
  confirmLabel?: string
  confirmSeverity?: string
}>()

const emit = defineEmits<{
  (e: 'confirm'): void
  (e: 'cancel'): void
  (e: 'update:visible', value: boolean): void
}>()

const closeAndCancel = () => {
  emit('update:visible', false)
  emit('cancel')
}
</script>

<template>
  <Dialog
    :visible="visible"
    modal
    dismissable-mask
    :draggable="false"
    :style="{ width: '600px' }"
    @update:visible="$emit('update:visible', $event)"
  >
    <template #header>
      <h3 class="text-xl font-bold">{{ title }}</h3>
    </template>

    <p>{{ description }}</p>

    <template #footer>
      <Button :label="t('common.cancel')" outlined @click="closeAndCancel" />
      <Button
        :label="confirmLabel ?? t('common.confirm')"
        :severity="confirmSeverity ?? 'primary'"
        @click="$emit('confirm')"
      />
    </template>
  </Dialog>
</template>
```
</confirm>

<v3-vs-v4>
## v3 to v4 Migration Notes

| Feature | v3 | v4 |
|---------|----|----|
| Imports | Manual per component | Auto-import via resolver |
| Calendar | `Calendar` | `DatePicker` (renamed) |
| Theming | CSS files only | `definePreset()` + semantic tokens |
| Styling | Class overrides | Passthrough props (pt) |
| Toast severity | String literal | `ToastSeverity` enum from `@primevue/core/api` |
| Icons | `pi pi-*` class | Same, but also supports custom icon components |
| chart.js | **Peer dependency** | **Still a peer dependency** (do NOT remove) |
</v3-vs-v4>

<anti-patterns>
## Anti-Patterns

- **Removing chart.js** — it's a PrimeVue peer dependency (Chart component). Always `npm ls chart.js` first.
- **Missing `<Toast />`** in template — toast.add() silently fails without the component mounted
- **`pt` without `mergeProps: true`** — replaces default classes instead of merging
- **Hardcoded pixel widths** on Dialog — use responsive units or max-width
- **Missing `aria-label`** on icon-only Buttons — required for accessibility
- **Using `dateFormat` (camelCase)** in template — use `date-format` (kebab-case)
- **Global PrimeVue CSS overrides** — use scoped styles or pt system, not global `.p-*` selectors (blast radius)
- **Inline styles on DataTable columns** — use pt or CSS classes instead
</anti-patterns>
