---
globs: ["**/*.vue", "**/*.css", "**/*.scss"]
alwaysApply: false
---

# CSS & Tailwind v4 Rules

<critical>
## Before Changing Any Position/Spacing Value
1. **Calculate pixel equivalents** of the CURRENT value at each breakpoint
2. **Calculate pixel equivalents** of the PROPOSED value at each breakpoint
3. **Compare old vs new** — verify the direction matches what the user asked:
   - "too close to top" → `top` must INCREASE
   - "too far down" → `top` must DECREASE
   - "too much space" → gap/margin/padding must DECREASE
   - "not enough space" → gap/margin/padding must INCREASE
4. **Present the comparison to user BEFORE editing:**
   ```
   iPhone (667px):  currently 167px → proposing 250px (further down ✓)
   iPad (1024px):   currently 256px → proposing 250px (similar ✓)
   Laptop (900px):  currently 225px → proposing 200px (slightly higher)
   ```
5. **Max 2 failed visual positioning attempts** → STOP coding, ask user for specific pixel values or a screenshot

**Never replace a viewport-relative approach (vh, vw, clamp) with fixed values without understanding WHY the original used viewport-relative units.**
</critical>

<tailwind>
## Tailwind v4 (CSS-based Config)

### Project Setup
- **Version:** Tailwind CSS v4.2+ with `@tailwindcss/vite` plugin
- **Config:** CSS-based in `main.css` via `@theme {}` (NO `tailwind.config.js`)
- **Plugin:** `tailwindcss-primeui` for PrimeVue integration
- **Dark mode:** `@custom-variant dark (&:is(.dark *))` — uses `.dark` class on `<html>`
- **Layers:** `@layer theme, base, primevue, components, utilities`

### Custom Breakpoints
```css
@theme {
  --breakpoint-tablet: 641px;   /* tablet: prefix */
  --breakpoint-desktop: 1092px; /* desktop: prefix */
}
```

| Breakpoint | Prefix | Min-width | Max-width variant |
|------------|--------|-----------|-------------------|
| Default sm | `sm:` | ≥640px | `max-sm:` |
| Tablet | `tablet:` | ≥641px | `max-tablet:` |
| Default md | `md:` | ≥768px | `max-md:` |
| Default lg | `lg:` | ≥1024px | `max-lg:` |
| Desktop | `desktop:` | ≥1092px | `max-desktop:` |
| Default xl | `xl:` | ≥1280px | `max-xl:` |

### Mobile-First Approach (MANDATORY)
Tailwind is mobile-first: unprefixed = all screens, prefixed = that breakpoint and UP.

```vue
<!-- GOOD: Mobile-first — base is mobile, override for larger -->
<div class="flex flex-col tablet:flex-row">
<div class="text-sm desktop:text-base">
<div class="p-4 tablet:p-6 desktop:p-8">

<!-- BAD: Using sm: thinking it targets mobile -->
<div class="sm:text-center">  <!-- This is ≥640px, NOT mobile! -->

<!-- BAD: max-width when mobile-first works better -->
<div class="max-tablet:flex-col">  <!-- Use unprefixed + tablet: override instead -->
```

### Prefer Tailwind Classes Over Custom CSS
```vue
<!-- GOOD: Tailwind utilities -->
<div class="fixed right-0 top-48 z-10">
<div class="mt-16 flex w-full items-center gap-4">
<div class="hidden tablet:block">
<div class="bg-surface-0 dark:bg-surface-900 rounded-lg p-4">

<!-- BAD: Custom CSS for things Tailwind handles -->
<style scoped>
.my-div { margin-top: 4rem; display: flex; width: 100%; }
</style>
```

### When Custom CSS Is Needed
Use custom CSS only when Tailwind can't express it:
- Complex selectors (`:is()`, `::before`, `:hover .child`)
- CSS `clamp()`, `color-mix()`, complex `calc()`
- Animations and keyframes
- PrimeVue deep component overrides via `pt` or scoped styles
- Scoped styles that must not leak
</tailwind>

<dark-mode>
## Dark Mode

### In Templates (preferred)
```vue
<!-- Always provide BOTH light and dark variants -->
<div class="bg-white dark:bg-surface-900 text-gray-700 dark:text-gray-300">
<span class="text-gray-500 dark:text-gray-400">
```

### In Scoped CSS
```css
/* Use :is(.dark) selector */
.card { background: white; }
:is(.dark) .card { background: var(--p-surface-900); }

/* For color-mix with theme variables */
.bar { background-color: color-mix(in srgb, var(--sev-danger) 12%, white); }
:is(.dark) .bar { background-color: color-mix(in srgb, var(--sev-danger-dark) 15%, black); }
```

### Rules
- Always pair light and dark color utilities
- Use PrimeVue surface tokens (`surface-0` to `surface-900`) for theme consistency
- Use `white`/`black` as mix base in `color-mix()`, NOT `transparent`
</dark-mode>

<state-variants>
## State Variants

### Interactive States
```vue
<button class="bg-sky-500 hover:bg-sky-700 focus-visible:outline-2 active:bg-sky-800">
<input class="border-gray-300 focus:border-sky-500 invalid:border-red-500 disabled:bg-gray-50">
```

### Group & Peer Patterns
```vue
<!-- Parent hover affects children -->
<a class="group rounded-lg p-4">
  <h3 class="group-hover:text-primary">Title</h3>
  <p class="group-hover:text-gray-600">Description</p>
</a>

<!-- Sibling state affects next element (peer MUST come first in DOM) -->
<input type="email" class="peer" />
<p class="invisible peer-invalid:visible text-red-500">Invalid email</p>
```

### Structural
```vue
<li v-for="item in items" :key="item.id"
    class="py-4 first:pt-0 last:pb-0 odd:bg-white even:bg-gray-50">
```

### ARIA & Data Attributes
```vue
<div data-active class="border-gray-300 data-active:border-primary">
<button :aria-expanded="open" class="aria-expanded:bg-gray-100">
```
</state-variants>

<class-detection>
## Class Detection — Never Construct Dynamically

Tailwind scans source files as plain text. Dynamically constructed class names won't be detected.

```vue
<!-- BAD: Dynamic construction — Tailwind won't generate these -->
<div :class="`bg-${color}-500`">
<div :class="`text-${size}`">

<!-- GOOD: Complete class names in a map -->
<script setup>
const colorMap = {
  red: 'bg-red-500 text-white',
  blue: 'bg-blue-500 text-white',
  green: 'bg-green-500 text-white',
}
</script>
<div :class="colorMap[color]">

<!-- GOOD: Conditional with complete names -->
<div :class="error ? 'text-red-600' : 'text-green-600'">
```
</class-detection>

<arbitrary-values>
## Arbitrary Values & CSS Variables

```vue
<!-- One-off values with [] -->
<div class="top-[15.625rem] max-w-[35rem] min-h-[200px]">

<!-- CSS functions -->
<div class="max-h-[calc(100dvh-4rem)]">

<!-- Responsive arbitrary values -->
<div class="top-[14rem] desktop:top-[12rem]">

<!-- CSS variables as values -->
<div class="bg-[var(--sev-danger)]">

<!-- Setting CSS variables via arbitrary properties -->
<div class="[--gutter:1rem] lg:[--gutter:2rem]">
```
</arbitrary-values>

<responsive>
## Responsive Design Patterns

### Mobile-First Layout
```vue
<!-- Stack on mobile, row on tablet+ -->
<div class="flex flex-col gap-3 tablet:flex-row tablet:items-center tablet:justify-between">

<!-- Hide on mobile, show on desktop -->
<div class="hidden desktop:block">

<!-- Full width mobile, constrained on desktop -->
<div class="w-full desktop:max-w-2xl desktop:mx-auto">
```

### Targeting Breakpoint Ranges
```vue
<!-- Only between tablet and desktop -->
<div class="tablet:max-desktop:px-8">

<!-- Only below tablet -->
<div class="max-tablet:flex-col">
```

### Container Queries (prefer over media queries for components)
```vue
<!-- Parent becomes a query container -->
<div class="@container">
  <!-- Child responds to parent width, not viewport -->
  <div class="flex flex-col @md:flex-row">
</div>
```

### Viewport-Relative vs Layout-Anchored Positioning
| Approach | When to Use | Example |
|----------|-------------|---------|
| **Viewport-relative** (`vh`, `vw`, `clamp`) | Element should stay in a visual "zone" of the screen regardless of layout | Floating buttons, FABs, sidebar toggles |
| **Layout-anchored** (`calc`, fixed rem) | Element must stay relative to another element | Dropdowns below headers, content below nav |

```css
/* Viewport-relative: button stays ~25% down the screen */
.floating-btn { top: clamp(150px, 25vh, 350px); }

/* Layout-anchored: element sits below the navbar */
.below-nav { top: calc(4rem + 1rem); } /* navbar height + gap */
```

**Never replace one approach with the other without understanding the intent.**

### Breakpoint Consistency
When the same gap/spacing should be consistent across breakpoints, use the same offset from a breakpoint-aware anchor:

```css
/* GOOD: Same offset from topbar on all screens */
.element { top: calc(4rem + 8rem); }        /* desktop: topbar=4rem */
@media (max-width: 1091px) {
  .element { top: calc(7.125rem + 8rem); }  /* mobile: topbar=7.125rem */
}

/* BAD: Hardcoded values that drift between breakpoints */
.element { top: 8rem; }
@media (max-width: 1091px) {
  .element { top: 11.5rem; }  /* why 11.5? is the gap the same? */
}
```
</responsive>

<positioning>
## Position & Spacing

### Validation Checklist
Before applying any position change:
- [ ] Calculated current pixel values at each breakpoint
- [ ] Calculated proposed pixel values at each breakpoint
- [ ] Verified direction matches user request
- [ ] Compared old vs new in a table
- [ ] Presented comparison to user

### Common Pitfalls
```css
/* PITFALL: clamp() with viewport units — know the actual values */
top: clamp(150px, 25vh, 350px);
/* On 667px screen: 25vh = 167px → clamped to 167px */
/* On 1024px screen: 25vh = 256px → clamped to 256px */
/* On 1440px screen: 25vh = 360px → clamped to 350px */

/* PITFALL: calc() can produce smaller values than expected */
top: calc(4rem + 3rem + 1rem); /* = 8rem = 128px — might be LESS than original! */

/* PITFALL: position:fixed without explicit top relies on flow position — fragile */
.bar { position: fixed; /* no top value — depends on parent margin */ }
/* FIX: Always set explicit top on fixed elements */
.bar { position: fixed; top: 4rem; }
```

### Fixed Layout Heights (bss-ui-pharmacy-cockpit)
| Element | Desktop (≥1092px) | Mobile/Tablet (<1092px) |
|---------|-------------------|------------------------|
| `.layout-topbar` | 4rem (64px) | 7.125rem (114px) |
| `.layout-topbar-menu` | ~3.5-4rem | ~3.5-4rem |
| Content padding-top | standard | 7.125rem |

### rem to px Reference
| rem | px |
|-----|-----|
| 1rem | 16px |
| 4rem | 64px |
| 7.125rem | 114px |
| 8rem | 128px |
| 10rem | 160px |
| 12rem | 192px |
| 15rem | 240px |
| 20rem | 320px |
</positioning>

<style-conflicts>
## Managing Style Conflicts

### Never Add Conflicting Tailwind Classes
```vue
<!-- BAD: Last one wins unpredictably -->
<div class="grid flex">

<!-- GOOD: Conditional -->
<div :class="useGrid ? 'grid' : 'flex'">
```

### Important Modifier (last resort)
```vue
<!-- Use ! suffix to force priority -->
<div class="bg-red-500!">

<!-- In PrimeVue pt overrides, prefix with ! -->
:pt="{ root: { class: '!bg-transparent' } }"
```

### Specificity with Scoped CSS
```vue
<!-- When Tailwind classes are overridden by PrimeVue, use scoped CSS -->
<style scoped>
:deep(.p-menubar) {
  background: transparent;
}
</style>
```
</style-conflicts>

<duplication>
## Managing Duplication

### Prefer Components Over @apply
```vue
<!-- GOOD: Reusable Vue component -->
<BaseCard>
  <template #header>Title</template>
  Content
</BaseCard>

<!-- ACCEPTABLE: @apply in @layer components for simple, single-element patterns -->
@layer components {
  .btn-primary {
    @apply rounded-full bg-violet-500 px-5 py-2 font-semibold text-white;
  }
}

<!-- BAD: @apply everywhere — defeats the purpose of utility-first -->
```

### Use v-for for Repeated Elements
```vue
<!-- Write class list once, render many -->
<div v-for="item in items" :key="item.id"
     class="rounded-lg border p-4 shadow-sm">
```
</duplication>

<anti-patterns>
## Anti-Patterns
- Changing position values without calculating pixel equivalents
- Replacing viewport-relative units with fixed values without understanding why
- Using `position: fixed` without explicit `top`/`left`
- Writing custom CSS for layout that Tailwind handles (`flex`, `gap`, `p-*`, `m-*`)
- Dynamic class name construction (`` `bg-${color}-500` ``) — Tailwind can't detect these
- Using `sm:` to target mobile (it targets ≥640px, NOT mobile)
- Global unscoped styles that override PrimeVue internals
- Using `!important` in raw CSS (use Tailwind `!` suffix or higher specificity)
- Mixing `max-width` media queries with Tailwind's mobile-first `min-width` inconsistently
- Using `transparent` as mix base in `color-mix()` — use `white` (light) / `black` (dark)
- `@apply` overuse — extract Vue components instead
- Missing dark mode pair — always provide both `bg-white dark:bg-surface-900`
</anti-patterns>
