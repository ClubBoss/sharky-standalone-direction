# Archived UI Subsystem: lib/ui_v2/persona

## Archive Date
2026-05-14 (cleanup phase 3)

## Size
1.7M (399 files)

## Why Archived
- **No usage in Act0 shell** — the current active learner-facing product
- **Only used in abandoned simulation surface** — lib/ui_v2/simulation/simulation_table_screen.dart (not part of Act0)
- **Only used in old UI v3 map** — lib/ui_v3/learning_map_screen.dart (not the current active surface)
- **Legacy AI/ML subsystem** — built during earlier AI personalization exploration phase, then simplified away
- **Replaced by simpler lib/personalization/** — current app uses lib/personalization/ (132K, 21 files) instead

## Contents
- `ai_personalization/` — tier-based AI personalization system (themes, moods, etc.)
- `emotion/` — emotion engine subsystem
- Various persona UI components (renderer, controller, panel, etc.)
- Visual effects and state management

## Dependencies
Archive was isolated from lib/ui_v2/persona:
- Deleted 10 dependent files that were dead code:
  - 6 QA/test files (consolidation_qa_v4, stability_qa_bridge_v2, snapshot_runner_v3, etc.)
  - 4 unused production files (player_profile_screen, content_root, recommendations/*)

## Recovery Path
If future work needs persona functionality:
1. Review `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md` for design principles
2. Restore from git: `git checkout HEAD -- lib/ui_v2/persona/`
3. Consider migrating to lib/personalization/ instead for current product

## Notes
- lib/personalization/ (132K, 21 files) is the active replacement
- lib/ui_v2/simulation/ is broken without persona but not used in Act0
- lib/ui_v3/ also depends on persona but is not the active runtime surface
