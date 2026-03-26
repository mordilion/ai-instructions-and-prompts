# PowerShell Architecture

> **Scope**: PowerShell architectural patterns (`*.ps1`, `*.psm1`, `*.psd1`)  
> **Applies to**: PowerShell scripts and modules  
> **Extends**: General architecture guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Output objects (not formatted strings)
> **ALWAYS**: Use [CmdletBinding()] for advanced functions
> **ALWAYS**: Validate parameters with attributes
> **ALWAYS**: try/catch with -ErrorAction Stop
> **ALWAYS**: Modules for reusable code
> 
> **NEVER**: Format strings in pipeline (output objects)
> **NEVER**: Skip parameter validation
> **NEVER**: Suppress errors without handling
> **NEVER**: Mix UI logic with business logic
> **NEVER**: Skip SupportsShouldProcess for destructive ops

## 1. Core Patterns
- **Object-first**: Output objects, not formatted strings
- **Composable**: Functions work well in pipelines
- **Explicit errors**: Treat failures as exceptions

## 2. Script vs Module
- **Scripts (`.ps1`)**: Use for entry points and automation tasks.
- **Modules (`.psm1` + `.psd1`)**: Put reusable functions in a module and import it in scripts.
- **Public surface**: Keep a small, intentional set of exported functions (the “API” of the module).

## 3. Layout
- **Scripts**: `param(...)` at the top, then functions/helpers, then the execution block.
- **Advanced functions**: Prefer `[CmdletBinding()]` and `param(...)` for reusable functions.
- **Folders** (suggested):
  - `scripts/` for entry scripts
  - `modules/<ModuleName>/` for reusable modules
  - `tests/` for Pester

## 4. Parameters & Contracts
- **Validation**: Use `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`, and type annotations for parameters.
- **Defaults**: Provide sensible defaults; document behavior for omitted parameters.
- **WhatIf/Confirm**: For destructive operations, support `SupportsShouldProcess`.

## 5. Error Handling & Logging
- **Errors**: Prefer `try/catch/finally` with `-ErrorAction Stop` for required operations.
- **Observability**: Use `Write-Verbose`, `Write-Warning`, `Write-Error` appropriately; keep `Write-Host` for UI-only scenarios.

## AI Self-Check

- [ ] Outputting objects (not formatted strings)?
- [ ] [CmdletBinding()] for advanced functions?
- [ ] Parameters validated with attributes?
- [ ] try/catch with -ErrorAction Stop?
- [ ] Modules for reusable code?
- [ ] Functions composable in pipelines?
- [ ] SupportsShouldProcess for destructive ops?
- [ ] No formatted strings in pipeline?
- [ ] No suppressed errors without handling?
- [ ] Write-Verbose/Warning/Error used correctly?
- [ ] Scripts in scripts/, modules in modules/?
- [ ] Small public surface (exported functions)?

