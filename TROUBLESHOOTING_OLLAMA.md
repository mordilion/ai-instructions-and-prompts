# Troubleshooting Ollama Connection Error

You're seeing: `Error calling ollama: Connection error.`

This means Ollama is not running or not installed. Here's how to fix it:

---

## ✅ **Solution (Step-by-Step)**

### 1. Check if Ollama is Installed

```powershell
ollama --version
```

**If you see a version number** → Ollama is installed, go to step 3  
**If you see an error** → Ollama is not installed, continue to step 2

---

### 2. Install Ollama (If Not Installed)

**Windows (PowerShell)**:
```powershell
winget install Ollama.Ollama
```

**Or download manually**: https://ollama.com/download

**macOS**:
```bash
brew install ollama
```

**Linux**:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

---

### 3. Start Ollama

**Option A: Auto-start (Recommended)**
```powershell
ollama pull codellama:13b
```
This will automatically start Ollama and download the model.

**Option B: Manual start**
```powershell
# In one terminal:
ollama serve

# In another terminal:
ollama pull codellama:13b
```

---

### 4. Verify Ollama is Running

```powershell
# Check if Ollama is responding
curl http://localhost:11434/v1/models

# Or check the process
Get-Process ollama
```

**Expected output**: JSON response with model list or process info

---

### 5. Re-run the Test

```powershell
cd .github/scripts
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

**Expected output**:
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
Passed: 2
Failed: 1
Average Score: 78/100
Pass Rate: 67%
```

---

## 🔍 **Common Issues**

### Issue 1: "ollama: command not found"

**Cause**: Ollama is not installed or not in PATH

**Fix**:
```powershell
# Reinstall Ollama
winget install Ollama.Ollama

# Restart PowerShell
exit
# Open new PowerShell window
```

---

### Issue 2: "Connection refused" or "Connection error"

**Cause**: Ollama service is not running

**Fix**:
```powershell
# Start Ollama
ollama serve

# Or just run any ollama command to auto-start
ollama list
```

---

### Issue 3: "Model not found"

**Cause**: Model hasn't been downloaded

**Fix**:
```powershell
# Download the model (7GB, takes 5-10 minutes)
ollama pull codellama:13b

# Verify it's downloaded
ollama list
```

**Expected output**:
```
NAME              ID              SIZE      MODIFIED
codellama:13b     abc123def456    7.0 GB    2 minutes ago
```

---

### Issue 4: Port 11434 is in use

**Cause**: Another process is using port 11434

**Fix**:
```powershell
# Find what's using the port
netstat -ano | findstr :11434

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Restart Ollama
ollama serve
```

---

### Issue 5: Firewall blocking Ollama

**Cause**: Windows Firewall is blocking localhost connections

**Fix**:
```powershell
# Allow Ollama through firewall
New-NetFirewallRule -DisplayName "Ollama" -Direction Inbound -Program "C:\Users\<YourUsername>\AppData\Local\Programs\Ollama\ollama.exe" -Action Allow
```

---

## 🎯 **Quick Test**

After fixing, verify everything works:

```powershell
# 1. Check Ollama is running
ollama list

# 2. Test with a simple prompt
ollama run codellama:13b "Write a hello world in Java"

# 3. If that works, run the full test
cd .github/scripts
node test-ai.js --provider ollama --model codellama:13b --test-suite critical
```

---

## 💡 **Alternative: Use Paid API (No Setup)**

If Ollama setup is too complex, you can use a paid API instead:

```powershell
# Set API key
$env:OPENAI_API_KEY="sk-..."

# Run test (costs $0.09)
cd .github/scripts
node test-ai.js --provider openai --model gpt-4-turbo-preview --test-suite critical
```

**Cost**: $0.09 per test (vs free with Ollama)  
**Quality**: 95% (vs 78% with Ollama)  
**Setup**: Just need API key

---

## 📚 **Resources**

- **Ollama Installation**: https://ollama.com/download
- **Ollama Models**: https://ollama.com/library
- **Full Free Testing Guide**: `.github/scripts/FREE_AI_TESTING.md`
- **Quick Start**: `FREE_TESTING_QUICK_START.txt`

---

## ✅ **Success Checklist**

- [ ] Ollama installed (`ollama --version` works)
- [ ] Ollama running (`ollama list` works)
- [ ] Model downloaded (`codellama:13b` appears in `ollama list`)
- [ ] Connection works (`curl http://localhost:11434/v1/models` returns JSON)
- [ ] Test runs successfully (no "Connection error")

---

**Still having issues?** Check the full guide: `.github/scripts/FREE_AI_TESTING.md`

