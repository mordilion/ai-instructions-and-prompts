# Contributing

Thanks for your interest in contributing to **AI Instructions & Prompts**.

This repository is a **meta-project**: changes here are used to generate rules/prompts for multiple AI tools. Please
optimize for **clarity**, **consistency**, and **cross-AI understandability**.

## Ways to contribute

- **Report bugs**: Use a GitHub issue with a minimal reproduction and the expected vs actual result.
- **Suggest improvements**: Propose new rules/processes/functions, or improvements to existing ones.
- **Submit pull requests**: Fix bugs, improve docs, add/extend supported tools, languages, frameworks, or templates.

## Before you start

Please skim:

- `README.md` (overview and quick start)
- `CLAUDE.md` (maintainer expectations for **this** repo: propagation, verification, context memory)
- `docs/memory/README.md` (optional structured notes — ADRs, modules, features)
- `TEAM_ADOPTION_GUIDE.md` (context and adoption constraints)

## Project principles (please follow)

- **Keep outputs consistent across tools**: if you change a rule/process, consider how it affects all supported AI tools.
- **Rerunnable setup is mandatory**: generated outputs must be safe to regenerate; avoid deleting user-owned files.
- **Avoid fixed versions**: prefer detecting versions from the target project (`.nvmrc`, `global.json`, `pom.xml`, etc.).
- **Security first**: rules must align with OWASP Top 10 and avoid unsafe advice.
- **Token efficiency is secondary to clarity**: be concise, but never ambiguous.

## Pull request guidelines

### What makes a good PR

- **One logical change** per PR (easier review and less risk of breaking generated outputs)
- **Clear motivation** in the PR description (what problem it solves and why it matters)
- **No breaking changes** unless explicitly justified and documented

### Commit messages

Use **Conventional Commits** (the repository enforces this style). Examples:

- `docs: update setup instructions`
- `fix(config): handle missing optional fields`
- `feat(rules): add sql injection guidance`

### Local checks

Run the same checks CI runs:

- **Markdown lint**: ensure all `*.md` files pass `markdownlint`
- **Validation**: run `/ai-iap:validate` in Claude Code with this repo loaded as the plugin (`claude --plugin-dir .` or equivalent)
- **Checked-in Claude Code rules**: this repository keeps generated rules under `.claude/rules/` so Claude Code matches our sources without relying on a manual setup run. After changing rule **sources** under `plugin/lib/rules/` or changing which languages should apply here, regenerate:

```bash
node scripts/generate-ai-iap-claude-rules.mjs
```

Edit `SELECTION` at the top of `scripts/generate-ai-iap-claude-rules.mjs` if you intentionally add or remove languages or documentation bundles; keep `.ai-iap-state.json` in sync with that intent.

If your change touches setup/merge logic, run `/ai-iap:validate` again after your edits.

## Content guidelines

### Rules and processes

- **Be explicit**: use `> **ALWAYS**` and `> **NEVER**` directives where ambiguity is possible.
- **Keep structure consistent** with existing files (headings order, tables, self-check sections).
- **Avoid long prose** and repetition; prefer concise directive blocks and tables when it remains clear.
- **Model-neutral phrasing**: any LLM should parse intent without tool-specific cues; align with [CLAUDE.md](CLAUDE.md) (*Interpreting rules and processes*) and the short table in [plugin/lib/README.md](plugin/lib/README.md) (*Interpreting these rules*).
- **Paths after setup**: generated rules land in **`.claude/rules/`** in the user’s project. Markdown links from one rule to another must target that tree (see setup skill output paths). Avoid `plugin/lib/...` in rule bodies meant for end users — that path is only for working in **this** repository.

### Code Library (Functions & Design Patterns)

If you add or change a pattern:

- **For implementation patterns**: Start from the template in `plugin/lib/code-library/functions/_TEMPLATE.md`
- **For design patterns**: Start from the template in `plugin/lib/code-library/design-patterns/_TEMPLATE.md`
- Keep the YAML frontmatter format consistent
- After the YAML header, include **code examples only** (no install commands, no long explanations)
- Design patterns: Include complete implementations (20-100 lines) plus usage examples
- Update the relevant INDEX.md file so AIs can discover the pattern

## Licensing

By contributing, you agree that your contributions will be licensed under the MIT License (see `LICENSE`).
