# Token Efficiency Audit Report

**Based on**: Updated `.cursor/rules/general.mdc` guidelines  
**Date**: 2025-12-29  
**Target**: 80-150 lines per **rule** file

---

## ✅ **Compliant Files** (Within Target)

### General Rules (All Compliant ✅)
- `general/persona.md` - 21 lines ✅
- `general/architecture.md` - 26 lines ✅
- `general/code-style.md` - 24 lines ✅
- `general/security.md` - 80 lines ✅
- `general/commit-standards.md` - 101 lines ✅ (slightly over but acceptable)

### Security Rules (All Compliant ✅)
- All language security files: 53-84 lines ✅

### Architecture Rules (Mostly Compliant ✅)
- `javascript/architecture.md` - 29 lines ✅
- `python/architecture.md` - 55 lines ✅
- `dotnet/architecture.md` - 64 lines ✅
- `kotlin/architecture.md` - 62 lines ✅
- `swift/architecture.md` - 78 lines ✅
- `php/architecture.md` - 89 lines ✅
- `dart/architecture.md` - 94 lines ✅
- `java/architecture.md` - 103 lines ✅
- `typescript/architecture.md` - 138 lines ✅

### Code Style Rules (All Compliant ✅)
- All code-style files: 56-105 lines ✅

---

## ❌ **Non-Compliant Rule Files** (47 files need optimization)

### 🔴 CRITICAL (>300 lines) - 27 files

| File | Lines | Excess | Priority |
|------|-------|--------|----------|
| `java/frameworks/spring-boot.md` | 564 | +414 | 🔴 CRITICAL |
| `dotnet/frameworks/aspnetcore.md` | 479 | +329 | 🔴 CRITICAL |
| `typescript/frameworks/prisma.md` | 475 | +325 | 🔴 CRITICAL |
| `typescript/frameworks/vue.md` | 438 | +288 | 🔴 CRITICAL |
| `kotlin/frameworks/structures/ktor-layered.md` | 437 | +287 | 🔴 CRITICAL |
| `typescript/frameworks/svelte.md` | 437 | +287 | 🔴 CRITICAL |
| `swift/frameworks/swiftui.md` | 409 | +259 | 🔴 CRITICAL |
| `php/frameworks/symfony.md` | 405 | +255 | 🔴 CRITICAL |
| `php/frameworks/doctrine.md` | 404 | +254 | 🔴 CRITICAL |
| `typescript/frameworks/angular.md` | 400 | +250 | 🔴 CRITICAL |
| `php/frameworks/laravel.md` | 372 | +222 | 🔴 CRITICAL |
| `typescript/frameworks/structures/adonisjs-mvc.md` | 369 | +219 | 🔴 CRITICAL |
| `kotlin/frameworks/android.md` | 365 | +215 | 🔴 CRITICAL |
| `kotlin/frameworks/structures/android-mvi.md` | 355 | +205 | 🔴 CRITICAL |
| `swift/frameworks/ios.md` | 352 | +202 | 🔴 CRITICAL |
| `swift/frameworks/vapor.md` | 349 | +199 | 🔴 CRITICAL |
| `typescript/frameworks/adonisjs.md` | 347 | +197 | 🔴 CRITICAL |
| `kotlin/frameworks/spring-boot.md` | 337 | +187 | 🔴 CRITICAL |
| `typescript/frameworks/react.md` | 326 | +176 | 🔴 CRITICAL |
| `typescript/frameworks/nestjs.md` | 325 | +175 | 🔴 CRITICAL |
| `java/frameworks/android.md` | 317 | +167 | 🔴 CRITICAL |
| `typescript/frameworks/nextjs.md` | 308 | +158 | 🔴 CRITICAL |
| `dotnet/frameworks/efcore.md` | 306 | +156 | 🔴 CRITICAL |
| `swift/frameworks/combine.md` | 303 | +153 | 🔴 CRITICAL |

### 🟡 HIGH (200-299 lines) - 13 files

| File | Lines | Excess |
|------|-------|--------|
| `kotlin/code-style.md` | 291 | +141 |
| `python/frameworks/fastapi.md` | 289 | +139 |
| `swift/frameworks/coredata.md` | 277 | +127 |
| `python/frameworks/django.md` | 275 | +125 |
| `python/frameworks/structures/fastapi-clean.md` | 275 | +125 |
| `kotlin/frameworks/ktor.md` | 268 | +118 |
| `python/frameworks/pydantic.md` | 262 | +112 |
| `kotlin/frameworks/structures/spring-boot-clean.md` | 256 | +106 |
| `python/frameworks/flask.md` | 252 | +102 |
| `kotlin/frameworks/structures/spring-boot-modular.md` | 247 | +97 |
| `java/frameworks/hibernate.md` | 242 | +92 |
| `python/frameworks/structures/django-ddd.md` | 231 | +81 |
| `java/frameworks/structures/spring-boot-clean.md` | 229 | +79 |

### 🟢 MEDIUM (151-199 lines) - 7 files

| File | Lines | Excess |
|------|-------|--------|
| `kotlin/frameworks/exposed.md` | 217 | +67 |
| `dotnet/frameworks/maui.md` | 213 | +63 |
| `kotlin/frameworks/structures/android-mvvm.md` | 195 | +45 |
| `python/frameworks/sqlalchemy.md` | 184 | +34 |
| `java/frameworks/structures/spring-boot-modular.md` | 183 | +33 |
| `dart/frameworks/getx.md` | 182 | +32 |
| `python/frameworks/structures/fastapi-layered.md` | 177 | +27 |
| `java/frameworks/junit.md` | 167 | +17 |
| `python/frameworks/structures/fastapi-modular.md` | 157 | +7 |
| `python/frameworks/structures/django-modular.md` | 152 | +2 |

---

## 📊 **Summary Statistics**

| Category | Count | Status |
|----------|-------|--------|
| **Total Rule Files** | ~180 | - |
| **Compliant (<150 lines)** | ~133 | ✅ 74% |
| **Non-Compliant (>150 lines)** | 47 | ❌ 26% |
| **Critical (>300 lines)** | 27 | 🔴 15% |
| **High (200-299 lines)** | 13 | 🟡 7% |
| **Medium (151-199 lines)** | 7 | 🟢 4% |

---

## 🎯 **Recommended Action Plan**

### Phase 1: Critical Files (27 files, >300 lines)

**Priority**: Spring Boot, ASP.NET Core, React, Next.js, Angular, Vue, Svelte

**Target**: Reduce from 300-564 lines to 80-150 lines (~75% reduction)

**Method**:
- Remove verbose examples (keep 3-5 max)
- Convert prose to tables
- Use pattern names instead of code examples
- Keep only explicit directives (ALWAYS/NEVER)

**Example**: 
- `spring-boot.md`: 564 lines → target 120 lines (79% reduction)
- Following model of `architecture.md` (26 lines), `security.md` (80 lines)

### Phase 2: High Priority (13 files, 200-299 lines)

FastAPI, Django, Kotlin frameworks

**Target**: Reduce to 80-150 lines (~50% reduction)

### Phase 3: Medium Priority (7 files, 151-199 lines)

Expose, MAUI, SQLAlchemy, etc.

**Target**: Reduce to 80-150 lines (~20-30% reduction)

---

## 📈 **Expected Impact**

### Token Savings (Estimated)

Assuming average reduction of 250 lines per critical file:
- **Phase 1**: 27 files × 250 lines = 6,750 lines saved (~27,000 tokens)
- **Phase 2**: 13 files × 100 lines = 1,300 lines saved (~5,200 tokens)
- **Phase 3**: 7 files × 30 lines = 210 lines saved (~840 tokens)

**Total Savings**: ~33,000 tokens (14% reduction from current ~240,000 token total)

---

## 💡 **Optimization Pattern**

Based on successful optimizations:
1. **commit-standards.md**: 514 → 101 lines (80% reduction)
2. **security files**: 80% token reduction
3. **architecture.md**: Already optimal at 26 lines

**Apply same pattern**:
- Tables over prose
- Pattern names over examples
- 3-5 examples max
- Explicit directives only
- No redundant explanations

---

## ⚠️ **Note on Process Files**

Process files (200-400 lines) are **acceptable** as they are step-by-step guides:
- `test-implementation.md` files: 107-394 lines ✅
- `ci-cd-github-actions.md` files: 204-253 lines ✅
- `logging-observability.md` files: 117-258 lines ✅
- `docker-containerization.md` files: 75-311 lines ✅

**Recommendation**: Keep processes as-is, focus on **rule files** only.

---

## 🔄 **Next Steps**

1. ✅ Audit complete (this file)
2. ⏳ Get user approval for optimization plan
3. ⏳ Phase 1: Optimize 27 critical rule files
4. ⏳ Phase 2: Optimize 13 high-priority files
5. ⏳ Phase 3: Optimize 7 medium-priority files
6. ⏳ Update documentation with new token counts

**Estimated Effort**: 
- Phase 1: 2-3 hours per file × 27 files = substantial effort
- Recommend: Start with top 5 most-used frameworks first

---

## 🎯 **Top 5 Priority Files** (Start Here)

1. **`java/frameworks/spring-boot.md`** - 564 lines (most verbose)
2. **`dotnet/frameworks/aspnetcore.md`** - 479 lines
3. **`typescript/frameworks/react.md`** - 326 lines (most used)
4. **`typescript/frameworks/nextjs.md`** - 308 lines
5. **`typescript/frameworks/angular.md`** - 400 lines

---

**Ready for optimization?** Start with Top 5, then expand to all 47 files.

