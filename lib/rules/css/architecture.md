# CSS Architecture

> **Scope**: CSS architectural patterns  
> **Extends**: General architecture guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Design tokens first (CSS variables)
> **ALWAYS**: Low specificity (avoid !important)
> **ALWAYS**: Mobile-first media queries
> **ALWAYS**: Scoped styles (CSS Modules/scoped)
> 
> **NEVER**: Use !important
> **NEVER**: High specificity selectors
> **NEVER**: Global leakage
> **NEVER**: Hardcode colors/spacing
> **NEVER**: Style by JS hook classes

## 1. Layering
- Base: reset → tokens → utilities → components → pages
- Scoped styles preferred
- Component-first organization

## 2. Naming
- kebab-case for classes
- BEM for complex components
- data-* for JS selectors

## AI Self-Check

- [ ] CSS variables for design tokens?
- [ ] Low specificity?
- [ ] Mobile-first media queries?
- [ ] Scoped styles (CSS Modules/scoped)?
- [ ] No !important?
- [ ] No hardcoded colors/spacing?
- [ ] kebab-case for classes?
- [ ] No styling by JS hooks?
- [ ] Proper layering (reset → tokens → components)?
- [ ] No global leakage?

