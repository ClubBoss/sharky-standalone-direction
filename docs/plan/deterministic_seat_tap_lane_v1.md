# Deterministic Seat-Tap Lane v1

Purpose:

- formalize the explicit repo-level contract+guard-driven deterministic runtime-anchor lane for `seat_tap`
- keep lane truth source-owned, symbolic, and reusable across hosts
- anchor correctness in authored `expected.role` / `expected.seatId`, not seat geometry or runner-local projection

## Supported family

- drill kind: `seat_tap`
- current bounded source shelf:
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.find_bb.json`
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.find_btn.json`
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json`
  - `content/worlds/world2/v1/sessions/w2.s01/drills/d.find_seat_s6.json`
  - `content/worlds/world2/v1/sessions/w2.s02/drills/d.find_btn.json`
  - `content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s0.json`
  - `content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s1.json`
  - `content/worlds/world2/v1/sessions/w2.s03/drills/d.find_bb.json`
  - `content/worlds/world2/v1/sessions/w2.s03/drills/d.find_sb.json`
  - `content/worlds/world2/v1/sessions/w2.s05/drills/d.find_btn_turn_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s06/drills/d.find_bb_river_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s07/drills/d.find_btn_pressure_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s07/drills/d.find_seat_s3_pressure_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s09/drills/d.find_bb_bridge_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s09/drills/d.find_seat_s5_bridge_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s10/drills/d.find_btn_checkpoint_anchor.json`
  - `content/worlds/world2/v1/sessions/w2.s10/drills/d.find_seat_s6_checkpoint_anchor.json`

## Canonical authored truth

- `expected.role`
- `expected.seatId`
- `prompt`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`

Lane truth must resolve to one stable symbolic seat anchor from authored copy plus authored target.

## Supported deterministic grammar

- symbolic target fields:
  - `expected.role`
  - `expected.seatId`
- supported symbolic role targets:
  - `btn`
  - `sb`
  - `bb`
- supported symbolic seat targets:
  - `S*`

## Enforcement / projection seams

- runtime-anchor source contract:
  - `docs/plan/world2_runtime_anchor_source_contract_v1.md`
- validator:
  - `lib/services/world2_seat_tap_truth_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_seat_tap_truth_validator_v1_test.dart`
- current runtime event anchor:
  - `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
  - `lib/ui_v2/screens/modern_table_screen_v1.dart`

## v1 residual closeout target

- no dedicated seat-tap UI/runtime projection contract test is named yet
- next bounded closeout, if needed:
  - add one seat-tap surfaced-host/runtime contract anchor without broad host rewrite

## v1 exclusions

- do not treat seat hitboxes or geometry as truth
- do not infer runner-local seat ordering as truth
- do not broaden this lane beyond `seat_tap`
