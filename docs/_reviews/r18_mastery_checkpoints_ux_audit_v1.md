# R18 Mastery & Checkpoints UX Audit v1

## Purpose and Scope
- Milestone: R18 - Mastery & Checkpoints UX v1 (User-visible Loop).
- Scope locked: map checkpoint entry UX, runner checkpoint cue/step semantics, checkpoint completion return path.
- This is a closeout audit for P0.1-P0.4 with deterministic contract evidence.

## Contract Pointers
- P0.1 Map checkpoint entry UX (pending-only strip + deterministic CTA):
  - Runtime: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
    - `map_checkpoint_pending_strip`
    - `map_checkpoint_pending_text_v1`
    - `checkpoint_entry_cta_v1`
    - `_openGlobalCheckpointPackV1()` -> `season1_checkpoint_global_v1`
  - Tests:
    - `test/guards/world_campaign_map_home_contract_test.dart`
      - `checkpoint pending map strip opens global checkpoint and clears after completion`
      - `checkpoint pending strip is hidden when checkpoint is not pending`

- P0.2 Runner cue + step semantics (`Step X of 6` + checkpoint cue):
  - Runtime: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
    - `checkpoint_runner`
    - checkpoint cue text surface
  - Tests:
    - `test/ui_v2/session_result_screen_contract_test.dart`
      - `r17 checkpoint runner consumes seed top-3 deterministically`
      - asserts `Step 1 of 6`
      - asserts `Checkpoint: review your top mistakes.`

- P0.3 Completion return path and no dead ends:
  - Runtime:
    - `lib/ui_v2/screens/session_result_screen.dart`
    - `lib/services/progress_service.dart`
  - Tests:
    - `test/ui_v2/session_result_screen_contract_test.dart`
      - `r17 checkpoint pending routes to checkpoint pack and clears after checkpoint completion`
      - `r9 p0.5: after cash s03 result, back-to-map return path is deterministic`

## Tier0 Evidence (Behavior Locking Pass)
- Locking diff commit: `a3457ab4e`
- `flutter analyze`: PASS
- `./tools/fast_loop_world1_v1.sh`: PASS

## Open Risk List
- P0 risks: none.
- P1 risks: none.

Open-risk list is empty.

## Closeout Statement
- R18 DoD is satisfied with deterministic runtime behavior and contract coverage.
- No schema changes, no dependency changes, no content drift.
