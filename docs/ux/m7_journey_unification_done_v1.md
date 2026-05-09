# M7 Journey Unification Done v1

- Status: M7 v1 DONE.

- What shipped:
  - Circular-only production map path renderer is active; legacy Act0 square-card section is disabled in production map flow.
  - Levels sheet shipped from map header with deterministic level list, focus lines, and locked/unlocked visibility rules.
  - Level complete sheet shipped with once-only per-level display and explicit next/replay CTAs.

- SSOT entrypoints:
  - `computeLevelCompletionV1(...)` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
  - `computeNextLevelFirstPackIdV1(...)` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
  - UI keys:
    - `map_levels_button_v1`
    - `map_levels_sheet_v1`
    - `map_level_complete_sheet_v1`

- Telemetry:
  - `level_complete_shown_v1`
  - `level_complete_next_clicked_v1`
  - `level_complete_replay_clicked_v1`

- Proof tests and gates:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world1_campaign_telemetry_contract_test.dart`
  - `./tools/fast_loop_world1_v1.sh`
  - PASS signature: `FAST LOOP PASS`

- Out of scope and deferred:
  - Deeper explanation layer v1 (contextual why).
  - Real purchases SDK integration.
  - Future visual polish beyond M6 scope.
