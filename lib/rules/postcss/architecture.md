# Postcss Architecture

> **Scope**: Postcss stylesheet patterns  
> **Extends**: General architecture + CSS rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Design tokens first (variables/custom properties)
> **ALWAYS**: One-way dependencies (low-level → high-level)
> **ALWAYS**: Minimal global selectors
> 
> **NEVER**: Global leakage
> **NEVER**: High-level depends on low-level

## Layering

tokens → mixins → utilities → components → pages

## AI Self-Check

- [ ] Design tokens centralized?
- [ ] One-way dependencies?
- [ ] Minimal global selectors?
- [ ] Proper layering (tokens → components)?
