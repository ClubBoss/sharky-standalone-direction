# R78 World1 Scenario Truth Pilot Closeout v1

## Milestone purpose/scope recap
- Execute the first bounded World1 Scenario Truth migration.
- Scope locked to two pilot families only:
  - `action_choice / early decision`
  - `hand-loop mismatch / footer feedback`
- Out of scope:
  - broad World1 rewrite,
  - Worlds2-10 migration,
  - result/progression redesign,
  - archive/delete cleanup.

## Exact pilot families migrated
- `action_choice / early decision`
  - runtime path now consumes `world1ScenarioTruthPilotForStepV1(...)` for expected line, why line, correct/incorrect feedback baseline, and required focus label.
- `hand-loop mismatch / footer feedback`
  - runtime mismatch reason now consumes the same pilot truth path (`family=handLoopMismatchFooterFeedback`) for expected + why coherence.

## Exact truth-path changes
- New canonical pilot truth compiler:
  - `lib/campaign/world1_scenario_truth_pilot_v1.dart`
- Scenario truth fields now compiled and consumed for pilot families:
  - `visibleAffordancesV1`
  - `expectedActionFamilyV1`
  - `acceptableActionsV1`
  - `whyV1`
  - `feedbackCorrectV1`
  - `feedbackIncorrectV1`
  - `requiredFocusLabelV1`
- Runtime adoption:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - `world1SpineExpectedActionKindV1(...)` now delegates to pilot truth expected-action resolver.
  - outcome surface lines (`Expected`, `Why`, correct/incorrect baseline, debug `Focus`) now read pilot truth first.
  - mismatch reason path now reads pilot truth expected+why first.
- Migration-era protection retained:
  - legality normalization remains in the scenario truth resolver to clamp illegal explicit metadata deterministically.

## Validator/contract changes
- Validator strengthening:
  - `tools/validate_world_content_v1.dart` now runs pilot truth validation over World1 actionable spine/followup packs.
  - checks added for selected families:
    - illegal explicit expected action detection (`CHECK/BET` while facing bet, `CALL` with `toCall==0`),
    - expected/why coherence,
    - acceptable/legal coherence,
    - required focus label presence,
    - pilot family completeness consistency.
- Contract strengthening:
  - `test/guards/world1_scenario_truth_pilot_contract_test.dart`
  - validates deterministic scenario truth compile and zero validation errors for both pilot families across pilot packs.

## Repro-matrix effect summary
- `W1-RM-001`: now guarded by pilot truth legality + mismatch reason consumption + validator checks.
- `W1-RM-002`: now guarded by one expected/why source path + validator coherence checks.
- `W1-RM-004`: remains closed; now reinforced by pilot acceptable/legal coherence checks.
- Matrix updated in:
  - `docs/_reviews/r77_world1_repro_matrix_v1.md`

## Open-risk list
- Pilot truth currently compiles from existing step metadata rather than fully content-authored `why/feedback` fields.
- Non-pilot families (seat-quiz/result-handoff) remain on existing truth path and are intentionally not migrated in R78.

## Explicit defer list
- World1 seat-quiz field-level scenario migration.
- World1 result/progression scenario migration.
- Worlds2-10 scenario migration.
- Broad content schema expansion for scenario truth records.

## Anti-drift note
- R78 keeps migration bounded to two pilot families.
- Runtime safety normalization remains migration-era fallback, not a widening scope pass.
- New checks are deterministic and pilot-targeted only.

## Transition note (next focus only)
- Next bounded step should either:
  - expand scenario-truth field authoring for these same two families, or
  - migrate one additional World1 family only after R78 guard stability is confirmed.
