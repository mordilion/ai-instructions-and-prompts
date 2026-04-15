# Custom Extensions (Fork Space)

This directory is your **personal extension space** for the ai-iap plugin. Add your own rules, processes, config extensions, and agent templates here without touching upstream files.

## Why This Exists

When you fork this repository, any changes you make directly in `lib/` will cause merge conflicts when pulling upstream updates. The `custom/` directory is **never modified by upstream**, so your fork stays conflict-free.

## Directory Structure

```
custom/
  config.extend.json              # Extend/override config.json (new languages, frameworks, processes)
  claude-subagents.extend.json    # Additional agent templates
  rules/
    general/                      # Cross-cutting custom rules
    {language}/                   # Language-specific custom rules
      {rule-name}.md
      frameworks/
        {framework}.md            # Override or extend framework rules
        structures/
          {structure}.md
  processes/
    permanent/{language}/         # Always-loaded custom processes
    ondemand/{language}/          # Copy-when-needed custom processes
  code-library/
    functions/                    # Custom implementation patterns
    design-patterns/              # Custom design patterns
```

## How to Add Custom Rules

Create a Markdown file in the appropriate subdirectory. The path structure mirrors `lib/rules/`.

### New Rule (additive)

Create a file that does **not** exist in `lib/rules/`:

```
custom/rules/typescript/my-company-standards.md
```

This rule is added alongside the base rules during setup.

### Override an Existing Rule

Create a file with the **same relative path** as a base rule and add a frontmatter `override` field:

```markdown
---
override: replace
---

# Security (Company Override)

Your custom security rules here...
```

**Override modes:**

| Mode | Behavior |
|------|----------|
| `append` (default) | Custom rule is loaded **after** the base rule (both active) |
| `prepend` | Custom rule is loaded **before** the base rule (both active) |
| `replace` | Custom rule **replaces** the base rule entirely |

If no `override` field is present, `append` is used.

## How to Extend Config

Edit `config.extend.json` to add new languages, frameworks, or processes. The structure is identical to `lib/config.json`, but everything is optional — only define the delta.

### Add a New Framework

```json
{
  "languages": {
    "typescript": {
      "frameworks": {
        "my-internal-fw": {
          "name": "My Internal Framework",
          "file": "my-internal-fw",
          "category": "Backend Framework",
          "description": "Company-internal TypeScript framework"
        }
      }
    }
  }
}
```

Then create the rule file at `custom/rules/typescript/frameworks/my-internal-fw.md`.

### Add a New Process

```json
{
  "languages": {
    "typescript": {
      "processes": {
        "company-deploy": {
          "name": "Company Deploy",
          "file": "company-deploy",
          "description": "Internal deployment process",
          "type": "permanent",
          "loadIntoAI": true
        }
      }
    }
  }
}
```

Then create the process file at `custom/processes/permanent/typescript/company-deploy.md`.

### Add a New Language

```json
{
  "languages": {
    "rust": {
      "name": "Rust",
      "globs": "*.rs",
      "alwaysApply": false,
      "description": "Rust systems programming",
      "files": ["architecture", "code-style", "security"]
    }
  }
}
```

Then create the rule files at `custom/rules/rust/architecture.md`, etc.

## How to Add Agent Templates

Edit `claude-subagents.extend.json`:

```json
{
  "agentTemplates": [
    {
      "id": "rust-developer",
      "name": "rust-developer",
      "description": "Rust systems programming specialist.",
      "ruleBindings": { "general": [], "rust": [] },
      "tools": "Read, Glob, Grep, Write, Edit, Bash",
      "model": "sonnet"
    }
  ]
}
```

## Merge Behavior

During `/ai-iap:setup`, the plugin automatically detects and merges your custom extensions:

1. **Config**: `config.extend.json` is deep-merged over `lib/config.json` (custom values win)
2. **Rules**: Custom rules are resolved first; if no custom override exists, the base rule is used
3. **Processes**: Same resolution as rules
4. **Agent templates**: Custom templates are appended; matching IDs override the base template

## Keeping Your Fork Up to Date

```bash
# Add upstream remote (one-time)
git remote add upstream https://github.com/mordilion/ai-instructions-and-prompts.git

# Pull upstream changes (conflict-free)
git fetch upstream
git merge upstream/main
```

Since upstream never modifies `custom/`, merges are clean.
