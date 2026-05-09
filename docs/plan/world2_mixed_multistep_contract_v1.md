# World 2 Mixed Multi-Step Contract v1

Purpose:

- define the canonical lane for mixed multi-step semantics without flattening chains into single-step truth or trainer-policy
- keep chain validation sourced from authored structured chain payload
- prevent runner-local sequencing or prose from becoming the canonical chain source

## What Mixed Multi-Step Semantics Are

- one authored unit contains an ordered sequence of steps
- different steps may belong to different semantic lanes
- the chain is validated as a structured sequence of source-owned step states, not as one single-step truth family

## How Mixed Multi-Step Differs From Other Lanes

| Lane | Canonical source | What validators may claim |
| --- | --- | --- |
| canonical truth | cards, structured state, or symbolic target for one answer unit | exact contradiction against source fact |
| trainer-policy | authored policy target plus bounded tolerance for one answer unit | policy-consistency only |
| mixed multi-step | ordered authored `steps` plus per-step structured targets and per-step structured state | chain-structure consistency and step-level lane consistency only |

## Valid Canonical Chain Source

- top-level `chain_id`
- authored ordered `steps`
- for each step:
  - `street`
  - exactly one structured target: `expected_action` or `expected_preset_id` or `range_bucket_v1`
  - explicit structured state when the step depends on it:
    - seat state fields
    - board / hole-card fields
    - initiative fields
    - available action/preset fields
- canonical chain meaning must come from the authored ordered steps and authored structured step payload, not from runner transitions or explanatory prose

## Allowed Validation

- chain shape is bounded and deterministic:
  - `hand_chain_v1`
  - `steps` length
  - stable step order
  - one structured target per step
- step-local validation may reuse an already-defined lane when the step payload is sufficient
- chain-local validation may check only authored structural consistency such as:
  - repeated state staying identical when the later step explicitly reauthors the same state
  - later steps not dropping required structured state for the step target they ask the learner to answer
  - explicit exclusions for steps or chains whose step semantics are not yet canonically isolated

## Explicitly Disallowed

- flattening the whole chain into one truth answer
- treating `why_v1`, `feedback_*`, `recap_v1`, or prompt wording as the canonical chain source
- inferring omitted step state from phrases such as `keep the same flop` or `same scene`
- using runner-local current-step behavior as the canonical sequence definition
- broad generic chain engines or strategy systems

## Pilot Selection Criteria

- current family exposes a canonical non-prose seam through ordered steps plus structured per-step targets
- at least one bounded subset can be checked using already-defined step-local lanes or other explicit structured contracts
- exclusions can be stated deterministically at the chain or step level
- validator can stay family-specific and compact

## Current Hand-Chain Audit Snapshot

- canonical seam exists in current authored `hand_chain_v1` payload:
  - ordered `steps`
  - one structured target per step
  - explicit per-step board / seat / initiative payload where authored
- current blocker for full-family onboarding:
  - most World 2 chains still include action-fitting steps whose policy seam is embedded in the chain step and not yet isolated as a reusable non-prose step-local contract
- current blocker for first pilot subset onboarding:
  - no current World 2 chain reuses already-onboarded step-local contracts on every step
  - closest candidate `chain_position_then_initiative_v1` still starts with a preflop position step, while the onboarded position-truth contract is explicitly postflop-only
- post-R257 pilot status:
  - lane defined
  - no non-trivial clean pilot subset onboarded yet
