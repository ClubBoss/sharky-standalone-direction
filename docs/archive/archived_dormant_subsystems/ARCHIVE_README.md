# Archived Dormant Subsystems

**Archive Date**: 2026-05-14 (cleanup phase 3)  
**Total Size**: 7.3M  
**Impact on Act0**: NONE (verified with flutter analyze)

## Archived Components

### 1. assets/audit_hub_v1_assets_archived (6.9M)
**Type**: Image & data assets  
**Original Location**: `assets/audit_hub_v1/`

**Contents**:
- `world_screenshot_evidence_v1/` — world state screenshots for quality assurance
  - Multiple PNG files per world (tournament, mixed, cash variants)
  - 2.1M per file, very large PNG format

**Why Archived**:
- Only referenced by `lib/ui_v2/screens/audit_hub_screen_v1.dart`
- `audit_hub_screen_v1` is NOT used in Act0 shell
- 0 imports in active product code
- Legacy audit/verification system, not part of learner-facing product

**Recovery**:
```bash
git checkout HEAD -- assets/audit_hub_v1/
```

---

### 2. lib/ui_v3_archived (180K)
**Type**: UI foundation/design system  
**Original Location**: `lib/ui_v3/`

**Contents**:
- Learning map screen implementation
- Progress map components (v2)
- Alternative modern UI patterns
- Theme builders and visual consistency utilities

**Why Archived**:
- 33 total references in codebase, but 0 in Act0 shell
- Not the active runtime surface (`Act0ShellPreviewScreenV1` is)
- AGENTS.md marks UI v3 as "archived reference-only"
- Alternative future-proofing code, not current path

**Recovery**:
```bash
git checkout HEAD -- lib/ui_v3/
```

---

### 3. lib/audit_hub_v1_code_archived (184K)
**Type**: Audit interface code & models  
**Original Location**: `lib/audit_hub_v1/`

**Contents**:
- Audit operational builders and models
- Audit state management
- Verification/QA data structures

**Why Archived**:
- Only used by `lib/ui_v2/screens/audit_hub_screen_v1.dart`
- That screen is NOT in Act0 active path
- 0 references in production code outside audit_hub_screen
- Legacy quality assurance subsystem

**Recovery**:
```bash
git checkout HEAD -- lib/audit_hub_v1/
```

---

## Summary

All three subsystems were:
1. ✅ Verified to have 0 imports in Act0 shell (`lib/ui_v2/act0_shell/`, `lib/ui_v2/app_root.dart`)
2. ✅ Confirmed not used in active learner-facing product
3. ✅ Moved to archive with recovery instructions
4. ✅ Verified app still compiles: `flutter analyze` shows 0 errors

**Token/Read Burden**: Significant reduction (~7.3M less to scan during analysis/compilation)

**Active Replacement**: None needed (Act0 shell has all required functionality)

---

## Context

These archives followed the archival of:
- `lib/ui_v2/persona/` (1.7M, 399 files) — AI personalization subsystem
- 10 dependent dead-code files that used persona

Total cleanup this session: **1.7M + 7.3M = 9M+ of legacy code removed**

See [docs/archive/archived_ui_subsystems/PERSONA_ARCHIVE_README.md](../archived_ui_subsystems/PERSONA_ARCHIVE_README.md) for persona archival details.
