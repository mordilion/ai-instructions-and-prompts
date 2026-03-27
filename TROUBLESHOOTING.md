# Troubleshooting Guide

Common issues and solutions for AI Instructions & Prompts.

---

## Plugin Installation Issues

### Plugin Not Loading

**Issue**: Plugin components (skills, agents, hooks) not appearing

**Cause**: Plugin not installed or not loaded correctly

**Fix**:
```text
# Open the plugin manager
/plugin

# Check the Installed tab for ai-iap
# Check the Errors tab for loading errors

# For local development, load with --plugin-dir
claude --plugin-dir ./path/to/ai-instructions-and-prompts

# Reload plugins within a session
/reload-plugins
```

---

### Marketplace Not Found

**Issue**: `/plugin install ai-iap@ai-iap-marketplace` fails

**Cause**: Marketplace not added yet

**Fix**:
```text
# Add the marketplace first
/plugin marketplace add mordilion/ai-instructions-and-prompts

# Then install
/plugin install ai-iap@ai-iap-marketplace
```

---

### "No frameworks showing for my language"

**Issue**: Selected a language but no frameworks appear during `/ai-iap:setup`

**Cause 1**: Language has no frameworks defined in `plugin/lib/config.json`

**Cause 2**: JSON parsing error in config

**Fix**: Run `/ai-iap:validate` to check for config issues. If validation passes,
the language simply has no frameworks configured (e.g. HTML, CSS, JSON).

---

## File Generation Issues

### "No files generated after setup"

**Issue**: `/ai-iap:setup` completes but no Claude Code files created

**Cause**: Permission issue or wrong directory

**Check**:
```bash
# Verify .claude folder was created
ls -la .claude/
ls -la CLAUDE.md
```

**Fix**: Re-run `/ai-iap:setup` and ensure you are in your project root.

---

### "Generated files have wrong content"

**Issue**: Files generated but content seems incorrect

**Fix**:
```text
# Run validation
/ai-iap:validate

# Check for errors like:
# [FAIL] All rule files exist - Missing: dart/frameworks/bloc.md
```

If validation fails, check that all referenced files exist in the plugin repository under `plugin/lib/rules/`.

---

## Git Issues

### "Permission denied (publickey)" when pushing

**Error**:
```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

**Cause**: SSH key not configured or not added to GitHub

**Fix**:

1. **Check if you have an SSH key**:
```bash
ls ~/.ssh/
# Look for: id_ed25519, id_rsa, or similar
```

2. **If no key, generate one**:
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
# Press Enter to accept defaults
```

3. **Copy public key**:
```bash
# macOS/Linux
cat ~/.ssh/id_ed25519.pub

# Windows (PowerShell)
Get-Content ~/.ssh/id_ed25519.pub
```

4. **Add to GitHub**:
   - Go to: <https://github.com/settings/keys>
   - Click "New SSH key"
   - Paste your public key
   - Save

5. **Test connection**:
```bash
ssh -T git@github.com
# Should output: Hi username! You've successfully authenticated...
```

**Alternative**: Use HTTPS instead of SSH:
```bash
git remote set-url origin https://github.com/username/repo.git
git push origin main
```

---

### "Already up to date" but files not in Git

**Issue**: Git says "up to date" but generated files not tracked

**Cause**: The files are ignored by your repository configuration (often via `.gitignore`).

**Check**:
```bash
git status --ignored

# Look for:
# Ignored files:
#   .claude/
#   CLAUDE.md
```

**Fix** (only if you intentionally want to commit generated outputs):
```bash
# Option 1: Stop ignoring them
nano .gitignore
# Delete or comment out the ignore patterns for generated files

# Option 2: Force add specific files
git add -f .claude/rules/*.md CLAUDE.md
git commit -m "Add generated Claude Code configs"
```

**Recommendation**: Ensure your repo is not ignoring the files you intend to share.
For team sharing, install the `ai-iap` plugin at project scope (`--scope project`),
commit `.ai-iap-state.json`, and decide whether to also commit
generated outputs (`.claude/rules/`, `CLAUDE.md`, `.claude/agents/`).

---

## Validation Issues

### "All validation tests passed" but config seems wrong

**Issue**: Validation passes but something feels off

**Explanation**: `/ai-iap:validate` checks:
- Files exist
- JSON is valid
- Markdown has headers
- No circular dependencies

**But doesn't check**:
- Content quality
- Spelling/grammar
- Broken internal links in markdown

**Manual Check**: Review a few generated rule files in `.claude/rules/` and
compare them to the source files under `plugin/lib/rules/` in the plugin repository.

---

## Claude Code Issues

### Claude: too many rules applying

**Issue**: Claude responses feel noisy or irrelevant, as if too many rules apply at once

**Cause**: Selecting too many languages/frameworks/structures can increase the amount of
active guidance. For Claude Code rules, scoping is controlled via `paths:` frontmatter
in `.claude/rules/**/*.md`.

**Fix**: Re-run `/ai-iap:setup` with fewer frameworks/structures. Prefer:
- Only the languages you actively edit
- 1-2 main frameworks per language
- One structure per framework (if needed)

**Tip**: Ensure `paths:` patterns match your repo layout so rules only apply to relevant files.

**Claude Code agents**: To add or remove agents (e.g. code-reviewer, codebase-explorer),
re-run `/ai-iap:setup` and pick the ones you want. Generated agent files in `.claude/agents/`
are marked `aiIapManaged: true` and are removed on cleanup.

---

## Token Cost Issues

### "Token count seems high"

**Issue**: Token analysis shows >10,000 tokens for simple selection

**Typical File Sizes** (approximate; actual size **varies by selection** and rule revisions):
- General rules: **varies by selection** — the bundled set includes persona, architecture, code-style, design, security, accessibility, i18n, compliance-standards, and commit-standards; total size depends on how many of these your setup loads, not a single fixed chunk
- Language rules: ~1,700 chars (425 tokens)
- Framework rules: ~2,500 chars (625 tokens)
- Structure rules: ~1,800 chars (450 tokens)

**If file is too large**:
- Check for verbose examples
- Remove redundant explanations
- Keep examples concise

---

## Still Having Issues?

### Validation Checklist

```text
# 1. Run validation
/ai-iap:validate

# 2. Check plugin status
/plugin
# Go to Installed tab — is ai-iap listed?
# Go to Errors tab — any loading errors?

# 3. Reload plugins
/reload-plugins

# 4. Re-run setup if needed
/ai-iap:setup
```

### Get Help

If you're still stuck:

1. **Check GitHub Issues**: [GitHub Issues](https://github.com/mordilion/ai-instructions-and-prompts/issues)
2. **Run validation**: `/ai-iap:validate`
3. **Review full docs**: `plugin/lib/README.md`

### Report a Bug

If you found a bug:

1. Run validation: `/ai-iap:validate`
2. Note which checks fail
3. Include your OS and Claude Code version
4. Include steps to reproduce
5. Open GitHub issue with details

---

## Additional Resources

- **Full Documentation**: `plugin/lib/README.md`
- **Team Adoption**: `TEAM_ADOPTION_GUIDE.md`

---

<p align="center">
  <b>Still stuck? Run /ai-iap:validate first — it catches most configuration issues.</b>
</p>
