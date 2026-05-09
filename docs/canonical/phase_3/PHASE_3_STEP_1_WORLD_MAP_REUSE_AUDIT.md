# Phase 3 Step 1 - World Map Reuse Audit (Progress Map V2)

## A) Current surfaces (closest world map candidate)
- Primary candidate: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` (Progress Map V2).
  - Renders a vertical list of module nodes with state (completed / unlocked / locked).
  - Already labeled as “Progress Map V2” and uses node connectors + completion badges.
- Related entry points: `lib/ui_v2/screens/saga_map_screen.dart` (older saga list) and `lib/ui_v2/home/home_screen.dart` (entry to map / module summary).

## B) Current data model (what it renders)
- Data source: `DirectLoader.loadAvailableModules()` (in `lib/ui_v2/home/direct_loader.dart`) returns a list of module maps.
- Each module map is normalized in `UiV2ProgressMapScreenV2._loadData()`:
  - `id` derived from `id/name/title`.
  - `isUnlocked` and `isCompleted` are attached from `ProgressService`.
  - Title/description fields used in `_MapNode` from `moduleData['title']` and `moduleData['description']`.
- Node rendering:
  - `_MapNode` shows status icon + labels, and opens `ModuleSummaryScreen` when unlocked.
  - `_MapConnector` uses `_NodeState` to render connectors between nodes.

## C) Current persistence (completion/XP/streak)
- Completion + unlock signals live in `ProgressService` (file: `lib/services/progress_service.dart`).
  - Used in `UiV2ProgressMapScreenV2._loadData()` to query module completion + unlock state.
- Streak/Xp signal used in progress map header:
  - `ProgressService.getXp()` and `ProgressService.checkInStreak()` in `UiV2ProgressMapScreenV2._loadData()`.
  - Return loop data via `ReturnLoopServiceV1` (streak + daily hand index).
- Storage backing uses SharedPreferences (via services; see `lib/services/app_settings_service.dart` pattern and `ProgressService`).

## D) Minimal reuse plan (World Map)
- Keep `UiV2ProgressMapScreenV2` and re-label in-place to “World Map” (no new screen).
- Treat each module as a “Level” (same list order). No new data model required.
- Lock Level N+1 until Level N is completed (already implemented via `ProgressService.isModuleCompleted` and `isUnlocked` logic in `_loadData()`):
  - Current logic: force first module unlocked; unlock next module when previous completed.
- Show basic progress states:
  - Completed: uses `isCompleted` -> badge + styling in `_MapNode`.
  - Unlocked (active): uses `isUnlocked` -> icon and border.
  - Locked: blocked tap + locked styling.

## E) Do NOT do list
- Do not introduce new systems/managers/services.
- Do not add new telemetry or analytics events.
- Do not add new screens; reuse Progress Map V2 surface.
- Do not change training pack logic or module data schema.

## F) Risks + Step 2 path (1-2 files max)
- Risks:
  - Module ordering depends on `DirectLoader.loadAvailableModules()` output order; ensure order is deterministic for “Level” sequencing.
  - `ProgressService` may have legacy/alternate completion keys; verify continuity of completion state for existing users.
- Recommended Step 2 implementation path (1-2 files max, no new screens):
  1) `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` — re-label UI (“World Map”, “Level”) and confirm gating semantics remain linear.
  2) If needed, `lib/ui_v2/home/home_screen.dart` — update entry label only (no new routing).
