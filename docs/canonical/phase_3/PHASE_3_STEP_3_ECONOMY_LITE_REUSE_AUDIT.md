# Phase 3 Step 3 - Economy Lite Reuse Audit

## 1) Current economy-like signals (XP / streak / completion)
- XP shown on release path:
  - Progress Map V2 chips row uses XP value (`_xp`) from `ProgressService.getXp()` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
  - Session result screen shows XP gained and XP progress using `XpProgressService` in `lib/ui_v2/session/ui_v2_session_result_screen.dart`.
- Streak shown on release path:
  - Progress Map V2 uses `ReturnLoopServiceV1.instance.currentStreak` and displays it via `_infoChip` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
- Completion signals:
  - Module completion stored via `ProgressService.markModuleCompleted` and read via `isModuleCompleted` in `lib/services/progress_service.dart`.

## 2) Best reuse candidate for “Chips”
- Reuse existing XP value displayed in Progress Map V2 as “Chips” (rename label only) because XP is already fetched and displayed there (`_xp` and `_infoChip`).
- No new counter required if reusing XP as the economy proxy.

## 3) Stars feasibility
- No clear per-module “stars” persistence found in release path.
- Existing star icons appear in non-release screens (e.g., `lib/screens/training_template_detail_screen.dart`, `lib/screens/xp_dashboard_screen.dart`, `lib/ui_v2/onboarding/onboarding_interface_guide_screen.dart`) but no shared star rating model stored for modules.
- Minimal deterministic derivation path (if needed): use completion only (1 star for completed, 0 otherwise) using `ProgressService.isModuleCompleted` in Progress Map V2. This avoids new persistence but is a coarse proxy.
- If multi-star rating is required, mark BLOCKED for Phase 3.4 due to missing stored star data.

## 4) Recommended minimal implementation plan for Step 4 (1-2 files max)
- Primary: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - Rename the XP chip label to “Chips” (reuse existing `_xp` value).
  - Add a single-star visual for completed modules (derived from `isCompleted`) if required.
- Optional (only if needed for session summary consistency): `lib/ui_v2/session/ui_v2_session_result_screen.dart`
  - Keep XP as-is; do not introduce new counters unless Step 4 explicitly requires.
