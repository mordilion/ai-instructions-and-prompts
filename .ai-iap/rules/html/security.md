# HTML Security

> **Scope**: HTML-specific security  
> **Extends**: General security rules
> **Applies to**: *.html, *.htm, *.vue, *.svelte

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Content Security Policy (CSP)
> **ALWAYS**: rel="noopener noreferrer" for target="_blank"
> **ALWAYS**: Escape untrusted data before rendering
> 
> **NEVER**: Inject untrusted strings without escaping
> **NEVER**: Build HTML via string concatenation
> **NEVER**: Use innerHTML with untrusted data
> **NEVER**: Inline scripts with secrets
> **NEVER**: unsafe-inline in CSP (use nonces)

## 1. XSS Prevention
- NEVER inject untrusted strings without escaping
- Prefer DOM APIs (`textContent`, `setAttribute`) over `innerHTML`

## 2. Inline Script Safety
- **Prefer**: No inline scripts at all.
- **If inline scripts exist**:
  - Keep them minimal
  - Do not embed secrets/tokens
  - Avoid dynamic code execution (`eval`, `new Function`)

## 3. CSP Guidance
- **ALWAYS**: Use a strict Content Security Policy (CSP) when possible.
- **Prefer**: external scripts + nonces/hashes over `unsafe-inline`.

## 4. Links & Targets
- **ALWAYS**: For `target="_blank"`, include `rel="noopener noreferrer"`.

Follow the general security rules; the rules above are additive.

## AI Self-Check

- [ ] CSP configured?
- [ ] rel="noopener noreferrer" for target="_blank"?
- [ ] Untrusted data escaped before rendering?
- [ ] No untrusted strings injected without escaping?
- [ ] No HTML built via string concatenation?
- [ ] No innerHTML with untrusted data?
- [ ] No inline scripts with secrets?
- [ ] Using DOM APIs (textContent, setAttribute)?
- [ ] No unsafe-inline in CSP?
- [ ] External scripts with nonces/hashes?

