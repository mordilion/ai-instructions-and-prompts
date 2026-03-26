# Summary

What does this change do and why?

## Scope

- [ ] Rules library (`lib/rules/`)
- [ ] Processes library (`lib/processes/`)
- [ ] Code library (`lib/code-library/`)
- [ ] Plugin surface (`skills/`, `hooks/`, `agents/`)
- [ ] Docs (`README.md`, `CUSTOMIZATION.md`, etc.)
- [ ] CI / GitHub Actions (`.github/workflows/`)
- [ ] Other (please describe)

## How to test

- [ ] `/ai-iap:validate`
- [ ] Markdown lint passes (`markdownlint '**/*.md'`)
- [ ] If extension/customization behavior changed: re-ran `/ai-iap:validate`

## Checklist

- [ ] I kept the change focused (one logical change)
- [ ] I considered impact on generated outputs for all supported AI tools
- [ ] I did not introduce fixed version requirements (prefer project version detection)
- [ ] I did not add sensitive data (secrets, tokens, credentials)
- [ ] I updated any dependent docs/config/scripts if needed

