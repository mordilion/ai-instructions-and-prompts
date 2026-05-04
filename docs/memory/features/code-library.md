# Feature: Code library (functions & design patterns)

## Paths

- `plugin/lib/code-library/functions/` — multi-language pattern files + `INDEX.md`
- `plugin/lib/code-library/design-patterns/` — templates + `INDEX.md`
- Custom overlay: `plugin/custom/code-library/` (mirrors structure)

## Rules (project-wide)

- New function pattern: start from `plugin/lib/code-library/functions/_TEMPLATE.md`
- New design pattern: `plugin/lib/code-library/design-patterns/_TEMPLATE.md`
- **Always** update the relevant `INDEX.md` when adding files
- No install commands inside pattern bodies; user project versions come from their package managers

## Integration

- General rules and persona point authors to **check INDEX first** before generating code examples
