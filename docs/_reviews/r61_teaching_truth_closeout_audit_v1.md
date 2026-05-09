# R61 Teaching-Truth Closeout Audit v1

## Milestone purpose/scope recap
- Milestone: R61 — Early-Path Coherence Recovery v3 (Teaching-Truth Alignment).
- Purpose: close one highest-EV bounded teaching-truth mismatch in early action outcomes after R60.
- Scope held: one deterministic wording-alignment family only.
- Out of scope held: broad copy rewrite, result/progression redesign, onboarding redesign, personalization/scoring, schema/dependency changes.

## Verified teaching-truth inventory summary
- Confirmed family A (selected): `Correct:` raise wording in early action outcomes was not aligned to post-R60 affordance semantics.
  - Surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart` (`world1SpineOutcomeCorrectLineV1`).
  - Failing behavior: correct raise outcomes emitted generic `Correct: Raise increases the bet.` while early action contract now uses `RAISE TO` / `RAISE MIN` affordance semantics.
  - Type: runtime teaching-truth wording alignment mismatch.
  - User-visible impact: coherence gap between action affordance and post-action teaching feedback.
  - Boundedness: one line-family alignment seam plus minimal test contracts.
- Non-selected residuals: no-leak prompt family and action-contract expected-line family are already closed in R58/R60.

## Why the selected family won
- Highest-confidence remaining alignment mismatch in the active teaching-truth layer.
- Deterministic, single-file seam, minimal regression risk.
- Largest safe bounded slice without reopening broader copy systems.

## Deterministic contract
- For early correct outcomes where selected action is raise and `toCall > 0`:
  - if allowed actions imply raise-to semantics, `Correct:` line must use `RAISE TO` wording,
  - if allowed actions imply raise-min-only semantics, `Correct:` line must use `RAISE MIN` wording,
  - fallback behavior outside this family remains unchanged.

## Exact closure evidence
- Runtime implementation:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Added `world1SpinePreferredRaiseLabelV1(...)` canonical helper.
  - Updated `world1SpineOutcomeCorrectLineV1(...)` raise branch to align with `RAISE TO` / `RAISE MIN` semantics.
  - Reused same helper in expected/action label paths to keep deterministic label parity.
- Contract tests:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - Added:
    - `world1 spine preferred raise label resolves deterministically from allowed actions`
    - `world1 spine correct line aligns raise wording with available affordance`
    - `world1 spine correct outcome aligns raise wording with action affordance`

## Proof recap (gates + targeted tests)
- Targeted proofs (PASS):
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine preferred raise label resolves deterministically from allowed actions"`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine correct line aligns raise wording with available affordance"`
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine correct outcome aligns raise wording with action affordance"`
- Required gates (PASS):
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- Content validators: not required (no content/tooling surfaces touched).

## Open-risk list
- Other teaching-truth wording families may remain and should be isolated separately by evidence, not bundled.

## Explicit defer list
- Broad all-world wording harmonization.
- Result/progression copy redesign.
- Action-bar/layout redesign.
- Personalization/routing/scoring expansion.

## Anti-drift note
- R61 changed one bounded teaching-truth mismatch family only.
- No multi-family bundling and no broad UX/platform rewrite.

## Ambiguous P0 status
- No ambiguous P0 remains inside the selected R61 family.

## Transition note for next focus only
- Define `# Milestone R62` before R62 execution and re-compare remaining early-path layers by evidence.
