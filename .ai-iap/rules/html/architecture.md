# HTML Architecture

> **Scope**: HTML architectural patterns  
> **Extends**: General architecture guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Semantic markup (landmarks, labels, headings)
> **ALWAYS**: Separate structure (HTML), presentation (CSS), behavior (JS)
> **ALWAYS**: data-* for JS hooks (not IDs/classes)
> **ALWAYS**: External JS/CSS (not inline)
> 
> **NEVER**: Inline styles (use CSS)
> **NEVER**: Inline scripts (use external files)
> **NEVER**: IDs for JS hooks (use data-*)
> **NEVER**: Non-semantic divs (use semantic elements)
> **NEVER**: Forms without labels

## 1. Separation
- HTML = structure
- CSS = presentation
- JavaScript = behavior

## 2. Progressive Enhancement
- Pages usable without JS
- Forms work with native validation

## AI Self-Check

- [ ] Semantic markup used (header, nav, main, footer)?
- [ ] Structure/presentation/behavior separated?
- [ ] data-* for JS hooks?
- [ ] External JS/CSS (not inline)?
- [ ] No inline styles?
- [ ] No inline scripts?
- [ ] No IDs for JS hooks?
- [ ] Forms paired with labels?
- [ ] Progressive enhancement?
- [ ] Accessibility-first?

