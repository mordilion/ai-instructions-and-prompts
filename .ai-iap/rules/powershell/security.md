# PowerShell Security

> **Scope**: PowerShell-specific security  
> **Extends**: General security rules  
> **Applies to**: `*.ps1, *.psm1, *.psd1`

## CRITICAL REQUIREMENTS

> **ALWAYS**: Validate all parameters with attributes
> **ALWAYS**: Use -LiteralPath for file operations
> **ALWAYS**: Prefer HTTPS and verify integrity
> **ALWAYS**: Minimize admin actions
> **ALWAYS**: Support -WhatIf for destructive ops
> 
> **NEVER**: Use Invoke-Expression on untrusted input
> **NEVER**: Execute downloaded scripts without validation
> **NEVER**: Hardcode secrets
> **NEVER**: Log secrets
> **NEVER**: Disable TLS/SSL validation

## 1. Code Execution
- NEVER use `Invoke-Expression` on untrusted input
- NEVER execute downloaded scripts without validation
- Prefer calling cmdlets with parameters

## 2. Inputs & Injection Risks
- **ALWAYS**: Validate parameters using type constraints and validation attributes.
- **ALWAYS**: Use `-LiteralPath` when dealing with filesystem paths that may contain wildcard characters.
- **ALWAYS**: Treat env vars and file contents as untrusted input.

## 3. Secrets
- **NEVER**: Hardcode secrets in scripts, module files, or repo docs.
- **NEVER**: Log secrets (including via verbose output).
- **ALWAYS**: Prefer OS secret stores / SecretManagement / injected environment variables for secrets.

## 4. Network & Downloads
- **ALWAYS**: Prefer HTTPS; validate endpoints and pin versions where possible.
- **NEVER**: Disable TLS/SSL validation.
- **ALWAYS**: Verify integrity (checksums/signatures) for downloaded artifacts in automation contexts.

## 5. Privilege & System Changes
- **ALWAYS**: Minimize administrative actions; scope them to the smallest possible commands.
- **ALWAYS**: For destructive operations, require confirmation or support `-WhatIf` / `-Confirm`.

Follow the general security rules; the rules above are additive.

## AI Self-Check

- [ ] All parameters validated with attributes?
- [ ] Using -LiteralPath for file operations?
- [ ] HTTPS preferred and integrity verified?
- [ ] Admin actions minimized?
- [ ] -WhatIf supported for destructive ops?
- [ ] No Invoke-Expression on untrusted input?
- [ ] No downloaded scripts executed without validation?
- [ ] No hardcoded secrets?
- [ ] No secrets logged?
- [ ] No TLS/SSL validation disabled?
- [ ] SecretManagement for secrets?
- [ ] Checksums verified for downloads?

