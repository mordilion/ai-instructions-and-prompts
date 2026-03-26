# Team Adoption Guide

## Overview

For engineering teams adopting AI Instructions & Prompts with Claude Code

---

## Executive Summary

This is a **foundational standards system** that provides:

- **Universal coding best practices** (SOLID, OWASP, documentation)
- **Framework-specific patterns** (React, Django, Spring Boot, etc.)
- **Opinionated process workflows** (Git branches, CI/CD, Docker)

**Recommendation**: Adopt **selectively** based on your existing infrastructure.

---

## Assessment: What Should You Adopt?

### **Adopt without modification**

These are universally applicable and conflict-free:

| Component | Why Adopt |
| ----------- | ----------- |
| **General code-style** | SOLID, DRY, YAGNI - industry standard |

| **Security rules** | OWASP Top 10, prevents vulnerabilities |
| **Accessibility rules** | WCAG-aligned patterns, inclusive UX |
| **i18n rules** | Localization, string handling, locale-aware behavior |
| **Documentation standards** | Code comments, API docs, READMEs |
| **Framework best practices** | React hooks, Django ORM, Spring patterns |

**Action**: Load these into Claude Code immediately.

### **Adapt to your workflow**

These assume specific tooling/workflows - customize first:

| Component | Default Assumption | Your Alternative |
| ----------- | ------------------- | ------------------ |
| **Git branches** | `feature/`, `ci/` | JIRA keys, trunk-based |
| **CI/CD platform** | GitHub Actions | GitLab CI, Azure DevOps, Jenkins |
| **Docker** | Required for testing | Serverless, PaaS, custom containers |
| **Test frameworks** | Jest (TS), xUnit (.NET) | Your team's choice |
| **Commit conventions** | Conventional Commits | Your format |

**Action**: Skip or adapt the conflicting rules for your workflow during `/ai-iap:setup`.

### **Skip or replace**

These may conflict with established practices:

| Component | When to Skip |
| ----------- | -------------- |
| **Process phase prescriptions** | Team has existing workflows |
| **Docker templates** | Using Kubernetes, serverless |
| **Branch naming rules** | Established naming conventions |
| **"Wait for approval" steps** | Automated CI/CD workflows |

**Action**: Extract principles, ignore specific implementations.

---

## Adoption Strategies

### Strategy 1: **Gradual Rollout** (Recommended)

**Week 1-2**: Foundation

- Load general rules (code-style, security, accessibility, i18n)
- Add documentation standards
- Review with 2-3 senior engineers

**Week 3-4**: Framework-Specific

- Add framework rules (React, Spring Boot, etc.)
- Test with 1-2 projects
- Gather feedback from team

**Month 2**: Process Integration

- Adapt process guides to your workflow
- Skip incompatible sections

**Month 3+**: Refinement

- Monitor Claude Code behavior consistency
- Update based on team feedback
- Document deviations

### Strategy 2: **Big-Bang Adoption** (Risky)

**Only if**:

- Greenfield project (no existing standards)
- Small team (<5 engineers)
- All using GitHub + Docker
- No strong existing conventions

**Steps**:

1. Run setup: `/ai-iap:setup`
2. Select Claude Code, then applicable languages/frameworks
3. Commit generated configs (`.claude/rules/`, `CLAUDE.md`, `.claude/agents/`)
4. Announce to team with training session

### Strategy 3: **Cherry-Pick** (Conservative)

**For established teams with strong conventions**:

1. **Extract only general rules**:
   - security.md

   - code-style.md

   - accessibility.md

   - i18n.md

   - documentation/api.md

2. **Skip everything else**:
   - Process guides (you have your own)

   - CI/CD templates (platform-specific)

   - Structure templates (team-defined)

3. **Create custom processes**:

   - Reference your CI/CD platform

   - Use your branch naming

---

## Conflict Resolution Matrix

| Your Situation | AI Instructions & Prompts Says | Resolution |
| ---------------- | ------------------------------- | ------------ |
| **Use GitLab CI** | GitHub Actions | Adapt CI/CD process guide for your platform |
| **Use xUnit (.NET)** | NUnit required | Select your preferred test framework during setup |

| **Trunk-based dev** | Feature branches | Skip branch naming rules during setup |
| **Jira integration** | Generic branches | Adapt commit/branch rules to include Jira prefix |
| **No Docker** | Docker templates | Skip Docker sections, focus on CI/CD logic |
| **MSTest preferred** | xUnit recommended | Use MSTest - guide now supports all |

---

## Team Onboarding Checklist

### Pre-Adoption (Leadership)

- [ ] Designate "AI rules owner" (like API design lead)

- [ ] Review [Conflicts Matrix](#conflict-resolution-matrix)

- [ ] Decide: Adopt, Adapt, or Skip for each component

- [ ] Budget 4-8 hours for initial customization

- [ ] Plan rollout strategy (gradual vs. big-bang vs. cherry-pick)

### Setup Phase (Technical Lead)

- [ ] Clone repository

- [ ] Run `/ai-iap:setup` for Claude Code

- [ ] Review generated configs

- [ ] Install the `ai-iap` plugin, commit `.ai-iap-state.json` in the repo (shared across the team)

- [ ] Re-run setup in **Modify selection** mode when you need to add/remove languages, frameworks, or processes

- [ ] Test with 1-2 pilot projects

- [ ] Document deviations in a team wiki or README

### Rollout Phase (Team)

- [ ] Announce adoption plan (email/Slack)

- [ ] Provide 30-min training session

- [ ] Set up support channel (Slack #ai-standards)

- [ ] Monitor for 2 weeks, gather feedback

### Maintenance Phase (Ongoing)

- [ ] Quarterly review of AI rules

- [ ] Update for new frameworks/languages

- [ ] Sync with upstream project (if using vanilla)

- [ ] Document Claude Code behavior issues

- [ ] Refine generated rules and document team-specific adjustments

---

## Common Anti-Patterns (What NOT to Do)

- **Don't adopt everything blindly** → conflicts with existing workflows
- **Don't modify the plugin's core files** → fork or contribute upstream instead
- **Don't skip security rules** → increases risk of vulnerabilities in AI-generated code
- **Don't ignore team feedback** → low adoption and inconsistent Claude Code usage
- **Don't run without ownership** → rules become stale and unused

---

## Success Metrics

Track these after 30-60 days:

| Metric | Target | How to Measure |
| -------- | -------- | ---------------- |
| **AI code quality** | 90% PR approval without AI-specific feedback | PR review comments |
| **Security issues** | <5% OWASP violations | Security scan results |
| **Consistency** | Same patterns across projects | Code review |
| **Adoption rate** | 80% team using Claude Code | Survey |
| **Time saved** | 20% reduction in code review time | PR metrics |

---

## Support & Resources

- **Issues**: Report conflicts/bugs to [GitHub Issues](https://github.com/HenningHuncke/ai-instructions-and-prompts/issues)

---

## Decision Tree

```text
START: Should we adopt AI Instructions & Prompts?

Decision guide:
- If you have **no coding standards**: adopt broadly (big-bang can work for small teams).
- If you have **strong existing workflows**: cherry-pick general rules first.
- If you are **not on GitHub + Docker**: adapt process guides to your platform/tooling.
- If your team is **large**: start with a pilot (1-2 teams), then scale gradually.
```

---

## FAQs

**Q: Can we use this with other AI tools besides Claude Code?**
A: The setup is focused on Claude Code. For other tools, check if they support markdown-based instructions and adapt accordingly.

**Q: What if we find a bug or bad advice?**
A: Report upstream via GitHub Issues. For immediate fixes, adjust the generated rules in `.claude/rules/` directly.

**Q: How do we keep rules updated?**
A: Quarterly `git pull` from upstream + merge custom changes.

**Q: Can we contribute our customizations back?**
A: Yes! Generic improvements belong upstream. Company-specific stays custom.

**Q: Our team uses Rust/Go - not supported?**

A: Add your own rule files to `.claude/rules/` manually. Consider contributing the language upstream.

---

**Bottom Line**: This is a **foundation, not a straitjacket**. Use what helps, adapt what
conflicts, skip what doesn't fit. The setup wizard lets you select exactly what your team needs.
