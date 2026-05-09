# Engagement and Return Loop Audit (Phase 4 Step 1)

## 1) Current signals present
- Streak: ReturnLoopServiceV1 maintains `currentStreak` and updates on app open / progress map shown.
  - Source: lib/services/return_loop_service_v1.dart
- XP: ProgressService persists XP; session result adds XP based on correct count.
  - Source: lib/services/progress_service.dart, lib/ui_v2/screens/session_result_screen.dart
- Completion: ProgressService stores module completion flags via markModuleCompleted.
  - Source: lib/services/progress_service.dart
- Abort: No explicit abort signal on release path found in current sources.

## 2) Entry/exit points where return nudges already exist
- Progress Map entry: ReturnLoopServiceV1.updateOnAppOpenOrProgressMapShown called in
  - lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart
- Session result: XP gain computed on completion (no explicit return nudge hook).
  - lib/ui_v2/screens/session_result_screen.dart

## 3) Gaps that can be filled via reuse (P2 only)
- Display-only reuse: surface streak and daily hand index already in progress map header; no new data needed.
- Potential reuse: existing ProgressService streak (separate from ReturnLoopServiceV1) is available but not surfaced on release path.

## 4) Explicit NO-GO items
- No new persistence (no new keys or services beyond ReturnLoopServiceV1/ProgressService).
- No new notification or reminder systems.
- No new telemetry events.
- No new screens or routing changes.

Verdict: READY (reuse-only signals exist; no blocking gaps).
