# R60 Action-Contract Closeout Audit v1

## Milestone purpose/scope recap
- Milestone: R60 — Early-Path Coherence Recovery v2 (Action-Contract Alignment).
- Purpose: close one highest-EV early action-contract truth mismatch after R59 mode-separation closure.
- Strict scope: one deterministic mismatch family only in early runner action-decision steps.
- Out of scope: entry/binding redesign, mode-separation redesign, broad copy/content cleanup, personalization, schema/dependency changes.

## Verified action-contract inventory summary
- Confirmed family A (selected): raise-label mismatch between expected/outcome truth lines (`Expected: RAISE`) and visible action affordance semantics (`RAISE TO` / `RAISE MIN`) in early action steps.
  - Surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`.
  - Type: runtime label contract mismatch.
  - User impact: teaches inconsistent action truth in first wrong-answer feedback loop.
  - Boundedness: one label normalization family.
- Prompt/affordance mismatch beyond this family: not selected for R60.
- Action-bar ordering instability: no dominant new deterministic regression selected.
- Facing-bet vs unopened legality mismatch: existing guard coverage present; not selected as primary residual mismatch.

## Why the selected family won
- Highest user-visible EV among confirmed remaining action-contract mismatches.
- Deterministic and bounded to one runtime seam with one adjacent test surface.
- Largest safe slice that fixes both explicit `raise` and inferred raise expectation paths without broad UI/content drift.

## Selected contract and closure evidence
- Deterministic contract:
  - On early action-decision truth lines, if allowed-action semantics indicate raise-to affordance, expected/outcome label must be `RAISE TO`.
  - If only `raise_min` semantics exist, label must be `RAISE MIN`.
  - Preserve prior behavior outside this family.
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Updated `world1SpineOutcomeExpectedLineV1` and `_actionKindLabelV1` to resolve contextual raise label from normalized `allowedActions`.

## Proof recap (gates + targeted tests)
- Targeted proofs added:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `world1 spine expected line normalizes raise label to visible affordance deterministically`
  - `world1 spine incorrect action outcome aligns raise label with action affordance`
- Required gates (PASS):
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Content validators: not required (no content/tooling scope touched).

## Open risks
- Other non-raise wording coherence issues may still exist in later layers and should be handled only if they become the top bounded mismatch family.

## Explicit defer list
- Broad prompt/action copy harmonization across all worlds.
- Action-bar redesign or layout changes.
- Personalization/routing/scoring adjustments.
- Any schema or dependency changes.

## Anti-drift note
- R60 changed exactly one bounded runtime label-normalization family plus minimum proof contracts.
- No multi-family bundling and no broad early-world rewrite.

## Ambiguous P0 statement
- No ambiguous P0 remains inside the selected R60 family.

## Transition note for next focus only
- Next milestone selection should compare remaining early-path layers (teaching-truth vs result/progression vs any newly evidenced action-contract residuals) and lock one bounded winner.
