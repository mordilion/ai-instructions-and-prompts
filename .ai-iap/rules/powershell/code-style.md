# PowerShell Code Style

> **Scope**: PowerShell formatting (`*.ps1`, `*.psm1`, `*.psd1`)  
> **Applies to**: PowerShell scripts and modules  
> **Extends**: General code style guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use Verb-Noun naming with approved verbs
> **ALWAYS**: [CmdletBinding()] for advanced functions
> **ALWAYS**: PascalCase for parameters
> **ALWAYS**: Full cmdlet names (no aliases)
> **ALWAYS**: PSScriptAnalyzer for linting
> 
> **NEVER**: Use aliases in scripts/modules
> **NEVER**: Format strings in pipeline
> **NEVER**: Skip parameter validation
> **NEVER**: Swallow errors silently
> **NEVER**: Use Write-Host for pipeline data

## 1. Core Patterns
- **Prefer objects** over strings
- **No aliases** in scripts/modules
- **Consistency**: 4-space indentation

## 2. Naming
- **Functions**: Use `Verb-Noun` with approved verbs (e.g., `Get-`, `Set-`, `New-`, `Remove-`).
- **Parameters**: `PascalCase` names (e.g., `-ProjectRoot`).
- **Files**: Match exported function names where reasonable.

## 3. Advanced Functions
- **ALWAYS**: Use `[CmdletBinding()]` for reusable functions.
- **ALWAYS**: Put `param(...)` immediately after `[CmdletBinding()]`.
- **WHEN**: The function mutates state, use `SupportsShouldProcess` and call `$PSCmdlet.ShouldProcess(...)`.

## 4. Errors
- **ALWAYS**: Use `-ErrorAction Stop` (or `$ErrorActionPreference = 'Stop'`) around required operations.
- **ALWAYS**: Use `try/catch/finally` for operations with cleanup or recovery.
- **NEVER**: Swallow errors silently; rethrow or emit a terminating error when the caller must know.

## 5. Output & Logging
- **Output**: `return`/`Write-Output` objects for pipeline consumers.
- **Logging**: Use `Write-Verbose` for diagnostics; `Write-Warning` for non-fatal issues.
- **Avoid**: `Write-Host` for anything intended to be consumed by other tools.

## 6. Paths & External Processes
- **Paths**: Prefer `Join-Path` and `Resolve-Path`; avoid manual string concatenation for paths.
- **External commands**: Prefer `Start-Process -ArgumentList ... -Wait -PassThru` for controlled execution; avoid building command strings.

## 7. Tooling
- **ALWAYS**: Run `PSScriptAnalyzer` on changed files; address warnings unless you can justify a suppression.

## AI Self-Check

- [ ] Verb-Noun naming with approved verbs?
- [ ] [CmdletBinding()] for advanced functions?
- [ ] PascalCase for parameters?
- [ ] Full cmdlet names (no aliases)?
- [ ] PSScriptAnalyzer passing?
- [ ] Objects output (not formatted strings)?
- [ ] Pester tests for modules?
- [ ] No aliases in scripts?
- [ ] No formatted strings in pipeline?
- [ ] No swallowed errors?
- [ ] Write-Verbose/Warning for logging?
- [ ] Join-Path for path operations?
- **ALWAYS**: Use Pester for tests of reusable modules/functions.

