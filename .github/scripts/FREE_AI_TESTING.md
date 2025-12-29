# Free AI Testing (No API Keys Required)

Test your rules **completely free** using local AI models with **Ollama** or **LM Studio**.

---

## 🆓 **Why Use Free Local AIs?**

- ✅ **No API keys needed** - Test without paid accounts
- ✅ **No usage costs** - Run unlimited tests
- ✅ **Privacy** - Rules never leave your machine
- ✅ **Fast iteration** - No network latency, no rate limits
- ⚠️ **Lower quality** - Results may not match GPT-4/Claude quality

---

## 🚀 **Option 1: Ollama (Recommended)**

### Installation

**Windows**:
```powershell
# Download from https://ollama.com/download
# Or use winget:
winget install Ollama.Ollama
```

**macOS**:
```bash
brew install ollama
```

**Linux**:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Pull Models

```bash
# Code-focused models (recommended for testing rules)
ollama pull codellama:13b         # 7GB - Good code quality
ollama pull deepseek-coder:6.7b   # 4GB - Fast, decent quality
ollama pull mistral:7b            # 4GB - General purpose

# Larger models (better quality, slower)
ollama pull codellama:34b         # 19GB - Best code quality
ollama pull llama3:70b            # 40GB - Excellent general purpose
```

### Run Tests

```bash
# Start Ollama (if not running)
ollama serve

# In another terminal, run tests:
cd .github/scripts
node test-ai.js \
  --provider ollama \
  --model codellama:13b \
  --test-suite critical
```

**PowerShell**:
```powershell
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

### Results

```
Testing codellama:13b (ollama) with test suite: critical

Running test: Spring Boot Service
  Score: 78/100 ✓

Running test: React Component
  Score: 82/100 ✓

Running test: ASP.NET Core Controller
  Score: 75/100 ✓

=== Summary ===
Tests: 3
Passed: 0
Failed: 3
Average Score: 78/100
Pass Rate: 0%

Results saved to: test-results/ollama-codellama-13b-1234567890.json
```

**Note**: Scores will be lower than GPT-4/Claude (78% vs 95%), but still useful for quick validation.

---

## 🚀 **Option 2: LM Studio**

### Installation

1. Download from https://lmstudio.ai/
2. Install and open LM Studio
3. Go to **"Discover"** tab
4. Download a model:
   - **DeepSeek Coder 6.7B** (recommended, ~4GB)
   - **Code Llama 13B** (~7GB)
   - **Mistral 7B** (~4GB)

### Start Server

1. In LM Studio, go to **"Local Server"** tab
2. Select your downloaded model
3. Click **"Start Server"**
4. Server starts at `http://localhost:1234`

### Run Tests

```bash
cd .github/scripts
node test-ai.js \
  --provider lmstudio \
  --model deepseek-coder-6.7b-instruct \
  --test-suite critical
```

**PowerShell**:
```powershell
node test-ai.js --provider lmstudio --model deepseek-coder-6.7b-instruct --test-suite critical
```

---

## 📊 **Model Comparison**

| Model | Size | Provider | Quality | Speed | API Key? | Cost |
|-------|------|----------|---------|-------|----------|------|
| **GPT-4 Turbo** | ☁️ Cloud | OpenAI | ⭐⭐⭐⭐⭐ | Fast | ✅ Required | $0.09/run |
| **Claude 3.5** | ☁️ Cloud | Anthropic | ⭐⭐⭐⭐⭐ | Fast | ✅ Required | $0.045/run |
| **Gemini 1.5 Pro** | ☁️ Cloud | Google | ⭐⭐⭐⭐ | Fast | ✅ Required | $0.015/run |
| **Codestral** | ☁️ Cloud | Mistral | ⭐⭐⭐⭐ | Fast | ✅ Required | $0.03/run |
| **CodeLlama 34B** | 💻 Local | Ollama | ⭐⭐⭐⭐ | Slow | ❌ No | Free |
| **CodeLlama 13B** | 💻 Local | Ollama | ⭐⭐⭐ | Medium | ❌ No | Free |
| **DeepSeek Coder 6.7B** | 💻 Local | Ollama/LM Studio | ⭐⭐⭐ | Fast | ❌ No | Free |
| **Mistral 7B** | 💻 Local | Ollama | ⭐⭐ | Fast | ❌ No | Free |

### Quality Expectations

- **GPT-4/Claude**: 92-97% average score ⭐ Gold standard
- **CodeLlama 34B**: 80-88% average score ⭐ Close to paid AIs
- **CodeLlama 13B**: 75-82% average score ⭐ Good for quick checks
- **DeepSeek Coder 6.7B**: 70-78% average score ⭐ Fast, decent
- **Mistral 7B**: 65-75% average score ⭐ Baseline

---

## 🎯 **Recommended Workflow**

### For Active Development (No API Keys)

```bash
# 1. Quick check with local model (instant, free)
node test-ai.js --provider ollama --model codellama:13b --test-suite critical

# 2. If tests pass (>75%), rules are probably good
# 3. Optionally verify with one paid API (GPT-4) before committing
```

### For Production Validation (With API Keys)

```bash
# 1. Quick local validation
node test-ai.js --provider ollama --model codellama:13b --test-suite critical

# 2. Full validation with paid APIs
node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical
node test-ai.js --provider anthropic --model claude-3-5-sonnet-20241022 --test-suite critical
```

**Cost Savings**: ~80% (only run paid tests after local validation)

---

## ⚙️ **Configuration**

### Custom Ollama URL

If Ollama is running on a different port or remote server:

```bash
export OLLAMA_BASE_URL="http://192.168.1.100:11434/v1"
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

**PowerShell**:
```powershell
$env:OLLAMA_BASE_URL="http://192.168.1.100:11434/v1"
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

### Custom LM Studio URL

```bash
export LMSTUDIO_BASE_URL="http://localhost:1234/v1"
```

---

## 🔍 **Interpreting Local AI Results**

### Good Results (Free AI)

```
Average Score: 78/100
Pass Rate: 67%
```

**Interpretation**: Rules are likely good. Local AI understood most patterns.

### Poor Results (Free AI)

```
Average Score: 45/100
Pass Rate: 0%
```

**Actions**:
1. Check if model is code-focused (use CodeLlama, not general Mistral)
2. Try larger model (13B → 34B)
3. If still failing, rules might be unclear - test with GPT-4 to confirm

---

## 💡 **Best Practices**

### 1. Use Code-Focused Models

❌ **Don't use**: `llama3`, `mistral` (general purpose)
✅ **Do use**: `codellama`, `deepseek-coder` (code-focused)

### 2. Set Lower Pass Threshold

For local models, use 70% instead of 90%:

```javascript
// In test-ai.js, change:
passed: totalScore >= 70  // Instead of 90 for local models
```

### 3. Focus on Critical Patterns

Local models are better at catching:
- ✅ Constructor injection vs field injection
- ✅ Async/await patterns
- ✅ Component structure (functional vs class)

Less reliable for:
- ⚠️ Specific annotation names
- ⚠️ DTO vs Entity detection
- ⚠️ Advanced error handling patterns

### 4. Combine Free + Paid

```bash
# 1. Develop rules with free local AI (fast iteration)
while true; do
  # Edit rules
  node test-ai.js --provider ollama --model codellama:13b --test-suite critical
  # Check score, iterate
done

# 2. Final validation with paid API (once)
node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical
```

**Result**: 90% cost savings, same final quality

---

## 🐛 **Troubleshooting**

### "Connection refused"

**Ollama**:
```bash
# Check if Ollama is running
curl http://localhost:11434/v1/models

# Start Ollama
ollama serve
```

**LM Studio**:
- Open LM Studio app
- Go to "Local Server" tab
- Click "Start Server"

### "Model not found"

```bash
# List available models
ollama list

# Pull the model if missing
ollama pull codellama:13b
```

### "Out of memory"

- Use smaller model: `codellama:7b` instead of `codellama:34b`
- Close other applications
- Increase system swap/virtual memory

### Score is very low (<50%)

- Model might not be code-focused - try `codellama` or `deepseek-coder`
- Model might be too small - try 13B instead of 7B
- Rules might be unclear - test with GPT-4 to confirm

---

## 📈 **Success Stories**

### Developer Workflow

**Before** (Paid APIs only):
- Edit rules → Wait for GitHub Actions (5 min) → See results → Iterate
- Cost: $0.20 per iteration × 10 iterations = **$2.00**
- Time: 50 minutes total

**After** (Local AI + Paid):
- Edit rules → Test locally (30 sec) → See results → Iterate (9x local)
- Final validation with GPT-4 (1x paid)
- Cost: Free × 9 + $0.09 × 1 = **$0.09**
- Time: 10 minutes total

**Savings**: 95% cost, 80% time

---

## 📚 **Resources**

- **Ollama**: https://ollama.com/
- **LM Studio**: https://lmstudio.ai/
- **Model Library**: https://ollama.com/library
- **OpenAI-Compatible API**: https://github.com/ollama/ollama/blob/main/docs/openai.md

---

## 🎓 **Next Steps**

1. **Install Ollama**:
   ```bash
   # macOS
   brew install ollama
   
   # Windows
   winget install Ollama.Ollama
   ```

2. **Pull a model**:
   ```bash
   ollama pull codellama:13b
   ```

3. **Run your first free test**:
   ```bash
   cd .github/scripts
   node test-ai.js --provider ollama --model codellama:13b --test-suite critical
   ```

4. **Compare with paid API** (optional):
   ```bash
   node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical
   ```

---

**No API keys? No problem. Test for free!** 🎉

