# Frontend patterns (this repository)

**No product UI** (no React/Vue app in this repo).

## When “frontend” work here means

- **Authoring** rule markdown: component examples inside `plugin/lib/rules/**` (table-first, `> **ALWAYS**` / `> **NEVER**`, short code fences)
- **Optional** test UIs: only if added under e.g. `.github/scripts` for compatibility tests — not a maintained app shell

## Conventions for UI-related **rule files** (e.g. `*/frameworks/react*.md`)

- Match existing file section order in sibling rules
- Snippets 5–15 lines; no install commands in `code-library` pattern bodies
- Cross-link to `accessibility` / `i18n` general rules when UI text or a11y is in scope
