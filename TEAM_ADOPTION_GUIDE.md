# Team Adoption Guide

## Overview

For engineering teams evaluating AI Instructions & Prompts

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
| **Documentation standards** | Code comments, API docs, READMEs |
| **Framework best practices** | React hooks, Django ORM, Spring patterns |

**Action**: Load these into your AI tools immediately.

### **Adapt to your workflow**

These assume specific tooling/workflows - customize first:

| Component | Default Assumption | Your Alternative |
| ----------- | ------------------- | ------------------ |
| **Git branches** | `feature/`, `ci/` | JIRA keys, trunk-based |
| **CI/CD platform** | GitHub Actions | GitLab CI, Azure DevOps, Jenkins |
| **Docker** | Required for testing | Serverless, PaaS, custom containers |
| **Test frameworks** | Jest (TS), xUnit (.NET) | Your team's choice |
| **Commit conventions** | Conventional Commits | Your format |

**Action**: Use [Extension System](CUSTOMIZATION.md) to override. Example:

```json
// .ai-iap-custom/config.json
{
  "git": {
    "branchPrefix": "PROJ-",
    "workflow": "trunk-based"
  },
  "cicd": {
    "platform": "gitlab-ci"
  }
}
```

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

- Load general rules (code-style, security)
- Add documentation standards
- Review with 2-3 senior engineers

**Week 3-4**: Framework-Specific

- Add framework rules (React, Spring Boot, etc.)
- Test with 1-2 projects
- Gather feedback from team

**Month 2**: Process Integration

- Adapt process guides to your workflow
- Create custom extensions (`.ai-iap-custom/`)
- Skip incompatible sections

**Month 3+**: Refinement

- Monitor AI behavior consistency
- Update based on team feedback
- Document deviations

### Strategy 2: **Big-Bang Adoption** (Risky)

**Only if**:

- Greenfield project (no existing standards)
- Small team (<5 engineers)
- All using GitHub + Docker
- No strong existing conventions

**Steps**:

1. Run setup for all tools: `.ai-iap/setup.sh`
2. Select all applicable languages/frameworks
3. Commit generated configs
4. Announce to team with training session

### Strategy 3: **Cherry-Pick** (Conservative)

**For established teams with strong conventions**:

1. **Extract only general rules**:
   - security.md

   - code-style.md

   - documentation/api.md

2. **Skip everything else**:
   - Process guides (you have your own)

   - CI/CD templates (platform-specific)

   - Structure templates (team-defined)

3. **Create custom processes**:
   - Use `.ai-iap-custom/` for your actual workflows

   - Reference your CI/CD platform

   - Use your branch naming

---

## Conflict Resolution Matrix

| Your Situation | AI Instructions & Prompts Says | Resolution |
| ---------------- | ------------------------------- | ------------ |
| **Use GitLab CI** | GitHub Actions | Adapt CI/CD guide, create `.ai-iap-custom/processes/*/ci-cd-gitlab.md` |
| **Use xUnit (.NET)** | NUnit required | Resolved by customizing: document your preferred test framework via `.ai-iap-custom/` |

| **Trunk-based dev** | Feature branches | Skip branch naming, use `.ai-iap-custom/` to document trunk approach |
| **Jira integration** | Generic branches | Add `.ai-iap-custom/config.json` with Jira prefix |
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

- [ ] Run setup script for primary AI tool (Cursor/Claude Code)

- [ ] Review generated configs

- [ ] Commit `.ai-iap/`, `.ai-iap-custom/`, and `.ai-iap-state.json` in the repo (shared across the team)

- [ ] Re-run setup in **Modify selection** mode when you need to add/remove tools, languages, frameworks, or processes

- [ ] Create/update `.ai-iap-custom/` with team overrides and custom function patterns

- [ ] Test with 1-2 pilot projects

- [ ] Document deviations in `.ai-iap-custom/README.md`

### Rollout Phase (Team)

- [ ] Announce adoption plan (email/Slack)

- [ ] Provide 30-min training session

- [ ] Set up support channel (Slack #ai-standards)

- [ ] Monitor for 2 weeks, gather feedback

### Maintenance Phase (Ongoing)

- [ ] Quarterly review of AI rules

- [ ] Update for new frameworks/languages

- [ ] Sync with upstream project (if using vanilla)

- [ ] Document AI behavior issues

- [ ] Refine custom extensions

---

## Common Anti-Patterns (What NOT to Do)

- **Don't adopt everything blindly** → conflicts with existing workflows
- **Don't modify core `.ai-iap/` files directly** → makes upstream updates painful
- **Don't skip security rules** → increases risk of vulnerabilities in AI-generated code
- **Don't ignore team feedback** → low adoption and inconsistent usage
- **Don't run without ownership** → rules become stale and unused

---

## Success Metrics

Track these after 30-60 days:

| Metric | Target | How to Measure |
| -------- | -------- | ---------------- |
| **AI code quality** | 90% PR approval without AI-specific feedback | PR review comments |
| **Security issues** | <5% OWASP violations | Security scan results |
| **Consistency** | Same patterns across projects | Code review |
| **Adoption rate** | 80% team using AI tools | Survey |
| **Time saved** | 20% reduction in code review time | PR metrics |

---

## Support & Resources

- **Customization**: See [CUSTOMIZATION.md](CUSTOMIZATION.md)

- **Extension System**: `.ai-iap-custom/` examples

- **Issues**: Report conflicts/bugs to [GitHub Issues]

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

**Q: Can we use this with our internal AI tool?**
A: Yes, if it supports markdown instructions. Add your tool to `config.json`.

**Q: What if we find a bug or bad advice?**
A: Override in `.ai-iap-custom/` immediately, then report upstream.

**Q: How do we keep rules updated?**
A: Quarterly `git pull` from upstream + merge custom changes.

**Q: Can we contribute our customizations back?**
A: Yes! Generic improvements belong upstream. Company-specific stays custom.

**Q: Our team uses Rust/Go - not supported?**

A: Create `.ai-iap-custom/rules/rust/` with your standards.

---

**Bottom Line**: This is a **foundation, not a straitjacket**. Use what helps, adapt what
conflicts, skip what doesn't fit. The extension system exists specifically to make this work
for YOUR team.
