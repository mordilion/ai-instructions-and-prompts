# HTML Code Style

> **Scope**: HTML formatting  
> **Extends**: General code style guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: 2-space indentation
> **ALWAYS**: Quote attribute values (double quotes)
> **ALWAYS**: alt text for images
> **ALWAYS**: Labels for form inputs
> 
> **NEVER**: Inline event handlers (onclick, onload)
> **NEVER**: Inline scripts (use external files)
> **NEVER**: Forms without labels
> **NEVER**: Images without alt
> **NEVER**: Buttons for navigation (use <a>)

## 1. Formatting
- 2 spaces per level
- One attribute per line (many attributes)
- Double quotes for attributes

## 2. Inline JavaScript (when unavoidable)
- **NEVER**: Use inline event handlers (`onclick="..."`, `onload="..."`).
- **Prefer**: Add event listeners in JS and target elements via `data-*`.
- **Keep scripts small**: If inline JS exceeds ~10-15 lines, move it to an external file.

## 3. Script Tags
- **Modules**: Prefer `<script type="module" src="..."></script>` for modern code.
- **Defer**: Use `defer` on non-module scripts to avoid blocking rendering.
- **Placement**: Prefer loading scripts at end of body or with `defer`.

## 4. Accessibility
- **Images**: Always provide `alt` text (empty `alt=""` for decorative).
- **Buttons/Links**: Use `<button>` for actions, `<a>` for navigation.
- **Labels**: Every form input must have an associated `<label>`.

## AI Self-Check

- [ ] 2-space indentation?
- [ ] Attributes quoted (double quotes)?
- [ ] alt text for images?
- [ ] Labels for form inputs?
- [ ] No inline event handlers?
- [ ] No inline scripts?
- [ ] External JS/CSS used?
- [ ] Semantic markup (header, nav, main)?
- [ ] <button> for actions, <a> for navigation?
- [ ] data-* for JS hooks?

