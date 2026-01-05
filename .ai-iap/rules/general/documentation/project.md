# Project Documentation Standards

> **Scope**: README, CHANGELOG, CONTRIBUTING, LICENSE, project-level docs

---

## README Structure

> **ALWAYS**: Follow this order for consistency across projects

### Required Sections

1. **Title & Description** (1-2 sentences)
2. **Features** (bullet list, 3-8 items)
3. **Installation** (step-by-step commands)
4. **Quick Start** (minimal example)
5. **Documentation** (link to full docs)
6. **License** (SPDX identifier)

### Optional Sections

- **Prerequisites** (if non-standard)
- **Configuration** (environment variables)
- **API Reference** (or link to docs)
- **Contributing** (or link to CONTRIBUTING.md)
- **Support** (issue tracker, discussions)
- **Acknowledgments** (credits, sponsors)

---

## README Template

```markdown
# Project Name

Brief description (1-2 sentences explaining what and why).

## Features

- ✨ Feature one (user benefit)
- 🚀 Feature two (user benefit)
- 🔒 Feature three (user benefit)

## Installation

\`\`\`bash
npm install project-name
\`\`\`

## Quick Start

\`\`\`javascript
import { feature } from 'project-name';

const result = feature('hello');
console.log(result);
\`\`\`

## Documentation

Full documentation: https://docs.example.com

## License

MIT License - see [LICENSE](LICENSE)
```

---

## CHANGELOG Standards

> **Reference**: [Keep a Changelog v1.1.0](https://keepachangelog.com/)  
> **Format**: Markdown, reverse chronological order

### Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- New feature description

### Changed
- Changed behavior description

### Deprecated
- Soon-to-be removed feature

### Removed
- Removed feature description

### Fixed
- Bug fix description

### Security
- Security fix description

## [1.0.0] - 2024-01-15

### Added
- Initial release features

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

### Category Guidelines

| Category | Purpose | Example |
|----------|---------|---------|
| **Added** | New features | "Add OAuth authentication" |
| **Changed** | Existing feature changes | "Update API response format" |
| **Deprecated** | Soon-to-be-removed | "Deprecate v1 endpoints" |
| **Removed** | Removed features | "Remove Node 12 support" |
| **Fixed** | Bug fixes | "Fix memory leak in cache" |
| **Security** | Security patches | "Patch XSS vulnerability" |

> **ALWAYS**: Use present tense ("Add" not "Added")  
> **ALWAYS**: Link to issues/PRs when relevant  
> **NEVER**: Include internal refactoring unless user-facing

---

## CONTRIBUTING Guide

> **ALWAYS**: Include if accepting external contributions

### Required Sections

1. **Code of Conduct** (link to CODE_OF_CONDUCT.md)
2. **Getting Started** (development setup)
3. **Development Workflow** (branch strategy, commits)
4. **Testing** (how to run tests)
5. **Pull Request Process** (review, merge criteria)

**Minimal Example**:
```markdown
# Contributing

## Development Setup

\`\`\`bash
git clone https://github.com/user/repo.git
cd repo
npm install
npm test
\`\`\`

## Workflow

1. Fork the repository
2. Create feature branch: `git checkout -b feature/name`
3. Commit changes: `git commit -m "feat: description"`
4. Push to branch: `git push origin feature/name`
5. Open Pull Request

## Commit Standards

Follow [Conventional Commits](https://conventionalcommits.org/).

## Code Review

All PRs require:
- [ ] Tests passing
- [ ] Code review approval
- [ ] Documentation updated
```

---

## LICENSE File

> **ALWAYS**: Include LICENSE file in repository root  
> **ALWAYS**: Use SPDX identifier in README and package files

| License | Use Case | Commercial OK | Attribution Required |
|---------|----------|---------------|---------------------|
| MIT ⭐ | Permissive, popular | ✅ Yes | ✅ Yes |
| Apache 2.0 | Permissive + patent grant | ✅ Yes | ✅ Yes |
| GPL-3.0 | Copyleft, open source | ⚠️ Same license | ✅ Yes |
| BSD-3 | Permissive, simple | ✅ Yes | ✅ Yes |
| Unlicense | Public domain | ✅ Yes | ❌ No |

> **Reference**: [Choose a License](https://choosealicense.com/)

---

## Badge Standards

> **ALWAYS**: Place badges at top of README  
> **ALWAYS**: Keep badges relevant and up-to-date

### Recommended Badges

```markdown
![Build Status](https://img.shields.io/github/actions/workflow/status/user/repo/ci.yml)
![Coverage](https://img.shields.io/codecov/c/github/user/repo)
![Version](https://img.shields.io/npm/v/package-name)
![License](https://img.shields.io/github/license/user/repo)
```

### Badge Categories (Priority Order)

1. **Build/CI Status** (critical)
2. **Test Coverage** (quality indicator)
3. **Version** (latest release)
4. **License** (legal compliance)
5. **Downloads** (popularity - optional)

---

## Documentation Anti-Patterns

| ❌ Bad Practice | ✅ Better Approach |
|----------------|-------------------|
| Outdated installation steps | Test docs regularly, automate if possible |
| Screenshots without alt text | Add descriptive alt text |
| No version in docs | Include "Last updated" or version |
| Broken links | Use link checker in CI |
| Wall of text | Break into sections with headers |
| Missing prerequisites | List all required tools/versions |

---

## AI Self-Check

- [ ] README includes title, description, installation, usage
- [ ] README features list is user-benefit focused
- [ ] CHANGELOG follows Keep a Changelog format
- [ ] CHANGELOG uses present tense ("Add" not "Added")
- [ ] CONTRIBUTING guide included if open source
- [ ] LICENSE file present in repository root
- [ ] All badges are functional and up-to-date
- [ ] Installation steps tested and work
- [ ] No broken links in documentation
- [ ] Code examples are runnable and current
- [ ] Version numbers are consistent across files
- [ ] Documentation includes troubleshooting section
