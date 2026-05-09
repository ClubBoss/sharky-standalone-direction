# R76 Surviving Action-Truth Contradiction Closeout Audit v1

## Milestone purpose/scope recap
- Purpose: close the surviving real-path contradiction still visible after R75 on authoritative early action feedback.
- Scope: one contradiction family on the authoritative World1 action outcome seam.
- Out of scope: action-bar redesign, result/progression redesign, broad feedback/content cleanup.

## Exact surviving contradiction family
- Surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Route/state family: authoritative campaign hand-loop incorrect outcome path (`range_expectation_mismatch`) when first hero action is overridden from UI action tap.
- Symptom family:
  - mismatch reason could still derive expected action from explicit metadata (`world1SpineExplicitExpectedActionKindV1`) in the first-decision EngineV2 mismatch branch,
  - allowing facing-bet explicit `check` to survive as expected-family source and create contradiction against live legality/why semantics.

## Same-family vs sibling-family relative to R75
- Verdict: **sibling-family**.
- R75 fixed normalized expected/why coherence on the outcome helper chain.
- R76 fixed a separate adjacent branch used by EngineV2 mismatch reason construction for first overridden hero decision.

## Root-cause classification
- **Runtime-only** (precedence divergence in authoritative mismatch branch).

## Repro-grade contract added first
- Added targeted failing contract:
  - `world1 spine mismatch expected action normalizes facing-bet explicit check in authoritative mismatch branch`
- Red state before fix:
  - expected `ActionKindV1.raise`, actual `ActionKindV1.check`.
- This contract is branch-specific and fails if only nearby families are fixed.

## Selected bounded truth contract
- For this exact surviving family only:
  - expected action used by first-decision mismatch branch must use legality-normalized resolver (`world1SpineExpectedActionKindV1`) rather than explicit-only expected metadata.
  - rendered expected-family and why-family must remain coherent under identical state.
  - non-selected families preserve prior behavior.

## What changed
- Added `world1SpineMismatchExpectedActionKindV1(...)` as the authoritative mismatch expected-action resolver hook.
- Updated first-hero mismatch branch in `_runEngineV2FullHandLoop(...)` to use that resolver.
- Added repro-grade targeted contract in:
  - `test/guards/world1_foundations_microtask_contract_test.dart`

## Strengthened closure proof
- Exact surviving contradiction prevented:
  - facing-bet explicit-check source in mismatch branch now normalizes to raise-family expected action.
- Repro-grade contract now passes.
- Adjacent critical behavior intact:
  - full world1 foundations guard suite remains green.
- Not a nearby-family-only fix:
  - fix targets the exact EngineV2 first-decision mismatch branch that was still explicit-metadata driven after R75.

## Proof recap (gates + targeted tests)
- `flutter analyze` PASS
- `./tools/fast_loop_world1_v1.sh` PASS
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart` PASS
- Repro-grade targeted test:
  - `flutter test ... --plain-name "world1 spine mismatch expected action normalizes facing-bet explicit check in authoritative mismatch branch"` PASS

## Open-risk list
- Additional mismatch wording families may still exist outside this selected contradiction class, but no new branch was changed in R76.

## Explicit defer list
- Broad content expected-action normalization.
- Broad feedback text harmonization.
- Result-screen/progression/action-bar redesign work.

## Anti-drift note
- One contradiction family only.
- One runtime seam family changed.
- One targeted contract family added.

## Transition note for next focus only
- Define `# Milestone R77` before any R77 execution work.
