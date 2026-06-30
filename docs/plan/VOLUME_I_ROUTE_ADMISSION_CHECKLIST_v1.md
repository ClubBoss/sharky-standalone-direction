# Volume I Route Admission Checklist v1

## 1. Purpose

This checklist is the pre-implementation gate for admitting Volume I W7-W12 to the learner route.

It is not route admission. It is not W7 certification. It is not Human QA. It does not open cards, navigation, stale resume, Practice CTA, mapper targets, telemetry, monetization, ML/AI/persona, solver/GTO claims, W1-W6 rework, or Modern Table work.

## 2. Admission Order

Use staged admission:

1. W7 only.
2. W8-W10 only after W7 route proof.
3. W11-W12 only after W8-W10 route proof.

Do not batch-open W7-W12.

## 3. W7 Required Identity

- Learner-facing title: `Visible Cards Change Ranges`.
- Position: next Volume I extension after W6.
- Framing: visible cards change what ranges can still exist.
- Forbidden framing: `Lite`, solver/GTO, mastery proof, public outcome proof, or Human QA pass.

## 4. W8-W12 Required Identity

- W8: remains locked until W7 route proof exists.
- W9: must stay differentiated from W4 by call price/pot attractiveness, not bet-size purpose.
- W10: must stay differentiated from W9 by bet reason, value versus trying to make stronger hands fold.
- W11: remains transfer-focused and locked until prior route proof exists.
- W12: `Volume I Review: Putting the Clues Together`, not a final mastery capstone.

## 5. Route-Facing Copy Prerequisites

- Identify the active English card title/subtitle owner.
- Identify the active localized card copy owner.
- Identify the active route-visible intro owner for W7.
- Identify route-selected-state/progression copy owner.
- Identify completion/outro copy owner.
- Confirm hidden internal task copy is not treated as route-facing proof.
- Confirm all learner-facing W7 copy avoids certification, launch, 9.0, mastery, Human QA, solver/GTO, and learning-effect claims.

## 6. Display-Title Prerequisites

- Replace W7 route-facing title only in the admitted implementation wave.
- Ensure W7 title is not duplicated inconsistently across English and localized owners.
- Keep W8-W12 route-facing titles locked until their stages.
- Add or update tests for card title/status/selectability together.
- Do not create a generic display-title abstraction unless the active code pattern already requires it.

## 7. Mapper Prerequisites

- Keep default W7-W12 no-target behavior before route admission.
- Before adding any W7 mapper target, prove the target is:
  - route-owned;
  - visible to the learner;
  - not bridge-limited;
  - not a hidden internal-only task;
  - covered by a route-lock transition test;
  - covered by copy-safety expectations.
- Do not add W8-W12 mapper targets during W7 admission.
- Preserve mapper purity: no telemetry dependency, UI dependency, or queue mutation.

## 8. Practice CTA Prerequisites

- Practice CTA remains absent unless mapper returns a safe launch request.
- W7 first route admission should default to no Practice CTA.
- If admitted later, Practice CTA copy must be bounded and non-claiming.
- Session Summary must not show Practice for route-locked W8-W12.
- No Practice CTA should imply repair proof, mastery proof, Human QA pass, or learning-effect improvement.

## 9. Stale-Resume Prerequisites

- Keep current stale W7-W10 blocked behavior until a route-opening wave changes it intentionally.
- W7 stale resume must be tested before being allowed.
- W7 stale resume may only return to an admitted W7 route-owned task.
- Stale W8-W12 must remain blocked during W7 admission.
- Stale W12 review resume must remain blocked until W12 route stage.

## 10. Route-Lock Transition Tests

Required future tests for W7 route admission:

- W7 card title/status/selectability reflects the admitted state.
- W8-W12 remain locked and non-selectable.
- Post-W6 progression selects W7 only when W7 admission is intentional.
- Stale W7 behavior follows the admitted policy.
- Stale W8-W12 remain blocked.
- W6 completion/progression copy no longer contradicts W7 availability.
- Mapper returns no W8-W12 target.
- Practice CTA remains absent unless explicitly admitted.

## 11. Copy-Safety Tests

Required future assertions:

- No W7 route-visible copy uses `Lite`.
- No W7-W12 route-visible copy claims solver/GTO.
- No route-visible copy claims Human QA execution or pass.
- No route-visible copy claims launch readiness, public route proof, 9.0, mastery, or learning-effect improvement.
- W9 copy is not reduced to W4 bet-size purpose.
- W10 copy is not reduced to W9 call-price reasoning.
- W12 copy is review-framed, not capstone-framed.

## 12. Human QA Prerequisites

Before Human QA can be requested:

- Route-visible W7 copy exists.
- W7 route behavior exists.
- W7 stale-resume policy exists and is test-covered.
- Mapper and Practice CTA policy are explicit.
- W8-W12 remain locked or are separately admitted.
- QA packet names exactly what humans inspect.
- QA packet avoids claiming pass before evidence exists.

## 13. Rollback Criteria

Rollback or block a route-opening implementation if:

- W8-W12 become selectable during W7 admission.
- Output folders or screenshots are staged.
- Product/runtime files outside the planned route seams change unexpectedly.
- Mapper launches a hidden or route-locked target.
- Practice CTA appears without a safe mapped target.
- Stale resume reaches an unadmitted world.
- Copy claims Human QA, launch, 9.0, mastery, solver/GTO, or learning-effect proof.
- W12 is framed as a final capstone before its review-world route stage.

## 14. Explicit No-Go Conditions

Do not proceed with route implementation if:

- main is dirty beyond allowed output folders;
- main diverges from origin/main;
- accepted pre-route artifacts are missing;
- route-facing owner cannot be identified;
- W7 title/copy cannot be aligned without broad runtime refactor;
- stale-resume behavior is ambiguous;
- mapper/Practice CTA behavior is ambiguous;
- expected tests require changing W1-W6 behavior unexpectedly;
- implementation would require screenshots/output edits;
- Human QA is requested before route-visible W7 exists.

## 15. Validation for Future Implementation Waves

Minimum validation for a W7 route implementation wave:

- `git status`
- `git diff --check`
- `git diff --cached --check`
- targeted route-lock tests
- targeted mapper tests
- targeted copy-safety tests
- `graphify hook-check`
- ASCII/trailing whitespace/CRLF/final-newline checks for new docs

Do not run broad Flutter analyze/test by default unless source changes or policy require it.

## 16. Current Status

- Checklist created.
- Route admission remains blocked.
- W7 remains locked until a future implementation wave.
- W8-W12 remain locked until their future staged admission.
- No score movement is authorized by this checklist.
