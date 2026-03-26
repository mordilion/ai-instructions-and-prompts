# Postcss Security

> **Scope**: Postcss security and safety  
> **Extends**: General security + CSS security

## CRITICAL REQUIREMENTS

> **ALWAYS**: Allowlist user-controlled style values
> **ALWAYS**: Pin dependency versions
> 
> **NEVER**: Compile from untrusted input
> **NEVER**: Unreviewed third-party libraries
> **NEVER**: User-controlled compilation

## AI Self-Check

- [ ] No compilation from untrusted input?
- [ ] User values allowlisted?
- [ ] Dependencies pinned?
- [ ] Third-party libraries reviewed?
