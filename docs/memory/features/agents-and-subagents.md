# Feature: Agents & subagent templates

## Built-in agent files

- `plugin/agents/code-reviewer.md`
- `plugin/agents/codebase-explorer.md`
- `plugin/agents/test-writer.md`
- `plugin/agents/docs-writer.md`
- `plugin/agents/refactor-helper.md`

## Templates & bindings

- `plugin/lib/claude-subagents.json` — `subagents`, `agentTemplates`, rule bindings for generated agents

## Custom

- `plugin/custom/claude-subagents.extend.json` — merged per setup/custom merge rules (`plugin/custom/README.md`)

## Gotchas

- Agents reference `.claude/rules/` and `CLAUDE.md` in user projects — wording must stay consistent with setup output
