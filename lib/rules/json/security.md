# JSON Security

> **Scope**: JSON security guidance  
> **Extends**: General security rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Reference secret stores or environment variables
> **ALWAYS**: Validate executable hooks/scripts
> 
> **NEVER**: Store secrets/tokens in JSON committed to git
> **NEVER**: Unchecked command execution from JSON configs

## AI Self-Check

- [ ] No secrets in committed JSON?
- [ ] Using secret stores/env vars?
- [ ] Executable hooks validated?
- [ ] Least privilege for tooling?
