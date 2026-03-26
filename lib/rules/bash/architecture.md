# Bash Architecture

> **Scope**: Shell script architectural patterns (`*.sh`, `*.bash`, `*.zsh`, `*.ksh`, `*.bats`)  
> **Applies to**: Shell scripts  
> **Extends**: General architecture guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use strict mode (set -euo pipefail)
> **ALWAYS**: main() function pattern
> **ALWAYS**: Quote all variables ("$var")
> **ALWAYS**: Use getopts for CLI flags
> **ALWAYS**: Exit codes (0=success, 1=error, 2=usage)
> 
> **NEVER**: Use unquoted variables
> **NEVER**: Use eval unless justified
> **NEVER**: Parse ls output
> **NEVER**: Use backticks (use $(cmd))
> **NEVER**: Global mutable state without documentation

## 1. Core Patterns
- **Single responsibility**: One script = one job
- **Predictability**: Explicit inputs/outputs, clear exit codes
- **Portability**: Default to Bash

## 2. Script Layout
- **Entry point**: Prefer a `main()` function and call it at the bottom.
- **Sections order**:
  1. Shebang + metadata/comments
  2. Strict mode + globals (constants)
  3. Helper functions
  4. `main()` (or command dispatcher)
  5. `main "$@"`
- **Libraries**: Put reusable functions in `scripts/lib/*.sh` (or `lib/`) and source them explicitly.

## 3. Configuration & Inputs
- **Config**: Prefer env vars and flags; allow config files only when necessary.
- **CLI**: Use `getopts` for flags; document usage in `usage()` and return exit code `2` for CLI misuse.
- **I/O**: Prefer explicit files/paths; avoid implicit cwd assumptions.

## 4. Exit Codes & Error Boundaries
- **Exit codes**: Use `0` success, `1` generic failure, `2` usage/validation errors.
- **Error boundaries**: Fail fast; validate prerequisites early (required commands, files, permissions).
- **Logging**: Standardize `log_info`, `log_warn`, `log_error` and write errors to stderr.

## 5. Composition
- **Pipelines**: Avoid deep pipelines; break into named functions for readability.
- **Idempotency**: For provisioning/deploy scripts, prefer idempotent steps (safe to re-run).

## Example: Script Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/deploy.log"

# Helper functions
log_info() {
    printf '%s [INFO] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$1" | tee -a "$LOG_FILE"
}

log_error() {
    printf '%s [ERROR] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$1" >&2 | tee -a "$LOG_FILE"
}

# Main logic
main() {
    log_info "Starting deployment..."
    # Main logic here
}

main "$@"
```

## AI Self-Check

- [ ] Strict mode enabled (set -euo pipefail)?
- [ ] main() function pattern used?
- [ ] All variables quoted ("$var")?
- [ ] getopts for CLI flags?
- [ ] Exit codes correct (0/1/2)?
- [ ] Functions <50 lines?
- [ ] No unquoted variables?
- [ ] No eval unless justified?
- [ ] No parsing ls output?
- [ ] No backticks (using $(cmd))?
- [ ] Errors to stderr?
- [ ] Idempotent (safe to re-run)?

