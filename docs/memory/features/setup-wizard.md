# Feature: Setup wizard (`/ai-iap:setup`)

## Scope

- Interactive selection of languages, documentation standards, frameworks, structures, processes
- Writes generated markdown under user project `.claude/rules/` (and processes subtree), optional `.claude/agents/`
- Emits or merges **`CLAUDE.md`** using `config.tool.outputFileSource` → `plugin/lib/rules/general/{source}.md`

## Key sources

- `plugin/skills/setup/SKILL.md` — authoritative steps (custom-first resolution, state file, merge strategy)
- `plugin/lib/config.json` — drives available options
- State: `.ai-iap-state.json` in project root (rerunnable setup)
- **This repository:** `scripts/generate-ai-iap-claude-rules.mjs` reproduces rule generation (no frameworks/processes) for `plugin` development

## Merge strategy (`CLAUDE.md`)

1. No file: write content wrapped in `AI-IAP:START` … `AI-IAP:END`
2. Existing with markers: replace only marked region
3. Existing user file without markers: append marked block at end

## Gotchas

- Only delete generated files with **`aiIapManaged: true`** on cleanup
- Process rules: `loadIntoAI` + resolution `custom/processes` then `lib/processes`
- Framework `requires[]` must reference keys that exist in same language
