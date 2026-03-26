# CSS Security

> **Scope**: CSS-specific security and safety  
> **Extends**: General security rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Allowlist user values (themes, class names)
> **ALWAYS**: Pin third-party CSS versions
> 
> **NEVER**: Insert untrusted strings in `<style>` or `style=""`
> **NEVER**: Build CSS dynamically with untrusted input
> **NEVER**: Use unpinned CDN includes

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **User Input** | `style="${userColor}"` | Toggle `.theme-dark`, `.theme-light` |
| **Dynamic CSS** | Build CSS string | CSS variables with validated values |
| **Third-Party** | Unpinned CDN | Local build, pinned version |

## AI Self-Check

- [ ] User values allowlisted?
- [ ] No untrusted strings in `<style>` or `style=""`?
- [ ] No dynamic CSS building?
- [ ] Third-party CSS pinned?
- [ ] Using toggle classes instead of inline styles?

