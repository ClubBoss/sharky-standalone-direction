# World 2 Hand-Chain Seam Gap Audit v1

Purpose:

- map current `hand_chain_v1` step-local reuse blockers against already-onboarded single-step seams
- rank mismatch classes by source-level reuse value
- identify at most one bounded seam extension worth implementing now

## Current Step Map

| Class | Count | Current status |
| --- | --- | --- |
| already covered initiative exact steps | 4 | reusable now |
| position preflop boundary mismatch | 0 | resolved in R258 |
| outs/count step shape mismatch | 4 | near-fit |
| action-policy step shape mismatch | 11 | not near-fit yet |

## Mismatch Classes

| Mismatch type | Affected chains / steps | Blocked by | Candidate seam extension | EV / priority | Solve now? |
| --- | --- | --- | --- | --- | --- |
| `position_preflop_boundary` | `chain_position_then_initiative_v1#step1`, `chain_position_initiative_texture_v1#step1`, `chain_position_initiative_action_v1#step1`, `chain_world2_capstone_v1#step1` | onboarded `position_thinking_choice_v1` contract currently rejects `street_v1 == preflop` even when the question is the stable `who is in position` seat-relationship shape | extend the existing position-truth seam to allow preflop `in position` / `out of position` question shapes only | high | yes |
| `outs_count_shape_mismatch` | `chain_texture_then_outs_v1#step2`, `chain_texture_outs_action_v1#step2`, `chain_texture_outs_continue_v1#step2`, `chain_texture_outs_fold_v1#step2` | onboarded outs family expects `outs_count_choice_v1` shape, but chain steps are authored as generic `expected_action` numeric choices | extend the existing outs-truth seam to accept the same canonical cards-plus-numeric-choice shape at step level without changing runner semantics | high | yes |
| `action_policy_shape_mismatch` | `chain_texture_then_outs_v1#step1`, `chain_position_initiative_texture_v1#step3`, `chain_texture_outs_action_v1#step1`, `chain_texture_outs_action_v1#step3`, `chain_position_initiative_action_v1#step3`, `chain_world2_capstone_v1#step3`, `chain_world2_capstone_v1#step4`, `chain_texture_outs_continue_v1#step1`, `chain_texture_outs_continue_v1#step3`, `chain_texture_outs_fold_v1#step1`, `chain_texture_outs_fold_v1#step3` | current action-fitting chain steps expose `expected_action`, but do not carry the published `action_choice` policy seam (`intent_v1`, bounded `acceptable_actions`); policy meaning still depends on prompt/copy phrases such as `pressure-building`, `manageable price`, `poor price`, and `strong draw` | not a clean seam-extension candidate today; only revisit if those steps gain canonical policy metadata instead of prose-only policy meaning | low | no |

## Ranking

1. `outs_count_shape_mismatch`
Reason: same canonical board-plus-hole-cards seam as the onboarded outs family, same numeric answer space, and reuse across 4 current chain steps with no prose-derived rule.
2. `action_policy_shape_mismatch`
Reason: highest raw count, but still not a clean wrapper mismatch because the current chain steps do not share the published `action_choice` policy seam and would require prose-derived or chain-local policy interpretation.

## R258 Selection

- selected seam extension: `position_preflop_boundary`
- rationale:
  - bounded
  - source-driven
  - extends an existing single-step contract
  - improves reuse propagation across multiple chains without per-chain patching

## R259 Selection

- selected seam extension: `outs_count_shape_mismatch`
- rationale:
  - bounded
  - source-driven
  - reuses the existing visible-card outs contract
  - propagates across 4 current chain steps without per-chain or runner-local patching

## R260 Re-audit

- classification for `action_policy_shape_mismatch`: not suitable yet
- why:
  - chain steps expose `expected_action`, but not the published trainer-policy seam fields that make `action_choice` reusable as policy source
  - `acceptable_actions` is absent on all 11 affected steps
  - `intent_v1` is absent on all 11 affected steps
  - board / initiative / draw payload is present on some steps, but the action policy still depends on prose phrases rather than a canonical policy bucket
- result:
  - no clean extension to the existing `action_choice` policy path in R260
  - sharp STOP is correct until canonical policy metadata is authored for these step shapes

## R268 Post-Fix Re-audit

### Chain Classification

| Chain | Classification | Why |
| --- | --- | --- |
| `chain_position_then_initiative_v1` | now cleanly reusable from existing step-local seams | step1 now fits preflop position truth; step2 fits exact initiative truth; authored order is deterministic and two-step only |
| `chain_texture_then_outs_v1` | now cleanly reusable from existing step-local seams | step1 fits normalized action-policy seam; step2 fits outs truth seam |
| `chain_position_initiative_texture_v1` | now cleanly reusable from existing step-local seams | step1 position truth, step2 initiative truth, step3 normalized pressure-board policy |
| `chain_texture_outs_action_v1` | now cleanly reusable from existing step-local seams | step1 normalized pressure-board policy, step2 outs truth, step3 normalized strong-draw policy |
| `chain_position_initiative_action_v1` | now cleanly reusable from existing step-local seams | step1 position truth, step2 initiative truth, step3 normalized pressure-board policy |
| `chain_world2_capstone_v1` | now cleanly reusable from existing step-local seams | all four steps now fit onboarded position / initiative / policy seams |
| `chain_texture_outs_continue_v1` | now cleanly reusable from existing step-local seams | step1 normalized pressure-board policy, step2 outs truth, step3 normalized manageable-price policy |
| `chain_texture_outs_fold_v1` | now cleanly reusable from existing step-local seams | step1 normalized pressure-board policy, step2 outs truth, step3 normalized poor-price release policy |

### R268 Selection

- first bounded mixed-multi-step pilot subset:
  - `chain_position_then_initiative_v1`
- why this first:
  - smallest non-trivial chain
  - deterministic authored order
  - every step reuses exact-answer truth seams only
  - no embedded action-policy follow-up needed for the first pilot

## R269 Re-cluster

### Remaining Cluster Map After The Pilot

| Cluster | Chains | Shared step-shape composition | Status |
| --- | --- | --- | --- |
| `position_then_initiative_then_pressure_policy` | `chain_position_initiative_texture_v1`, `chain_position_initiative_action_v1` | preflop position -> flop initiative -> flop pressure-board action policy | selected in R269 |
| `texture_then_outs` | `chain_texture_then_outs_v1` | flop pressure-board policy -> flop outs truth | hold for later bounded step |
| `texture_then_outs_then_followup_policy` | `chain_texture_outs_action_v1`, `chain_texture_outs_continue_v1`, `chain_texture_outs_fold_v1` | flop pressure-board policy -> flop outs truth -> flop draw follow-up policy | hold for later bounded step |
| `position_then_initiative_then_two_policy_steps` | `chain_world2_capstone_v1` | preflop position -> flop initiative -> flop board policy -> flop draw policy | hold for later bounded step |

### R269 Selection

- next bounded mixed-multi-step cluster:
  - `chain_position_initiative_texture_v1`
  - `chain_position_initiative_action_v1`
- why this cluster:
  - same validation pattern as the existing pilot plus one already-onboarded action-policy step
  - no outs-step or four-step expansion
  - no chain-local special handling

## R270 Re-cluster

### Remaining Cluster Ranking After R269

| Rank | Cluster | Chains | Why |
| --- | --- | --- | --- |
| 1 | `texture_then_outs_then_followup_policy` | `chain_texture_outs_action_v1`, `chain_texture_outs_continue_v1`, `chain_texture_outs_fold_v1` | same three-step composition across all chains, same flop-only structure, same texture-policy -> outs-truth -> followup-policy reuse pattern, and no hidden branch-specific validator rules needed |
| 2 | `texture_then_outs` | `chain_texture_then_outs_v1` | clean but singleton and lower EV than the reusable three-chain cluster |
| 3 | `position_then_initiative_then_two_policy_steps` | `chain_world2_capstone_v1` | still clean, but four-step capstone expansion is a broader move than needed now |

### R270 Selection

- next bounded mixed-multi-step cluster:
  - `chain_texture_outs_action_v1`
  - `chain_texture_outs_continue_v1`
  - `chain_texture_outs_fold_v1`
- why selected:
  - highest EV remaining clean cluster
  - all chains share the same authored validation composition
  - no chain-local special handling beyond already-onboarded step-local seams

## R271 Audit

### Remaining Candidate Check After R270

| Candidate | Classification | Why |
| --- | --- | --- |
| `chain_texture_then_outs_v1` | clean standalone mixed-subset candidate | deterministic two-step flop order, one structured target per step, and exact reuse of the onboarded action-policy plus outs seams with no chain-local rules |
| `chain_world2_capstone_v1` | hold for later bounded step | four-step capstone expansion is still a broader move than needed for the next incremental onboarding |

### R271 Selection

- next bounded mixed-multi-step singleton:
  - `chain_texture_then_outs_v1`
- why selected:
  - closes the simplest remaining non-capstone chain shape
  - reuses the existing mixed-subset validation pattern without any new semantics
  - leaves the capstone explicitly isolated for a later bounded decision

## R272 Audit

### Final Remaining Candidate Check After R271

| Candidate | Classification | Why |
| --- | --- | --- |
| `chain_world2_capstone_v1` | clean standalone mixed-subset candidate | deterministic four-step authored order, one structured target per step, and exact reuse of the onboarded position, initiative, and action-policy seams with no hidden branching or chain-local semantics |

### R272 Selection

- final bounded mixed-multi-step singleton:
  - `chain_world2_capstone_v1`
- why selected:
  - it is the final current `hand_chain_v1` authored shape
  - it still fits the existing bounded mixed-subset validation pattern
  - onboarding it closes the current family without widening into a generic engine
