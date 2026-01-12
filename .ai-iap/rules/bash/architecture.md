# Bash Architecture

> **Scope**: Apply these rules ONLY when working with shell scripts (`*.sh`, `*.bash`, etc.). These extend the general architecture guidelines.

## 1. Core Principles
- **Single responsibility**: One script = one job. Split reusable logic into libraries.
- **Predictability**: Prefer explicit inputs/outputs, clear exit codes, and deterministic behavior.
- **Portability**: Default to Bash; avoid relying on non-standard tools unless explicitly required.

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

