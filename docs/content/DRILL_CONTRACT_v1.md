# Drill Contract v1

Drill Contract v1 defines a minimal, deterministic drill schema for session production.

## Supported drill kinds (append-only)
- seat_tap
- action_choice
- board_tap
- hole_cards_tap

## Deterministic rules
- No RNG.
- No timestamps.
- No pixels or screen coordinates.
- Evaluation uses identifiers only.

## Required identifiers
- seat_tap: expected.seatId and/or expected.role
- action_choice: expected.actionId
- board_tap: expected.boardSlot
- hole_cards_tap: expected.cardSlot (p0 or p1), optional expected.cardId
  - expected.cardId format (v1): `[AKQJT98765432][shdc]`
  - examples: `As`, `Td`, `7h`

## Session drill layout
- content/worlds/worldN/v1/sessions/<id>/drills/index.md
- content/worlds/worldN/v1/sessions/<id>/drills/drills_manifest_v1.json (generated; not hand-edited)
- content/worlds/worldN/v1/sessions/<id>/drills/d.<drillId>.json

## v1 scope
- v1 enforces structure and deterministic identifiers only.
- v1 does not enforce content quality, UI binding, or difficulty calibration.
- `intent_v1` is optional semantic alignment metadata (ASCII only, `[a-z0-9_]+`).
- `intent_v1` is not user-facing and may be required by world-specific audits (for example World1).

## Scenario-Backed Deterministic Families v1
- Purpose:
  - define the smallest reusable repo-level contract for scenario-backed deterministic drill families
  - use World 2 as pilot evidence only, not as blind canonical policy
- Applies when a drill family depends on authored table/scene state rather than identifier-only prompts.
- Canonical source must stay in authored structured payload, not runner-local behavior or prose.

### Required authored truth
- A scenario-backed family must author the exact state it expects runtime and validators to consume.
- Required structured payload is family-specific, but when a family depends on it the authored source must include:
  - scene/street truth
  - explicit actor/seat truth
  - legal answer vocabulary for that family
  - explicit expected target
  - explicit `feedback_correct_v1`
  - explicit `feedback_incorrect_v1`
- If a family asks about a board-, card-, or initiative-dependent fact, that source state must be authored explicitly. Do not infer missing state from prompt wording.

### Family-specific grammar
- Scenario-backed families must declare a bounded legal-answer vocabulary per family.
- Validators may enforce only that family's authored vocabulary and target shape.
- Do not generalize one family's answer encoding into a repo-wide semantic rule.

### Chain step invariants
- If a family uses authored chains or ordered steps, the chain must remain deterministic:
  - stable authored step order
  - explicit step-local target per step
  - explicit step-local state whenever the step depends on table/scene truth
- Validators may enforce chain-shape consistency and step-local contract reuse.
- Validators must not flatten multi-step flow into one answer unit or infer omitted state from recap/prompt prose.

### Deferred-family handling
- If a family's expected answer is still coupled to heuristic wording, trainer preference, or local pedagogy rather than authored factual state, do not treat it as canonical truth.
- Such families must remain explicitly deferred, excluded, or validated only under a separate policy contract.

### Explicit non-generalizations from the World 2 pilot
- Do not generalize World 2 board-texture `call`/`raise` encoding into a global action rule.
- Do not generalize initiative "pressure" wording residue into canonical truth.
- Do not generalize local chip-delta or consequence phrasing into the content contract.
- Do not treat the current dual runtime shape (`MicroTaskStep` campaign beats vs `DrillSpecV1` session drills) as the final authoring ideal.

## intent_v1 (semantic alignment metadata)
- Purpose: keep drill sets aligned to SSOT world meaning and atoms.
- Global rule (v1): optional.
- World1 audit rule (v1): required and must be one of:
  - `hand_discipline_fold`
  - `dominated_aces`
  - `trash_hands`

## Example drill JSON (seat_tap)
{
  "id": "find_sb",
  "kind": "seat_tap",
  "prompt": "Tap the small blind seat.",
  "expected": {"role": "sb"},
  "error_class": "seat_role_confusion"
}

## Example drill JSON (action_choice)
{
  "id": "choose_fold",
  "kind": "action_choice",
  "prompt": "Choose fold.",
  "expected": {"actionId": "fold"},
  "error_class": "action_selection"
}

## Example drill JSON (board_tap)
{
  "id": "tap_flop_left",
  "kind": "board_tap",
  "prompt": "Tap the left flop card slot.",
  "expected": {"boardSlot": "flop_left"},
  "error_class": "board_slot_confusion"
}

## Example drill JSON (hole_cards_tap)
{
  "id": "tap_hole_left",
  "kind": "hole_cards_tap",
  "prompt": "Tap your left hole card.",
  "expected": {"cardSlot": "p0"},
  "error_class": "hole_card_slot_confusion"
}

## Example drill JSON (hole_cards_tap with cardId)
{
  "id": "tap_ace_spades",
  "kind": "hole_cards_tap",
  "prompt": "Tap the Ace of spades in your hole cards.",
  "expected": {"cardSlot": "p0", "cardId": "As"},
  "error_class": "hole_card_identity_confusion"
}

## Hole card evaluation rule (v1)
- `expected.cardSlot` is required and always checked.
- `expected.cardId` is optional.
- If `expected.cardId` is present, runtime event must provide matching `cardId` to pass.
- If runtime cannot provide deterministic card identity, use slot-only drills (`cardSlot` only).
