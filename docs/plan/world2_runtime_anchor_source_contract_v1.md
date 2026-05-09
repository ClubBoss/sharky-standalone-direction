# World 2 Runtime-Anchor Source Contract v1

Purpose:

- canonical source contract for deterministic runtime-anchor truth
- keep anchor truth source-driven and reusable across families
- prevent per-runner or per-node truth patching

## Valid Runtime-Anchor Truth

- truth resolves from a source-owned symbolic target in authored payload
- the symbolic target is carried in `expected.*`
- validator derives the same symbolic target from prompt / copy and checks for contradiction

## Canonical Source-Owned Symbolic Targets

| Symbolic target | Current family |
| --- | --- |
| `expected.boardSlot` | `board_tap` |
| `expected.role` | `seat_tap` |
| `expected.seatId` | `seat_tap` |

## Contract Requirements

- target must be symbolic, stable, and source-owned
- prompt wording must resolve to exactly one target
- copy checks may validate explicit target wording in `prompt`, `why_v1`, `feedback_*`, `recap_v1`
- validator must not depend on runtime host behavior

## Invalid Runtime-Anchor Truth

- UI coordinates
- hit-testing behavior
- display-order quirks
- runner-local anchor rules
- layout projection from symbolic ids to screen positions

## Onboarding Criteria

- family uses one explicit symbolic target seam in authored `expected.*`
- target can be derived without strategy semantics
- target can be checked without UI/runtime redesign
- checked vs skipped boundary can be reported deterministically

## Current Lane Status

- onboarded:
  - `board_tap`
  - `seat_tap`
- no additional current World 2 family fits this contract cleanly

## Remaining Family Classification Against This Contract

| Family | Fits contract | Reason |
| --- | --- | --- |
| `board_tap` | yes | uses `expected.boardSlot` |
| `seat_tap` | yes | uses `expected.role` / `expected.seatId` |
| `action_choice` | no | symbolic target is strategic action advice, not runtime-anchor truth |
| `board_texture_classifier_v1` remaining `dry` subset | no | heuristic board-pressure semantics, not symbolic anchor truth |
| `initiative_aggressor_choice_v1` remaining pressure subset | no | heuristic pressure continuation wording, not symbolic anchor truth |
| `hand_chain_v1` | no | mixed multi-step flow, not one lane-local symbolic target seam |
