# Bash Code Style

> **Scope**: Shell script formatting (`*.sh`, `*.bash`, `*.zsh`, `*.ksh`, `*.bats`)  
> **Applies to**: Shell scripts  
> **Extends**: General code style guidelines

## CRITICAL REQUIREMENTS

> **ALWAYS**: Use strict mode (set -euo pipefail, IFS=$'\n\t')
> **ALWAYS**: Quote all variables ("$var", "${arr[@]}")
> **ALWAYS**: Use [[ ... ]] for conditionals (not [ ... ])
> **ALWAYS**: Use $(cmd) for command substitution (not backticks)
> **ALWAYS**: Use local for function variables
> 
> **NEVER**: Use unquoted variables
> **NEVER**: Use backticks (use $(cmd))
> **NEVER**: Use eval unless justified
> **NEVER**: Parse ls output
> **NEVER**: Use echo -e (use printf)

## 1. Strict Mode
- Use strict mode near the top:
  - `set -euo pipefail`
  - `IFS=$'\n\t'`
- Use `trap` for cleanup

## 2. Quoting & Expansions
- **ALWAYS**: Quote variables unless you explicitly want word-splitting/globbing: `"$var"`, `"${arr[@]}"`.
- **ALWAYS**: Use `"$@"` to forward args; NEVER use `$*` for forwarding.
- **NEVER**: Use unquoted command substitutions in arguments; wrap: `"$(cmd)"`.

## 3. Conditionals & Tests
- **Bash**: Prefer `[[ ... ]]` over `[ ... ]`.
- **Strings**: Use `[[ -n "$s" ]]` / `[[ -z "$s" ]]`.
- **Numbers**: Use `-eq/-ne/-lt/...` with `[[ ... ]]` or `(( ... ))`.

## 4. Functions & Variables
- **Functions**: Use `snake_case` names; keep functions small (<50 lines).
- **Locals**: Use `local` for function variables. Prefer `readonly` for constants.
- **Globals**: Minimize global state; if needed, define at top and document.

## 5. Output & Logging
- **ALWAYS**: Use `printf` for user-facing output; avoid `echo -e` portability pitfalls.
- **stderr**: Errors and warnings go to stderr: `printf '%s\n' "message" >&2`.

## 6. Common Pitfalls (MUST avoid)
- **NEVER**: Use backticks (`` `cmd` ``); use `$(cmd)`.
- **NEVER**: Use `eval` (unless you fully control the input and can justify it).
- **NEVER**: Parse `ls` output.
- **NEVER**: Rely on `cd` side effects; use subshells `( ... )` when needed.

## 7. Tooling
- **ALWAYS**: Run `shellcheck` on changed scripts; address warnings unless you can justify a suppression.
- **ALWAYS**: Format with `shfmt` (2-space indent, keep it consistent).

## AI Self-Check

- [ ] Strict mode enabled (set -euo pipefail)?
- [ ] All variables quoted ("$var")?
- [ ] Using [[ ... ]] for conditionals?
- [ ] Using $(cmd) (not backticks)?
- [ ] local for function variables?
- [ ] snake_case for function names?
- [ ] Functions <50 lines?
- [ ] printf (not echo -e)?
- [ ] Errors to stderr (>&2)?
- [ ] No unquoted command substitutions?
- [ ] shellcheck passing?
- [ ] shfmt for formatting?

