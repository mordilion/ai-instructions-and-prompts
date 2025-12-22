# GitHub Actions Testing Guide
## Automated Cross-AI Compatibility Testing

---

## 📋 Overview

This testing system automatically validates that your AI instruction rules produce consistent, high-quality code across all major AI models (GPT-4, Claude, Gemini, Codestral).

**Key Features**:
- ✅ Automated testing on every rule change
- ✅ Tests 4+ AI models simultaneously
- ✅ Validates 5 critical code generation scenarios
- ✅ Generates detailed comparison reports
- ✅ Fails CI if quality drops below 90%
- ✅ Daily monitoring for consistency

---

## 🚀 Quick Start

### Step 1: Add API Keys to GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

| Secret Name | Description | Required | Get It From |
|-------------|-------------|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key | ✅ Yes | [platform.openai.com](https://platform.openai.com/api-keys) |
| `ANTHROPIC_API_KEY` | Anthropic/Claude API key | ✅ Yes | [console.anthropic.com](https://console.anthropic.com/) |
| `GOOGLE_API_KEY` | Google Gemini API key | Optional | [makersuite.google.com](https://makersuite.google.com/app/apikey) |
| `MISTRAL_API_KEY` | Mistral/Codestral API key | Optional | [console.mistral.ai](https://console.mistral.ai/) |
| `SLACK_WEBHOOK_URL` | Slack notifications | Optional | Slack Workspace Settings |

**Minimum**: You need at least `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` for GPT-4 and Claude tests.

### Step 2: Enable GitHub Actions

1. Go to repository → Actions
2. Enable workflows if disabled
3. Tests will run automatically on:
   - Every push to `main` or `develop`
   - Every pull request
   - Daily at 2 AM UTC
   - Manual trigger (workflow_dispatch)

### Step 3: Run Your First Test

**Option A: Make a change to trigger tests**
```bash
# Edit any rule file
vim .ai-iap/rules/typescript/frameworks/react.md

# Commit and push
git add .ai-iap/rules/
git commit -m "test: trigger AI compatibility tests"
git push
```

**Option B: Manual trigger**
1. Go to Actions → AI Compatibility Tests
2. Click "Run workflow"
3. Select test suite (default: critical)
4. Click "Run workflow"

### Step 4: View Results

1. Go to Actions → Latest workflow run
2. Click on "Analyze Test Results"
3. View summary in job output or download artifacts

---

## 📊 Test Suites

### Critical (Default)
Tests the most important patterns that affect 80% of code:
- ✅ Spring Boot Service (constructor injection, DTOs, transactions)
- ✅ React Component (functional components, useEffect deps, hooks)
- ✅ ASP.NET Core Controller (DI, DTOs, async/await)

**Runtime**: ~5 minutes per AI model

### All Tests
Runs complete test suite:
- All critical tests
- FastAPI endpoint validation
- Next.js Server Component patterns

**Runtime**: ~8 minutes per AI model

### Individual Test Suites
- `spring-boot`: Only Spring Boot tests
- `react`: Only React tests
- `aspnet`: Only ASP.NET tests
- `fastapi`: Only FastAPI tests
- `nextjs`: Only Next.js tests

---

## 📈 Understanding Results

### Test Scores

Each test generates a score from 0-100:

| Score Range | Status | Meaning |
|-------------|--------|---------|
| 95-100 | ✅ Excellent | Perfect or near-perfect adherence to rules |
| 90-94 | ⚠️ Good | Minor issues, acceptable quality |
| 80-89 | ⚠️ Fair | Several issues, needs improvement |
| <80 | ❌ Poor | Major issues, AI not following rules |

**Threshold**: Tests fail if average score < 90 or pass rate < 90%

### Pattern Matching

Tests validate two types of patterns:

**Expected Patterns** (70% of score):
- Patterns that MUST be present in generated code
- Example: `@RequiredArgsConstructor`, `useState`, `async/await`

**Forbidden Patterns** (30% of score):
- Anti-patterns that MUST NOT appear
- Example: `@Autowired` on fields, class components, entity exposure

### Example Results

```
=== Spring Boot Service Test ===

GPT-4: 100/100 ✅
  Expected: @Service, @RequiredArgsConstructor, UserDto - all found ✓
  Forbidden: @Autowired, entity exposure - none found ✓

Gemini: 85/100 ⚠️
  Expected: All found except @Transactional ✗
  Forbidden: Found @Autowired on field ✗

Codestral: 75/100 ❌
  Expected: Missing UserDto (returned User entity) ✗
  Forbidden: Found entity exposure ✗

Action: Add explicit "NEVER return entity" directive to spring-boot.md
```

---

## 📁 Artifacts & Reports

Each test run generates:

### 1. Individual Test Results (JSON)
- `gpt4-test-results/`: GPT-4 detailed results
- `claude-test-results/`: Claude detailed results
- `gemini-test-results/`: Gemini detailed results
- `codestral-test-results/`: Codestral detailed results

**Location**: Workflow run → Artifacts

**Format**:
```json
{
  "model": "gpt-4-turbo-preview",
  "provider": "openai",
  "averageScore": 98,
  "passRate": 100,
  "tests": [
    {
      "testId": "test-1-spring-boot",
      "score": 100,
      "passed": true,
      "output": "...",
      "validation": {
        "expectedMatches": ["@Service", "..."],
        "forbiddenFound": []
      }
    }
  ]
}
```

### 2. Summary Report (Markdown)
- `test-summary/summary.md`: Overall summary
- Shows scores by model
- Shows scores by test
- Recommendations for improvements

**Location**: Workflow run → Job summary or artifacts

**Example**:
```markdown
## Overall Summary
- Models Tested: GPT-4, Claude 3.5, Gemini Pro
- Average Score: 94/100
- Average Pass Rate: 95%

✅ Status: EXCELLENT

## Results by AI Model
| Model | Score | Pass Rate | Status |
|-------|-------|-----------|--------|
| GPT-4 | 100/100 | 100% | ✅ |
| Claude | 98/100 | 100% | ✅ |
| Gemini | 85/100 | 85% | ⚠️ |
```

### 3. Comparison Report (Markdown)
- `test-summary/comparison.md`: Detailed comparison
- Side-by-side results for each test
- Shows which models struggled with which patterns

---

## 🔧 Configuration

### Changing Test Thresholds

Edit `.github/scripts/check-thresholds.py`:
```python
# Default minimum score: 90
parser.add_argument('--min-score', type=int, default=90)

# Change to 95 for stricter validation:
parser.add_argument('--min-score', type=int, default=95)
```

### Adding New Tests

Edit `.github/scripts/test-ai.js`:

```javascript
const testDefinitions = {
  'your-test': {
    id: 'test-6-your-test',
    name: 'Your Test Name',
    language: 'typescript',
    framework: 'your-framework',
    prompt: `Your test prompt here`,
    expectedPatterns: [
      'pattern1',
      'pattern2'
    ],
    forbiddenPatterns: [
      'antipattern1'
    ],
    rules: [
      'rules/general/persona.md',
      'rules/your-language/architecture.md',
      'rules/your-language/frameworks/your-framework.md'
    ]
  }
};

// Add to test suite
const testSuites = {
  all: [..., 'your-test'],
  'your-test': ['your-test']
};
```

### Customizing Schedule

Edit `.github/workflows/ai-compatibility-tests.yml`:

```yaml
on:
  schedule:
    # Change from daily at 2 AM to twice daily
    - cron: '0 2,14 * * *'  # 2 AM and 2 PM UTC
```

---

## 🐛 Troubleshooting

### Tests Not Running

**Problem**: Workflow not triggering on push

**Solution**:
1. Check workflow is enabled: Actions → Workflows → Enable
2. Verify file paths in `on.push.paths` match your changes
3. Check branch names match (`main` vs `master`)

### API Key Errors

**Problem**: `Error: Invalid API key`

**Solution**:
1. Verify secret name matches exactly (case-sensitive)
2. Check API key is valid and has credits
3. Test key locally: `curl https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY"`

### Low Test Scores

**Problem**: Tests suddenly failing after rule changes

**Solution**:
1. Download test artifacts to see exact AI outputs
2. Compare against expected patterns
3. Check if your rule changes conflicted with other rules
4. Review `CROSS_AI_COMPATIBILITY_GUIDE.md` for fixes
5. Add more explicit ALWAYS/NEVER directives

### Missing Dependencies

**Problem**: `Cannot find module 'openai'`

**Solution**:
```bash
cd .github/scripts
npm install
```

---

## 📊 Continuous Monitoring

### Daily Reports

Tests run daily at 2 AM UTC and report:
- ✅ Pass: No action needed
- ⚠️ Warning: Review artifacts, monitor trends
- ❌ Fail: Immediate investigation required

### Slack Notifications

If `SLACK_WEBHOOK_URL` is configured:
- Get notified of test completion
- Click link to view detailed results
- Set up custom alerts for failures

### Trend Analysis

Monitor these metrics over time:
- **Average Score Trend**: Should stay above 95
- **Pass Rate Trend**: Should stay at 100%
- **Model Consistency**: Scores should be similar across models

**Red flags**:
- Declining scores over time
- Increasing gap between models
- New failures after rule updates

---

## 🎯 Best Practices

### 1. Test Before Merging

Always check CI results before merging PRs:
```bash
# Create PR
git checkout -b feature/improve-rules
git push origin feature/improve-rules

# Wait for tests to complete
# Review test summary in PR comments
# Only merge if tests pass
```

### 2. Iterate on Failures

If tests fail:
1. **Don't ignore**: Investigate immediately
2. **Find root cause**: Which pattern is missing/wrong?
3. **Fix explicitly**: Add NEVER directive if AI used forbidden pattern
4. **Re-test**: Push fix and verify tests pass
5. **Document**: Add to "Common AI Mistakes" section

### 3. Validate Locally First

Before pushing rule changes, test locally:
```bash
cd .github/scripts
npm install

# Test with your API key
export OPENAI_API_KEY="sk-..."
node test-ai.js --model gpt-4-turbo-preview --provider openai --test-suite critical

# Check score
cat test-results/*.json | jq '.averageScore'
```

### 4. Monitor Daily Runs

Check daily test results weekly:
- Look for trends
- Catch regressions early
- Validate no API changes broke tests

---

## 🔒 Security

### API Key Safety

- ✅ **DO**: Use GitHub Secrets
- ✅ **DO**: Rotate keys periodically
- ✅ **DO**: Use separate keys for CI vs production
- ❌ **DON'T**: Commit keys to repository
- ❌ **DON'T**: Print keys in logs
- ❌ **DON'T**: Share keys between repos

### Cost Management

Tests consume API credits:

**Estimated costs per run**:
- GPT-4: ~$0.10 per test run (5 prompts × ~500 tokens each)
- Claude: ~$0.05 per test run
- Gemini: ~$0.01 per test run (cheaper)
- **Total**: ~$0.20-0.30 per complete test run

**With daily runs**:
- ~$6-9 per month for continuous monitoring

**Cost optimization**:
- Use `critical` suite by default (3 tests instead of 5)
- Run `all` tests only on main branch
- Use workflow_dispatch for manual testing
- Set up billing alerts

---

## 📚 Related Documentation

- **Setup**: This file (you're reading it!)
- **Test Definitions**: `.ai-iap/TEST_PROMPTS.md`
- **Improvement Guide**: `PRIORITY_ACTIONS.md`
- **Technical Details**: `CROSS_AI_COMPATIBILITY_GUIDE.md`
- **Full Analysis**: `EXPERT_ANALYSIS.md`

---

## 🎉 Success Criteria

Your testing system is working well when:

✅ All tests pass with 95%+ average score  
✅ All AI models score within 5% of each other  
✅ No failed tests in last 7 days  
✅ New rule changes don't break existing tests  
✅ PRs include test results before merging  

---

## 🆘 Getting Help

### Issues with Tests

1. Check workflow logs
2. Download and review test artifacts
3. Compare against expected patterns in `TEST_PROMPTS.md`
4. Review related rules files

### Issues with AI Models

1. Verify API keys are valid
2. Check API service status
3. Review API rate limits
4. Test key locally

### Issues with Results

1. Review analysis scripts output
2. Check Python dependencies installed
3. Verify JSON results are valid
4. Check file permissions

---

## ✅ Checklist: First Time Setup

- [ ] Added `OPENAI_API_KEY` secret
- [ ] Added `ANTHROPIC_API_KEY` secret
- [ ] Added optional Google/Mistral keys (if using)
- [ ] Enabled GitHub Actions
- [ ] Triggered first manual test run
- [ ] Verified tests complete successfully
- [ ] Reviewed test summary report
- [ ] Downloaded and examined artifacts
- [ ] Set up Slack notifications (optional)
- [ ] Configured branch protections to require tests

---

**Ready to start testing? Go to Actions → Run workflow! 🚀**


