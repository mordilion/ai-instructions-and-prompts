# CSS Code Style

> **Scope**: CSS formatting  
> **Extends**: General code style guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: 2-space indentation
> **ALWAYS**: One selector per line
> **ALWAYS**: Property ordering (layout → box → typography → visuals)
> **ALWAYS**: CSS variables for repeated values
> 
> **NEVER**: Use !important
> **NEVER**: Deep descendant selectors
> **NEVER**: Hardcode colors/spacing
> **NEVER**: Style by tag (except base styles)
> **NEVER**: App-wide resets in component styles

## 1. Formatting
- 2 spaces indentation
- One selector per line
- Consistent property ordering

## 2. Best Practices
- **Prefer**: CSS variables for repeated values.
- **Prefer**: `rem` for font sizing and spacing; use `px` only when needed.
- **Avoid**: Deep descendant selectors (e.g., `.a .b .c .d`).
- **Avoid**: Styling by tag selectors except for base styles (e.g., `h1`, `p` in a reset layer).
- **NEVER**: Use `!important`.

## 3. Performance
- **Avoid**: Expensive selectors (overly generic descendant chains).
- **Prefer**: Classes and shallow selectors.

## 4. Component SFCs (Vue/Svelte)
- **Prefer**: Scoped styles where supported.
- **Never**: Put application-wide resets inside a component’s `<style>` block.


## AI Self-Check

- [ ] 2-space indentation?
- [ ] One selector per line?
- [ ] Property ordering consistent?
- [ ] CSS variables for repeated values?
- [ ] No !important?
- [ ] No deep descendant selectors?
- [ ] No hardcoded colors/spacing?
- [ ] rem for sizing?
- [ ] Scoped styles in components?
- [ ] No app resets in component styles?
