# Deployment & CI (this repository)

## Distribution

- **Claude Code marketplace**: `.claude-plugin/marketplace.json` → plugin id `ai-iap`, `source: ./plugin`
- **Local dev**: `claude --plugin-dir <path-to-repo>` (see root `README.md`)

## GitHub Actions

| Workflow | Path | Purpose |
|----------|------|---------|
| Validate plugin | `.github/workflows/validate.yml` | JSON parse, directory layout, config refs → rule files exist, markdown smoke (`#` first line), persona files, subagents JSON |
| Claude tests | `.github/workflows/ai-compatibility-tests.yml` | Node 20 in `.github/scripts`; optional `ANTHROPIC_API_KEY`; triggers on `plugin/lib/rules/**`, `plugin/lib/processes/**` |

## Release coupling

- Bump **`plugin/.claude-plugin/plugin.json`** `version`
- Align **`plugin/lib/config.json`** `version` and **`.claude-plugin/marketplace.json`** plugin entry `version` when cutting a release (team convention)

## Checked-in Claude Code rules (this repo)

Developers regenerate `.claude/rules/` with `node scripts/generate-ai-iap-claude-rules.mjs` (see [CONTRIBUTING.md](../../CONTRIBUTING.md)). This is not part of GitHub Actions today; run locally after changing `plugin/lib/rules/` for tracked languages.

## Not used for this repo

- Container registry / K8s — no deploy target for the plugin source itself beyond Git + marketplace
