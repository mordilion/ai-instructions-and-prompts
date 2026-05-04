# Feature: Validate (`/ai-iap:validate`)

## Scope

Structural integrity of plugin package before/during development; **not** end-user app tests.

## Key source

- `plugin/skills/validate/SKILL.md` — full checklist (`[PASS]`/`[FAIL]`)

## Checks (summary)

1. `config.json` valid JSON + schema (`version`, `tool`, `languages`, no obsolete `enabled`, `globs` string)
2. Every rule/framework/structure/optional path referenced exists under `plugin/lib/rules/`
3. Every `.md` under `lib/rules` non-empty, first line `#`
4. Framework `requires` keys exist
5. No forbidden strings in rules/processes (`.ai-iap/`, `.cursor/rules/` paths)
6. Persona split files under `lib/rules/general/`
7. `claude-subagents.json` shape if present
8. Optional `.ai-iap-state.json` in cwd
9. `plugin/.claude-plugin/plugin.json` + repo `.claude-plugin/marketplace.json`
10. Custom folder merge rules if `plugin/custom/` populated

## Gotchas

- Paths in skill use `${CLAUDE_PLUGIN_ROOT}/lib/...` — runtime resolves to `plugin/lib/` in this repo layout
