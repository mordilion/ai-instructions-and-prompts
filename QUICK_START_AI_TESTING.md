# 🚀 Quick Start: AI Compatibility Testing

Test your rules against GPT-4, Claude, Gemini, and Codestral to ensure consistent code quality.

---

## ⚡ **4 Ways to Run Tests**

### 0️⃣ **Free Local AI** (No API Keys!) ⭐ NEW

```bash
# Install Ollama (one-time)
# macOS: brew install ollama
# Windows: winget install Ollama.Ollama
ollama pull codellama:13b

# Run tests (completely free)
cd .github/scripts
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

**Cost**: $0 (completely free)  
**Quality**: 75-82% score (vs 95% for GPT-4)  
**Speed**: 30-60 seconds

📖 **Full Guide**: `.github/scripts/FREE_AI_TESTING.md`

---

### 1️⃣ **Local Testing** (With API Keys)

```bash
# Install dependencies
cd .github/scripts
npm install

# Test with GPT-4 (requires OPENAI_API_KEY)
export OPENAI_API_KEY="sk-..."
node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical

# Test with Claude (requires ANTHROPIC_API_KEY)
export ANTHROPIC_API_KEY="sk-ant-..."
node test-ai.js --provider anthropic --model claude-3-5-sonnet-20241022 --test-suite critical

# Test with Gemini (requires GOOGLE_API_KEY)
export GOOGLE_API_KEY="..."
node test-ai.js --provider google --model gemini-1.5-pro --test-suite critical

# Test with Codestral (requires MISTRAL_API_KEY)
export MISTRAL_API_KEY="..."
node test-ai.js --provider mistral --model codestral-latest --test-suite critical
```

**Results**: Check `test-results/` directory for JSON reports

---

### 2️⃣ **GitHub Actions** (Automated)

#### Setup (One-Time)

1. Go to **GitHub Repository Settings** → **Secrets and Variables** → **Actions**
2. Add secrets:
   - `OPENAI_API_KEY` (for GPT-4)
   - `ANTHROPIC_API_KEY` (for Claude)
   - `GOOGLE_API_KEY` (for Gemini)
   - `MISTRAL_API_KEY` (for Codestral)

#### Trigger Tests

**Option A: Manual Run**
1. Go to **Actions** tab
2. Select **"AI Compatibility Tests"** workflow
3. Click **"Run workflow"**
4. Select:
   - Test suite: `critical` (3 tests, faster) or `all` (5 tests)
   - Models: `gpt4,claude,gemini,codestral` (or subset)
5. Click **"Run workflow"**

**Option B: Automatic** (Weekly Schedule)
- Runs every Sunday at 00:00 UTC
- Tests all configured models with critical suite
- No action needed

**Option C: On Rule Changes**
- Automatically runs when files in `.ai-iap/rules/` or `.ai-iap/processes/` change
- Triggered on push to `main` branch

---

### 3️⃣ **Compare Results Across AIs**

After running tests for multiple AIs:

```bash
cd .github/scripts
node analyze-results.js ./test-results
```

**Output**: `analysis-report.md` with:
- Cross-AI consistency analysis
- Model performance comparison
- Variance warnings
- Actionable recommendations

---

## 📊 **What Gets Tested?**

### Critical Suite (3 tests) ⭐ Recommended

| Test | Language | Framework | What It Checks |
|------|----------|-----------|----------------|
| **Spring Boot Service** | Java | Spring Boot | Constructor injection, `@Transactional`, DTOs, error handling |
| **React Component** | TypeScript | React | Functional components, hooks, dependency arrays, loading states |
| **ASP.NET Controller** | C# | ASP.NET Core | `[ApiController]`, async/await, DTOs, proper HTTP status codes |

**Runtime**: ~30-60 seconds per AI
**Cost**: ~$0.20 per run (all 4 AIs)

### All Suite (5 tests)

Adds:
- **FastAPI Endpoint** (Python): Pydantic models, async functions, response models
- **Next.js Page** (TypeScript): Server Components, async data fetching, no client hooks

**Runtime**: ~60-90 seconds per AI
**Cost**: ~$0.35 per run (all 4 AIs)

---

## 📈 **Understanding Results**

### ✅ **Good Results** (Pass)

```
Tests: 3
Passed: 3
Failed: 0
Average Score: 95/100
Pass Rate: 100%
```

**Interpretation**: Rules are working! AI generates consistent, high-quality code.

---

### ⚠️ **Mixed Results**

```
Tests: 3
Passed: 2
Failed: 1
Average Score: 87/100
Pass Rate: 67%
```

**Actions**:
1. Check `test-results/*.json` for details
2. Look at `expectedMissing` → AI didn't follow a rule
3. Look at `forbiddenFound` → AI used an anti-pattern
4. Strengthen rules in `.ai-iap/rules/` with more `> **ALWAYS**` / `> **NEVER**`

---

### ❌ **Poor Results** (Fail)

```
Tests: 3
Passed: 1
Failed: 2
Average Score: 62/100
Pass Rate: 33%
```

**Actions**:
1. Rules may be unclear or conflicting
2. Review failed tests in detail
3. Run manual test with verbose output:
   ```bash
   node test-ai.js --provider openai --model gpt-4 --test-suite spring-boot | tee debug.log
   ```
4. Iterate on rules based on what patterns are missing

---

## 💰 **Cost Estimates**

### Per Test Run

| Provider | Model | Critical Suite (3 tests) | All Suite (5 tests) |
|----------|-------|--------------------------|---------------------|
| **OpenAI** | GPT-4 Turbo | ~$0.09 | ~$0.15 |
| **Anthropic** | Claude 3.5 Sonnet | ~$0.045 | ~$0.075 |
| **Google** | Gemini 1.5 Pro | ~$0.015 | ~$0.025 |
| **Mistral** | Codestral | ~$0.03 | ~$0.05 |

### Monthly Budget

| Strategy | Frequency | Suite | Cost/Month |
|----------|-----------|-------|------------|
| **Minimal** | Weekly (4x), GPT-4 only | Critical | ~$0.36 |
| **Balanced** | Weekly (4x), All 4 AIs | Critical | ~$0.80 |
| **Comprehensive** | Weekly (4x), All 4 AIs | All | ~$1.40 |
| **Intensive** | Per-commit (40x), All 4 AIs | Critical | ~$8.00 |

**Recommendation**: Weekly with critical suite (~$0.80/month)

---

## 🎯 **Success Metrics**

Your goal (from `.cursor/rules/general.mdc`):
> "All rules and processes **MUST** be understandable the same way for all AI's - The goal is to have the same result no matter which AI is used"

### Targets

- ✅ **Pass Rate**: ≥90% (at least 9 out of 10 tests pass)
- ✅ **Average Score**: ≥92/100
- ✅ **Cross-AI Variance**: ≤10 points (all AIs within 10 points of each other)

### Example: Meeting Criteria ✅

```
GPT-4 Turbo:      95/100
Claude 3.5:       93/100
Gemini 1.5 Pro:   92/100
Codestral:        90/100

Average: 92.5/100
Variance: 5 points
Status: ✅ PASS
```

---

## 🔧 **Troubleshooting**

### "API key not found"

```bash
# Windows (PowerShell)
$env:OPENAI_API_KEY="sk-..."

# macOS / Linux
export OPENAI_API_KEY="sk-..."
```

### "Rule file not found"

Make sure you're running from project root:
```bash
cd /path/to/ai-instructions-and-prompts
node .github/scripts/test-ai.js ...
```

### "Score lower than expected"

1. Check detailed results:
   ```bash
   cat test-results/*.json | jq '.tests[] | select(.score < 90)'
   ```

2. Identify missing patterns and strengthen rules

3. Test again to verify improvement

### "GitHub Actions workflow not running"

1. Check if API key secrets are set (Settings → Secrets)
2. Verify workflow file syntax in GitHub Actions tab
3. Check if cost limits are reached (billing)

---

## 📚 **Next Steps**

1. **Run your first FREE test** (no API key):
   ```bash
   # Install Ollama: https://ollama.com/
   ollama pull codellama:13b
   
   cd .github/scripts
   npm install
   node test-ai.js --provider ollama --model codellama:13b --test-suite critical
   ```

2. **Or run with paid API** (better quality):
   ```bash
   cd .github/scripts
   npm install
   export OPENAI_API_KEY="sk-..."
   node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical
   ```

2. **Review results**:
   ```bash
   cat test-results/*.json | jq '.'
   ```

3. **Set up GitHub Actions**:
   - Add API keys to GitHub Secrets
   - Trigger manual workflow run

4. **Expand test suite**:
   - Read `.github/scripts/EXPANDING_TESTS.md`
   - Add 10 more tests from `TEST_PROMPTS.md`

5. **Iterate on rules**:
   - Fix any failing tests by strengthening rules
   - Re-run tests to verify improvements

---

## 📖 **Documentation**

- **Full Testing Guide**: `.github/scripts/README.md`
- **Expand Tests**: `.github/scripts/EXPANDING_TESTS.md`
- **Test Definitions**: `.ai-iap/TEST_PROMPTS.md` (15 manual tests)
- **Rules Source**: `.ai-iap/rules/`

---

## 🎉 **Success!**

When all tests pass with ≥90% score across all AIs, you've achieved your goal:

> **"Same Result"** - Consistent, high-quality code across GPT-4, Claude, Gemini, and Codestral

Your rules are production-ready! 🚀

