# Bugs & fixes (recurring failure modes)

Fact-based; add rows when a failure mode repeats. **Not** a substitute for GitHub issues.

| Symptom | Likely cause | Fix / pointer |
|---------|----------------|---------------|
| No frameworks in setup for a language | No frameworks in `config.json` for that lang, or JSON broken | `/ai-iap:validate`; see `TROUBLESHOOTING.md` §No frameworks |
| Validate: missing rule file | `config.json` references stem without matching `plugin/lib/rules/.../*.md` | Add file or remove reference |
| Generated rules mention `.cursor/` paths | Violates validate check 5 | Remove paths; rules must work in user projects without Cursor |
| Setup cleanup deleted wanted files | Missing or false `aiIapManaged` | Only managed files are deleted; user files never |
| Plugin not loading | Wrong install path or marketplace | `claude --plugin-dir`; `/reload-plugins`; see `TROUBLESHOOTING.md` |
| CI validate fails markdown | Rule file empty or first line not `#` | Fix offending `plugin/lib/rules/**/*.md` |
| Version drift | `plugin.json` / `config.json` / `marketplace.json` out of sync | Align on release (see `docs/memory/deployment.md`) |
