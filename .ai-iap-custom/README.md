# Custom AI Instructions & Prompts

This directory lives in **your project** and lets you extend or override the **plugin’s** core configuration (shipped under `lib/` in the plugin repo, resolved at runtime via the plugin install) without editing those core files. You can pull plugin updates without losing your customizations here.

## 📁 Directory Structure

```
.ai-iap-custom/
├── README.md                   # This file
├── config.json                 # Custom configuration (extends core)
├── rules/                      # Custom or override rules
│   └── typescript/
│       └── company-standards.md
├── processes/                  # Custom processes
│   └── typescript/
│       └── deploy-internal.md
└── code-library/               # Custom code patterns
    ├── functions/              # Custom implementation patterns
    │   └── company-auth-header.md
    └── design-patterns/        # Custom design patterns
        ├── creational/
        ├── structural/
        └── behavioral/
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

- Core (plugin): `lib/rules/typescript/code-style.md`
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

### **5. Add Custom Implementation Patterns**

Add company-specific implementation patterns (auth flows, API clients, etc.):

- **Start from template**: Copy `lib/code-library/functions/_TEMPLATE.md` from the plugin (or your plugin checkout)
- **Create file**: `.ai-iap-custom/code-library/functions/company-pattern.md`
- **Update index**: Add to `.ai-iap-custom/code-library/functions/INDEX.md`

AIs will check custom patterns before core patterns.

### **6. Add Custom Design Patterns**

Add company-specific design pattern implementations:

- **Start from template**: Copy `lib/code-library/design-patterns/_TEMPLATE.md` from the plugin (or your plugin checkout)
- **Create file**: `.ai-iap-custom/code-library/design-patterns/[category]/company-pattern.md`
- **Categories**: creational, structural, or behavioral
- **Update index**: Add to `.ai-iap-custom/code-library/design-patterns/INDEX.md`

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
- `code-library/functions/company-auth-header.example.md` - Example custom function
- Templates available under `lib/code-library/` in the plugin for functions and design patterns

Copy and rename (remove `.example`) to activate.

## ✅ Validation

Run validation to check your custom files: use `/ai-iap:validate` in Claude Code.

## 🆘 Troubleshooting

**Custom files not appearing?**
- Ensure `config.json` is valid JSON
- Check file paths match exactly
- Run `/ai-iap:validate`

**Merge conflicts when pulling updates?**
- Core plugin files (under `lib/` in the plugin) should never conflict with this directory
- Custom files (`.ai-iap-custom/`) are yours to manage

**Want to reset?**
- Delete `.ai-iap-custom/` directory
- Re-run `/ai-iap:setup` in Claude Code

## 📚 More Information

- **[CUSTOMIZATION.md](../CUSTOMIZATION.md)** – Complete guide with examples and troubleshooting
- **[Main README](../README.md)** – Full project documentation (plugin repo root)
- **[Core Config](../lib/config.json)** – See core configuration structure (plugin repo)
