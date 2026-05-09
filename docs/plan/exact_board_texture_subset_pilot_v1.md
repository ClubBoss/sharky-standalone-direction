# Exact Board Texture Subset Pilot v1

Purpose:

- formalize the bounded partial-family pilot for the exact `board_texture_classifier_v1` subset
- keep truth source-owned and contract-first
- exclude the remaining `dry` residue until a non-policy exact seam exists

## Supported family boundary

- drill kind: `board_texture_classifier_v1`
- current exact checked subset:
  - `content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json`
  - `content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json`

## Canonical authored truth

- exactly 3 `board_cards_v1`
- `board_texture_v1`
- `street_v1`
- `expected.actionId`
- `prompt`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`

Pilot truth must resolve from authored board cards plus exact texture label, not from calmer / pressure-building policy wording.

## Supported exact texture labels

- `paired`
- `connected`

## Enforcement / projection seams

- validator:
  - `lib/services/world2_board_texture_truth_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_board_texture_truth_validator_v1_test.dart`
- current surfaced-host/runtime contract anchors:
  - `test/ui_v2/session_drill_player_world2_board_texture_contract_test.dart`
  - `test/ui_v2/session_drill_player_board_texture_contract_test.dart`

## Explicit exclusions

- `content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json`
- `content/worlds/world2/v1/sessions/w2.s05/drills/d.review_texture_dry_board_stays_calmer.json`

Excluded because `dry` still depends on calmer / pressure-building policy framing rather than one clean exact board-shape seam, and the review node also lacks the full exact-card payload expected by this pilot.

## v1 residual closeout state

- no extra runtime closeout is required for the exact subset pilot
- surfaced-host/runtime anchors already exist for the board-texture family path
