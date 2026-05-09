# Initiative Pressure Subset Policy Pilot v1

Purpose:

- formalize the bounded trainer-policy pilot for the pressure residue inside `initiative_aggressor_choice_v1`
- keep the pilot policy-source-owned and contract-first
- keep this pilot explicitly separate from the exact initiative truth subset

## Supported family boundary

- drill kind: `initiative_aggressor_choice_v1`
- current pressure-policy subset:
  - `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json`
  - `content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json`

This pilot is trainer-policy semantics, not canonical truth.

## Canonical authored policy seam

- `initiative_policy_shape_v1`
- `pressure_owner_v1`
- `expected.actionId`
- `why_v1`
- `feedback_correct_v1`
- `feedback_incorrect_v1`
- `recap_v1` when present

Policy must resolve from the authored policy seam, not from runner-local behavior or prose inference alone.

## Supported policy shape

- `initiative_policy_shape_v1: "pressure_owner"`
- current bounded value: `pressure_owner`

## Enforcement / projection seams

- current initiative truth validator boundary reference:
  - `lib/services/world2_initiative_truth_validator_v1.dart`
- representative validator/test guard:
  - `test/tools/world2_initiative_truth_validator_v1_test.dart`
- current surfaced-host/runtime contract anchor:
  - `test/ui_v2/session_drill_player_initiative_contract_test.dart`
- semantic boundary:
  - `docs/plan/world2_semantic_boundary_v1.md`
- trainer-policy contract:
  - `docs/plan/world2_trainer_policy_contract_v1.md`

## Explicit separation from exact initiative truth

- exact initiative truth remains limited to:
  - `Who was the last aggressor?`
  - `Who has initiative?`
- pressure subset is not part of the exact initiative truth pilot
- pressure subset must be evaluated as trainer-policy consistency, not as objective initiative truth

## v1 residual closeout state

- no extra runtime closeout is required for this bounded policy pilot
- the current initiative surfaced-host/runtime anchor already exists at the family level
