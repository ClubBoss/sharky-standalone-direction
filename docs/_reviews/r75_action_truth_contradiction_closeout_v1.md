# R75 Action-Truth Contradiction Closeout Audit v1

## Milestone purpose/scope recap
- Purpose: fix one P0 contradiction family on the authoritative early action path where outcome text could show illegal expected action semantics while facing a live bet.
- Scope: one bounded expected-action/why coherence family on the authoritative runner seam.
- Out of scope: action-bar redesign, broad content rewrite, finish/progression redesign, multi-family feedback cleanup.

## Exact contradiction family summary
- Family fixed:
  - explicit `expectedActionKind` in step data could force `Expected: CHECK` (or similarly illegal explicit family) even when runtime state indicates facing a live bet (`toCall > 0`).
- User-visible contradiction pattern:
  - table state shows a live bet,
  - outcome could render illegal expected family (`Expected: CHECK`),
  - why/because lines then describe call/fold/raise logic, creating semantic mismatch.

## Authoritative seam recap
- Surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Authoritative helper chain:
  - `world1SpineExpectedActionKindV1(...)`
  - `world1SpineOutcomeExpectedLineV1(...)`
  - `_isExpectedActionMismatchV1(...)`
  - `_buildOutcomeWhyLineV1(...)` + `_buildOutcomeBecauseLineV1(...)`

## Root-cause classification
- **Runtime (data-handling precedence) root cause**
- Specific cause:
  - explicit expected action precedence was accepted without legality normalization against live `toCall` state and allowed-action family.
  - expected label path used raw explicit token mapping, bypassing runtime legality normalization.

## Selected bounded truth contract
- For selected contradiction family only:
  - if facing live bet/raise (`toCall > 0`), rendered expected action cannot be `CHECK`/illegal no-call family.
  - rendered expected label and mismatch reasoning must use the same normalized expected-action resolver.
  - why-line remains in the same legal action family for the state (call/fold/raise semantics when facing bet).
  - non-selected families preserve prior behavior.

## What changed
- Runtime normalization:
  - `world1SpineExpectedActionKindV1(...)` now normalizes illegal explicit expected actions:
    - facing-bet (`toCall > 0`): explicit `check`/`bet` no longer accepted as expected; falls back to legal expected family from allowed actions.
    - no-to-call (`toCall == 0`): explicit `call` no longer accepted as expected; falls back to legal expected family.
- Expected line coherence:
  - `world1SpineOutcomeExpectedLineV1(...)` now renders from normalized expected-action resolver only (not raw explicit token branching).
- Mismatch coherence:
  - `_isExpectedActionMismatchV1(...)` now uses normalized expected action instead of explicit-only expected.
- Targeted proof additions:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - added deterministic checks that facing-bet explicit `check` cannot render `Expected: CHECK` and why-line remains in call/raise family.

## Reality-lock statement (authoritative-path proof)
- Same family as observed video:
  - the observed symptom specifically requires an illegal expected label under facing-bet state.
  - this can only happen on the authoritative outcome helper chain when explicit expected token bypasses legality.
- Why recurrence is now unlikely on real path:
  - the authoritative expected label and mismatch logic now consume the same legality-normalized expected-action resolver.
  - targeted contracts prove facing-bet explicit-check input can no longer emit `Expected: CHECK`.

## Proof recap (gates + targeted tests)
- `flutter analyze` PASS
- `./tools/fast_loop_world1_v1.sh` PASS
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart` PASS
- Targeted new proof within same suite:
  - `world1 spine facing-bet explicit check cannot render Expected: CHECK`
  - `world1 spine facing-bet why line stays in call-or-raise family when expected check source is illegal`

## Open-risk list
- Legacy content may still contain semantically weak explicit expected tokens, but this selected illegal facing-bet contradiction family is now normalized at runtime on the authoritative path.

## Explicit defer list
- Broad content expectedActionKind cleanup across all worlds.
- Broad outcome copy harmonization outside the selected contradiction family.
- Any result-screen/progression/action-bar redesign work.

## Anti-drift note
- One contradiction family only.
- One authoritative runtime seam chain updated.
- No multi-family runtime cleanup and no content sweep.

## Transition note for next focus only
- Define `# Milestone R76` before execution; do not start implementation without a bounded seam lock.
