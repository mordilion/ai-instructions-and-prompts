# Module status (plugin source)

Snapshot for navigation; update when layout changes.

| Module | Path | Role |
|--------|------|------|
| Plugin manifest | `plugin/.claude-plugin/plugin.json` | name `ai-iap`, version |
| Marketplace | `.claude-plugin/marketplace.json` | lists plugin for marketplace consumers |
| Setup skill | `plugin/skills/setup/SKILL.md` | `/ai-iap:setup`, rule/agent generation, CLAUDE.md merge |
| Validate skill | `plugin/skills/validate/SKILL.md` | `/ai-iap:validate`, integrity checks |
| Config | `plugin/lib/config.json`, `plugin/lib/config.schema.json`, `plugin/lib/config.extend.schema.json` | registry + validation |
| Rules library | `plugin/lib/rules/` (~191 `.md`) | per-language + frameworks + structures |
| Processes | `plugin/lib/processes/` (~78 `.md`) | permanent / ondemand by language |
| Code library | `plugin/lib/code-library/` | `functions/`, `design-patterns/`, INDEX files |
| Agents | `plugin/agents/*.md`, `plugin/lib/claude-subagents.json` | built-in agents + templates |
| Hooks | `plugin/hooks/hooks.json` | SessionStart setup hint |
| Custom | `plugin/custom/` | fork-safe extensions |
| CI | `.github/workflows/` | validate + optional Claude tests |
| **Claude Code rules (this repo)** | `.claude/rules/**` | Same format as `/ai-iap:setup` — regenerate with `node scripts/generate-ai-iap-claude-rules.mjs` |
| **Setup state** | `.ai-iap-state.json` | Language/doc selection for the generator / reference for full setup |
| Root docs | `README.md`, `plugin/lib/README.md`, `CONTRIBUTING.md`, `TROUBLESHOOTING.md`, `TEAM_ADOPTION_GUIDE.md` | human onboarding |

## Fragile / high-touch areas

- **`config.json`** — many downstream references; always run validate + check dependent skills/docs
- **Setup skill** — merge logic and paths; test after behavioral edits
- **Forbidden path strings** in rules — CI validates none slip into user-facing rules
