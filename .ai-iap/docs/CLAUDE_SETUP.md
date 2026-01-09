# Claude Setup Guide

> **Reference**: 
> - [Claude Memory Documentation](https://code.claude.com/docs/en/memory)
> - [Claude Skills Documentation](https://code.claude.com/docs/en/skills)

---

## Overview

Claude supports two powerful features for context management:

1. **Memory** - Persistent knowledge stored in Claude's knowledge base
2. **Skills** - Auto-triggered instructions based on project context

This setup routine generates both components automatically.

---

## Generated Files

### 1. CLAUDE.md (Always-On Rules)

**Location**: `CLAUDE.md` (project root)

**Purpose**: Contains rules that are **always active** during conversations

**Content**:
- General coding standards
- Language-specific code style
- Security guidelines
- Architecture patterns
- Testing approaches

**When to use**: Core standards that apply to all development work

```markdown
# AI Coding Instructions

## TypeScript - code-style

...rules...

## General - security

...rules...
```

---

### 2. .claude/rules/ (Modular Rules)

**Location**: `.claude/rules/{category}/{framework}.md`

**Purpose**: Modular, topic-specific instructions that are **automatically loaded** by Claude

**Structure**:
```
.claude/rules/
├── frontend/
│   ├── react.md
│   ├── vue.md
│   └── angular.md
├── backend/
│   ├── express.md
│   ├── django.md
│   └── spring.md
├── mobile/
│   └── flutter.md
└── processes/
    ├── typescript-database-migrations.md
    └── python-testing.md
```

**Rule File Format** (with optional path-specific frontmatter):
```markdown
---
paths: **/*.{jsx,tsx}
---

# React Framework Standards

...React-specific rules that apply to .jsx and .tsx files...
```

---

## How Claude Uses These Files

### Memory (CLAUDE.md)

1. **Always Loaded**: Rules in `CLAUDE.md` are active in every conversation
2. **Context Window**: Consumes token budget, so keep concise
3. **Best For**: 
   - Core coding standards
   - Security requirements
   - Commit message formats
   - General architecture principles

### Rules (.claude/rules/)

1. **Automatically Loaded**: All `.md` files in `.claude/rules/` are loaded as project memory
2. **Path-Specific**: Rules with `paths:` frontmatter only apply to matching files
3. **Modular Organization**: Organized by category (frontend, backend, mobile, processes)
4. **Best For**:
   - Framework-specific guidelines (React, Vue, Spring Boot)
   - Project structure patterns (Feature-First, Clean Architecture)
   - Process workflows (Database Migrations, CI/CD)
   - Language-specific conventions for certain file types

**Example**: A rule with `paths: **/*.{jsx,tsx}` only applies when working with React component files.

---

## Setup Process

### Run Setup Script

```bash
# Linux/Mac
./ai-iap/setup.sh

# Windows
.\.ai-iap\setup.ps1
```

### Select Options

1. **Languages**: TypeScript, Python, Java, etc.
2. **Frameworks**: React, Django, Spring Boot, etc.
3. **Structures**: Feature-First, Clean Architecture, etc.
4. **Processes**: Database Migrations, Testing, CI/CD, etc.

### Generated Output

✅ **CLAUDE.md** - Always-on core rules (15-30KB typical)
✅ **.claude/rules/** - Modular rules organized by category (10-20 files typical)

---

## Rule Types Generated

### 1. Framework Rules

**Location**: `.claude/rules/{category}/{framework}.md`

**Example**: `.claude/rules/frontend/react.md`

**Path-Specific**: Rules can target specific file types

```yaml
---
paths: **/*.{jsx,tsx}
---

# React Framework Standards

...React component guidelines...
```

### 2. Structure Rules

**Location**: `.claude/rules/{category}/{framework}-{structure}.md`

**Example**: `.claude/rules/frontend/react-feature.md`

**Purpose**: Architectural patterns for specific frameworks

```yaml
---
paths: src/**/*.{jsx,tsx}
---

# Feature-First Architecture for React

...feature organization guidelines...
```

### 3. Process Rules

**Location**: `.claude/rules/processes/{language}-{process}.md`

**Example**: `.claude/rules/processes/typescript-database-migrations.md`

**Purpose**: Implementation processes that are used repeatedly

**Note**: Only **permanent processes** (`loadIntoAI: true`) are included as rules. On-demand processes are copied manually when needed.

---

## Using Claude's Memory Feature

### Storing Project-Specific Information

Claude can remember project-specific details using the Memory feature:

**How to Add Memory**:
1. During conversation: "Remember that we use feature-first architecture"
2. Claude stores this in its knowledge base
3. Future conversations automatically include this context

**What to Remember**:
- Project-specific naming conventions
- Custom architecture decisions
- Team preferences
- Technology stack details
- Deployment procedures

**Example**:
```
You: "Remember that we use PostgreSQL with Prisma ORM, 
and all migrations must include rollback logic"

Claude: "I've noted that. I'll ensure all database 
migration guidance includes PostgreSQL-specific advice 
and Prisma migration commands with rollback support."
```

---

## Best Practices

### CLAUDE.md (Always-On)

✅ **DO**:
- Include universal coding standards
- Add security requirements
- Define commit message format
- Keep concise (10-30KB max)

❌ **DON'T**:
- Include framework-specific details (use skills)
- Add implementation processes (use skills)
- Make it too large (token cost)

### Skills (Context-Triggered)

✅ **DO**:
- Create granular skills (React, Vue, Django)
- Use clear, descriptive names
- Write specific trigger descriptions
- Include concrete examples

❌ **DON'T**:
- Duplicate content from CLAUDE.md
- Make skills too broad
- Forget to update after framework changes

### Memory Feature

✅ **DO**:
- Store project-specific decisions
- Remember custom conventions
- Note technology stack choices
- Track team preferences

❌ **DON'T**:
- Store temporary information
- Duplicate what's in CLAUDE.md
- Include sensitive data

---

## Maintenance

### Updating Rules

```bash
# Re-run setup after changing rules
./ai-iap/setup.sh

# Skills are regenerated automatically
# Memory persists across setups
```

### Adding Custom Skills

Create custom skills manually:

```bash
mkdir -p .claude/skills/my-custom-skill
```

```markdown
# .claude/skills/my-custom-skill/SKILL.md
---
name: my-custom-skill
description: Custom company standards. Use when working with internal tools.
---

# Company-Specific Standards

...content...
```

### Clearing Memory

To reset Claude's memory for your project:
1. Open Claude
2. Settings → Memory
3. Clear project-specific memories

---

## Token Efficiency

### Before (without skills)

- All rules in CLAUDE.md: **50,000 tokens**
- Loaded in every conversation
- High cost per interaction

### After (with skills)

- CLAUDE.md: **15,000 tokens** (always)
- Skills: **5,000 tokens** (when triggered)
- **70% token savings** on non-framework conversations

---

## Troubleshooting

### Skills Not Triggering

**Problem**: Claude doesn't load expected skill

**Solutions**:
1. Check skill name matches pattern
2. Verify SKILL.md has frontmatter
3. Make description more specific
4. Mention framework explicitly in conversation

### CLAUDE.md Too Large

**Problem**: Token limit warnings

**Solutions**:
1. Move framework rules to skills
2. Move processes to skills
3. Keep only core standards
4. Remove verbose examples

### Memory Not Persisting

**Problem**: Claude forgets project details

**Solutions**:
1. Explicitly ask Claude to remember
2. Check memory settings in Claude
3. Re-state important context periodically

---

## Example Workflow

### Initial Setup

```bash
# 1. Run setup
./ai-iap/setup.sh

# 2. Select: TypeScript, React, Feature-First, Database Migrations

# 3. Generated:
✓ CLAUDE.md (core rules)
✓ .claude/skills/typescript-framework-react/SKILL.md
✓ .claude/skills/typescript-react-feature/SKILL.md
✓ .claude/skills/typescript-process-database-migrations/SKILL.md
```

### Using with Claude

```
You: "Remember we use Postgres with Prisma and feature-first structure"

Claude: "Noted. I'll use those standards."

You: "Create a new user authentication feature"

Claude: [Automatically loads typescript-framework-react and 
typescript-react-feature skills, applies Prisma + Postgres 
preferences from memory]
```

---

## Additional Resources

- **Claude Memory**: [https://code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)
- **Claude Skills**: [https://code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
- **Main Project README**: [../README.md](../../README.md)
- **Customization Guide**: [../../CUSTOMIZATION.md](../../CUSTOMIZATION.md)

---

**Questions?** Open an issue on GitHub or consult the Claude documentation.
