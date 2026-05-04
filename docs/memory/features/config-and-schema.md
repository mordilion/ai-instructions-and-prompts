# Feature: Config & schema

## Files

- `plugin/lib/config.json` — full registry (version **must** align with release practice alongside `plugin/.claude-plugin/plugin.json`)
- `plugin/lib/config.schema.json` — validates plugin config shape
- `plugin/lib/config.extend.schema.json` — validates fork/custom `plugin/custom/config.extend.json`

## Concepts

- **`languages`**: arbitrary keys; each has `files[]` listing rule **stems** (no `.md`)
- **`general`**: `alwaysApply: true`; all others glob-driven
- **`documentation`**: nested bundles (`code`, `project`, `api`) under `general` only in current layout
- **`frameworks`**: per-language; may chain `requires`
- **`structures`**: live under `frameworks/structures/` in filesystem
- **`processes`**: per-language lists mapping to files under `plugin/lib/processes/`

## When editing

- Any new rule stem → add to `files[]` or framework list + create `.md` file
- Run validate skill; update `config.schema.json` if new top-level concepts introduced
