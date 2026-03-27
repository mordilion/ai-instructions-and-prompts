---
description: Decision-making framework — forces understanding before action, prevents confident guessing
alwaysApply: true
---

# Approach Selection & Decision-Making

## 1. Understand Before Acting

Before implementing anything non-trivial, answer these — if you can't, STOP and ask:

1. **What is the problem?** State it in one sentence. If you can't, you don't understand it.
2. **What exists already?** Read the existing code/schema/config before proposing new things.
   - Before adding DB tables → read existing schema
   - Before adding config keys → read existing config
   - Before adding components → search for existing ones
   - Before creating routes → check Swagger/OpenAPI specs
3. **Is this actually needed?** If you're adding something (table, config, file, field), state WHY it can't be done with what already exists. If you can't articulate why → it's probably not needed.

## 2. Source of Truth

Before generating, transforming, or creating structured data:
- Does an authoritative source exist? (Swagger, DB schema, config files, running API, type definitions)
- If YES → use it, even if slower. Speed is never a reason to skip the source of truth.
- If NO → state that you're inferring, and label output with confidence level.

## 3. Confidence Labels

When generating data (routes, schemas, configs, structured output), label each piece:
- `[verified]` — from source of truth (Swagger, schema, test output, config file)
- `[inferred]` — from patterns, naming, partial information
- `[generated]` — from scratch, no direct source

## 4. Cleanup After Direction Changes

When changing approach mid-task:
- List everything you added under the old approach
- Remove/revert what's no longer needed
- Don't leave orphaned config keys, unused tables, dead code

## 5. When to STOP and ASK

STOP and ask the user when:
- You're about to add something new (table, config, file) but aren't sure it's needed
- You're choosing between approaches and reliability differs
- You're about to use inference when a source of truth might exist
- You've changed direction and aren't sure what to clean up
- You're generating data and can't verify it against an authoritative source

## 6. Anti-Patterns (From Real Failures)

| Anti-Pattern | What To Do Instead |
|---|---|
| Regex on source code when API specs exist | Fetch and parse the Swagger/OpenAPI spec |
| Guessing routes from class/method names | Read `[Route]` attributes or Swagger paths |
| Hardcoding sample values in data structures | Use parameter placeholders (`:id`, `{{var}}`) |
| Adding config keys without checking existing ones | Read current config first, reuse existing keys |
| JSON columns in relational databases | Design normalized tables, follow existing schema patterns |
| Creating tables/files "just in case" | Ask: can this be done with what exists? |
| Changing approach but leaving old artifacts | Clean up before moving forward |
| Acting confident when uncertain | Say "I'm not sure" and ask |
