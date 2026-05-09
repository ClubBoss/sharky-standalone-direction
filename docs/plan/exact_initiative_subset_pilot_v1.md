# Exact Initiative Subset Pilot v1

Purpose:

- formalize the bounded partial-family pilot for the exact `initiative_aggressor_choice_v1` subset
- keep truth source-owned and contract-first
- exclude the remaining pressure-shaped residue until a non-prose source seam exists

## Supported family boundary

- drill kind: `initiative_aggressor_choice_v1`
- current exact checked subset:
  - `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json`
  - `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json`

## Canonical authored truth

- `last_aggressor_v1`
- `initiative_owner_v1`
- `active_seats_v1`
- `street_v1`
- `expected.actionId`
- `prompt`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`

Pilot truth must resolve to one exact actor from authored initiative state, not from pressure-policy language.

## Supported exact question shapes

- `Who was the last aggressor?`
- `Who has initiative?`

## Enforcement / projection seams

- validator:
  - `lib/services/world2_initiative_truth_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_initiative_truth_validator_v1_test.dart`
- current surfaced-host/runtime contract anchor:
  - `test/ui_v2/session_drill_player_initiative_contract_test.dart`

## Explicit exclusions

- `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json`
- `content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json`

Excluded because the pressure residue still depends on prose-level policy wording rather than one canonical non-prose initiative seam.

## v1 residual closeout state

- no extra runtime closeout is required for the exact subset pilot
- the surfaced-host/runtime anchor already exists for the exact initiative family path
