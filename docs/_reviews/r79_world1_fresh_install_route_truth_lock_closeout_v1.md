# R79 World1 Fresh-Install Route Truth Lock Closeout v1

## Purpose and scope
- Lock and prove first-user route truth on the authoritative map/progress seam:
  - `Start Now -> Act0-first -> runner launch`
- Scope stayed bounded to:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/services/progress_service.dart`
  - targeted map contract coverage
- Out of scope respected:
  - no new Scenario Truth families,
  - no result/finish work,
  - no Worlds2-10 migration,
  - no broad refactor.

## PIEC reconciliation summary
- Reconciled:
  - `docs/_reviews/r74_authoritative_user_visible_surface_registry_v1.md`
  - `docs/_reviews/r77_world1_phase_contracts_v1.md`
  - `docs/_reviews/r77_world1_repro_matrix_v1.md`
  - `docs/_reviews/r78_world1_scenario_truth_pilot_closeout_v1.md`
- Authoritative chain confirmed:
  - map owner: `_handleCampaignStartNowActionV1()`
  - pack resolver: `_resolveEarliestIncompleteWorld1PackIdV1()`
  - launcher: `_openNextCampaignPackFromSsoT()` -> `_openCampaignPack(...)`
  - source order: `kWorld1CanonicalModuleOrder`

## What changed
- Runtime behavior change: none (proof-first closure).
- Contract strengthening only:
  - expanded Start Now earliest-incomplete ladder assertions in:
    - `test/guards/world_campaign_map_home_contract_test.dart`
  - covered cases now include:
    - fresh-install empty completion -> `world1_act0_table_literacy`
    - first Act0 complete -> `world1_act0_action_literacy`
    - first two Act0 complete -> `world1_act0_street_flow`
    - all Act0 complete -> `world1_spine_campaign_v1`

## User-visible effect
- No UI changes.
- Regression risk reduced: Start Now first-user routing can no longer silently drift deeper than canonical earliest incomplete World1 pack without test failure.

## Repro matrix update
- `W1-RM-003` updated to guarded via route truth lock in:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md`

## Open risk / defer
- Result/finish route coherence (`W1-RM-005`) remains deferred and unchanged by R79.
- Non-fresh-install personalization/checkpoint routing remains intentionally outside this milestone.
