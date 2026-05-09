# Board Texture Dry Subset Policy Pilot v1

Purpose:

- formalize the bounded trainer-policy pilot for the `dry` residue inside `board_texture_classifier_v1`
- keep the pilot policy-source-owned and contract-first
- keep this pilot explicitly separate from the exact board-texture truth subset

## Supported family boundary

- drill kind: `board_texture_classifier_v1`
- current dry-policy subset:
  - `content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json`
  - `content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json`

This pilot is trainer-policy semantics, not canonical truth.

## Canonical authored policy seam

- `board_texture_policy_shape_v1`
- `board_texture_policy_target_v1`
- `expected_action`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`
- `recap_v1` when present

Policy must resolve from the authored policy seam, not from runner-local behavior or prose inference alone.

## Supported policy shape

- `board_texture_policy_shape_v1: "pressure_level"`
- current bounded value: `pressure_level`

## Supported policy target

- `board_texture_policy_target_v1: "calmer"`
- current bounded value: `calmer`

## Enforcement / projection seams

- current board-texture truth validator boundary reference:
  - `lib/services/world2_board_texture_truth_validator_v1.dart`
- representative validator/test guard:
  - `test/tools/world2_board_texture_truth_validator_v1_test.dart`
- current surfaced-host/runtime contract anchors:
  - `test/ui_v2/session_drill_player_world2_board_texture_contract_test.dart`
  - `test/ui_v2/session_drill_player_board_texture_contract_test.dart`
- semantic boundary:
  - `docs/plan/world2_semantic_boundary_v1.md`
- trainer-policy contract:
  - `docs/plan/world2_trainer_policy_contract_v1.md`

## Explicit separation from exact board-texture truth

- exact board-texture truth remains limited to:
  - `paired`
  - `connected`
- dry subset is not part of the exact board-texture truth pilot
- dry subset must be evaluated as trainer-policy consistency, not as objective board-shape truth

## v1 residual closeout state

- no extra runtime closeout is required for this bounded policy pilot
- the current board-texture surfaced-host/runtime anchors already exist at the family level
