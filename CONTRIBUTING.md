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
- `CUSTOMIZATION.md` (extension system and update-safe overrides)
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
- `fix(config): handle missing custom config`
- `feat(rules): add sql injection guidance`

### Local checks

Run the same checks CI runs:

- **Markdown lint**: ensure all `*.md` files pass `markdownlint`
- **Script validation**:
  - Windows: run `.\.ai-iap\validate.ps1`
  - macOS/Linux: run `./.ai-iap/validate.sh`

If your change touches setup/merge logic, also run:

- Windows: `.\.ai-iap\verify-extension.ps1`
- macOS/Linux: `./.ai-iap/verify-extension.sh`

## Content guidelines

### Rules and processes

- **Be explicit**: use `> **ALWAYS**` and `> **NEVER**` directives where ambiguity is possible.
- **Keep structure consistent** with existing files (headings order, tables, self-check sections).
- **Avoid long prose** and repetition; prefer concise directive blocks and tables when it remains clear.

### Functions library

If you add or change a function pattern:

- **Start from the template** in `.ai-iap/functions/_TEMPLATE.md`
- Keep the YAML frontmatter format consistent
- After the YAML header, include **code examples only** (no install commands, no long explanations)
- Update the relevant functions index so AIs can discover the pattern

## Licensing

By contributing, you agree that your contributions will be licensed under the MIT License (see `LICENSE`).
