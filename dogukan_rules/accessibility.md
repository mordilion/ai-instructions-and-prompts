---
globs: ["**/*.vue", "**/*.html", "**/*.tsx"]
alwaysApply: false
---

# Accessibility (a11y) Rules

<checklist>
## Before Submitting Code
- [ ] All images have alt text
- [ ] Form labels associated with inputs
- [ ] Semantic HTML elements used
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] Color not sole means of conveying info
- [ ] ARIA labels for dynamic content
</checklist>

<semantic-html>
## Semantic HTML

### Use Proper Elements
```vue
<!-- GOOD: Semantic elements -->
<header>...</header>
<nav>...</nav>
<main>...</main>
<article>...</article>
<section>...</section>
<aside>...</aside>
<footer>...</footer>
<button @click="handleClick">Click me</button>
<h1>Main Title</h1>
<h2>Section Title</h2>

<!-- BAD: Div soup -->
<div class="header">...</div>
<div @click="handleClick">Click me</div>
<div class="title">Main Title</div>
```

### Heading Hierarchy
```vue
<!-- GOOD: Proper hierarchy -->
<h1>Page Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
  <h2>Section 2</h2>

<!-- BAD: Skipping levels -->
<h1>Page Title</h1>
  <h4>Section</h4>  <!-- Skipped h2, h3 -->
```
</semantic-html>

<forms>
## Form Accessibility

### Labels and Inputs
```vue
<!-- GOOD: Associated label -->
<div class="field">
  <label for="email">{{ t('forms.email') }}</label>
  <InputText
    id="email"
    v-model="form.email"
    type="email"
    aria-describedby="email-help"
    required
  />
  <small id="email-help">{{ t('forms.emailHelp') }}</small>
</div>

<!-- BAD: No label association -->
<div>
  <span>Email</span>
  <input v-model="form.email" />
</div>
```

### Error Messages
```vue
<template>
  <div class="field">
    <label for="email">{{ t('forms.email') }}</label>
    <InputText
      id="email"
      v-model="form.email"
      :class="{ 'p-invalid': errors.email }"
      aria-invalid="errors.email ? 'true' : undefined"
      aria-describedby="email-error"
    />
    <small
      v-if="errors.email"
      id="email-error"
      class="p-error"
      role="alert"
    >
      {{ errors.email }}
    </small>
  </div>
</template>
```

### Required Fields
```vue
<label for="name">
  {{ t('forms.name') }}
  <span class="required" aria-hidden="true">*</span>
  <span class="sr-only">{{ t('forms.required') }}</span>
</label>
<InputText id="name" required aria-required="true" />
```
</forms>

<keyboard>
## Keyboard Navigation

### Focus Management
```vue
<script setup lang="ts">
import { ref, nextTick } from 'vue'

const dialogOpen = ref(false)
const firstInput = ref<HTMLInputElement | null>(null)
const triggerButton = ref<HTMLButtonElement | null>(null)

const openDialog = async () => {
  dialogOpen.value = true
  await nextTick()
  firstInput.value?.focus() // Focus first input
}

const closeDialog = () => {
  dialogOpen.value = false
  triggerButton.value?.focus() // Return focus to trigger
}

const handleKeyDown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    closeDialog()
  }
}
</script>

<template>
  <button ref="triggerButton" @click="openDialog">
    {{ t('common.open') }}
  </button>

  <Dialog
    v-if="dialogOpen"
    :visible="dialogOpen"
    @keydown="handleKeyDown"
    aria-modal="true"
  >
    <input ref="firstInput" type="text" />
    <button @click="closeDialog">{{ t('common.close') }}</button>
  </Dialog>
</template>
```

### Skip Links
```vue
<!-- At top of page -->
<a href="#main-content" class="skip-link">
  {{ t('a11y.skipToContent') }}
</a>

<main id="main-content" tabindex="-1">
  <!-- Main content -->
</main>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--primary-color);
  color: white;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
</style>
```
</keyboard>

<aria>
## ARIA Labels

### Dynamic Content Announcements
```vue
<template>
  <!-- Live region for announcements -->
  <div
    role="status"
    aria-live="polite"
    aria-atomic="true"
    class="sr-only"
  >
    {{ statusMessage }}
  </div>

  <!-- Loading state -->
  <button
    @click="handleSubmit"
    :disabled="isLoading"
    :aria-busy="isLoading"
  >
    {{ isLoading ? t('common.loading') : t('common.submit') }}
  </button>

  <!-- Icon buttons need labels -->
  <Button
    icon="pi pi-trash"
    @click="deleteItem"
    aria-label="Delete item"
  />
</template>
```

### Tables
```vue
<DataTable
  :value="users"
  aria-label="User management table"
>
  <Column field="name" header="Name" />
  <Column field="email" header="Email" />
  <Column header="Actions">
    <template #body="{ data }">
      <Button
        icon="pi pi-pencil"
        aria-label="Edit user"
        @click="editUser(data)"
      />
    </template>
  </Column>
</DataTable>
```

### Navigation
```vue
<nav aria-label="Main navigation">
  <ul>
    <li><router-link to="/">Home</router-link></li>
    <li><router-link to="/users">Users</router-link></li>
  </ul>
</nav>

<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/users">Users</a></li>
    <li aria-current="page">Edit User</li>
  </ol>
</nav>
```
</aria>

<visual>
## Visual Accessibility

### Color Contrast
```css
/* Ensure 4.5:1 contrast ratio for normal text */
.text-primary {
  color: #1a1a1a; /* Dark enough on white */
}

/* Don't rely on color alone */
.status-error {
  color: #d32f2f;
  border-left: 4px solid #d32f2f; /* Visual indicator too */
}

.status-success {
  color: #388e3c;
  border-left: 4px solid #388e3c;
}
```

### Focus Indicators
```css
/* Visible focus indicator */
button:focus-visible,
a:focus-visible,
input:focus-visible {
  outline: 3px solid var(--primary-color);
  outline-offset: 2px;
}

/* High contrast mode support */
@media (prefers-contrast: more) {
  button:focus-visible {
    outline-width: 4px;
  }
}

/* Reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Screen Reader Only Text
```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```
</visual>

<images>
## Images and Media

```vue
<!-- Informative image -->
<img
  :src="pharmacyLogo"
  :alt="t('pharmacy.logoAlt', { name: pharmacyName })"
/>

<!-- Decorative image -->
<img src="/decorative-pattern.svg" alt="" aria-hidden="true" />

<!-- Icon with text - hide icon from AT -->
<button>
  <i class="pi pi-save" aria-hidden="true"></i>
  {{ t('common.save') }}
</button>

<!-- Icon only - needs label -->
<button aria-label="Save">
  <i class="pi pi-save" aria-hidden="true"></i>
</button>
```
</images>

<primevue-a11y>
## PrimeVue Accessibility

PrimeVue components have built-in a11y. Always provide labels:

```vue
<InputText
  id="email"
  aria-label="Email address"
  aria-describedby="email-help"
/>

<Dropdown
  id="status"
  aria-label="Select status"
  :placeholder="t('common.select')"
/>

<DataTable aria-label="User list">
  <Column field="name" header="Name" />
</DataTable>

<Button
  icon="pi pi-trash"
  severity="danger"
  aria-label="Delete item"
/>
```
</primevue-a11y>

<anti-patterns>
## Anti-Patterns to Avoid
- Using div/span for interactive elements
- Missing alt text on images
- Color as only indicator
- Skipping heading levels
- Missing form labels
- No focus indicators
- Inaccessible modals (no focus trap)
- Missing ARIA labels on icon buttons
- Ignoring keyboard navigation
</anti-patterns>
