# Feature: Hooks

## Current behavior

- **SessionStart** (`plugin/hooks/hooks.json`): prompt model to suggest `/ai-iap:setup` if project lacks managed rules (`aiIapManaged`); mention custom extensions if `plugin/custom/` has content

## Constraints

- Hooks ship with plugin; changing JSON affects all users on next plugin load
- Keep prompt text short; avoid noisy reminders when rules already present
