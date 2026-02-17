# Project Rules (Claude)

Use this file for the **few** project-specific rules that must not be missed.

## Hard Rules (violations cause bugs)
- Follow all applicable rules and rule precedence.
- Ask 2–5 targeted questions if outcomes or constraints are unclear.
- Do not assume project defaults; confirm or follow explicit rules.
- Validate all external input before use (type, format, bounds).
- Never log or store secrets; redact sensitive values in logs.
- Use the code library patterns instead of inventing new ones.
- Do not introduce fixed versions; read from project config files.
- Prefer smallest change that satisfies requirements.
- Update dependent docs/configs when changing rule sources.
- Keep outputs concise and unambiguous across AI tools.

## Style Preferences
- Use short, directive sentences.
- Avoid long checklists; keep critical items visible.
- Use consistent terminology across files.
- Prefer tables for comparisons and options.
- Use examples only when they reduce ambiguity.

## Environment Notes (Optional)
- Rules are consumed by multiple AI tools; avoid tool-specific phrasing.
