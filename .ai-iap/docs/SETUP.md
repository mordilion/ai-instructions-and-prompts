# Setup Guide

This guide explains how to install and run **AI Instructions & Prompts** in a new or existing project.

---

## 1) Copy the folder into your project

Copy **only** the `.ai-iap/` folder into your project root.

Optional: also add `.ai-iap-custom/` if you use the extension system.

---

## 2) Run setup (interactive wizard)

**Windows (PowerShell)**

```powershell
.\.ai-iap\setup.ps1
```

**macOS / Linux**

```bash
chmod +x .ai-iap/setup.sh && ./.ai-iap/setup.sh
```

The wizard will prompt for:
- tools
- languages
- documentation standards (optional)
- frameworks (optional)
- structures (optional)
- processes (optional)

---

## 3) Re-run setup safely (recommended)

Setup is **rerunnable** and stores your last choices in `.ai-iap-state.json`.

On rerun, you can:
- reuse previous selection and regenerate
- modify selection (defaults to previous)
- cleanup previously generated outputs (only files marked as managed)
- start fresh

---

## 4) Generated outputs (high level)

Outputs are generated into the project root for each selected tool.

Examples:
- Cursor: `.cursor/rules/**/*.mdc`
- Claude (Claude Code rules): `.claude/rules/**/*.md`
- GitHub Copilot: `.github/copilot-instructions.md`

---

## 5) Troubleshooting

If setup fails, start here:
- run from project root
- ensure required dependencies exist (`jq` on macOS/Linux)
- see `.ai-iap/TROUBLESHOOTING.md`

