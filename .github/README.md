# GitHub Actions - AI Compatibility Testing

Automated testing system to ensure consistent code quality across all major AI models.

## 📁 Structure

```
.github/
├── workflows/
│   └── ai-compatibility-tests.yml    # Main GitHub Actions workflow
├── scripts/
│   ├── test-ai.js                    # Test runner (calls AI APIs)
│   ├── analyze-results.py            # Results analysis
│   ├── generate-report.py            # Comparison reports
│   ├── check-thresholds.py           # Quality validation
│   └── package.json                  # Node dependencies
├── TESTING_GUIDE.md                  # Complete setup guide
└── README.md                         # This file
```

## 🚀 Quick Start

### 1. Add API Keys

Go to **Settings → Secrets → New repository secret**:

- `OPENAI_API_KEY` - Required for GPT-4
- `ANTHROPIC_API_KEY` - Required for Claude
- `GOOGLE_API_KEY` - Optional for Gemini
- `MISTRAL_API_KEY` - Optional for Codestral

### 2. Run Tests

**Automatic**: Push to `main` or create a PR  
**Manual**: Actions → AI Compatibility Tests → Run workflow

### 3. View Results

Actions → Latest run → Download artifacts or view summary

## 📊 What Gets Tested

- ✅ **Spring Boot**: Constructor injection, DTOs, transactions
- ✅ **React**: Functional components, useEffect deps, hooks
- ✅ **ASP.NET Core**: DI patterns, DTOs, async/await
- ✅ **FastAPI**: Async patterns, Pydantic models
- ✅ **Next.js**: Server vs Client Components

## 📈 Success Criteria

Tests pass when:
- ✅ Average score ≥ 90/100
- ✅ Pass rate ≥ 90%
- ✅ All models within 10% of each other

## 📖 Documentation

- **Full Guide**: [TESTING_GUIDE.md](TESTING_GUIDE.md)
- **Test Definitions**: [../.ai-iap/TEST_PROMPTS.md](../.ai-iap/TEST_PROMPTS.md)
- **Improvement Strategies**: [../PRIORITY_ACTIONS.md](../PRIORITY_ACTIONS.md)

## 🔧 Local Testing

```bash
cd .github/scripts
npm install

export OPENAI_API_KEY="sk-..."
node test-ai.js --model gpt-4-turbo-preview --provider openai --test-suite critical
```

## 💡 Troubleshooting

**Tests not running?**
- Check GitHub Actions are enabled
- Verify API keys are set correctly

**Tests failing?**
- Download artifacts to see AI outputs
- Compare against expected patterns
- Review TESTING_GUIDE.md

## 📞 Need Help?

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive documentation.


