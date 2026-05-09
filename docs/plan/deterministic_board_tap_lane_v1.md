# Deterministic Board-Tap Lane v1

Purpose:

- formalize the explicit repo-level contract+guard-driven deterministic runtime-anchor lane for `board_tap`
- keep lane truth source-owned, symbolic, and reusable across hosts
- anchor correctness in authored `expected.boardSlot`, not UI geometry or runner-local projection

## Supported family

- drill kind: `board_tap`
- current bounded source shelf:
  - `content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json`
  - `content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json`
  - `content/worlds/world2/v1/sessions/w2.s05/drills/d.tap_turn_context.json`
  - `content/worlds/world2/v1/sessions/w2.s06/drills/d.tap_river_context.json`
  - `content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_flop_sequence_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_turn_sequence_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s08/drills/d.tap_river_sequence_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_flop_mid_checkpoint_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s10/drills/d.tap_turn_checkpoint_anchor.json`

## Canonical authored truth

- `expected.boardSlot`
- `prompt`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`

Lane truth must resolve to one stable symbolic board anchor from authored copy plus authored target.

## Supported deterministic grammar

- symbolic target field: `expected.boardSlot`
- supported symbolic slots:
  - `flop_left`
  - `flop_mid`
  - `flop_right`
  - `turn`
  - `river`

## Enforcement / projection seams

- runtime-anchor source contract:
  - `docs/plan/world2_runtime_anchor_source_contract_v1.md`
- validator:
  - `lib/services/world2_board_tap_truth_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_board_tap_truth_validator_v1_test.dart`
- current runtime event anchor:
  - `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
  - `lib/ui_v2/screens/modern_table_screen_v1.dart`

## v1 residual closeout target

- no dedicated board-tap UI/runtime projection contract test is named yet
- next bounded closeout, if needed:
  - add one board-tap surfaced-host/runtime contract anchor without broad host rewrite

## v1 exclusions

- do not treat UI coordinates or hitboxes as truth
- do not infer runner-local board ordering as truth
- do not broaden this lane beyond `board_tap`
