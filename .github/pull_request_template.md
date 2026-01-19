# Summary

What does this change do and why?

## Scope

- [ ] Rules library (`.ai-iap/rules/`)
- [ ] Processes library (`.ai-iap/processes/`)
- [ ] Functions library (`.ai-iap/functions/`)
- [ ] Setup scripts (`.ai-iap/setup.*`, validation scripts)
- [ ] Docs (`README.md`, `CUSTOMIZATION.md`, etc.)
- [ ] CI / GitHub Actions (`.github/workflows/`)
- [ ] Other (please describe)

## How to test

- [ ] Windows: `.\.ai-iap\validate.ps1`
- [ ] macOS/Linux: `./.ai-iap/validate.sh`
- [ ] Markdown lint passes (`markdownlint '**/*.md'`)
- [ ] If extension/customization behavior changed: ran `verify-extension` scripts

## Checklist

- [ ] I kept the change focused (one logical change)
- [ ] I considered impact on generated outputs for all supported AI tools
- [ ] I did not introduce fixed version requirements (prefer project version detection)
- [ ] I did not add sensitive data (secrets, tokens, credentials)
- [ ] I updated any dependent docs/config/scripts if needed

