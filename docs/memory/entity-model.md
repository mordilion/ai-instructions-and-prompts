# Config & content model (not a business entity model)

This repository has **no application database**. “Entity model” here = **how configuration and content reference each other**.

## `plugin/lib/config.json` hierarchy

- **`version`**: string (semver) — keep in sync with release / `plugin/.claude-plugin/plugin.json` for clean releases
- **`tool`**: `name`, `outputDir` (e.g. `.claude/rules`), `outputFile` (e.g. `CLAUDE.md`), `outputFileSource` (e.g. `claude-project-rules` → `plugin/lib/rules/general/claude-project-rules.md`)
- **`languages.{key}`**:
  - `name`, `globs`, `alwaysApply`, `description`, `files[]` (rule stems without `.md` → `plugin/lib/rules/{key}/{file}.md`)
  - optional: `frameworks`, `documentation`, `optionalRules`, `structures` (per framework), `processes`
- **Framework entry**: `file`, `description`, optional `requires[]` (other framework keys in same language)
- **Process entry**: maps to `plugin/lib/processes/{permanent|ondemand}/{lang}/...` per setup resolution (custom-first)

## State in **user** projects (not in this repo by default)

- **`.ai-iap-state.json`**: last setup choices for reruns — schema expectations in validate skill

## File system counts (approximate; re-count after large adds)

- Rules: `plugin/lib/rules/**/*.md` (~191)
- Processes: `plugin/lib/processes/**/*.md` (~78)
- Code library: `plugin/lib/code-library/**/*.md` (~37)
