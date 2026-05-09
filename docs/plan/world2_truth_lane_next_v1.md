# World 2 Truth Lane Next v1

Purpose:

- define the next bounded truth lane after the saturated exact-card / exact-answer lane
- keep the phase shift operational and deterministic
- identify one smallest safe pilot family
- defer shared seam details to `world2_runtime_anchor_source_contract_v1.md`

## Why The Current Lane Is Saturated

- exact-card families are already onboarded where authored payload is crisp:
  - `showdown_winner_choice_v1`
  - `outs_count_choice_v1`
- exact-answer families are already onboarded where structured state resolves a single choice:
  - `position_thinking_choice_v1`
- bounded contract residues already tracked are blocked on heuristic wording, not missing validator structure:
  - `board_texture_classifier_v1` remaining `dry` subset
  - `initiative_aggressor_choice_v1` remaining pressure subset

## Remaining Families By Truth Type

| Family group | Truth type | Current status |
| --- | --- | --- |
| `seat_tap`, `board_tap` | deterministic runtime-anchor truth | clean next-lane candidates |
| `action_choice` | strategy / heuristic truth | out of scope for truth validation |
| remaining `board_texture_classifier_v1` / `initiative_aggressor_choice_v1` residues | strategy / heuristic truth | remain excluded |
| `hand_chain_v1` | mixed multi-step truth | out of scope until lane-local step truth is isolated |

## Proposed Next Lane

- Lane name: deterministic runtime-anchor truth
- Truth basis:
  - authored prompt and feedback must resolve to one stable source-owned symbolic anchor
  - anchor ids may be `boardSlot`, `role`, or `seatId`
  - the seam lives in authored `expected.*` targets, not in runner-local projection
  - validator checks symbolic target truth only, not live UI hitboxes or rendering

## Valid Truth In This Lane

- exact `boardSlot` target from prompt/copy
- exact `role` / `seatId` target from prompt/copy
- explicit target-copy contradictions in prompt / why / feedback

## Explicitly Out Of Scope

- UI layout geometry
- tap regions, hit testing, animation, or runtime event plumbing
- strategy advice or action recommendation semantics
- mixed chain flow across multiple steps

## Pilot Selection Criteria

- smallest family boundary
- one stable symbolic target field
- prompt wording already explicit enough to derive the target deterministically
- no dependency on runtime host behavior

## Selected Pilot

- `board_tap`
- Why:
  - smaller than `seat_tap`
  - every current drill resolves to one stable `expected.boardSlot`
  - current prompt/copy patterns are explicit enough for a bounded symbolic contract

## Source Seam Confirmation

- Source-owned seam for this lane:
  - `board_tap` uses `expected.boardSlot`
  - `seat_tap` uses `expected.role` or `expected.seatId`
- Invalid seam shapes for this lane:
  - UI coordinates
  - display-order quirks
  - runner-specific seat projection
