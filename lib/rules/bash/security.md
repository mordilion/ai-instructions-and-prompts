# Bash Security

> **Scope**: Bash/shell-specific security  
> **Extends**: General security rules  
> **Applies to**: `*.sh, *.bash, *.zsh, *.ksh, *.bats`

## CRITICAL REQUIREMENTS

> **ALWAYS**: Treat all inputs as untrusted
> **ALWAYS**: Quote all variables ("$var")
> **ALWAYS**: Validate paths and flags early
> **ALWAYS**: Use mktemp for temp files
> **ALWAYS**: Verify checksums for downloads
> 
> **NEVER**: Use eval on untrusted input
> **NEVER**: source untrusted files
> **NEVER**: curl | bash pattern
> **NEVER**: Print secrets to logs
> **NEVER**: Enable set -x with secrets

## 1. Input Handling
- Treat all inputs as untrusted (args, env vars, files, command output)
- Validate paths, flags, and required values early
- Quote expansions to prevent injection

## 2. Command Execution
- **NEVER**: Use `eval` on untrusted input.
- **NEVER**: `source`/`.` untrusted files.
- **ALWAYS**: Prefer arrays for command + args when constructing invocations.
- **ALWAYS**: Use full paths or verify commands via `command -v` when running in controlled environments (CI, provisioning).

## 3. Filesystem Safety
- **ALWAYS**: Use `mktemp` for temp files/dirs; clean up with `trap`.
- **ALWAYS**: Set safe permissions when writing secrets or artifacts (`umask 077` when appropriate).
- **ALWAYS**: Use `--` to end option parsing for commands that support it (avoid “filename starts with dash” issues).

## 4. Secrets
- **NEVER**: Print secrets to stdout/stderr or logs.
- **NEVER**: Enable `set -x` in scripts handling secrets (or ensure it is disabled around secret operations).
- **ALWAYS**: Prefer env vars, secret stores, or injected files with restricted permissions.

## 5. Downloads & Supply Chain
- **NEVER**: `curl | bash`.
- **ALWAYS**: Pin versions and verify integrity (checksums/signatures) for downloaded artifacts.
- **ALWAYS**: Prefer HTTPS; fail on HTTP and handle redirects intentionally.

## 6. Privilege & Environment
- **ALWAYS**: Minimize `sudo` usage; scope it to the smallest possible commands.
- **ALWAYS**: Sanitize/avoid trusting `PATH` in privileged scripts; consider setting a safe `PATH`.

## Example: Safe Script Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Validate input
if [[ $# -ne 1 ]]; then
    printf 'Usage: %s <username>\n' "$0" >&2
    exit 2
fi

readonly USERNAME="$1"

# Validate username (allowlist pattern)
if [[ ! "$USERNAME" =~ ^[a-z0-9_-]+$ ]]; then
    printf 'Error: Invalid username\n' >&2
    exit 1
fi

# Safe temp file
readonly TEMP_FILE="$(mktemp)"
trap 'rm -f "$TEMP_FILE"' EXIT

# Use quoted variables
printf 'Processing user: %s\n' "$USERNAME"
```

## AI Self-Check

- [ ] All inputs treated as untrusted?
- [ ] All variables quoted ("$var")?
- [ ] Paths and flags validated early?
- [ ] mktemp for temp files with trap cleanup?
- [ ] Checksums verified for downloads?
- [ ] No eval on untrusted input?
- [ ] No source of untrusted files?
- [ ] No curl | bash?
- [ ] No secrets printed to logs?
- [ ] No set -x with secrets?
- [ ] Minimal sudo usage?
- [ ] Safe PATH in privileged scripts?

