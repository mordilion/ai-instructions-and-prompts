---
name: validate
description: Validate the ai-iap configuration and rule library integrity. Use when checking for missing files, broken references, or configuration issues.
---

# AI Instructions & Prompts Validation

Run validation checks on the plugin's configuration and rule library.

## Important Paths

- Config: `${CLAUDE_PLUGIN_ROOT}/lib/config.json`
- Config schema: `${CLAUDE_PLUGIN_ROOT}/lib/config.schema.json`
- Rule library: `${CLAUDE_PLUGIN_ROOT}/lib/rules/`
- Process library: `${CLAUDE_PLUGIN_ROOT}/lib/processes/`
- State file (in user project): `.ai-iap-state.json`

## Validation Checks

Run all checks below and report results as `[PASS]` or `[FAIL]` with details.

### 1. Config File Validation

1. Read `${CLAUDE_PLUGIN_ROOT}/lib/config.json` — must exist and be valid JSON.
2. Validate against `${CLAUDE_PLUGIN_ROOT}/lib/config.schema.json`:
   - Must have `version` (string, semver pattern).
   - Must have `tool` object with `name`, `outputDir`, `outputFile`, `fileExtension`.
   - Must have `languages` object.
3. Each language must have: `name`, `globs`, `alwaysApply` (boolean), `description`, `files` (array).
4. `general` language must have `alwaysApply: true`.
5. No language other than `general` should have `alwaysApply: true` (warn).
6. `globs` must be a string, not an array.
7. No obsolete `enabled` property on any language.

### 2. Rule File Existence

For each language in config:
1. For each entry in `files[]`, verify `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/{file}.md` exists.
2. For each `optionalRules` entry, verify the referenced file exists.
3. For each framework, verify `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/frameworks/{fw_file}.md` exists.
4. For each structure, verify `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/frameworks/structures/{struct_file}.md` exists.
5. If `tool.outputFileSource` is set, verify `${CLAUDE_PLUGIN_ROOT}/lib/rules/general/{source}.md` exists.

### 3. Markdown Structure

For each `.md` file under `${CLAUDE_PLUGIN_ROOT}/lib/rules/`:
1. File must not be empty.
2. File must start with a `#` heading on the first line.

### 4. Framework Dependencies

For each framework that has a `requires` array:
1. Each required framework key must exist in the same language's `frameworks` object.

### 5. No Forbidden File References

For each `.md` file under `${CLAUDE_PLUGIN_ROOT}/lib/rules/` and `${CLAUDE_PLUGIN_ROOT}/lib/processes/`:
1. Must not contain references to paths like `.ai-iap/...`, `.cursor/rules/...`, or
   other repo-internal paths that won't exist in user projects.

### 6. Persona Split Files

Verify these files exist under `${CLAUDE_PLUGIN_ROOT}/lib/rules/general/`:
- `persona-core.md`
- `persona-specialist-software.md`
- `persona-specialist-seo.md`
- `persona-specialist-ui-ux.md`
- `persona-specialist-testing.md`
- `persona-specialist-devops.md`

### 7. Subagent Templates

If `${CLAUDE_PLUGIN_ROOT}/lib/claude-subagents.json` exists:
1. Must be valid JSON.
2. Must have `subagents` array and `agentTemplates` array.

### 8. State File (Optional)

If `.ai-iap-state.json` exists in the project root:
1. Must be valid JSON.
2. Must have `version` and `selectedLanguages`.

### 9. Plugin Manifest & Marketplace

Verify `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`:
1. Must exist and be valid JSON.
2. Must have `name` field.

Verify `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/marketplace.json`:
1. Must exist and be valid JSON.
2. Must have `name`, `owner`, and `plugins` fields.
3. `plugins` array must contain at least one entry with `name` and `source`.

## Output Format

```
=== AI Instructions & Prompts Validation ===

[PASS] Config file exists and is valid JSON
[PASS] Config has required fields (version, tool, languages)
[PASS] All 192 rule files exist
[FAIL] Missing rule file: typescript/frameworks/structures/angular-ddd.md
...

=== Summary ===
Passed: 42
Failed: 1
```

Exit with failure status if any check fails.
