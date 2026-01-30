# Project Learnings Capture (Optional, Setup-Enabled)

Use learnings **only** when the feature is enabled and the file already exists.

## When to Use

> **ONLY IF ALL are true**:
> - Setup enabled learnings capture for this project
> - `.ai-iap-custom/rules/general/learnings.md` already exists
> - The new information is **stable** (not a one-off choice)

If any condition is false, **do not create or modify** learnings files.

## What Learnings Are

Learning examples: persistent decisions, conventions, constraints, and "how we do things here".
Examples: "Use Prisma for DB access", "Prefer `feature-first` structure", "All logs must include correlation ID".

## How to Write Learnings

> **ALWAYS**:
> - Append only **stable, reusable** decisions
> - Write updates directly to `.ai-iap-custom/rules/general/learnings.md`
> - Write short, directive statements (1-2 lines each)
> - Keep wording unambiguous across AI models
> - Update/replace outdated learnings instead of duplicating
> - Tell the user to **re-run setup/regeneration** if they want the new learnings reflected in generated AI outputs
>
> **NEVER**:
> - Create `learnings.md` if it does not already exist
> - Treat learnings as higher priority than rule precedence
> - Store secrets, credentials, or sensitive data
> - Record guesses or temporary choices
> - Write learnings into generated tool output files

## Rule Precedence

Learning entries are **project-specific** and should complement (not override) higher-priority rules. If a learning conflicts with a rule, **follow rule precedence**.
