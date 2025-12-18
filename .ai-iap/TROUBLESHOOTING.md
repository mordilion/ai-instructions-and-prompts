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
./.ai-iap/setup.sh   # macOS/Linux
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

### "Permission denied" when running setup.sh

**Error**:
```bash
-bash: ./.ai-iap/setup.sh: Permission denied
```

**Cause**: Script is not executable

**Fix**:
```bash
# Make script executable
chmod +x .ai-iap/setup.sh

# Then run it
./.ai-iap/setup.sh
```

---

### "General rules missing in Cursor output"

**Error**: Generated `.cursor/rules/` folder doesn't contain general rules

**Cause**: This was a bug in early versions (fixed in v1.0.0)

**Fix**:
```bash
# Pull latest version
git pull origin main

# Re-run setup
.\.ai-iap\setup.ps1
```

**Status**: ✅ Fixed in current version (general rules have `alwaysApply: true`)

---

### "No frameworks showing for my language"

**Issue**: Selected a language but no frameworks appear

**Cause 1**: Language has no frameworks defined

**Check**:
```bash
# View config.json
cat .ai-iap/config.json | grep -A 10 "\"yourlanguage\""

# Check if "frameworks" key exists
```

**Cause 2**: JSON parsing error

**Fix**:
```bash
# Validate config.json
jq empty .ai-iap/config.json

# If error, check for:
# - Missing commas
# - Extra commas
# - Mismatched quotes
```

---

## 📁 File Generation Issues

### "No files generated in .cursor folder"

**Issue**: Setup completes but no files created

**Cause**: Script didn't have write permissions or wrong directory

**Check**:
```bash
# Verify you're in project root
pwd

# Check if .cursor folder was created
ls -la .cursor/

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
./.ai-iap/validate.sh   # macOS/Linux

# Check for errors like:
# [FAIL] All rule files exist - Missing: dart/frameworks/bloc.md
```

**Fix**: If validation fails, check that all referenced files exist in `.ai-iap/rules/`

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

**Cause**: Files are in `.gitignore`

**Check**:
```bash
git status --ignored

# Look for:
# Ignored files:
#   .cursor/
#   CLAUDE.md
```

**Fix** (if you want to commit generated files):
```bash
# Option 1: Remove from .gitignore
nano .gitignore
# Delete or comment out the lines for generated files

# Option 2: Force add specific files
git add -f .cursor/rules/*.mdc
git commit -m "Add generated AI configs"
```

**Recommendation**: See README for git strategy options (share generated files vs share source)

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
cat .ai-iap/rules/general/persona.md
cat .ai-iap/rules/typescript/architecture.md

# Generate test config
.\.ai-iap\setup.ps1
# Select: Cursor, TypeScript, React
# Check generated .cursor/rules/ files
```

---

## 🔧 Tool-Specific Issues

### Cursor: Rules not being applied

**Issue**: Generated `.cursor/rules/*.mdc` but AI not following them

**Cause 1**: Cursor needs to index the rules

**Fix**: Restart Cursor or reload window

**Cause 2**: Rules files have syntax errors

**Check**:
```bash
# Validate frontmatter
head -5 .cursor/rules/general-persona.mdc

# Should start with:
# ---
# globs:
#   - "**/*"
# ---
```

**Cause 3**: File globs don't match your files

**Example**:
```yaml
# If rule has:
globs:
  - "*.ts"

# But your files are .js
# Then rule won't apply
```

**Fix**: Check glob patterns match your file types

---

### Claude CLI: CLAUDE.md too large

**Issue**: CLAUDE.md generated but Claude says it's too large

**Cause**: Selected too many frameworks (>50,000 tokens)

**Check**:
```bash
# Count tokens (rough estimate)
wc -c CLAUDE.md | awk '{print $1/4}'
# If >50,000, it's too large
```

**Fix**:
```bash
# Re-run setup with fewer frameworks
.\.ai-iap\setup.ps1

# Select only what you need:
# - Core language
# - 1-2 main frameworks
# - 1 structure template
```

**See**: README.md "Token Cost Analysis" for typical selections

---

### GitHub Copilot: Instructions not being followed

**Issue**: Generated `.github/copilot-instructions.md` but Copilot ignores it

**Cause 1**: File must be in `.github/` at repo root

**Check**:
```bash
ls .github/copilot-instructions.md
# Should exist
```

**Cause 2**: Copilot needs time to index

**Fix**: Wait 5-10 minutes, then try again

**Cause 3**: File too large (>100KB)

**Check**:
```bash
du -h .github/copilot-instructions.md
# Should be <100KB
```

---

## 📊 Token Cost Issues

### "Token count seems high"

**Issue**: Token analysis shows >10,000 tokens for simple selection

**Investigate**:
```bash
# Run token analysis
cd .ai-iap/rules
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
jq empty .ai-iap/config.json
echo "✓ Config is valid JSON"

# 2. Run validation tests
.\.ai-iap\validate.ps1  # Windows
./.ai-iap/validate.sh   # macOS/Linux
# Should show: Passed: 9, Failed: 0

# 3. Check dependencies (macOS/Linux only)
which jq
# Should output: /usr/bin/jq or similar

# 4. Check file structure
ls -R .ai-iap/rules/ | grep -c ".md"
# Should show: 67+ files

# 5. Test file generation
.\.ai-iap\setup.ps1
# Select: Cursor, TypeScript, React
# Check: .cursor/rules/ folder created
```

### Get Help

If you're still stuck:

1. **Check GitHub Issues**: [github.com/yourusername/ai-instructions-and-prompts/issues](.)
2. **Review Expert Analysis**: `.ai-iap/EXPERT_ANALYSIS.md`
3. **Check Implementation Summary**: `.ai-iap/IMPLEMENTATION_SUMMARY.md`
4. **Review Dependency Guide**: `.ai-iap/DEPENDENCY_GRAPH_GUIDE.md`

### Report a Bug

If you found a bug:

1. Run validation: `.\.ai-iap\validate.ps1`
2. Note which tests fail
3. Include your OS, PowerShell/Bash version
4. Include steps to reproduce
5. Open GitHub issue with details

---

## 📚 Additional Resources

- **README**: `.ai-iap/README.md` - Full documentation
- **Expert Analysis**: `.ai-iap/EXPERT_ANALYSIS.md` - Comprehensive review
- **Remaining Improvements**: `.ai-iap/REMAINING_IMPROVEMENTS.md` - Future enhancements
- **Dependency Graph**: `.ai-iap/DEPENDENCY_GRAPH_GUIDE.md` - Framework dependencies

---

<p align="center">
  <b>Still stuck? Double-check you're running from project root! 90% of issues are wrong directory.</b>
</p>

