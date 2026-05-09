# Deterministic Outs Lane v1

Purpose:

- formalize the first explicit repo-level contract+guard-driven deterministic drill lane
- keep the supported outs lane factual, bounded, and batch-safe
- anchor lane truth in authored visible-card state rather than prose or trainer preference

## Supported family

- drill kind: `outs_count_choice_v1`
- current bounded source shelf:
  - `content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json`
  - `content/worlds/world2/v1/sessions/w2.s06/drills/d.count_open_ended_straight_draw_eight_outs.json`
  - `content/worlds/world2/v1/sessions/w2.s06/drills/d.count_gutshot_four_outs.json`

## Canonical authored truth

- `street_v1`
- `hero_hole_cards_v1`
- `board_cards_v1`
- `available_actions_v1`
- `expected.actionId`
- `feedback_correct_v1`
- `feedback_incorrect_v1`

Lane truth must come from visible cards plus authored target, not from prompt-only wording.

## Supported deterministic grammar

- runtime answer grammar: `4|8|9|15`
- supported canonical visible-card outcomes in the current lane:
  - `4`
  - `8`
  - `9`

## Enforcement / projection seams

- validator:
  - `lib/services/world2_outs_truth_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_outs_truth_validator_v1_test.dart`
- runtime/source projection contract:
  - `test/ui_v2/session_drill_player_world2_outs_contract_test.dart`

## v1 exclusions

- do not treat non-visible-card heuristics as part of this lane
- do not broaden this lane beyond `outs_count_choice_v1`
- do not infer missing source fields from prompt wording
