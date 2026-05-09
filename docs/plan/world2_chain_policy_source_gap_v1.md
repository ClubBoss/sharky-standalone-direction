# World 2 Chain Policy Source Gap v1

Purpose:

- define the minimal structured policy seam missing from current World 2 `hand_chain_v1` action-policy steps
- keep future policy validation source-driven
- prevent prose-carried chain policy from being treated as canonical source

## Current Structured Policy Source In `action_choice`

| Field | Role |
| --- | --- |
| `expected.actionId` | primary policy target |
| `acceptable_actions` | bounded tolerance envelope when present |
| `intent_v1` | policy-bucket metadata |

## Current Structured Source In Chain Action-Policy Steps

| Field | Present now | Role |
| --- | --- | --- |
| `expected_action` | yes | primary chosen action |
| `available_actions_v1` | yes | answer menu shape |
| `board_texture_v1` | partial | board-state context only |
| `board_cards_v1` | partial | board-state context only |
| `hero_hole_cards_v1` | partial | hand-state context only |
| `initiative_owner_v1` / `last_aggressor_v1` | partial | initiative state only |
| `acceptable_actions` | no | missing policy tolerance seam |
| `intent_v1` | no | missing policy-bucket seam |

## Exact Seam Gap

- current chain action-policy steps already expose the selected action
- they do not expose the authored policy bucket that explains why that action is the canonical training response
- they do not expose whether any second-best action is intentionally tolerated
- current policy meaning therefore lives in `prompt`, `why_v1`, `feedback_*`, and `recap_v1`, which is not an allowed canonical policy source

## Smallest Canonical Payload Extension Needed

- add explicit policy-bucket metadata at step level:
  - minimal concept: step-local `intent_v1` analogous to `action_choice`
- add bounded tolerance only when the authored policy actually intends it:
  - minimal concept: step-local `acceptable_actions`
- keep the primary target as the existing step-local `expected_action`

## Recommended Normalized Step Shape

| Field | Requirement |
| --- | --- |
| `expected_action` | required |
| `intent_v1` | required for action-policy-shaped chain steps |
| `acceptable_actions` | optional, but canonical when present |

## What Remains Out Of Scope

- broad strategy taxonomies
- solver-style metadata
- new runtime sequencing logic
- deriving policy buckets from `board_texture_v1`, initiative, draw strength, or prompt wording alone
- inferring tolerance from feedback copy alone

## Why This Is Source Normalization, Not Validator Work

- validators already know how to check a canonical policy seam once it is authored
- the current blocker is that the seam is absent from source for chain action-policy steps
- adding validators before normalizing source would force prose-derived or chain-local policy inference, which is explicitly disallowed

## R261 Recommendation

- smallest normalization path: one minimal content contract extension for action-policy-shaped chain steps
- exact recommendation:
  - reuse step-local `expected_action`
  - add step-local `intent_v1`
  - allow step-local `acceptable_actions` when needed
- next implementation step should be source-normalization only; do not start with validator work or chain onboarding

## R263 Pilot Expansion Note

- normalized subset expanded only for the homogeneous `texture_pressure_building` steps that ask the same texture-matching `call` vs `raise` question
- still blocked:
  - draw-plus-price follow-up steps
  - singleton pressure-board follow-up step without draw metadata (`chain_position_initiative_action_v1#step3`)

## R264 Selection Note

- selected next homogeneous subset:
  - `chain_texture_outs_action_v1#step3`
  - `chain_world2_capstone_v1#step4`
- shared canonical policy meaning:
  - strong draw on a pressure-building flop supports the assertive `raise` over passive `call`
- normalization applied:
  - kept `expected_action: "raise"`
  - added step-local `intent_v1: "draw_pressure_assertive"`
  - did not add `acceptable_actions` because authored tolerance is not present
- still blocked after R264:
  - draw-plus-price follow-up steps still split across opposite `call` vs `fold` meanings and would need new price-discipline semantics
  - `chain_position_initiative_action_v1#step3` remains a singleton pressure-board follow-up and is not a non-trivial homogeneous subset by itself

## R265 Draw-Price Re-audit Note

- explicit remaining pair inspected:
  - `chain_texture_outs_continue_v1#step3`
  - `chain_texture_outs_fold_v1#step3`
- honest split result:
  - clean bounded subset: `chain_texture_outs_continue_v1#step3`
  - remaining blocker: `chain_texture_outs_fold_v1#step3`
- selected canonical policy meaning:
  - strong draw plus manageable continue price supports `call` over `fold`
- normalization applied:
  - kept `expected_action: "call"`
  - added step-local `intent_v1: "draw_price_continue"`
  - did not add `acceptable_actions` because no authored tolerance is present
- still blocked after R265:
  - `chain_texture_outs_fold_v1#step3` is a separate poor-price release meaning and cannot share the same bucket honestly
  - `chain_position_initiative_action_v1#step3` remains a singleton pressure-board follow-up outside the draw-price residue

## R266 Poor-Price Singleton Note

- explicit singleton inspected:
  - `chain_texture_outs_fold_v1#step3`
- standalone audit result:
  - clean bounded subset
- selected canonical policy meaning:
  - weak draw plus poor continue price supports `fold` over `call`
- normalization applied:
  - kept `expected_action: "fold"`
  - added step-local `intent_v1: "draw_price_release"`
  - did not add `acceptable_actions` because no authored tolerance is present
- still blocked after R266:
  - `chain_position_initiative_action_v1#step3` remains the only visible hand-chain policy-shaped residue and is still a singleton pressure-board follow-up

## R267 Pressure-Board Singleton Note

- explicit singleton inspected:
  - `chain_position_initiative_action_v1#step3`
- standalone audit result:
  - clean bounded subset
- selected canonical policy meaning:
  - same existing `texture_pressure_building` meaning already used by other pressure-board `call` vs `raise` steps
- normalization applied:
  - kept `expected_action: "raise"`
  - added step-local `intent_v1: "texture_pressure_building"`
  - did not add `acceptable_actions` because no authored tolerance is present
- still blocked after R267:
  - no remaining visible `hand_chain_v1` action-policy residue is tracked in this note set
