# World 2 Semantic Boundary v1

Purpose:

- define the boundary between canonical truth, trainer-policy semantics, and mixed multi-step semantics
- prevent heuristic advice from being mislabeled as truth
- keep next-lane selection honest and bounded

## Semantic Buckets

| Bucket | Definition | Allowed validation style |
| --- | --- | --- |
| canonical truth | answer derives from authored cards, structured state, or source-owned symbolic targets and resolves to a deterministic fact | truth validators may enforce exact contradictions from source truth |
| trainer-policy / heuristic semantics | answer expresses the trainer's preferred default, pressure rule, or simplified strategic policy rather than an objective fact | policy validators may only enforce consistency against an explicit authored policy contract, not claim objective truth |
| mixed multi-step semantics | flow combines multiple steps or multiple semantic buckets in one unit | validate only after step-level semantics are isolated; do not force into single-step validators |
| not yet classifiable | authored/source structure is too weak to separate truth from policy cleanly | stop and refine authored structure before onboarding |

## Why The Distinction Matters

- canonical truth can be validated as contradiction against source fact
- trainer-policy semantics may be useful, but they are not objective truth
- mixed chains can reuse prior validators at the step level, but the chain itself is not one truth family

## Explicitly Disallowed

- treating heuristic advice as truth
- forcing multi-step flow into single-step validators
- encoding runner-local behavior as content truth

## Current World 2 Boundary

| Family or residue | Bucket | Reason |
| --- | --- | --- |
| onboarded showdown / outs / position / runtime-anchor families | canonical truth | deterministic source fact or symbolic target |
| `board_texture_classifier_v1` remaining `dry` subset | trainer-policy / heuristic semantics | `dry` is coupled to calmer / pressure-building advice |
| `initiative_aggressor_choice_v1` remaining pressure subset | trainer-policy / heuristic semantics | `more likely to continue pressure` is a heuristic tendency, not fact |
| `action_choice` | trainer-policy / heuristic semantics | expected action is a trainer default or policy response |
| `hand_chain_v1` | mixed multi-step semantics | steps combine truth, policy, and sequencing in one unit |

## Honest Next-Lane Candidate

- next lane: trainer-policy semantics
- smallest clean pilot candidate: `action_choice`
- reason:
  - single-step family
  - bounded expected action per authored node
  - cleaner than `hand_chain_v1`, which is already mixed by construction

## Pilot Preconditions

- define an explicit policy contract first
- make clear that validator output is policy-consistency, not truth
- keep chain families out of scope until step-level policy/truth boundaries are reused cleanly
