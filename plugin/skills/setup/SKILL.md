---
name: setup
description: Interactive setup wizard for AI coding standards. Generates .claude/rules/ with modular rules, CLAUDE.md project instructions, and optional agents. Use when the user wants to configure Claude Code rules for their project, set up coding standards, or regenerate configuration.
---

# AI Instructions & Prompts Setup

You are an interactive setup wizard. Guide the user through configuring Claude Code
rules for their project by reading the plugin's rule library and generating files.

## Important Paths

- Plugin root: `${CLAUDE_PLUGIN_ROOT}`
- Config: `${CLAUDE_PLUGIN_ROOT}/lib/config.json`
- Config schema: `${CLAUDE_PLUGIN_ROOT}/lib/config.schema.json`
- Config extend schema: `${CLAUDE_PLUGIN_ROOT}/lib/config.extend.schema.json`
- Rule library: `${CLAUDE_PLUGIN_ROOT}/lib/rules/`
- Process library: `${CLAUDE_PLUGIN_ROOT}/lib/processes/`
- Code library: `${CLAUDE_PLUGIN_ROOT}/lib/code-library/`
- Custom extensions: `${CLAUDE_PLUGIN_ROOT}/custom/`
- Custom config: `${CLAUDE_PLUGIN_ROOT}/custom/config.extend.json`
- Custom rules: `${CLAUDE_PLUGIN_ROOT}/custom/rules/`
- Custom processes: `${CLAUDE_PLUGIN_ROOT}/custom/processes/`
- Custom subagents: `${CLAUDE_PLUGIN_ROOT}/custom/claude-subagents.extend.json`
- Subagent templates: `${CLAUDE_PLUGIN_ROOT}/lib/claude-subagents.json`
- State file (in user project): `.ai-iap-state.json`

## Before You Start

Recommend the user run `/clear` before starting setup. This ensures a clean context
without prior conversation history that could interfere with file generation.

## Custom Extensions Layer

The plugin supports a **custom extensions layer** in `${CLAUDE_PLUGIN_ROOT}/custom/` for users
who fork the repository. This layer is automatically detected and merged with the base library.

### Custom Layer Detection

Before starting the wizard, check if `${CLAUDE_PLUGIN_ROOT}/custom/` exists and contains
extension files:

1. Check if `${CLAUDE_PLUGIN_ROOT}/custom/config.extend.json` exists and is valid JSON.
2. Check if `${CLAUDE_PLUGIN_ROOT}/custom/rules/` contains any `.md` files.
3. Check if `${CLAUDE_PLUGIN_ROOT}/custom/processes/` contains any `.md` files.
4. Check if `${CLAUDE_PLUGIN_ROOT}/custom/claude-subagents.extend.json` exists and is valid JSON.

If any custom content is found, display a notice:

```
Custom extensions detected:
  - Config extensions: {count} language(s) extended
  - Custom rules: {count} file(s)
  - Custom processes: {count} file(s)
  - Custom agent templates: {count} template(s)

Custom extensions will be merged with base library during generation.
```

### Config Merge Strategy

When `custom/config.extend.json` exists, deep-merge it over the base `lib/config.json`:

1. Read and parse `${CLAUDE_PLUGIN_ROOT}/lib/config.json` (base config).
2. Read and parse `${CLAUDE_PLUGIN_ROOT}/custom/config.extend.json` (extension config).
3. Deep-merge with these rules:
   - **New language keys**: Added to the merged config.
   - **Existing language keys**: Properties are merged recursively.
   - **`files` arrays**: Concatenated (custom entries appended, duplicates removed).
   - **`frameworks` objects**: Merged by key (custom adds or overrides framework entries).
   - **`processes` objects**: Merged by key (custom adds or overrides process entries).
   - **`structures` objects**: Merged by key (custom adds or overrides structure entries).
   - **Scalar properties** (`name`, `globs`, `description`, etc.): Custom value wins.
4. Use the merged config for all subsequent wizard steps.

### Rule File Resolution

When reading a rule file, resolve it with custom-first priority:

1. Check if `${CLAUDE_PLUGIN_ROOT}/custom/rules/{relative_path}` exists.
2. If it exists, read its YAML frontmatter for an `override` field:
   - `override: replace` — Use **only** the custom file (skip base).
   - `override: prepend` — Read custom file content first, then append base file content.
   - `override: append` (default if no `override` field) — Read base file content first,
     then append custom file content.
3. If no custom file exists, read from `${CLAUDE_PLUGIN_ROOT}/lib/rules/{relative_path}`.

For custom-only rules (files that exist in `custom/rules/` but not in `lib/rules/`), these
are always included when the corresponding language/framework is selected. They are treated
as additional rule files for that language.

### Process File Resolution

Same resolution logic as rules, but using `custom/processes/` and `lib/processes/` paths.

### Agent Template Merge

When `custom/claude-subagents.extend.json` exists:

1. Read base `${CLAUDE_PLUGIN_ROOT}/lib/claude-subagents.json`.
2. Read custom `${CLAUDE_PLUGIN_ROOT}/custom/claude-subagents.extend.json`.
3. Merge `agentTemplates` arrays: custom templates with matching `id` override the base
   template; new IDs are appended.

## Setup Flow

Follow these steps in order. Present choices clearly and wait for user input at each step.

### Step 0: Check for Previous State

1. Check if `.ai-iap-state.json` exists in the project root.
2. If it exists, read it and display a summary of the previous setup.
3. Ask the user:
   - **Reuse** previous selection and regenerate (recommended)
   - **Modify** selection (run the wizard again)
   - **Cleanup** previously generated files only
   - **Start fresh** (ignore previous selection)
4. If "Reuse", skip to Step 7 (Generation) using previous selections.
5. If "Cleanup", run cleanup (see **Cleanup Command** section below) and stop.
6. If "Start fresh" or "Modify", continue with Step 1.

### Step 1: Read Configuration

1. Read `${CLAUDE_PLUGIN_ROOT}/lib/config.json`.
2. If `${CLAUDE_PLUGIN_ROOT}/custom/config.extend.json` exists, read and deep-merge it
   over the base config (see **Config Merge Strategy** above).
3. Parse the merged `languages` object to get available options.

### Step 2: Select Languages

1. List all available languages from config with their names and descriptions.
2. Mark languages with `alwaysApply: true` as "always included" (e.g., General).
3. Languages with no base `files` but with `frameworks` get labeled "(frameworks only)".
4. Ask the user to select languages (numbers, space-separated, or 'a' for all).
5. Always include languages where `alwaysApply: true`.
6. If user chose "Modify" in Step 0, show previous selections as defaults.

### Step 3: Select Documentation Standards

1. Read `languages.general.documentation` from config.
2. List documentation options with descriptions and recommendations.
3. Suggest based on project type:
   - Frontend-only (Dart/Flutter): code + project docs
   - Backend/fullstack: all docs
4. Allow skip ('s') or all ('a').

### Step 4: Commit Standards

1. Ask whether to enable commit standards rules (Conventional Commits).
2. Default: yes.

### Step 5: Select Frameworks

For each selected language that has frameworks:

1. List frameworks grouped by `category`, showing `description` and `recommended` markers.
2. Allow multiple selection, skip ('s'), or all ('a').
3. If user chose "Modify", show previous selections as defaults.

After framework selection, for each framework that has `structures`:

1. List available structures with descriptions and `recommended` markers.
2. Allow single selection or skip ('s').

### Step 6: Select Processes

For each selected language that has processes:

1. List processes with their `description` and type indicator:
   - `[permanent]` if `loadIntoAI: true` (loaded into AI permanently)
   - `[on-demand]` if `loadIntoAI: false` (user copies prompt when needed)
2. Allow multiple selection, skip ('s'), or all ('a').

### Step 7: Generate Files

Before generating, show a summary of all selections and ask for confirmation.

Then generate Claude Code configuration files:

#### 7a: Cleanup Previous Output

If `.ai-iap-state.json` exists or `.claude/rules/` exists:

1. Find all `.md` files under `.claude/rules/` that contain `aiIapManaged: true` in their
   YAML frontmatter and delete them.
2. Remove empty directories left behind.
3. If `CLAUDE.md` contains `AI-IAP:START` / `AI-IAP:END` markers, remove only the marked
   section. If it contains "Generated by AI Instructions and Prompts Setup" but no markers
   (legacy), delete it. Otherwise leave it untouched.

#### 7b: Generate Core Language Rules

For each selected language, for each file in `languages[lang].files`:

1. Resolve the rule content using **Rule File Resolution** (custom-first, then base):
   - Check `${CLAUDE_PLUGIN_ROOT}/custom/rules/{lang}/{file}.md` first.
   - Apply override mode (`replace`, `prepend`, `append`) if custom file exists.
   - Fall back to `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/{file}.md`.
2. Also scan `${CLAUDE_PLUGIN_ROOT}/custom/rules/{lang}/` for additional `.md` files not
   listed in `files[]` — include these as extra custom rules for the language.
3. Skip `commit-standards` if commit standards are disabled.
4. Write to `.claude/rules/core/{lang}/{file}.md` with this format:

```markdown
---
aiIapManaged: true
paths:
  - "**/*.ext"
---

<!-- Generated by AI Instructions and Prompts Setup (ai-iap plugin) -->

{content from rule file}
```

The `paths:` frontmatter comes from `languages[lang].globs` in config:
- If `alwaysApply: true`, omit `paths:` (rule applies to all files).
- Otherwise, split the globs string by comma and list each pattern.
- Ensure patterns have `**/` prefix if they don't already contain a path separator.

#### 7c: Generate Optional Rules

For each language, check `optionalRules`. If the toggle is enabled (e.g.,
`enableCommitStandards`), generate the rule file in the same core directory.

#### 7d: Generate Documentation Rules

If documentation standards were selected, for each selected doc file:

1. Read from `${CLAUDE_PLUGIN_ROOT}/lib/rules/general/{doc_file}.md`.
2. Write to `.claude/rules/core/documentation/{basename}.md` with `aiIapManaged: true`
   frontmatter (no paths — documentation rules apply always).

#### 7e: Generate Framework Rules

For each selected framework:

1. Resolve framework rule using **Rule File Resolution** (custom-first, then base):
   - Check `${CLAUDE_PLUGIN_ROOT}/custom/rules/{lang}/frameworks/{fw_file}.md` first.
   - Apply override mode if custom file exists.
   - Fall back to `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/frameworks/{fw_file}.md`.
2. Write to `.claude/rules/frameworks/{lang}/{fw_key}.md` with `aiIapManaged: true` and
   `paths:` frontmatter based on framework-specific glob patterns:

| Framework | Paths |
|-----------|-------|
| react | `**/*.{jsx,tsx}` |
| vue (TS) | `**/*.vue`, `**/*.{ts,tsx,mts,cts}` |
| vue (JS) | `**/*.vue`, `**/*.{js,jsx,mjs,cjs}` |
| angular | `**/*.{ts,html,scss}` |
| nextjs (TS) | `{app,pages,components}/**/*.{ts,tsx,mts,cts}` |
| nestjs (TS) | `src/**/*.{ts,controller.ts,service.ts,module.ts}` |
| django/fastapi/flask | `**/*.py` |
| spring-boot | `**/*.java` |
| laravel | `**/*.php` |
| flutter | `**/*.dart` |
| swiftui/ios | `**/*.swift` |

For frameworks not listed, use the language's globs.

#### 7f: Generate Structure Rules

For each selected structure:

1. Resolve structure rule using **Rule File Resolution** (custom-first, then base):
   - Check `${CLAUDE_PLUGIN_ROOT}/custom/rules/{lang}/frameworks/structures/{struct_file}.md` first.
   - Apply override mode if custom file exists.
   - Fall back to `${CLAUDE_PLUGIN_ROOT}/lib/rules/{lang}/frameworks/structures/{struct_file}.md`.
2. Write to `.claude/rules/structures/{lang}/{fw}-{struct_name}.md` with same paths
   as the parent framework.

#### 7g: Generate Process Rules

For each selected process where `loadIntoAI: true`:

1. Resolve process file using **Process File Resolution** (custom-first, then base):
   - Check `${CLAUDE_PLUGIN_ROOT}/custom/processes/{ondemand|permanent}/{lang}/{proc_file}.md` first.
   - Apply override mode if custom file exists.
   - Fall back to `${CLAUDE_PLUGIN_ROOT}/lib/processes/{ondemand|permanent}/{lang}/{proc_file}.md`.
2. Write to `.claude/rules/processes/{lang}-{proc_key}.md` with `aiIapManaged: true`
   frontmatter (no paths — processes apply broadly).

#### 7h: Generate CLAUDE.md (Merge Strategy)

Read `config.tool.outputFileSource` (e.g., `claude-project-rules`).
Read content from `${CLAUDE_PLUGIN_ROOT}/lib/rules/general/{source}.md`.

**Merge with existing CLAUDE.md**:

1. If `CLAUDE.md` does NOT exist: create it with the generated content wrapped in markers:

```markdown
<!-- AI-IAP:START - Do not edit this section manually -->
{generated content}
<!-- AI-IAP:END -->
```

2. If `CLAUDE.md` exists and contains `AI-IAP:START` / `AI-IAP:END` markers:
   replace ONLY the content between the markers (preserve everything outside).

3. If `CLAUDE.md` exists but has NO markers (user-owned file):
   append the generated section at the END of the existing file, separated by a blank line:

```markdown
{existing user content}

<!-- AI-IAP:START - Do not edit this section manually -->
{generated content}
<!-- AI-IAP:END -->
```

This ensures user-written project context is always preserved and the generated
section can be safely updated on reruns.

### Step 8: Save State

Write `.ai-iap-state.json` in the project root with this structure:

```json
{
  "version": "1.0.0",
  "scope": "project",
  "setupType": "rules",
  "selectedLanguages": ["general", "typescript", ...],
  "selectedDocumentation": ["documentation/code", ...],
  "selectedFrameworks": { "typescript": ["react", "nestjs"], ... },
  "selectedStructures": { "typescript-react": "react-modular", ... },
  "selectedProcesses": { "typescript": ["test-implementation", "ci-cd"], ... },
  "enableCommitStandards": true
}
```

### Step 9: Completion

Show a summary:
- Number of rule files generated
- Number of custom extensions applied (if any)
- Location of generated files
- Note that `.ai-iap-state.json` tracks the setup for safe reruns

## Agent Setup (Optional)

If the user asks about agents (e.g., `/ai-iap:setup agents`), guide them through
defining custom Claude Code agents:

1. Read `${CLAUDE_PLUGIN_ROOT}/lib/claude-subagents.json` for templates.
   If `${CLAUDE_PLUGIN_ROOT}/custom/claude-subagents.extend.json` exists, merge custom
   templates (see **Agent Template Merge** above).
2. Ask how many agents the user wants to define.
3. For each agent, collect:
   - Name (slug, e.g., `ios-developer`)
   - Description (when Claude should use this agent)
   - Tech stack preset or custom language/framework selection
   - Persona specialization (software/seo/ui-ux/testing/devops/generic)
4. Generate agent files in `.claude/agents/{name}.md` with:
   - Frontmatter: `aiIapManaged: true`, `name`, `description`, `tools`, `model`
   - Body: Inject rules from selected languages/frameworks using rule binding

For rule injection, for each bound language:
- Read all files from `languages[lang].files`
- Read framework-specific rules for bound frameworks
- For persona: use `persona.md` + `persona-specialist-{spec}.md` when a
  specialization is set

## Cleanup Command

If the user runs `/ai-iap:setup cleanup`:

1. Find all files under `.claude/rules/` with `aiIapManaged: true` frontmatter and delete.
2. Find all files under `.claude/agents/` with `aiIapManaged: true` frontmatter and delete.
3. Handle `CLAUDE.md`:
   - If it contains `AI-IAP:START` / `AI-IAP:END` markers: remove ONLY the marked section
     (including markers). If the file is empty after removal, delete it.
   - If it contains "Generated by AI Instructions and Prompts Setup" but no markers
     (legacy format): delete the entire file.
   - Otherwise: leave it untouched (user-owned).
4. Remove empty directories.
5. Optionally delete `.ai-iap-state.json`.

## Rules for Generated Files

- All generated `.md` files under `.claude/rules/` MUST have `aiIapManaged: true` in
  YAML frontmatter (for safe cleanup on reruns).
- All generated `.md` files under `.claude/agents/` MUST have `aiIapManaged: true` in
  YAML frontmatter.
- NEVER delete files that don't have `aiIapManaged: true` — those are user-owned.
