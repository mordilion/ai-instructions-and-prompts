# Architecture decisions (ADRs)

Fact-only; extend when behavior changes. Full template: `plugin/lib/rules/general/claude-project-rules.md` (output `CLAUDE.md` in consumer projects).

| ID | Decision | Rationale / where enforced |
|----|----------|------------------------------|
| ADR-001 | **Modular rules** by language under `plugin/lib/rules/{lang}/` | User selects subsets; glob-based loading in target projects |
| ADR-002 | **`plugin/lib/config.json` is the registry** of languages, `files[]`, frameworks, structures, documentation bundles, processes | Single source; `plugin/lib/config.schema.json` validates shape |
| ADR-003 | **Only `general` has `alwaysApply: true`** | Avoid rule overload; other langs match globs |
| ADR-004 | **Custom extension layer** `plugin/custom/` never touched by upstream merges | `plugin/custom/README.md`; merge via `config.extend.json`, path mirroring, `override` frontmatter |
| ADR-005 | **Setup output is safe to regenerate** | Generated `.claude/rules/**` and agents use `aiIapManaged: true` in frontmatter; cleanup deletes only those |
| ADR-006 | **CLAUDE.md merge** in user projects: `AI-IAP:START` / `AI-IAP:END` | `plugin/skills/setup/SKILL.md` step 7h |
| ADR-007 | **Code patterns are library + INDEX** | `plugin/lib/code-library/`; AIs must check `functions/INDEX.md` before inventing patterns |
| ADR-008 | **Processes** split `permanent` vs `ondemand` under `plugin/lib/processes/` | Setup copies ondemand when selected; see config `processes` + `loadIntoAI` |
| ADR-009 | **Validate skill** is structural gate | `plugin/skills/validate/SKILL.md` — config vs schema, file existence, no forbidden path strings in rules |
| ADR-010 | **Plugin identity** in `plugin/.claude-plugin/plugin.json` | Version should stay aligned with `plugin/lib/config.json` `version` and `.claude-plugin/marketplace.json` when releasing |
| ADR-011 | **SessionStart hook** nudges setup | `plugin/hooks/hooks.json` — prompt if no managed rules in project |
| ADR-012 | **No user-project paths inside rule text** | Validate check 5 — no `.ai-iap/...` or `.cursor/...` in published rules |
