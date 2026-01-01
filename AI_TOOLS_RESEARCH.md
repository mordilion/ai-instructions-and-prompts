# AI Tools Configuration Research

## Research Summary

Based on documentation and common patterns, here's how each tool handles custom instructions:

### 1. Amazon Q Developer (formerly CodeWhisperer)
**Format:** Uses AWS-specific configuration or IDE settings
**Best Approach:** Markdown file similar to Copilot
**Output File:** `.amazonq/instructions.md` or `AMAZON_Q.md`
**Status:** ✅ Markdown concatenated format (similar to Copilot)

### 2. Tabnine
**Format:** Team-level custom rules via web dashboard or `.tabnine` folder
**Best Approach:** Markdown file for documentation/reference
**Output File:** `TABNINE.md` or `.tabnine/instructions.md`
**Status:** ✅ Markdown concatenated format (for team sharing)

### 3. Cody by Sourcegraph
**Format:** `.cody/instructions.md` in repository root
**Best Approach:** Single markdown file with instructions
**Output File:** `.cody/instructions.md`
**Status:** ✅ Markdown concatenated format (official format)

### 4. Continue.dev
**Format:** `.continue/config.json` with `systemMessage` field
**Best Approach:** JSON config with embedded markdown OR separate `.continue/instructions.md`
**Output File:** `.continue/instructions.md` (simpler) or config.json modification
**Status:** ✅ Markdown concatenated format (easier to maintain)

## Implementation Decision

**All 4 tools will use concatenated markdown format** (like Claude CLI, Copilot, Windsurf, Aider, Google AI Studio)

### Rationale:
1. **Consistency** - Same format across all tools
2. **Maintainability** - Single source of truth
3. **Flexibility** - Users can adapt to tool-specific formats if needed
4. **Documentation** - Markdown is readable and portable

### Output Files:
- Amazon Q Developer: `AMAZON_Q.md`
- Tabnine: `TABNINE.md`
- Cody: `.cody/instructions.md`
- Continue.dev: `.continue/instructions.md`

