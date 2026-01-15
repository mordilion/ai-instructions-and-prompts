# Custom AI Instructions & Prompts

This directory allows you to extend or override the core `.ai-iap/` configuration without modifying core files. This ensures you can safely pull updates from the main repository without losing your customizations.

## 📁 Directory Structure

```
.ai-iap-custom/
├── README.md                   # This file
├── config.json                 # Custom configuration (extends core)
├── rules/                      # Custom or override rules
│   └── typescript/
│       └── company-standards.md
└── processes/                  # Custom processes
    └── typescript/
        └── deploy-internal.md
```

## 🎯 Usage

### **1. Add Custom Rules**

Create new rule files that will be included alongside core rules:

```json
// config.json
{
  "languages": {
    "typescript": {
      "customFiles": ["company-standards"]
    }
  }
}
```

Then create: `.ai-iap-custom/rules/typescript/company-standards.md`

### **2. Override Core Rules**

Replace a core rule file by creating a file with the same path:

- Core: `.ai-iap/rules/typescript/code-style.md`
- Override: `.ai-iap-custom/rules/typescript/code-style.md` ✅ (this wins)

### **3. Add Custom Processes**

```json
{
  "languages": {
    "typescript": {
      "customProcesses": {
        "deploy-internal": {
          "name": "Deploy to Internal Platform",
          "file": "deploy-internal",
          "description": "Deploy to company Kubernetes cluster"
        }
      }
    }
  }
}
```

Then create: `.ai-iap-custom/processes/typescript/deploy-internal.md`

### **4. Add Custom Frameworks**

```json
{
  "languages": {
    "typescript": {
      "customFrameworks": {
        "remix": {
          "name": "Remix",
          "file": "remix",
          "category": "Full-Stack Framework",
          "description": "Company Remix standards",
          "recommended": true
        }
      }
    }
  }
}
```

Then create: `.ai-iap-custom/rules/typescript/frameworks/remix.md`

## 🔄 Update Strategy

### **Option A: Git Ignore (Default)**
Add `.ai-iap-custom/` to `.gitignore` to keep customizations local.

### **Option B: Team Sharing**
Commit `.ai-iap-custom/` to share customizations across your team.

### **Option C: Separate Repo**
Maintain `.ai-iap-custom/` as a separate git repository for company-wide standards.

## 📋 Examples

See example files in this directory:
- `config.example.json` - Example custom configuration
- `rules/typescript/company-standards.example.md` - Example custom rule
- `processes/typescript/deploy-internal.example.md` - Example custom process

Copy and rename (remove `.example`) to activate.

## ✅ Validation

Run validation to check your custom files:

```bash
# Linux/Mac
./.ai-iap/validate.sh

# Windows
.\.ai-iap\validate.ps1
```

## 🆘 Troubleshooting

**Custom files not appearing?**
- Ensure `config.json` is valid JSON
- Check file paths match exactly
- Run validation scripts

**Merge conflicts when pulling updates?**
- Core files (`.ai-iap/`) should never conflict
- Custom files (`.ai-iap-custom/`) are yours to manage

**Want to reset?**
- Delete `.ai-iap-custom/` directory
- Re-run setup script

## 📚 More Information

- **[CUSTOMIZATION.md](../CUSTOMIZATION.md)** – Complete guide with examples and troubleshooting
- **[Main README](.ai-iap/README.md)** – Full project documentation
- **[Core Config](../.ai-iap/config.json)** – See core configuration structure
