# Scenario-Driven Rollout Contract v1

Purpose:

- formalize the shared guarded-scale contract already proven across the first rollout wave
- define the minimum contract shape a slice must satisfy before it is treated as a clean scenario-driven rollout slice
- keep future rollout decisions factory-like instead of ad hoc

## Use

Use this document after a family or bounded subset has already proven:

- a stable authored truth seam
- a bounded validator/test surface
- a realistic runtime path

This document does not start a broad rewrite.
It defines the minimum shared rollout contract for slices that are being promoted from bounded pilot work into stable scenario-driven rollout.

## Proven rollout set used to extract this contract

- `outs_count_choice_v1`
- `showdown_winner_choice_v1`
- `board_tap`
- `seat_tap`
- exact initiative subset
- exact board-texture subset
- exact position subset
- bounded factual reusable hand-chain subset

## Core rule

- authored source owns scenario truth
- the interpreter path must prefer normalized contract payloads over local screen wiring
- rollout promotion requires contract proof, not just reachability

## Minimum shared rollout contract

### 1. Normalized scenario payload ownership

A rollout slice must expose a normalized contract-layer scenario payload.

Examples already proven in the repo:

- `scenarioOutsContextV1`
- `scenarioShowdownContextV1`
- `scenarioBoardTapContextV1`
- `scenarioSeatTapContextV1`
- `scenarioInitiativeContextV1`
- `scenarioBoardTextureContextV1`
- `scenarioPositionContextV1`
- `scenarioFactualHandChainContextV1`

The normalized payload should carry the slice truth needed by the interpreter and surfaced host.
The screen should not remain the primary owner of that truth.

### 2. Interpreter-facing expected target shape

The rollout slice must expose one stable interpreter-facing target shape through the normalized payload.

Examples:

- symbolic target:
  - `expectedBoardSlotV1`
  - `expectedSeatIdV1`
  - `expectedRoleV1`
- exact answer target:
  - `expectedActionIdV1`
- multi-step factual target:
  - current-step normalized target inside ordered chain-step contexts

If the expected target still depends mainly on local widget branching or prose inference, the slice is not yet ready for rollout promotion.

### 3. Source/meta contract expectations

The meaningful surfaced source/meta path must read from the normalized payload.

This includes, where relevant:

- board labels
- seat labels
- source/meta chips
- current-step factual source displays

Bounded fallback code is acceptable.
Primary surfaced source/meta projection must prefer the normalized payload.

### 4. Prompt/reveal handoff expectations

The meaningful user-facing prompt/reveal path must prefer the normalized payload.

This includes, where relevant:

- prompt override / short prompt
- reveal / why copy
- feedback copy
- current-step handoff for multi-step factual slices

If prompt/reveal still centers on raw family-local structures, rollout closeout is not complete.

### 5. Rollout-closeout evidence required

A slice should not be called clean until all of the following exist:

- canonical authored truth seam or bounded authored policy seam
- normalized scenario payload in the contract layer
- interpreter-facing expected target shape
- validator/tool coverage appropriate to the slice
- targeted UI/runtime contract coverage
- no remaining meaningful local-UI truth bypass on the active surfaced/interpreter path

## Acceptable residuals

The following do not block rollout closeout by themselves:

- assertions and defensive guards
- bounded fallback paths
- failure-detail messaging that still references raw expected fields
- generic helper code that is not the primary authored-truth path

## What blocks rollout closeout

Do not promote a slice as clean if any of the following still apply:

- source truth is still mainly inferred from prose
- expected target is still owned by local widget logic
- surfaced source/meta still depends on raw family-local reads
- prompt/reveal still depends on raw family-local structures
- multi-step sequencing still lacks a normalized current-step interpreter handoff

## How to classify the next candidate

When evaluating a new rollout candidate, ask:

1. Is there a normalized scenario payload already, or can one be added in one bounded seam?
2. Is the expected target shape explicit and stable?
3. Does the surfaced source/meta path prefer the normalized payload?
4. Does the prompt/reveal path prefer the normalized payload?
5. Do targeted validator and UI/runtime tests already exist or fit naturally?

If those answers are mostly yes, the slice is a valid rollout candidate.
If not, the next move should be a bounded prerequisite seam, not rollout promotion.

## Relationship to other planning docs

- scenario-driven direction:
  - `docs/plan/SCENARIO_DRIVEN_TRAINING_ENGINE_CONTRACT_PLAN_v1.md`
- mode-family discipline:
  - `docs/plan/MODE_FAMILY_STRATEGY_v1.md`
- package-type taxonomy:
  - `docs/plan/family_packaging_taxonomy_v1.md`

This document does not replace those references.
It extracts the specific guarded-scale contract shared by the first proven rollout wave.
