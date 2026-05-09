# Factual Reusable Hand-Chain Lane v1

Purpose:

- formalize the third explicit repo-level contract+guard-driven production lane
- keep the supported hand-chain lane factual, deterministic, and bounded
- anchor lane truth in authored ordered steps plus structured per-step state, not prompt-only wording or policy residue

## Supported subset

- drill kind: `hand_chain_v1`
- subset class: `factualReusable`
- current bounded chain ids:
  - `w2_s07_position_then_initiative_v1`
  - `w2_s08_texture_then_outs_v1`
  - `w2_s09_position_initiative_texture_v1`
- current bounded source shelf:
  - `content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json`
  - `content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json`
  - `content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json`

## Canonical authored truth

- top-level `chain_id`
- authored ordered `steps`
- deterministic step count and stable step order
- explicit structured target per step
- explicit per-step state required by the reused factual lanes
- explicit `feedback_correct_v1`
- explicit `feedback_incorrect_v1`

Lane truth must come from authored ordered steps plus authored structured step payload, not from runner-local sequencing or prompt-only wording.

## Supported factual compositions

- `w2_s07_position_then_initiative_v1`
  - step 1: `position_thinking_choice_v1` semantics with explicit `question_shape_v1`
  - step 2: `initiative_aggressor_choice_v1` factual initiative state
- `w2_s08_texture_then_outs_v1`
  - step 1: bounded board-texture action encoding already supported in the current validator subset
  - step 2: `outs_count_choice_v1` visible-card factual step
- `w2_s09_position_initiative_texture_v1`
  - step 1: `position_thinking_choice_v1` seat-state semantics
  - step 2: `initiative_aggressor_choice_v1` factual initiative state
  - step 3: bounded board-texture action encoding on the same authored scene

## Enforcement / projection seams

- validator:
  - `lib/services/world2_hand_chain_mixed_subset_validator_v1.dart`
- representative validator guard:
  - `test/tools/world2_hand_chain_mixed_subset_validator_v1_test.dart`
- runtime/source projection contract:
  - `test/ui_v2/session_drill_player_hand_chain_contract_test.dart`

## v1 exclusions

- do not include the follow-up `policyCoupled` chains beyond `w2.s09`
- do not include `capstoneComposition` chains
- do not treat broader `hand_chain_v1` as this lane
- do not infer position-step semantics from prompt wording when `question_shape_v1` is authored
