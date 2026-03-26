# JSON Architecture

> **Scope**: JSON configuration patterns (configs, manifests, app settings)  
> **Extends**: General architecture rules

## CRITICAL REQUIREMENTS

> **ALWAYS**: Stable structure (no "sometimes string, sometimes array")
> **ALWAYS**: Separate files for separate concerns
> **ALWAYS**: Validate with JSON Schema where applicable
> 
> **NEVER**: Inconsistent field types
> **NEVER**: Mix unrelated configs in one file

## Best Practices

| Pattern | ❌ Wrong | ✅ Correct |
|---------|---------|-----------|
| **Type Stability** | `"tags": "foo"` or `"tags": ["foo"]` | Always `"tags": ["foo"]` |
| **Separation** | One `config.json` for all | `build.json`, `runtime.json` |
| **Validation** | No schema | JSON Schema validation |

## AI Self-Check

- [ ] Field types stable?
- [ ] Concerns separated?
- [ ] JSON Schema used?
- [ ] Environment overrides documented?
