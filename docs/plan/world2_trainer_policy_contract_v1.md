# World 2 Trainer-Policy Contract v1

Purpose:

- define the canonical lane for trainer-policy semantics without calling it objective truth
- keep policy source authored and reusable
- prevent per-runner or per-node policy patching outside a canonical source seam

## What Trainer-Policy Semantics Are

- authored training defaults, response rules, and simplified practice policy
- deterministic for a given authored node
- useful for consistency validation, but not equivalent to canonical truth

## How Policy Differs From Truth

- truth is contradicted by source fact
- policy is contradicted only by the authored canonical policy source for that node or family
- policy validators check policy-consistency, not real-world poker optimality

## Allowed Canonical Policy Source

- authored `expected.actionId` as the primary policy target
- authored `acceptable_actions` as the bounded tolerance envelope when present
- authored `intent_v1` as policy-bucket metadata
- authored `why_v1` / `feedback_*` / `recap_v1` as explanatory copy that must stay aligned with the canonical policy target

## Allowed Policy Checks

- `expected.actionId` matches the authored policy target for the node
- `acceptable_actions` does not contradict the expected policy branch
- explanatory copy does not contradict the authored policy branch
- deterministic family boundary and explicit exclusions

## Explicitly Disallowed

- treating heuristic advice as objective truth
- using UI behavior as policy source
- using runner-local text or branch behavior as canonical policy
- silently inferring policy from prose when no canonical authored target exists
- broad solver/strategy-engine claims beyond the authored training policy

## Canonical Propagation Rule

- policy should propagate from one canonical authored source seam
- for World 2 `action_choice`, that seam is:
  - `expected.actionId`
  - plus `acceptable_actions` when present
  - plus `intent_v1` as grouping metadata
- fixes should update the canonical authored policy seam, then validators/tools derive from that seam

## Current Pilot Audit

- `action_choice`: clean pilot candidate
- Why:
  - single-step family
  - every current drill has authored `expected.actionId`
  - many drills also provide `acceptable_actions`
  - copy already uses explicit policy wording such as `defined response`, `default`, `approved`, `control`, `value`, `bluff`, `poor price`, `acceptable price`

## Known Pilot Guardrails

- validator output must be labeled policy-consistency, not truth
- mixed `hand_chain_v1` stays out of scope
- heuristic texture / initiative residues stay out of scope until separated from their policy copy
