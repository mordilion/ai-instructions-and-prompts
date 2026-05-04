# Feature: Custom extensions (`plugin/custom/`)

## Purpose

Fork-safe layer: upstream never writes here; reduces merge conflicts when pulling.

## Entry points

- `plugin/custom/config.extend.json` — partial config overlay (languages, frameworks, processes)
- `plugin/custom/rules/` — mirror of `lib/rules/` layout; optional YAML frontmatter `override: append|prepend|replace`
- `plugin/custom/processes/{permanent|ondemand}/{lang}/` — same resolution order as base (custom-first)
- `plugin/custom/code-library/` — extra patterns
- `plugin/custom/claude-subagents.extend.json` — extra agent templates

## Resolution

- Setup skill resolves **custom path first**, then `plugin/lib/` (documented in `plugin/custom/README.md` and validate skill §10)

## Gotchas

- `replace` mode must keep frontmatter valid YAML
- Extended config must still validate against extend schema when present
