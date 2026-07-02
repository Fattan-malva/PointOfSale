# Flutter Audit — Quick Reference (One-Pager)

**Overall Status:** 🔴 **CRITICAL** — 11% complete  
**Date:** 2026-07-03  
**Action Required:** Architectural overhaul BEFORE feature development

---

## Current State vs Required

| App | Exists | Should Exist | Status |
|---|---|---|---|
| **main.dart** | ✅ | ✅ (but separated to app.dart) | ⚠️ Wrong pattern |
| **app.dart** | ❌ | ✅ | 🔴 MISSING |
| **core/constants/** | ❌ (only theme/) | ✅ | 🔴 MISSING |
| **core/network/** | ❌ | ✅ | 🔴 MISSING |
| **core/storage/** | ❌ | ✅ | 🔴 MISSING |
| **core/utils/** | ❌ | ✅ | 🔴 MISSING |
| **core/widgets/** | ❌ | ✅ | 🔴 MISSING |
| **features/** | ❌ | ✅ | 🔴 MISSING |
| **models/** | ❌ | ✅ | 🔴 MISSING |
| **routes/** | ❌ | ✅ | 🔴 MISSING |
| **Design tokens** | ✅ | ✅ | ✅ COMPLETE |
| **Theme setup** | ⚠️ 70% | ✅ | ⚠️ Needs nav rail, dark mode |

---

## Critical Fixes Required (Do First!)

```
❌ Missing File                  ✅ Create In
─────────────────────────────────────────────────────
app.dart                          lib/
app_button.dart                   lib/core/widgets/
app_card.dart                     lib/core/widgets/
app_text_field.dart               lib/core/widgets/
responsive.dart                   lib/core/utils/
app_colors.dart (move)            lib/core/constants/
app_typography.dart               lib/core/constants/
app_spacing.dart (extract)        lib/core/constants/
app_shadows.dart (extract)        lib/core/constants/
api_client.dart                   lib/core/network/
secure_storage.dart               lib/core/storage/
app_router.dart                   lib/routes/
```

---

## Design Tokens Scorecard

| Category | Status | Notes |
|---|---|---|
| Colors | ✅ 100% | All defined, used correctly |
| Spacing | ✅ 100% | All 16 values (4px to 64px) |
| Radius | ✅ 100% | sm, md, lg, xl, pill |
| Shadows | ✅ 100% | xs, sm, md, lg with correct opacity |
| Typography | ✅ 90% | Missing tabular figures |
| Buttons | ✅ 85% | Missing ghost/tertiary variants |
| Navigation | ❌ 0% | No rail theme for BackOffice |

---

## Per-App Gaps

### pos-kasir
- ❌ No responsive POS screen layout (grid columns by breakpoint)
- ❌ No cart state management
- ❌ No order workflow
- 🟡 Needs pos_keypad, order_summary_panel widgets

### backoffice
- 🔴 **CRITICAL:** No navigation rail (required for desktop)
- ❌ No responsive table component
- ❌ No dashboard summary widgets
- 🟡 Needs data-dense layout support

### user-apk
- ❌ No consistent image grid (aspect ratio handling)
- ❌ No menu browsing UI
- ❌ No order tracking UI
- 🟡 Needs consumer-friendly spacing

### dashboard-admin
- ❌ No chart theming
- ❌ No cross-branch comparison UI
- ❌ No performance metrics visualization
- 🟡 Needs admin-specific layouts

---

## Quick Fixes Checklist

**Day 1:**
- [ ] Separate main.dart → app.dart (all 4 apps)
- [ ] Create lib/core/ directory structure (all 4 apps)
- [ ] Move AppColors to lib/core/constants/app_colors.dart
- [ ] Extract AppSpacing to lib/core/constants/app_spacing.dart
- [ ] Extract AppRadius & AppShadows to lib/core/constants/

**Day 2:**
- [ ] Create app_button.dart, app_card.dart, app_text_field.dart
- [ ] Create responsive.dart with AppBreakpoints class
- [ ] Create all core/utils/, core/network/, core/storage/ files (stubs OK)

**Week 1:**
- [ ] Setup GoRouter with named routes
- [ ] Implement API client
- [ ] Create feature folder structures
- [ ] Implement all remaining core/widgets/

---

## Don't Proceed With Features Until:

1. ✅ All 4 apps have core/ structure
2. ✅ app.dart separated from main.dart
3. ✅ AppBreakpoints working
4. ✅ Shared widgets (button, card, text_field) working
5. ✅ Router setup complete
6. ✅ API client ready

**Expected wait:** 2-3 weeks  
**Risk if skipped:** Technical debt explosion, unmaintainable code

---

## Why This Matters

| If Not Fixed | Consequence |
|---|---|
| No core/widgets/ | Each developer creates own button → inconsistent UI |
| No app.dart | main.dart becomes bloated with logic |
| No routing | Can't navigate between screens |
| No AppBreakpoints | Apps broken on tablets/desktop |
| No API client | Can't connect to backend |
| No features/ structure | Codebase chaos, impossible to maintain |

---

## Files to Review

1. **Design.md §10** — Full folder structure requirements
2. **FLUTTER_AUDIT_REPORT.md** — This detailed audit
3. **AGENT.md** — Architectural guidelines

---

## Estimated Timeline

| Phase | Duration | Deliverable |
|---|---|---|
| **Phase 0** (Foundation) | 2 days | Main.dart, core/, shared widgets, responsive |
| **Phase 1** (Infrastructure) | 3 days | Router, API client, storage, features/ |
| **Phase 2** (State & Utils) | 5 days | State management, formatters, dark mode |
| **Phase 3** (Ready for Features) | — | **Ready to build actual features** |

**Total:** ~2.5 weeks before feature development can properly begin

---

Generated: 2026-07-03
