# Dockerfile Code Style

> **Scope**: Dockerfile formatting and maintainability rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Uppercase instructions (FROM, RUN, COPY, ENV)
> **ALWAYS**: Clean caches in same layer
> **ALWAYS**: Explicit versions for packages
> 
> **NEVER**: Use `curl | sh` installs
> **NEVER**: Leave package caches across layers

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Instructions** | `from node:18` | `FROM node:18` |
| **Layer Cleanup** | Separate RUN | `RUN apt install && rm -rf /var/lib/apt` |
| **Versioning** | `RUN pip install flask` | `RUN pip install flask==2.3.0` |

## AI Self-Check

- [ ] Instructions uppercase?
- [ ] Caches cleaned in same layer?
- [ ] Package versions explicit?
- [ ] No `curl | sh` installs?
- [ ] Combined related commands?

