# Troubleshooting Guide

Common issues and solutions for AI Instructions & Prompts setup.

---

## 🔧 Setup Script Issues

### "Config file not found"

**Error**:
```
Config file not found: C:\path\to\.ai-iap\config.json
```

**Cause**: Running script from wrong directory

**Fix**:
```bash
# Make sure you're in the project root
cd /path/to/your/project

# Then run setup
.\.ai-iap\setup.ps1  # Windows
/ai-iap:setup        # In Claude Code
```

---

### "jq: command not found" (macOS/Linux)

**Error**:
```bash
./setup.sh: line 82: jq: command not found
```

**Cause**: Missing `jq` dependency

**Fix**:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt update && sudo apt install jq

# Arch Linux
sudo pacman -S jq

# CentOS/RHEL
sudo yum install jq
```

**Verify Installation**:
```bash
jq --version
# Should output: jq-1.6 or similar
```

---

### Plugin Not Loading

**Issue**: Plugin components (skills, agents, hooks) not appearing

**Cause**: Plugin not installed or not loaded correctly

**Fix**:
```bash
# Check installed plugins
claude plugin list

# For local development, load with --plugin-dir
claude --plugin-dir ./path/to/ai-instructions-and-prompts

# Reload plugins within a session
/reload-plugins
```

---

### "No frameworks showing for my language"

**Issue**: Selected a language but no frameworks appear

**Cause 1**: Language has no frameworks defined

**Check**:
```bash
# View config.json
cat lib/config.json | grep -A 10 "\"yourlanguage\""

# Check if "frameworks" key exists
```

**Cause 2**: JSON parsing error

**Fix**:
```bash
# Validate config.json
jq empty lib/config.json

# If error, check for:
# - Missing commas
# - Extra commas
# - Mismatched quotes
```

---

## 📁 File Generation Issues

### "No files generated after setup"

**Issue**: Setup completes but no Claude Code files created

**Cause**: Script didn't have write permissions or wrong directory

**Check**:
```bash
# Verify you're in project root
pwd

# Check if .claude folder was created
ls -la .claude/
ls -la CLAUDE.md

# Check write permissions
ls -ld .
```

**Fix**:
```bash
# Make sure you're in the right place
cd /path/to/your/project

# Run setup again
.\.ai-iap\setup.ps1
```

---

### "Generated files have wrong content"

**Issue**: Files generated but content seems incorrect

**Cause**: Config.json references wrong files

**Validate**:
```bash
# Run validation script
.\.ai-iap\validate.ps1  # Windows
.//ai-iap:validate      # In Claude Code

# Check for errors like:
# [FAIL] All rule files exist - Missing: dart/frameworks/bloc.md
```

**Fix**: If validation fails, check that all referenced files exist in `lib/rules/`

---

## 🔀 Git Issues

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
   - Go to: https://github.com/settings/keys
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
The setup script will **not** modify `.gitignore`.

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
For team sharing, install the `ai-iap` plugin at project scope (`--scope project`), commit `.ai-iap-custom/` and `.ai-iap-state.json`, and decide whether to also commit generated outputs (`.claude/rules/`, `CLAUDE.md`, `.claude/agents/`).

---

## 🧪 Validation Issues

### "All validation tests passed" but config seems wrong

**Issue**: Validation passes but something feels off

**Explanation**: Validation checks:
- ✅ Files exist
- ✅ JSON is valid
- ✅ Markdown has headers
- ✅ No circular dependencies

**But doesn't check**:
- ❌ Content quality
- ❌ Spelling/grammar
- ❌ Broken internal links in markdown

**Manual Check**:
```bash
# Read a few rule files
cat lib/rules/general/persona.md
cat lib/rules/typescript/architecture.md

# Generate test config
.\.ai-iap\setup.ps1
# Select: Claude Code, TypeScript, React
# Check generated .claude/rules/ files and CLAUDE.md
```

---

## 🔧 Claude Code Issues

### Claude: too many rules applying

**Issue**: Claude responses feel noisy or irrelevant, as if too many rules apply at once

**Cause**: Selecting too many languages/frameworks/structures can increase the amount of active guidance. For Claude Code rules, scoping is controlled via `paths:` frontmatter in `.claude/rules/**/*.md`.

**Fix**:
```bash
# Re-run setup with fewer frameworks/structures
.\.ai-iap\setup.ps1

# Prefer:
# - only the languages you actively edit
# - 1-2 main frameworks per language
# - one structure per framework (if needed)
```

**Tip**: Ensure `paths:` patterns match your repo layout so rules only apply to relevant files.

**Claude Code subagents**: To add or remove subagents (e.g. code-reviewer, codebase-explorer), re-run setup and choose "reuse" then when prompted "Set up Claude Code subagents?" answer yes and pick the ones you want. Generated subagent files in `.claude/agents/` are marked `aiIapManaged: true` and are removed on cleanup when you run setup in cleanup mode.

---

## 📊 Token Cost Issues

### "Token count seems high"

**Issue**: Token analysis shows >10,000 tokens for simple selection

**Investigate**:
```bash
# Run token analysis
cd lib/rules
find . -name "*.md" -exec wc -c {} + | sort -n

# Look for unusually large files (>10,000 chars)
```

**Typical File Sizes**:
- General rules: ~1,500 chars (375 tokens)
- Language rules: ~1,700 chars (425 tokens)
- Framework rules: ~2,500 chars (625 tokens)
- Structure rules: ~1,800 chars (450 tokens)

**If file is too large**: 
- Check for verbose examples
- Remove redundant explanations
- Keep examples concise

---

## 🆘 Still Having Issues?

### Validation Checklist

Run through this checklist:

```bash
# 1. Validate config
jq empty lib/config.json
echo "✓ Config is valid JSON"

# 2. Run validation tests
.\.ai-iap\validate.ps1  # Windows
.//ai-iap:validate      # In Claude Code
# Should show: Passed: 9, Failed: 0

# 3. Check dependencies (macOS/Linux only)
which jq
# Should output: /usr/bin/jq or similar

# 4. Check file structure
ls -R lib/rules/ | grep -c ".md"
# Should show: 67+ files

# 5. Test file generation
.\.ai-iap\setup.ps1
# Select: Claude Code, TypeScript, React
# Check: .claude/rules/ folder and CLAUDE.md created
```

### Get Help

If you're still stuck:

1. **Check GitHub Issues**: [github.com/HenningHuncke/ai-instructions-and-prompts/issues](.)
2. **Run validation**: `/ai-iap:validate`
3. **Review full docs**: `lib/README.md`

### Report a Bug

If you found a bug:

1. Run validation: `/ai-iap:validate`
2. Note which checks fail
3. Include your OS and Claude Code version
4. Include steps to reproduce
5. Open GitHub issue with details

---

## Additional Resources

- **Full Documentation**: `lib/README.md`
- **Customization Guide**: `CUSTOMIZATION.md`
- **Team Adoption**: `TEAM_ADOPTION_GUIDE.md`

---

<p align="center">
  <b>Still stuck? Double-check you're running from project root! 90% of issues are wrong directory.</b>
</p>

